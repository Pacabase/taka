import 'dart:async';
import 'dart:math';

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
  required final Duration warningLifetime,
  required final List<Duration> retryDelays,
  required final Duration stableAfter,
  final bool isRestored = false,
}) {
  final _abort = Completer<void>();
  TunnelStatus _status = const Connecting();
  SshTunnel? _opened;
  Timer? _clearWarning;
  Timer? _retry;
  Timer? _stable;
  late bool _retries = isRestored;
  int _attempts = 0;

  TunnelStatus get status => _status;

  bool get isStopped => _abort.isCompleted;

  Future<void> connect() async {
    final SshTunnel opened;
    try {
      await beforeConnect?.call();
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

  // A tunnel that has connected, or was restored, retries; a first try the
  // user is watching that fails stays failed.
  void _drop(Object? exception) {
    if (isStopped) return;

    _stable?.cancel();
    final message = exception == null ? 'Disconnected' : _messageOf(exception);
    final isPermanent = switch (exception) {
      SshException(:final isPermanent) => isPermanent,
      null => false,
      _ => true,
    };
    if (!_retries || isPermanent) return _fail(message);

    final delay = retryDelays[min(_attempts++, retryDelays.length - 1)];
    _log.w(
      '${tunnel.title} dropped: $message; reconnecting in ${delay.inSeconds}s',
    );
    _status = Reconnecting(message);
    _retry = Timer(delay, () => unawaited(connect()));
    onChange();
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

  // A stopping session is already out of the manager's sessions but still
  // Connected.
  void _warn(String reason) {
    if (isStopped || _status is! Connected) return;

    final destination = switch (tunnel) {
      Tunnel(kind: TunnelKind.socks) => 'A SOCKS destination',
      Tunnel(:final remoteHost, :final remotePort) => '$remoteHost:$remotePort',
    };
    final warning = '$destination: $reason';
    _clearWarning?.cancel();
    _clearWarning = Timer(warningLifetime, () {
      if (_status is Connected) {
        _status = const Connected();
        onChange();
      }
    });
    if (_status == Connected(warning: warning)) return;

    _log.w('${tunnel.title}: $warning');
    _status = Connected(warning: warning);
    onChange();
  }
}
