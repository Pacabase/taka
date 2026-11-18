import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:core/src/failure_reason.dart';
import 'package:core/src/tunnel.dart';
import 'package:core/src/tunnels_snapshot.dart';
import 'package:fimber/fimber.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:system_ssh/system_ssh.dart';

part 'tunnel_session.freezed.dart';

final _log = FimberLog('Tunnels');
final _sshLog = FimberLog('ssh');

typedef _Opened = ({Future<void> done, Future<void> Function() close});

/// Hands focus back to the app that had it before Taka came forward.
typedef HandBack = Future<void> Function();

@freezed
sealed class const Phase._() with _$Phase {
  const factory opening() = Opening;

  /// Opening again after a drop, still showing why it dropped.
  const factory redialing(Reconnecting reconnecting) = Redialing;

  const factory up({
    @Default('') String warning,
    @Default(false) bool isVerifying,
  }) = Up;

  const factory waiting(
    Reconnecting reconnecting, {
    @Default(false) bool forUnlock,
  }) = Waiting;

  const factory awaitingTrust(SshHostKey key) = AwaitingTrust;

  const factory trusting() = Trusting;

  const factory gaveUp(Failed failed) = GaveUp;

  const factory ended(TunnelStatus last) = Ended;

  TunnelStatus get status => switch (this) {
    Opening() => const Connecting(),
    Redialing(:final reconnecting) => reconnecting,
    Up(:final warning) => Connected(warning: warning),
    Waiting(:final reconnecting) => reconnecting,
    AwaitingTrust(:final key) => UnknownHostKey(
      host: key.host,
      type: key.type,
      fingerprint: key.fingerprint,
    ),
    Trusting() => const Connecting(),
    GaveUp(:final failed) => failed,
    Ended(:final last) => last,
  };
}

/// [isWatched] isn't [hasConnected]: a trust after a reconnect comes forward.
@freezed
sealed class const SessionState._() with _$SessionState {
  const factory({
    required Phase phase,
    @Default(0) int attempts,
    @Default(false) bool hasConnected,
    @Default(true) bool isWatched,
  }) = _SessionState;

  TunnelStatus get status => phase.status;
}

@freezed
sealed class const SessionEvent._() with _$SessionEvent {
  const factory connect(Completer<void> settled) = Connect;

  const factory dropped(Object? error) = Dropped;

  const factory retryDue() = RetryDue;

  const factory stable() = Stable;

  const factory checked() = Checked;

  const factory warned(String reason) = Warned;

  const factory warningExpired() = WarningExpired;

  const factory refused(SshForwardFailed log) = Refused;

  const factory trust(Completer<bool> trusted) = Trust;

  const factory stop(Completer<void> closed) = Stop;
}

class TunnelSession({
  required final Tunnel tunnel,
  required final SshClient client,
  required final Future<HandBack> Function()? comeForward,
  required final Future<bool> Function()? isLocked,
  required final Future<void> Function(String address, int localPort)?
  checkDestination,
  required final Duration warningLifetime,
  required final Duration checkWindow,
  required final List<Duration> retryDelays,
  required final Duration lockedRecheck,
  required final Duration stableAfter,
  final bool isRestored = false,
}) extends Bloc<SessionEvent, SessionState> {
  final _abort = Completer<void>();
  final _timers = <Type, Timer>{};
  final List<Future<HandBack?>> _cameForward = [];
  // Handles the phases stand for, which aren't values a state can hold.
  Future<void>? _attempt;
  _Opened? _tunnel;
  Future<void>? _closed;

  @override
  String toString() => 'TunnelSession';

  TunnelStatus get status => state.status;

  bool get isStopped => state.phase is Ended;

  Future<void> connect() {
    final settled = Completer<void>();
    add(SessionEvent.connect(settled));
    return settled.future;
  }

  Future<void> stop() {
    if (_closed case final closed?) return closed;

    final closed = Completer<void>();
    add(SessionEvent.stop(closed));
    return closed.future;
  }

  /// Whether the key it stopped at is in `known_hosts` now, for [connect].
  Future<bool> trust() {
    final trusted = Completer<bool>();
    add(SessionEvent.trust(trusted));
    return trusted.future;
  }

  this : super(const SessionState(phase: Opening())) {
    on<Connect>((event, emit) async {
      // Only a new session, a redial or a trusted key opens ssh.
      if (state.phase
          case Up() || Redialing() || AwaitingTrust() || GaveUp() || Ended()) {
        return event.settled.complete();
      }

      emit(
        state.copyWith(
          phase: switch (state.phase) {
            Waiting(:final reconnecting) => Redialing(reconnecting),
            _ => const Opening(),
          },
        ),
      );
      _attempt = event.settled.future;
      final _Opened opened;
      try {
        opened = await _open();
      } on Object catch (exception) {
        _drop(exception, emit);
        return event.settled.complete();
      }
      if (isStopped) return event.settled.complete(_close(opened));

      // Not on reconnects or at login: each check hits the service for real.
      final checks =
          tunnel.kind == TunnelKind.local &&
          !isRestored &&
          !state.hasConnected &&
          checkDestination != null;
      _tunnel = opened;
      emit(
        state.copyWith(
          phase: Up(isVerifying: checks),
          hasConnected: true,
          isWatched: false,
        ),
      );
      _after(stableAfter, const SessionEvent.stable());
      _log.i('Connected ${tunnel.title}');
      unawaited(
        opened.done.then(
          (_) => add(const SessionEvent.dropped(null)),
          onError: (Object exception) => add(SessionEvent.dropped(exception)),
        ),
      );
      if (checks) unawaited(_checkDestination());
      event.settled.complete();
    });

    on<Dropped>((event, emit) {
      if (state.phase is Up) _drop(event.error, emit);
    });

    // A login prompt, such as a browser sign-in, needs someone at the screen.
    on<RetryDue>((event, emit) async {
      final locked = await _isLocked();
      if (state.phase case final Waiting waiting) {
        if (!locked) return add(SessionEvent.connect(Completer()));

        if (!waiting.forUnlock) {
          _log.i('${tunnel.title}: waiting for the screen to unlock');
        }
        emit(state.copyWith(phase: waiting.copyWith(forUnlock: true)));
        _after(lockedRecheck, const SessionEvent.retryDue());
      }
    });

    on<Stable>((event, emit) {
      if (state.phase is Up) emit(state.copyWith(attempts: 0));
    });

    on<Checked>((event, emit) {
      if (state.phase case final Up up) {
        emit(state.copyWith(phase: up.copyWith(isVerifying: false)));
      }
    });

    on<Warned>((event, emit) {
      if (state.phase case final Up up) {
        _after(warningLifetime, const SessionEvent.warningExpired());
        if (up.warning == event.reason) return;

        _log.w('${tunnel.title}: ${forwardWarning(tunnel)} (${event.reason})');
        emit(state.copyWith(phase: up.copyWith(warning: event.reason)));
      }
    });

    on<WarningExpired>((event, emit) {
      if (state.phase case final Up up) {
        emit(state.copyWith(phase: up.copyWith(warning: '')));
      }
    });

    on<Refused>((event, emit) {
      if ((state.phase, _tunnel) case (Up(), final tunnel?)) {
        final SshForwardFailed(:line) = event.log;
        _log.w('${this.tunnel.title} failed: $line');
        _end(
          Failed(
            line,
            failure: event.log is SshForwardProhibited
                ? TunnelFailure.forwardProhibited
                : TunnelFailure.forwardRefused,
          ),
          _close(tunnel),
          emit,
        );
      }
    });

    on<Trust>((event, emit) async {
      if (state.phase case AwaitingTrust(:final key)) {
        _log.i('${tunnel.title}: trusting ${key.type} ${key.fingerprint}');
        // The user is at the screen to trust it.
        emit(
          state.copyWith(phase: const Trusting(), isWatched: true, attempts: 0),
        );
        try {
          await client.trustHostKey(
            tunnel.target,
            key,
            abortTrigger: _abort.future,
          );
        } on Object catch (exception) {
          _drop(exception, emit);
          return event.trusted.complete(false);
        }
        return event.trusted.complete(!isStopped);
      }
      event.trusted.complete(false);
    });

    on<Stop>((event, emit) {
      if (_closed case final closed?) return event.closed.complete(closed);

      final closed = switch ((state.phase, _tunnel, _attempt)) {
        (Up(), final tunnel?, _) => _close(tunnel),
        (Opening() || Redialing(), _, final attempt?) => attempt,
        _ => Future<void>.value(),
      };
      _end(state.status, closed, emit);
      event.closed.complete(closed);
    });
  }

  @override
  void onChange(Change<SessionState> change) {
    super.onChange(change);
    final Change(:currentState, :nextState) = change;
    if (currentState.phase.runtimeType == nextState.phase.runtimeType) return;

    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    switch (currentState.phase) {
      case Opening() || Redialing():
        _attempt = null;
        _handBack();
      case Up():
        _tunnel = null;
      case _:
    }
  }

  // Caught once here, so every later stop returns without the error.
  Future<void> _close(_Opened tunnel) => tunnel.close().catchError(
    (Object exception) =>
        _log.w('${this.tunnel.title}: could not close ssh ($exception)'),
  );

  void _after(Duration delay, SessionEvent event) {
    _timers.remove(event.runtimeType)?.cancel();
    _timers[event.runtimeType] = Timer(delay, () {
      _timers.remove(event.runtimeType);
      add(event);
    });
  }

  void _end(
    TunnelStatus last,
    Future<void> closed,
    Emitter<SessionState> emit,
  ) {
    _closed = closed;
    emit(state.copyWith(phase: Ended(last)));
    if (!_abort.isCompleted) _abort.complete();
  }

  // A first try the user is watching stays failed; others retry.
  void _drop(Object? exception, Emitter<SessionState> emit) {
    if (isStopped) return;

    if (exception case SshUnknownHostKeyException(:final hostKey)) {
      _log.w('${tunnel.title}: waiting for the user to check $hostKey');
      return emit(state.copyWith(phase: AwaitingTrust(hostKey)));
    }
    final message = exception == null ? 'Disconnected' : _messageOf(exception);
    final failure = _failureOf(exception);
    final isPermanent = switch (exception) {
      SshPermanentException() => true,
      SshException() || null => false,
      _ => true,
    };
    if (!(isRestored || state.hasConnected) || isPermanent) {
      return _fail(message, failure, emit);
    }
    if (state.attempts == retryDelays.length) {
      _log.w('${tunnel.title}: giving up after ${state.attempts} tries');
      return _fail(message, failure, emit);
    }

    final delay = retryDelays[state.attempts];
    _log.w(
      '${tunnel.title} dropped: $message; reconnecting in ${delay.inSeconds}s',
    );
    emit(
      state.copyWith(
        phase: Waiting(Reconnecting(message, failure: failure)),
        attempts: state.attempts + 1,
        isWatched: false,
      ),
    );
    _after(delay, const SessionEvent.retryDue());
  }

  void _fail(
    String message,
    TunnelFailure failure,
    Emitter<SessionState> emit,
  ) {
    _log.w('${tunnel.title} failed: $message');
    emit(state.copyWith(phase: GaveUp(Failed(message, failure: failure))));
  }

  Future<void> _checkDestination() async {
    try {
      await checkDestination!(tunnel.reachableAt, tunnel.localPort);
    } on Object catch (exception) {
      _log.w('${tunnel.title}: could not check where it leads ($exception)');
    }
    // ssh logs the refusal only after the check's connection has closed.
    _after(checkWindow, const SessionEvent.checked());
  }

  // 1Password prompts only for the app in front; a retry may find nobody there.
  void _comeForward() {
    final come = comeForward;
    if (come == null || !state.isWatched) return;

    _cameForward.add(
      Future.sync(come).then<HandBack?>(
        (handBack) => handBack,
        onError: (Object exception) {
          _log.w('${tunnel.title}: could not come to the front ($exception)');
          return null;
        },
      ),
    );
  }

  void _handBack() {
    for (final cameForward in _cameForward) {
      unawaited(
        cameForward
            .then((handBack) => handBack?.call())
            .catchError(
              (Object exception) => _log.w(
                '${tunnel.title}: could not hand focus back ($exception)',
              ),
            ),
      );
    }
    _cameForward.clear();
  }

  Future<bool> _isLocked() async {
    try {
      return await isLocked?.call() ?? false;
    } on Object catch (exception) {
      _log.w('Could not tell whether the screen is locked ($exception)');
      return false;
    }
  }

  Future<_Opened> _open() async {
    final abortTrigger = _abort.future;
    // ssh's lines, named since tunnels connect at once.
    void onLog(SshLog log) {
      _sshLog.d('${tunnel.title}: ${log.line}');
      switch ((log, state.phase)) {
        // A ProxyCommand such as a browser sign-in may take focus between them.
        case (SshLoginStarted(), Opening() || Redialing()):
          _comeForward();
        case (final SshForwardFailed failed, Up(isVerifying: true)):
          add(SessionEvent.refused(failed));
        case (SshForwardFailed(:final reason), Up()):
          add(SessionEvent.warned(reason));
        case _:
      }
    }

    final bindAddress = tunnel.listenAddress;
    final SshTunnel opened;
    switch (tunnel) {
      case Tunnel(kind: TunnelKind.socks):
        opened = await client.openSocksProxy(
          tunnel.target,
          bindAddress: bindAddress,
          localPort: tunnel.localPort,
          onLog: onLog,
          abortTrigger: abortTrigger,
        );
      case Tunnel(kind: TunnelKind.remote, :final remotePort?):
        final remote = await client.openRemoteTunnel(
          tunnel.target,
          localHost: tunnel.localHost ?? 'localhost',
          localPort: tunnel.localPort,
          remotePort: remotePort,
          onLog: onLog,
          abortTrigger: abortTrigger,
        );
        return (done: remote.done, close: remote.close);
      case Tunnel(kind: TunnelKind.remote):
        throw ArgumentError('A remote tunnel needs a port on the SSH host');
      case Tunnel(:final remoteSocket?):
        opened = await client.openSocketTunnel(
          tunnel.target,
          remoteSocket: remoteSocket,
          bindAddress: bindAddress,
          localPort: tunnel.localPort,
          onLog: onLog,
          abortTrigger: abortTrigger,
        );
      case Tunnel(:final remoteHost?, :final remotePort?):
        opened = await client.openTunnel(
          tunnel.target,
          remoteHost: remoteHost,
          remotePort: remotePort,
          bindAddress: bindAddress,
          localPort: tunnel.localPort,
          onLog: onLog,
          abortTrigger: abortTrigger,
        );
      case _:
        throw ArgumentError('A local tunnel needs a remote host and port');
    }
    return (done: opened.done, close: opened.close);
  }

  String _messageOf(Object exception) => switch (exception) {
    SshException(:final message) => message,
    ArgumentError(:final message) => '$message',
    _ => '$exception',
  };

  TunnelFailure _failureOf(Object? exception) => switch (exception) {
    null || SshDroppedException() => TunnelFailure.dropped,
    SshNotFoundException() => TunnelFailure.sshNotFound,
    SshConfigException() => TunnelFailure.config,
    SshPortInUseException() => TunnelFailure.portInUse,
    SshDuplicateForwardException() => TunnelFailure.duplicateForward,
    SshAddressUnavailableException() => TunnelFailure.addressUnavailable,
    SshHostNotFoundException() => TunnelFailure.hostNotFound,
    SshUnreachableException() => TunnelFailure.unreachable,
    SshLoginRefusedException() => TunnelFailure.loginRefused,
    SshHostKeyRefusedException() ||
    SshHostKeyChangedException() ||
    SshUnknownHostKeyException() => TunnelFailure.hostKey,
    SshRemotePortRefusedException() => TunnelFailure.remotePortRefused,
    _ => TunnelFailure.other,
  };
}
