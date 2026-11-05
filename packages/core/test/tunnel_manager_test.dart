@Tags(['unit'])
library;

import 'dart:async';

import 'package:core/core.dart';
import 'package:fimber/fimber.dart';
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
    onLog: any(named: 'onLog'),
    abortTrigger: any(named: 'abortTrigger'),
  );

  Future<SshTunnel> openAnySocksProxy() => client.openSocksProxy(
    any(),
    localPort: any(named: 'localPort'),
    onLog: any(named: 'onLog'),
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

    test(
      'reconnects a tunnel that is on when its connection changes',
      () async {
        final manager = await loaded();
        await manager.toggle('a1');
        final moved = database.copyWith(localPort: 15433);

        await manager.save(moved);

        expect(tunnel.closeCount, 1);
        verify(
          () => client.openTunnel(
            any(),
            remoteHost: any(named: 'remoteHost'),
            remotePort: any(named: 'remotePort'),
            localPort: 15433,
            onLog: any(named: 'onLog'),
            abortTrigger: any(named: 'abortTrigger'),
          ),
        ).called(1);
        expect(manager.snapshot.statusOf('a1'), const Connected());
      },
    );

    test('keeps a tunnel that is on connected when only renamed', () async {
      final manager = await loaded();
      await manager.toggle('a1');

      await manager.save(database.copyWith(name: 'Staging database'));

      expect(tunnel.closeCount, 0);
      verify(openAnyTunnel).called(1);
      expect(manager.snapshot.statusOf('a1'), const Connected());
    });
  });

  group('toggle', () {
    test('runs beforeConnect before ssh starts', () async {
      final calls = <String>[];
      when(openAnyTunnel).thenAnswer((_) async {
        calls.add('ssh');
        return tunnel;
      });
      final manager = TunnelManager(
        store: store,
        client: client,
        beforeConnect: () async => calls.add('before'),
      );
      addTearDown(manager.close);
      await manager.load();

      await manager.toggle('a1');

      expect(calls, ['before', 'ssh']);
    });

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
          onLog: any(named: 'onLog'),
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
          onLog: any(named: 'onLog'),
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

  test('a dropped tunnel says why ssh stopped', () async {
    final manager = await loaded();
    await manager.toggle('a1');

    tunnel.dropWith(
      const SshTunnelException('Connection to bastion closed by remote host.'),
    );
    await pumpEventQueue();

    expect(
      manager.snapshot.statusOf('a1'),
      const Failed('Connection to bastion closed by remote host.'),
    );
  });

  group('a warning from ssh', () {
    const refused =
        'channel 2: open failed: connect failed: Connection refused';
    late void Function(String line) sshSays;

    Future<TunnelManager> warned(Tunnel added) async {
      void capture(Invocation invocation) => sshSays =
          invocation.namedArguments[#onLog]! as void Function(String line);
      when(openAnyTunnel).thenAnswer((invocation) async {
        capture(invocation);
        return tunnel;
      });
      when(openAnySocksProxy).thenAnswer((invocation) async {
        capture(invocation);
        return FakeTunnel(1080);
      });
      final manager = TunnelManager(
        store: store,
        client: client,
        warningLifetime: const Duration(milliseconds: 50),
      );
      addTearDown(manager.close);
      await manager.load();
      await manager.toggle(added.id);
      return manager;
    }

    test('keeps the tunnel connected and names the destination', () async {
      final manager = await warned(database);

      sshSays(refused);

      expect(
        manager.snapshot.statusOf('a1'),
        const Connected(warning: 'db.internal:5432: Connection refused'),
      );
    });

    test('for a SOCKS proxy says a destination refused', () async {
      final manager = await warned(proxy);

      sshSays(refused);

      expect(
        manager.snapshot.statusOf('b2'),
        const Connected(warning: 'A SOCKS destination: Connection refused'),
      );
    });

    test('fades once ssh has said nothing more for a while', () async {
      final manager = await warned(database);
      sshSays(refused);

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(manager.snapshot.statusOf('a1'), const Connected());
    });

    test('is not kept for a tunnel that is stopped', () async {
      final manager = await warned(database);
      sshSays(refused);

      await manager.toggle('a1');
      sshSays(refused);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(manager.snapshot.statusOf('a1'), const Stopped());
    });

    test('ignores lines that are not open failures', () async {
      final manager = await warned(database);

      sshSays('debug1: channel 3: new direct-tcpip');

      expect(manager.snapshot.statusOf('a1'), const Connected());
    });
  });

  group('logs', () {
    const connecting =
        'I/Tunnels: Connecting Production database: '
        'localhost:15432 → db.internal:5432 via deploy@bastion';
    const denied = 'deploy@bastion: Permission denied (publickey).';
    late List<String> lines;

    setUp(() {
      lines = [];
      Fimber.plantTree(_RecordingTree(lines));
      addTearDown(Fimber.clearAll);
    });

    test('a tunnel connecting, connected, stopping and dropped', () async {
      final manager = await loaded();
      await manager.toggle('a1');
      await manager.toggle('a1');
      tunnel = FakeTunnel(15432);
      await manager.toggle('a1');
      tunnel.drop();
      await pumpEventQueue();

      expect(lines, [
        connecting,
        'I/Tunnels: Connected Production database',
        'I/Tunnels: Stopping Production database',
        connecting,
        'I/Tunnels: Connected Production database',
        'W/Tunnels: Production database failed: Disconnected',
      ]);
    });

    test("ssh's lines while it connects, then why it failed", () async {
      when(openAnyTunnel).thenAnswer((invocation) async {
        (invocation.namedArguments[#onLog]! as void Function(String))
          ..call('debug1: Connecting to bastion port 22.')
          ..call(denied);
        throw const SshTunnelException(denied);
      });
      final manager = await loaded();

      await manager.toggle('a1');

      expect(lines, [
        connecting,
        'D/ssh: Production database: debug1: Connecting to bastion port 22.',
        'D/ssh: Production database: $denied',
        'W/Tunnels: Production database failed: $denied',
      ]);
    });
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

  test(
    'close from a listener of changes waits for the tunnels to stop',
    () async {
      final stopping = Completer<void>();
      when(openAnyTunnel).thenAnswer((_) async => _SlowTunnel(stopping.future));
      final manager = await loaded();
      await manager.toggle('a1');
      var listenerClosed = false;
      manager.changes.listen(
        null,
        onDone: () async {
          await manager.close();
          listenerClosed = true;
        },
      );

      final closing = manager.close();
      await pumpEventQueue();
      expect(listenerClosed, isFalse);

      stopping.complete();
      await closing;
      await pumpEventQueue();
      expect(listenerClosed, isTrue);
    },
  );

  test('handle quit stops every tunnel and ends changes', () async {
    final manager = await loaded();
    await manager.toggle('a1');
    final changes = manager.changes.toList();

    await manager.handle(const AgentCommand.quit());

    await changes;
    expect(tunnel.closeCount, 1);
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

class _SlowTunnel(final Future<void> _stopped) implements SshTunnel {
  @override
  int get localPort => 15432;

  @override
  Future<void> get done => Completer<void>().future;

  @override
  Future<void> close() => _stopped;
}

class _RecordingTree(final List<String> _lines) extends LogTree {
  @override
  List<String> getLevels() => const ['V', 'D', 'I', 'W', 'E'];

  @override
  void log(
    String level,
    String message, {
    String? tag,
    dynamic ex,
    StackTrace? stacktrace,
  }) => _lines.add('$level/$tag: $message');
}
