@Tags(['unit'])
library;

import 'dart:async';
import 'dart:io';

import 'package:core/core.dart';
import 'package:mocktail/mocktail.dart';
import 'package:system_ssh/system_ssh.dart';
import 'package:test/test.dart';

import 'fakes/fakes.dart';

void main() {
  late Directory directory;
  late String path;
  late MockSshClient client;
  late TunnelManager manager;

  setUpAll(() => registerFallbackValue(const SshTarget('fallback')));

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('taka_socket');
    path = '${directory.path}/agent.sock';
    client = MockSshClient();
    manager = TunnelManager(store: FakeStore([database]), client: client);
    await manager.load();
  });

  tearDown(() async {
    await manager.close();
    await directory.delete(recursive: true);
  });

  Future<AgentServer> serve() async {
    final server = (await AgentServer.bind(path, manager))!;
    addTearDown(server.close);
    return server;
  }

  Future<StreamIterator<TunnelsSnapshot>> connect() async {
    final agent = await SocketAgentClient.connect(path);
    addTearDown(agent.close);
    return StreamIterator(agent.snapshots);
  }

  test('a client gets the snapshot when it connects', () async {
    await serve();
    final snapshots = await connect();

    expect(await snapshots.moveNext(), isTrue);
    expect(snapshots.current, manager.snapshot);
  });

  test('a command reaches the manager and every client sees it', () async {
    await serve();
    final agent = await SocketAgentClient.connect(path);
    addTearDown(agent.close);
    final mine = StreamIterator(agent.snapshots);
    final theirs = await connect();
    await mine.moveNext();
    await theirs.moveNext();
    const added = Tunnel(id: 'c3', sshHost: 'web', localPort: 8080);

    agent.send(const AgentCommand.save(added));

    expect(await mine.moveNext(), isTrue);
    expect(mine.current.tunnels, [database, added]);
    expect(await theirs.moveNext(), isTrue);
    expect(theirs.current.tunnels, [database, added]);
  });

  test('a bad line is ignored and the client stays connected', () async {
    await serve();
    final socket = await Socket.connect(
      InternetAddress(path, type: InternetAddressType.unix),
      0,
    );
    addTearDown(socket.destroy);
    final snapshots = await connect();
    await snapshots.moveNext();

    socket
      ..writeln('not json')
      ..writeln('[]')
      ..writeln('{"command": "toggle"}');
    await manager.save(proxy);

    expect(await snapshots.moveNext(), isTrue);
    expect(snapshots.current.tunnels, [database, proxy]);
  });

  test('snapshots end when the agent closes', () async {
    final server = await serve();
    final snapshots = await connect();
    await snapshots.moveNext();

    await server.close();

    expect(await snapshots.moveNext(), isFalse);
    expect(File(path).existsSync(), isFalse);
  });

  test('a second agent finds the first one running', () async {
    await serve();

    expect(await AgentServer.bind(path, manager), isNull);
  });

  test('a socket left behind by a dead agent is replaced', () async {
    final stale = await ServerSocket.bind(
      InternetAddress(path, type: InternetAddressType.unix),
      0,
    );
    await stale.close();
    File(path).createSync();

    await serve();
    final snapshots = await connect();

    expect(await snapshots.moveNext(), isTrue);
  });
}
