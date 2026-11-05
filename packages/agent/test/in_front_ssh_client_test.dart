@Tags(['unit'])
library;

import 'package:agent/src/in_front_ssh_client.dart';
import 'package:system_ssh/system_ssh.dart';
import 'package:test/test.dart';

class FakeTunnel implements SshTunnel {
  @override
  int get localPort => 1080;

  @override
  Future<void> get done => Future.value();

  @override
  Future<void> close() async {}
}

class FakeClient(final List<String> _calls) implements SshClient {
  @override
  Future<SshTunnel> openTunnel(
    SshTarget server, {
    required String remoteHost,
    required int remotePort,
    int? localPort,
    void Function(String line)? onLog,
    Future<void>? abortTrigger,
  }) async {
    _calls.add('tunnel ${server.host} $localPort:$remoteHost:$remotePort');
    return FakeTunnel();
  }

  @override
  Future<SshTunnel> openSocksProxy(
    SshTarget server, {
    int? localPort,
    void Function(String line)? onLog,
    Future<void>? abortTrigger,
  }) async {
    _calls.add('socks ${server.host} $localPort');
    return FakeTunnel();
  }
}

void main() {
  late List<String> calls;
  late InFrontSshClient client;

  setUp(() {
    calls = [];
    client = InFrontSshClient(
      FakeClient(calls),
      () async => calls.add('front'),
    );
  });

  test('comes to the front before opening a tunnel', () async {
    await client.openTunnel(
      const SshTarget('bastion'),
      remoteHost: 'db',
      remotePort: 5432,
      localPort: 15432,
    );

    expect(calls, ['front', 'tunnel bastion 15432:db:5432']);
  });

  test('comes to the front before opening a SOCKS proxy', () async {
    await client.openSocksProxy(const SshTarget('bastion'), localPort: 1080);

    expect(calls, ['front', 'socks bastion 1080']);
  });
}
