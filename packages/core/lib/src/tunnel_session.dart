import 'dart:async';

import 'package:core/src/failure_reason.dart';
import 'package:core/src/tunnel.dart';
import 'package:core/src/tunnels_snapshot.dart';
import 'package:fimber/fimber.dart';
import 'package:system_ssh/system_ssh.dart';

final _log = FimberLog('Tunnels');
final _sshLog = FimberLog('ssh');

typedef _Opened = ({Future<void> done, Future<void> Function() close});

/// Hands focus back to the app that had it before Taka came forward.
typedef HandBack = Future<void> Function();

class TunnelSession({
  required final Tunnel tunnel,
  required final SshClient client,
  required final void Function() onChange,
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
}) {
  final _abort = Completer<void>();
  late _Phase _phase = _Opening(tunnel.title);
  int _attempts = 0;
  bool _hasConnected = false;
  // No connect or retry yet since the start or a trusted key: someone is there.
  bool _isWatched = true;

  TunnelStatus get status => _phase.status;

  bool get isStopped => _phase is _Stopped;

  void _enter(_Phase next, {bool quietly = false}) {
    if (_phase is _Stopped) return next.dispose();

    _phase.dispose();
    _phase = next;
    if (!quietly) onChange();
  }

  Future<void> connect() async {
    final retrying = switch (_phase) {
      _Waiting(:final status) => status,
      _ => null,
    };
    _enter(_Opening(tunnel.title, retrying: retrying), quietly: true);
    final _Opened opened;
    try {
      opened = await _open();
    } on Object catch (exception) {
      return _drop(exception);
    }
    if (isStopped) return opened.close();

    // Not on reconnects or at login: each check hits the service for real.
    final checks =
        tunnel.kind == TunnelKind.local &&
        !isRestored &&
        !_hasConnected &&
        checkDestination != null;
    _hasConnected = true;
    _isWatched = false;
    final up = _Up(
      opened,
      Timer(stableAfter, () => _attempts = 0),
      isVerifying: checks,
    );
    _enter(up);
    _log.i('Connected ${tunnel.title}');
    unawaited(opened.done.then((_) => _drop(null), onError: _drop));
    if (checks) unawaited(_checkDestination(up));
  }

  Future<void> _checkDestination(_Up up) async {
    try {
      await checkDestination!(tunnel.reachableAt, tunnel.localPort);
    } on Object catch (exception) {
      _log.w('${tunnel.title}: could not check where it leads ($exception)');
    }
    // ssh logs the refusal only after the check's connection has closed.
    await Future<void>.delayed(checkWindow);
    up.isVerifying = false;
  }

  Future<void> stop() => _stop(_phase.status);

  Future<void> _stop(TunnelStatus status) {
    if (_phase case _Stopped(:final closed)) return closed;

    final closed = switch (_phase) {
      _Up(:final opened) => opened.close(),
      _ => Future<void>.value(),
    };
    _enter(_Stopped(status, closed), quietly: true);
    _abort.complete();
    return closed;
  }

  /// Whether the key it stopped at is in `known_hosts` now, for [connect].
  Future<bool> trust() async {
    if (_phase case _AwaitingTrust(:final key)) {
      _log.i('${tunnel.title}: trusting ${key.type} ${key.fingerprint}');
      _isWatched = true;
      _attempts = 0;
      _enter(_Trusting());
      try {
        await client.trustHostKey(
          tunnel.target,
          key,
          abortTrigger: _abort.future,
        );
      } on Object catch (exception) {
        _drop(exception);
        return false;
      }
      return !isStopped;
    }
    return false;
  }

  // 1Password prompts only for the app in front; a retry may find nobody there.
  void _comeForward(_Opening opening) {
    final come = comeForward;
    if (come == null || !_isWatched) return;

    opening.cameForward.add(
      Future.sync(come).then<HandBack?>(
        (handBack) => handBack,
        onError: (Object exception) {
          _log.w('${tunnel.title}: could not come to the front ($exception)');
          return null;
        },
      ),
    );
  }

  Future<_Opened> _open() async {
    final abortTrigger = _abort.future;
    // ssh's lines, named since tunnels connect at once.
    void onLog(SshLog log) {
      _sshLog.d('${tunnel.title}: ${log.line}');
      switch ((log, _phase)) {
        // A ProxyCommand such as a browser sign-in may take focus between them.
        case (SshLoginStarted(), final _Opening opening):
          _comeForward(opening);
        case (final SshForwardFailed failed, final _Up up) when up.isVerifying:
          _refuse(failed);
        case (SshForwardFailed(:final reason), final _Up up):
          _warn(up, reason);
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

  // A first try the user is watching stays failed; others retry.
  void _drop(Object? exception) {
    if (isStopped) return;

    if (exception case SshUnknownHostKeyException(:final hostKey)) {
      _log.w('${tunnel.title}: waiting for the user to check $hostKey');
      return _enter(_AwaitingTrust(hostKey));
    }
    final message = exception == null ? 'Disconnected' : _messageOf(exception);
    final failure = _failureOf(exception);
    final isPermanent = switch (exception) {
      SshPermanentException() => true,
      SshException() || null => false,
      _ => true,
    };
    if (!(isRestored || _hasConnected) || isPermanent) {
      return _fail(message, failure);
    }
    if (_attempts == retryDelays.length) {
      _log.w('${tunnel.title}: giving up after $_attempts tries');
      return _fail(message, failure);
    }

    final delay = retryDelays[_attempts++];
    _isWatched = false;
    _log.w(
      '${tunnel.title} dropped: $message; reconnecting in ${delay.inSeconds}s',
    );
    _enter(
      _Waiting(
        Reconnecting(message, failure: failure),
        Timer(delay, () => unawaited(_reconnect())),
      ),
    );
  }

  // A login prompt, such as a browser sign-in, needs someone at the screen.
  Future<void> _reconnect() async {
    final locked = await _isLocked();
    if (_phase case final _Waiting waiting) {
      if (!locked) return connect();

      if (!waiting.forUnlock) {
        _log.i('${tunnel.title}: waiting for the screen to unlock');
      }
      _enter(
        _Waiting(
          waiting.status,
          Timer(lockedRecheck, () => unawaited(_reconnect())),
          forUnlock: true,
        ),
        quietly: true,
      );
    }
  }

  Future<bool> _isLocked() async {
    try {
      return await isLocked?.call() ?? false;
    } on Object catch (exception) {
      _log.w('Could not tell whether the screen is locked ($exception)');
      return false;
    }
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

  void _fail(String message, TunnelFailure failure) {
    _log.w('${tunnel.title} failed: $message');
    _enter(_Failed(Failed(message, failure: failure)));
  }

  void _refuse(SshForwardFailed failed) {
    _log.w('${tunnel.title} failed: ${failed.line}');
    unawaited(
      _stop(
        Failed(
          failed.line,
          failure: failed is SshForwardProhibited
              ? TunnelFailure.forwardProhibited
              : TunnelFailure.forwardRefused,
        ),
      ).catchError(
        (Object exception) =>
            _log.w('${tunnel.title}: could not close ssh ($exception)'),
      ),
    );
    onChange();
  }

  void _warn(_Up up, String reason) {
    up.clearWarning?.cancel();
    up.clearWarning = Timer(warningLifetime, () {
      up.warning = '';
      onChange();
    });
    if (up.warning == reason) return;

    _log.w('${tunnel.title}: ${forwardWarning(tunnel)} ($reason)');
    up.warning = reason;
    onChange();
  }
}

sealed class _Phase {
  TunnelStatus get status;

  void dispose() {}
}

class _Opening(final String title, {final Reconnecting? retrying})
    extends _Phase {
  final List<Future<HandBack?>> cameForward = [];

  @override
  TunnelStatus get status => retrying ?? const Connecting();

  @override
  void dispose() {
    for (final handBack in cameForward) {
      unawaited(
        handBack
            .then((handBack) => handBack?.call())
            .catchError(
              (Object exception) =>
                  _log.w('$title: could not hand focus back ($exception)'),
            ),
      );
    }
  }
}

class _Up(
  final _Opened opened,
  final Timer stable, {
  required var bool isVerifying,
}) extends _Phase {
  String warning = '';
  Timer? clearWarning;

  @override
  TunnelStatus get status => Connected(warning: warning);

  @override
  void dispose() {
    stable.cancel();
    clearWarning?.cancel();
  }
}

class _Waiting(
  @override final Reconnecting status,
  final Timer retry, {
  final bool forUnlock = false,
}) extends _Phase {
  @override
  void dispose() => retry.cancel();
}

class _AwaitingTrust(final SshHostKey key) extends _Phase {
  @override
  TunnelStatus get status => UnknownHostKey(
    host: key.host,
    type: key.type,
    fingerprint: key.fingerprint,
  );
}

class _Trusting() extends _Phase {
  @override
  TunnelStatus get status => const Connecting();
}

class _Failed(@override final Failed status) extends _Phase;

class _Stopped(@override final TunnelStatus status, final Future<void> closed)
    extends _Phase;
