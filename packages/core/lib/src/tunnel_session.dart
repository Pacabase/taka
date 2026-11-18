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
  TunnelStatus _status = const Connecting();
  _Opened? _opened;
  Timer? _clearWarning;
  Timer? _retry;
  Timer? _stable;
  late bool _retries = isRestored;
  int _attempts = 0;
  bool _waitsForUnlock = false;
  bool _hasChecked = false;
  bool _isChecking = false;
  bool _wasConnected = false;
  bool _isOpening = false;
  final List<Future<HandBack?>> _cameForward = [];

  TunnelStatus get status => _status;

  bool get isStopped => _abort.isCompleted;

  Future<void> connect() async {
    final _Opened opened;
    _isOpening = true;
    try {
      opened = _opened = await _open();
    } on Object catch (exception) {
      return _drop(exception);
    } finally {
      _isOpening = false;
      _handBack();
    }
    if (isStopped) return opened.close();

    _status = const Connected();
    _retries = true;
    _wasConnected = true;
    _stable = Timer(stableAfter, () => _attempts = 0);
    onChange();
    _log.i('Connected ${tunnel.title}');
    unawaited(opened.done.then((_) => _drop(null), onError: _drop));
    // Not on reconnects or at login: each check hits the service for real.
    if (tunnel.kind == TunnelKind.local && !isRestored && !_hasChecked) {
      _hasChecked = true;
      unawaited(_checkDestination());
    }
  }

  Future<void> _checkDestination() async {
    final check = checkDestination;
    if (check == null) return;

    _isChecking = true;
    try {
      await check(tunnel.reachableAt, tunnel.localPort);
    } on Object catch (exception) {
      _log.w('${tunnel.title}: could not check where it leads ($exception)');
    }
    // ssh logs the refusal only after the check's connection has closed.
    await Future<void>.delayed(checkWindow);
    _isChecking = false;
  }

  Future<void> stop() async {
    _clearWarning?.cancel();
    _retry?.cancel();
    _stable?.cancel();
    if (!isStopped) _abort.complete();
    await _opened?.close();
  }

  /// Whether the key it stopped at is in `known_hosts` now, for [connect].
  Future<bool> trust() async {
    final asking = _status;
    if (asking is! UnknownHostKey || isStopped) return false;

    _log.i('${tunnel.title}: trusting ${asking.type} ${asking.fingerprint}');
    _status = const Connecting();
    // The user is at the screen to trust it.
    _wasConnected = false;
    _attempts = 0;
    onChange();
    try {
      await client.trustHostKey(
        tunnel.target,
        SshHostKey(
          host: asking.host,
          type: asking.type,
          fingerprint: asking.fingerprint,
        ),
        abortTrigger: _abort.future,
      );
    } on Object catch (exception) {
      _drop(exception);
      return false;
    }
    return !isStopped;
  }

  // 1Password prompts only for the app in front; a retry may find nobody there.
  void _comeForward() {
    final come = comeForward;
    // A line after the attempt would hold the front with nothing to hand back.
    if (come == null || _wasConnected || _attempts > 0 || !_isOpening) return;

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

  Future<_Opened> _open() async {
    final abortTrigger = _abort.future;
    // ssh's lines, named since tunnels connect at once.
    void onLog(SshLog log) {
      _sshLog.d('${tunnel.title}: ${log.line}');
      // A ProxyCommand such as a browser sign-in may take focus between them.
      if (log is SshLoginStarted) _comeForward();
      if (log case final SshForwardFailed failed) {
        _isChecking ? _refuse(failed) : _warn(failed.reason);
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

    // A reconnect isn't checked, so a refusal on it comes from a client.
    _isChecking = false;

    _stable?.cancel();
    if (exception case SshUnknownHostKeyException(:final hostKey)) {
      _log.w('${tunnel.title}: waiting for the user to check $hostKey');
      _status = UnknownHostKey(
        host: hostKey.host,
        type: hostKey.type,
        fingerprint: hostKey.fingerprint,
      );
      return onChange();
    }
    final message = exception == null ? 'Disconnected' : _messageOf(exception);
    final failure = _failureOf(exception);
    final isPermanent = switch (exception) {
      SshPermanentException() => true,
      SshException() || null => false,
      _ => true,
    };
    if (!_retries || isPermanent) return _fail(message, failure);
    if (_attempts == retryDelays.length) {
      _log.w('${tunnel.title}: giving up after $_attempts tries');
      return _fail(message, failure);
    }

    final delay = retryDelays[_attempts++];
    _log.w(
      '${tunnel.title} dropped: $message; reconnecting in ${delay.inSeconds}s',
    );
    _status = Reconnecting(message, failure: failure);
    _retry = Timer(delay, () => unawaited(_reconnect()));
    onChange();
  }

  // A login prompt, such as a browser sign-in, needs someone at the screen.
  Future<void> _reconnect() async {
    final locked = await _isLocked();
    if (isStopped) return;
    if (locked) {
      if (!_waitsForUnlock) {
        _log.i('${tunnel.title}: waiting for the screen to unlock');
      }
      _waitsForUnlock = true;
      _retry = Timer(lockedRecheck, () => unawaited(_reconnect()));
      return;
    }

    _waitsForUnlock = false;
    await connect();
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
    _status = Failed(message, failure: failure);
    onChange();
  }

  void _refuse(SshForwardFailed failed) {
    if (isStopped || _status is! Connected) return;

    unawaited(
      stop().catchError(
        (Object exception) =>
            _log.w('${tunnel.title}: could not close ssh ($exception)'),
      ),
    );
    _fail(
      failed.line,
      failed is SshForwardProhibited
          ? TunnelFailure.forwardProhibited
          : TunnelFailure.forwardRefused,
    );
  }

  // A stopping session has left the manager's sessions but is still Connected.
  void _warn(String reason) {
    if (isStopped || _status is! Connected) return;

    _clearWarning?.cancel();
    _clearWarning = Timer(warningLifetime, () {
      if (_status is Connected) {
        _status = const Connected();
        onChange();
      }
    });
    if (_status == Connected(warning: reason)) return;

    _log.w('${tunnel.title}: ${forwardWarning(tunnel)} ($reason)');
    _status = Connected(warning: reason);
    onChange();
  }
}
