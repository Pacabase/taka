@Tags(['unit'])
library;

import 'dart:io';

import 'package:async/async.dart';
import 'package:core/core.dart';
import 'package:test/test.dart';

import 'fakes/fakes.dart';

void main() {
  late Directory directory;
  late String path;
  late TunnelManager manager;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('taka_socket');
    path = '${directory.path}/agent.sock';
    manager = TunnelManager(
      store: FakeStore([database]),
      client: MockSshClient(),
    );
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

  Future<SocketAgentClient> connect() async {
    final agent = await SocketAgentClient.connect(path);
    addTearDown(agent.close);
    return agent;
  }

  Future<StreamQueue<TunnelsSnapshot>> listen() async =>
      StreamQueue((await connect()).snapshots);

  test('a client gets the snapshot when it connects', () async {
    await serve();

    expect(await (await listen()).next, manager.snapshot);
  });

  test('a command reaches the manager and every client sees it', () async {
    await serve();
    final agent = await connect();
    final mine = StreamQueue(agent.snapshots);
    final theirs = await listen();
    await (mine.next, theirs.next).wait;
    const added = Tunnel(id: 'c3', sshHost: 'web', localPort: 8080);

    agent.send(const AgentCommand.save(added));

    expect((await mine.next).tunnels, [database, added]);
    expect((await theirs.next).tunnels, [database, added]);
  });

  test('a bad line is ignored and the client stays connected', () async {
    await serve();
    final socket = await Socket.connect(
      InternetAddress(path, type: InternetAddressType.unix),
      0,
    );
    addTearDown(socket.destroy);
    final snapshots = await listen();
    await snapshots.next;

    socket
      ..writeln('not json')
      ..writeln('[]')
      ..writeln('{"command": "toggle"}');
    await manager.save(proxy);

    expect((await snapshots.next).tunnels, [database, proxy]);
  });

  test('snapshots end when the agent closes', () async {
    final server = await serve();
    final snapshots = await listen();
    await snapshots.next;

    await server.close();

    expect(await snapshots.hasNext, isFalse);
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

    expect(await (await listen()).next, manager.snapshot);
  });
}
