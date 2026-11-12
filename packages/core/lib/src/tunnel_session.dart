import 'dart:async';

import 'package:core/src/failure_reason.dart';
import 'package:core/src/tunnel.dart';
import 'package:core/src/tunnels_snapshot.dart';
import 'package:fimber/fimber.dart';
import 'package:system_ssh/system_ssh.dart';

final _log = FimberLog('Tunnels');
final _sshLog = FimberLog('ssh');

class TunnelSession({
  required final Tunnel tunnel,
  required final SshClient client,
  required final void Function() onChange,
  required final Future<void> Function()? beforeConnect,
  required final Future<bool> Function()? isLocked,
  required final Duration warningLifetime,
  required final List<Duration> retryDelays,
  required final Duration lockedRecheck,
  required final Duration stableAfter,
  final bool isRestored = false,
}) {
  final _abort = Completer<void>();
  TunnelStatus _status = const Connecting();
  SshTunnel? _opened;
  SshHostKey? _unknownHostKey;
  Timer? _clearWarning;
  Timer? _retry;
  Timer? _stable;
  late bool _retries = isRestored;
  int _attempts = 0;
  bool _waitsForUnlock = false;

  TunnelStatus get status => _status;

  bool get isStopped => _abort.isCompleted;

  Future<void> connect() async {
    try {
      await beforeConnect?.call();
    } on Object catch (exception) {
      _log.w(
        '${tunnel.title}: beforeConnect failed, connecting anyway ($exception)',
      );
    }
    final SshTunnel opened;
    try {
      opened = _opened = await _open();
    } on Object catch (exception) {
      return _drop(exception);
    }
    if (isStopped) return opened.close();

    _status = const Connected();
    _retries = true;
    _stable = Timer(stableAfter, () => _attempts = 0);
    onChange();
    _log.i('Connected ${tunnel.title}');
    unawaited(opened.done.then((_) => _drop(null), onError: _drop));
  }

  Future<void> stop() async {
    _clearWarning?.cancel();
    _retry?.cancel();
    _stable?.cancel();
    if (!isStopped) _abort.complete();
    await _opened?.close();
  }

  /// Adds the key this session stopped at to `known_hosts`, then connects.
  Future<void> trust() async {
    final hostKey = _unknownHostKey;
    if (hostKey == null || isStopped) return;

    _log.i('${tunnel.title}: trusting $hostKey');
    _unknownHostKey = null;
    _status = const Connecting();
    onChange();
    try {
      await client.trustHostKey(
        tunnel.target,
        hostKey,
        abortTrigger: _abort.future,
      );
    } on Object catch (exception) {
      return _drop(exception);
    }
    if (!isStopped) await connect();
  }

  Future<SshTunnel> _open() {
    final abortTrigger = _abort.future;
    // ssh's lines, named since tunnels connect at once.
    void onLog(SshLog log) {
      _sshLog.d('${tunnel.title}: ${log.line}');
      if (log case SshForwardFailed(:final reason)) _warn(reason);
    }

    return switch (tunnel) {
      Tunnel(kind: TunnelKind.socks) => client.openSocksProxy(
        tunnel.target,
        localPort: tunnel.localPort,
        onLog: onLog,
        abortTrigger: abortTrigger,
      ),
      Tunnel(:final remoteHost?, :final remotePort?) => client.openTunnel(
        tunnel.target,
        remoteHost: remoteHost,
        remotePort: remotePort,
        localPort: tunnel.localPort,
        onLog: onLog,
        abortTrigger: abortTrigger,
      ),
      _ => throw ArgumentError('A local tunnel needs a remote host and port'),
    };
  }

  // A first try the user is watching stays failed; others retry.
  void _drop(Object? exception) {
    if (isStopped) return;

    _stable?.cancel();
    if (exception case SshUnknownHostKeyException(:final hostKey)) {
      _log.w('${tunnel.title}: waiting for the user to check $hostKey');
      _unknownHostKey = hostKey;
      _status = UnknownHostKey(
        host: hostKey.host,
        type: hostKey.type,
        fingerprint: hostKey.fingerprint,
      );
      return onChange();
    }
    final message = exception == null ? 'Disconnected' : _messageOf(exception);
    final isPermanent = switch (exception) {
      SshException(:final isPermanent) => isPermanent,
      null => false,
      _ => true,
    };
    if (!_retries || isPermanent) return _fail(message);
    if (_attempts == retryDelays.length) {
      _log.w('${tunnel.title}: giving up after $_attempts tries');
      return _fail(message);
    }

    final delay = retryDelays[_attempts++];
    _log.w(
      '${tunnel.title} dropped: $message; reconnecting in ${delay.inSeconds}s',
    );
    _status = Reconnecting(message);
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

  void _fail(String message) {
    _log.w('${tunnel.title} failed: $message');
    _status = Failed(message);
    onChange();
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
