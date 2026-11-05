@Tags(['unit'])
library;

import 'dart:convert';
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

  test('showAbout asks every open window', () async {
    final server = await serve();
    final mine = await connect();
    final theirs = await connect();
    final requests = [
      StreamQueue(mine.aboutRequests),
      StreamQueue(theirs.aboutRequests),
    ];
    await (
      StreamQueue(mine.snapshots).next,
      StreamQueue(theirs.snapshots).next,
    ).wait;

    expect(server.showAbout(), isTrue);

    await Future.wait(requests.map((queue) => queue.next));
  });

  test('showAbout with no window open asks the next one, once', () async {
    final server = await serve();

    expect(server.showAbout(), isFalse);

    final first = await connect();
    final second = await connect();
    final snapshots = StreamQueue(second.snapshots);
    await snapshots.next;
    await manager.save(proxy);
    await snapshots.next;
    await first.close();
    await second.close();

    expect(await first.aboutRequests.length, 1);
    expect(await second.aboutRequests.length, 0);
  });

  test('a window can listen for About after its first snapshot', () async {
    final server = await serve();
    final agent = await connect();
    final snapshots = StreamQueue(agent.snapshots);
    await snapshots.next;
    server.showAbout();
    await manager.save(proxy);
    await snapshots.next;
    await agent.close();

    expect(await agent.aboutRequests.length, 1);
  });

  test('showAbout with a window open leaves none pending', () async {
    final server = await serve();
    final open = await connect();
    await StreamQueue(open.snapshots).next;
    server.showAbout();
    await open.close();

    final next = await connect();
    final snapshots = StreamQueue(next.snapshots);
    await snapshots.next;
    await manager.save(proxy);
    await snapshots.next;
    await next.close();

    expect(await next.aboutRequests.length, 0);
  });

  test('the client ignores bad lines and stays connected', () async {
    final server = await ServerSocket.bind(
      InternetAddress(path, type: InternetAddressType.unix),
      0,
    );
    addTearDown(server.close);
    server.listen(
      (socket) => socket
        ..writeln('not json')
        ..writeln('[]')
        ..writeln('{}')
        ..writeln('{"show": "settings"}')
        ..writeln('{"tunnels": [1], "statuses": {}}')
        ..writeln(jsonEncode(manager.snapshot.toJson()))
        ..destroy(),
    );
    final agent = await connect();

    expect(await agent.snapshots.toList(), [manager.snapshot]);
    expect(await agent.aboutRequests.length, 0);
  });

  test('a client learns which build of the agent it reached', () async {
    final server = (await AgentServer.bind(
      path,
      manager,
      identity: '/Taka@1',
    ))!;
    addTearDown(server.close);

    expect(await (await connect()).identity, '/Taka@1');
  });

  test(
    'an agent too old to send its identity is identified as empty',
    () async {
      final server = await ServerSocket.bind(
        InternetAddress(path, type: InternetAddressType.unix),
        0,
      );
      addTearDown(server.close);
      server.listen((socket) {
        addTearDown(socket.destroy);
        socket.writeln(jsonEncode(manager.snapshot.toJson()));
      });
      final agent = await connect();

      expect(await agent.identity, '');
      expect(await agent.snapshots.first, manager.snapshot);
    },
  );

  test(
    'an agent that goes away before a word is identified as empty',
    () async {
      final server = await ServerSocket.bind(
        InternetAddress(path, type: InternetAddressType.unix),
        0,
      );
      addTearDown(server.close);
      server.listen((socket) => socket.destroy());

      expect(await (await connect()).identity, '');
    },
  );

  test('a quit command closes the manager', () async {
    await serve();
    final changes = manager.changes.toList();

    (await connect()).send(const AgentCommand.quit());

    await changes;
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
