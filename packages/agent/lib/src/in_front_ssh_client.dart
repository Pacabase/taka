import 'package:system_ssh/system_ssh.dart';

/// Brings the agent to the front before each tunnel opens: 1Password shows
/// its approval prompt only while the app asking for the key is in front.
class InFrontSshClient(
  final SshClient _client,
  final Future<void> Function() _bringForward,
) implements SshClient {
  @override
  Future<SshTunnel> openTunnel(
    SshTarget server, {
    required String remoteHost,
    required int remotePort,
    int? localPort,
    void Function(String line)? onLog,
    Future<void>? abortTrigger,
  }) async {
    await _bringForward();
    return _client.openTunnel(
      server,
      remoteHost: remoteHost,
      remotePort: remotePort,
      localPort: localPort,
      onLog: onLog,
      abortTrigger: abortTrigger,
    );
  }

  @override
  Future<SshTunnel> openSocksProxy(
    SshTarget server, {
    int? localPort,
    void Function(String line)? onLog,
    Future<void>? abortTrigger,
  }) async {
    await _bringForward();
    return _client.openSocksProxy(
      server,
      localPort: localPort,
      onLog: onLog,
      abortTrigger: abortTrigger,
    );
  }
}
