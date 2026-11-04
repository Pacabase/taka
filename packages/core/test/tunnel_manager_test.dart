@Tags(['unit'])
library;

import 'dart:async';

import 'package:core/core.dart';
import 'package:mocktail/mocktail.dart';
import 'package:system_ssh/system_ssh.dart';
import 'package:test/test.dart';

import 'fakes/fakes.dart';

void main() {
  late MockSshClient client;
  late FakeStore store;
  late FakeTunnel tunnel;

  Future<SshTunnel> openAnyTunnel() => client.openTunnel(
    any(),
    remoteHost: any(named: 'remoteHost'),
    remotePort: any(named: 'remotePort'),
    localPort: any(named: 'localPort'),
    abortTrigger: any(named: 'abortTrigger'),
  );

  Future<SshTunnel> openAnySocksProxy() => client.openSocksProxy(
    any(),
    localPort: any(named: 'localPort'),
    abortTrigger: any(named: 'abortTrigger'),
  );

  Future<SshTunnel> abortable(Invocation invocation) async {
    await (invocation.namedArguments[#abortTrigger]! as Future<void>);
    throw const SshTunnelAbortedException();
  }

  setUpAll(() => registerFallbackValue(const SshTarget('fallback')));

  setUp(() {
    client = MockSshClient();
    store = FakeStore([database, proxy]);
    tunnel = FakeTunnel(15432);
    when(openAnyTunnel).thenAnswer((_) async => tunnel);
    when(openAnySocksProxy).thenAnswer((_) async => FakeTunnel(1080));
  });

  Future<TunnelManager> loaded() async {
    final manager = TunnelManager(store: store, client: client);
    addTearDown(manager.close);
    await manager.load();
    return manager;
  }

  Future<TunnelManager> connecting(Future<SshTunnel> opened) async {
    when(openAnyTunnel).thenAnswer((_) => opened);
    final manager = await loaded();
    unawaited(manager.toggle('a1'));
    await pumpEventQueue();
    return manager;
  }

  test('starts empty, then load reads the saved tunnels and says so', () async {
    final manager = TunnelManager(store: store, client: client);
    addTearDown(manager.close);
    expect(manager.snapshot, const TunnelsSnapshot());
    expect(manager.snapshot.statusOf('a1'), const Stopped());
    final changes = manager.changes.toList();

    await manager.load();
    await manager.close();

    expect(manager.snapshot.tunnels, [database, proxy]);
    expect(await changes, [manager.snapshot]);
  });

  group('save', () {
    test('adds a new tunnel at the end and saves it', () async {
      final manager = await loaded();
      const added = Tunnel(id: 'c3', sshHost: 'web', localPort: 8080);

      await manager.save(added);

      expect(manager.snapshot.tunnels, [database, proxy, added]);
      expect(store.tunnels, [database, proxy, added]);
    });

    test('replaces the tunnel with the same id in place', () async {
      final manager = await loaded();
      final renamed = database.copyWith(name: 'Staging database');

      await manager.save(renamed);

      expect(manager.snapshot.tunnels, [renamed, proxy]);
      expect(store.tunnels, [renamed, proxy]);
    });
  });

  group('toggle', () {
    test('opens a local tunnel with its fields', () async {
      final manager = await loaded();

      await manager.toggle('a1');

      expect(manager.snapshot.statusOf('a1'), const Connected());
      expect(manager.snapshot.connectedCount, 1);
      verify(
        () => client.openTunnel(
          const SshTarget('bastion', user: 'deploy'),
          remoteHost: 'db.internal',
          remotePort: 5432,
          localPort: 15432,
          abortTrigger: any(named: 'abortTrigger'),
        ),
      ).called(1);
    });

    test('opens a SOCKS proxy on its port', () async {
      final manager = await loaded();

      await manager.toggle('b2');

      expect(manager.snapshot.statusOf('b2'), const Connected());
      verify(
        () => client.openSocksProxy(
          const SshTarget('bastion'),
          localPort: 1080,
          abortTrigger: any(named: 'abortTrigger'),
        ),
      ).called(1);
    });

    test('says Connecting while ssh connects', () async {
      final manager = await connecting(Completer<SshTunnel>().future);

      expect(manager.snapshot.statusOf('a1'), const Connecting());
      expect(manager.snapshot.statusOf('a1').isOn, isTrue);
    });

    test('again closes an open tunnel', () async {
      final manager = await loaded();
      await manager.toggle('a1');

      await manager.toggle('a1');

      expect(manager.snapshot.statusOf('a1'), const Stopped());
      expect(tunnel.closeCount, 1);
    });

    test('again while connecting aborts it', () async {
      when(openAnyTunnel).thenAnswer(abortable);
      final manager = await loaded();
      final connecting = manager.toggle('a1');
      await pumpEventQueue();

      await manager.toggle('a1');
      await connecting;

      expect(manager.snapshot.statusOf('a1'), const Stopped());
    });

    test('closes a tunnel that opens after it was aborted', () async {
      final opened = Completer<SshTunnel>();
      final manager = await connecting(opened.future);
      await manager.toggle('a1');

      opened.complete(tunnel);
      await pumpEventQueue();

      expect(manager.snapshot.statusOf('a1'), const Stopped());
      expect(tunnel.closeCount, 1);
    });

    test('again after an abort ssh has not finished connects', () async {
      final first = Completer<SshTunnel>();
      final manager = await connecting(first.future);
      await manager.toggle('a1');
      when(openAnyTunnel).thenAnswer((_) async => tunnel);

      await manager.toggle('a1');
      first.completeError(const SshTunnelAbortedException());
      await pumpEventQueue();

      expect(manager.snapshot.statusOf('a1'), const Connected());
    });

    for (final (error, message) in [
      (const SshPortInUseException(15432), '127.0.0.1:15432 is already in use'),
      (ArgumentError.value('-x', 'server', 'bad host'), 'bad host'),
      (StateError('boom'), 'Bad state: boom'),
    ]) {
      test('says why ssh failed: $message', () async {
        when(openAnyTunnel).thenAnswer((_) => Future.error(error));
        final manager = await loaded();

        await manager.toggle('a1');

        expect(manager.snapshot.statusOf('a1'), Failed(message));
        expect(manager.snapshot.statusOf('a1').isOn, isFalse);
      });
    }

    test('fails a local tunnel without a remote host', () async {
      store = FakeStore([const Tunnel(id: 'c3', sshHost: 'web', localPort: 1)]);
      final manager = await loaded();

      await manager.toggle('c3');

      expect(
        manager.snapshot.statusOf('c3'),
        const Failed('A local tunnel needs a remote host and port'),
      );
    });

    test('ignores an unknown id', () async {
      final manager = await loaded();

      await manager.toggle('missing');

      expect(manager.snapshot.statuses, isEmpty);
    });

    test('can reconnect after a failure', () async {
      when(
        openAnyTunnel,
      ).thenAnswer((_) => Future.error(const SshTunnelException('Timed out')));
      final manager = await loaded();
      await manager.toggle('a1');
      expect(manager.snapshot.statusOf('a1'), const Failed('Timed out'));
      when(openAnyTunnel).thenAnswer((_) async => tunnel);

      await manager.toggle('a1');

      expect(manager.snapshot.statusOf('a1'), const Connected());
    });
  });

  test('connectAll opens every tunnel that is off', () async {
    final manager = await loaded();
    await manager.toggle('a1');

    await manager.connectAll();

    expect(manager.snapshot.connectedCount, 2);
    verify(openAnyTunnel).called(1);
  });

  test('disconnectAll stops every tunnel that is on', () async {
    final manager = await loaded();
    await manager.toggle('a1');

    await manager.disconnectAll();

    expect(tunnel.closeCount, 1);
    expect(manager.snapshot.statusOf('a1'), const Stopped());
    expect(manager.snapshot.statusOf('b2'), const Stopped());
  });

  test('a dropped tunnel says Disconnected', () async {
    final manager = await loaded();
    await manager.toggle('a1');

    tunnel.drop();
    await pumpEventQueue();

    expect(manager.snapshot.statusOf('a1'), const Failed('Disconnected'));
    expect(manager.snapshot.connectedCount, 0);
  });

  test('remove while connecting leaves no status behind', () async {
    final opened = Completer<SshTunnel>();
    final manager = await connecting(opened.future);

    await manager.remove('a1');
    opened.completeError(const SshTunnelAbortedException());
    await pumpEventQueue();

    expect(manager.snapshot.statuses.containsKey('a1'), isFalse);
  });

  test('remove closes the tunnel, forgets it and saves', () async {
    final manager = await loaded();
    await manager.toggle('a1');

    await manager.remove('a1');

    expect(tunnel.closeCount, 1);
    expect(manager.snapshot.tunnels, [proxy]);
    expect(manager.snapshot.statuses.containsKey('a1'), isFalse);
    expect(store.tunnels, [proxy]);
  });

  test('handle runs each command', () async {
    final manager = await loaded();
    const added = Tunnel(id: 'c3', sshHost: 'web', localPort: 8080);

    await manager.handle(const AgentCommand.save(added));
    await manager.handle(const AgentCommand.toggle('a1'));
    await manager.handle(const AgentCommand.remove('b2'));

    expect(manager.snapshot.tunnels, [database, added]);
    expect(manager.snapshot.statusOf('a1'), const Connected());
  });

  test('close stops every tunnel, ends changes, and is idempotent', () async {
    when(openAnySocksProxy).thenAnswer(abortable);
    final manager = await loaded();
    await manager.toggle('a1');
    final connecting = manager.toggle('b2');
    await pumpEventQueue();
    final changesDone = manager.changes.drain<void>();

    await manager.close();
    await manager.close();
    await connecting;

    expect(tunnel.closeCount, 1);
    await expectLater(changesDone, completes);
  });

  test('toggle after close opens nothing', () async {
    final manager = await loaded();
    await manager.close();

    await manager.toggle('a1');

    verifyNever(openAnyTunnel);
  });
}
