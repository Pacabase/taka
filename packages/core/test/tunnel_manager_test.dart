@Tags(['unit'])
library;

import 'dart:async';
import 'dart:io';

import 'package:core/core.dart';
import 'package:fake_async/fake_async.dart';
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

  group('import', () {
    test('adds new tunnels after the others and saves them', () async {
      final manager = await loaded();
      const added = Tunnel(id: 'c3', sshHost: 'web', localPort: 8080);

      await manager.import([added]);

      expect(manager.snapshot.tunnels, [database, proxy, added]);
      expect(store.tunnels, [database, proxy, added]);
    });

    test('skips a tunnel already saved, whatever its id', () async {
      final manager = await loaded();

      await manager.import([database.copyWith(id: 'z9'), proxy]);

      expect(manager.snapshot.tunnels, [database, proxy]);
      expect(store.saveCount, 0);
    });

    test('gives a new id to a tunnel whose id is taken', () async {
      final manager = await loaded();
      final other = database.copyWith(localPort: 15433);

      await manager.import([other, other.copyWith(localPort: 15434)]);

      expect(manager.snapshot.tunnels.map((tunnel) => tunnel.id), [
        'a1',
        'b2',
        'a1-2',
        'a1-3',
      ]);
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

    test('connects anyway when beforeConnect throws', () async {
      final manager = TunnelManager(
        store: store,
        client: client,
        beforeConnect: () async => throw StateError('no window'),
      );
      addTearDown(manager.close);
      await manager.load();

      await manager.toggle('a1');

      expect(manager.snapshot.statusOf('a1'), const Connected());
      expect(store.on, {'a1'});
      verify(openAnyTunnel).called(1);
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

    test('opens a tunnel to a socket with its fields', () async {
      store = FakeStore([docker]);
      when(
        () => client.openSocketTunnel(
          any(),
          remoteSocket: any(named: 'remoteSocket'),
          localPort: any(named: 'localPort'),
          onLog: any(named: 'onLog'),
          abortTrigger: any(named: 'abortTrigger'),
        ),
      ).thenAnswer((_) async => tunnel);
      final manager = await loaded();

      await manager.toggle('s6');
      expect(manager.snapshot.statusOf('s6'), const Connected());
      verify(
        () => client.openSocketTunnel(
          const SshTarget('bastion'),
          remoteSocket: '/var/run/docker.sock',
          localPort: 2375,
          onLog: any(named: 'onLog'),
          abortTrigger: any(named: 'abortTrigger'),
        ),
      ).called(1);

      await manager.toggle('s6');
      expect(tunnel.closeCount, 1);
    });

    test('opens the socket even with a host and port left over', () async {
      store = FakeStore([docker.copyWith(remoteHost: 'db', remotePort: 5432)]);
      when(
        () => client.openSocketTunnel(
          any(),
          remoteSocket: any(named: 'remoteSocket'),
          localPort: any(named: 'localPort'),
          onLog: any(named: 'onLog'),
          abortTrigger: any(named: 'abortTrigger'),
        ),
      ).thenAnswer((_) async => tunnel);
      final manager = await loaded();

      await manager.toggle('s6');

      expect(manager.snapshot.statusOf('s6'), const Connected());
      verifyNever(openAnyTunnel);
    });

    group('a remote tunnel', () {
      late FakeRemoteTunnel remote;

      Future<SshRemoteTunnel> openAnyRemoteTunnel() => client.openRemoteTunnel(
        any(),
        localHost: any(named: 'localHost'),
        localPort: any(named: 'localPort'),
        remotePort: any(named: 'remotePort'),
        onLog: any(named: 'onLog'),
        abortTrigger: any(named: 'abortTrigger'),
      );

      setUp(() {
        store = FakeStore([preview]);
        remote = FakeRemoteTunnel(8080);
        when(openAnyRemoteTunnel).thenAnswer((_) async => remote);
      });

      test('opens with its fields', () async {
        final manager = await loaded();

        await manager.toggle('r5');

        expect(manager.snapshot.statusOf('r5'), const Connected());
        verify(
          () => client.openRemoteTunnel(
            const SshTarget('bastion'),
            localHost: any(named: 'localHost', that: equals('localhost')),
            localPort: 3000,
            remotePort: 8080,
            onLog: any(named: 'onLog'),
            abortTrigger: any(named: 'abortTrigger'),
          ),
        ).called(1);
      });

      test('opens back to its local host when it has one', () async {
        store = FakeStore([preview.copyWith(localHost: '192.168.1.1')]);
        final manager = await loaded();

        await manager.toggle('r5');

        verify(
          () => client.openRemoteTunnel(
            any(),
            localHost: '192.168.1.1',
            localPort: 3000,
            remotePort: 8080,
            onLog: any(named: 'onLog'),
            abortTrigger: any(named: 'abortTrigger'),
          ),
        ).called(1);
      });

      test('again closes it', () async {
        final manager = await loaded();
        await manager.toggle('r5');

        await manager.toggle('r5');

        expect(manager.snapshot.statusOf('r5'), const Stopped());
        expect(remote.closeCount, 1);
      });

      test('reconnects when ssh drops it', () {
        fakeAsync((time) {
          final opened = <FakeRemoteTunnel>[];
          when(
            openAnyRemoteTunnel,
          ).thenAnswer((_) async => (opened..add(FakeRemoteTunnel(8080))).last);
          final manager = TunnelManager(store: store, client: client);
          unawaited(manager.load().then((_) => manager.toggle('r5')));
          time.flushMicrotasks();

          opened.last.drop();
          time.flushMicrotasks();
          expect(manager.snapshot.statusOf('r5'), isA<Reconnecting>());

          time.elapse(const Duration(seconds: 1));
          expect(manager.snapshot.statusOf('r5'), const Connected());
          expect(opened, hasLength(2));

          unawaited(manager.close());
          time.flushMicrotasks();
        });
      });

      test('closes one that opens after it was aborted', () async {
        final opened = Completer<SshRemoteTunnel>();
        when(openAnyRemoteTunnel).thenAnswer((_) => opened.future);
        final manager = await loaded();
        unawaited(manager.toggle('r5'));
        await pumpEventQueue();

        await manager.toggle('r5');
        opened.complete(remote);
        await pumpEventQueue();

        expect(manager.snapshot.statusOf('r5'), const Stopped());
        expect(remote.closeCount, 1);
      });

      test('connects once its server\'s new key is trusted', () async {
        const hostKey = SshHostKey(
          host: 'bastion',
          type: 'ED25519',
          fingerprint: 'SHA256:4Q0Hx2v6PZ9dW1yYk0r6hN1m1bGq9cY',
        );
        registerFallbackValue(hostKey);
        var isKnown = false;
        when(openAnyRemoteTunnel).thenAnswer((_) async {
          if (!isKnown) throw SshUnknownHostKeyException(hostKey);
          return remote;
        });
        when(
          () => client.trustHostKey(
            any(),
            any(),
            abortTrigger: any(named: 'abortTrigger'),
          ),
        ).thenAnswer((_) async => isKnown = true);
        final manager = await loaded();
        await manager.toggle('r5');
        expect(manager.snapshot.statusOf('r5'), isA<UnknownHostKey>());

        await manager.trustHostKey('r5', hostKey.fingerprint);

        expect(manager.snapshot.statusOf('r5'), const Connected());
      });

      test('says why the server would not open its port', () async {
        const message =
            'Error: remote port forwarding failed for listen port 8080';
        when(openAnyRemoteTunnel)
            .thenAnswer((_) => Future.error(const SshTunnelException(message)));
        final manager = await loaded();

        await manager.toggle('r5');

        expect(manager.snapshot.statusOf('r5'), const Failed(message));
      });

      test('fails without a port on the SSH host', () async {
        store = FakeStore([preview.copyWith(remotePort: null)]);
        final manager = await loaded();

        await manager.toggle('r5');

        expect(
          manager.snapshot.statusOf('r5'),
          const Failed('A remote tunnel needs a port on the SSH host'),
        );
      });
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

    group('to a server whose host key is new', () {
      const hostKey = SshHostKey(
        host: 'bastion',
        type: 'ED25519',
        fingerprint: 'SHA256:4Q0Hx2v6PZ9dW1yYk0r6hN1m1bGq9cYw8u2bq3Jm8sY',
      );
      final asking = UnknownHostKey(
        host: hostKey.host,
        type: hostKey.type,
        fingerprint: hostKey.fingerprint,
      );

      Future<void> trustAnyHostKey() => client.trustHostKey(
        any(),
        any(),
        abortTrigger: any(named: 'abortTrigger'),
      );

      setUpAll(() => registerFallbackValue(hostKey));

      setUp(() {
        var isKnown = false;
        when(openAnyTunnel).thenAnswer((_) async {
          if (!isKnown) throw SshUnknownHostKeyException(hostKey);
          return tunnel;
        });
        when(openAnySocksProxy).thenAnswer((_) async {
          if (!isKnown) throw SshUnknownHostKeyException(hostKey);
          return FakeTunnel(1080);
        });
        when(trustAnyHostKey).thenAnswer((_) async => isKnown = true);
      });

      test('shows the key and trusts nothing', () async {
        final manager = await loaded();

        await manager.toggle('a1');

        expect(manager.snapshot.statusOf('a1'), asking);
        expect(store.on, isEmpty);
        verifyNever(trustAnyHostKey);
      });

      test('shows it for a restored tunnel too, without retrying', () async {
        store = FakeStore([database], {'a1'});
        final manager = await loaded();

        await manager.restore();

        expect(manager.snapshot.statusOf('a1'), asking);
        expect(store.on, isEmpty);
        verify(openAnyTunnel).called(1);
      });

      test('trustHostKey adds the key and connects', () async {
        final manager = await loaded();
        await manager.toggle('a1');

        await manager.trustHostKey('a1', hostKey.fingerprint);

        expect(manager.snapshot.statusOf('a1'), const Connected());
        expect(store.on, {'a1'});
        verify(
          () => client.trustHostKey(
            const SshTarget('bastion', user: 'deploy'),
            hostKey,
            abortTrigger: any(named: 'abortTrigger'),
          ),
        ).called(1);
      });

      test(
        'trustHostKey runs beforeConnect before ssh reads the key',
        () async {
          final calls = <String>[];
          when(trustAnyHostKey).thenAnswer((_) async => calls.add('trust'));
          final manager = TunnelManager(
            store: store,
            client: client,
            beforeConnect: () async => calls.add('before'),
          );
          addTearDown(manager.close);
          await manager.load();
          await manager.toggle('a1');
          calls.clear();

          await manager.trustHostKey('a1', hostKey.fingerprint);

          expect(calls.take(2), ['before', 'trust']);
        },
      );

      test('trustHostKey says Connecting while it works', () async {
        final trusted = Completer<void>();
        when(trustAnyHostKey).thenAnswer((_) => trusted.future);
        final manager = await loaded();
        await manager.toggle('a1');

        unawaited(manager.trustHostKey('a1', hostKey.fingerprint));

        expect(manager.snapshot.statusOf('a1'), const Connecting());
        trusted.complete();
      });

      test('trustHostKey connects every tunnel waiting on that key', () async {
        final manager = await loaded();
        await manager.toggle('a1');
        await manager.toggle('b2');

        await manager.trustHostKey('a1', hostKey.fingerprint);

        expect(manager.snapshot.statusOf('a1'), const Connected());
        expect(manager.snapshot.statusOf('b2'), const Connected());
        verify(trustAnyHostKey).called(1);
      });

      test('trustHostKey ignores a fingerprint that is not shown', () async {
        final manager = await loaded();
        await manager.toggle('a1');

        await manager.trustHostKey('a1', 'SHA256:other');
        await manager.trustHostKey('b2', hostKey.fingerprint);
        await manager.trustHostKey('missing', hostKey.fingerprint);

        expect(manager.snapshot.statusOf('a1'), asking);
        verifyNever(trustAnyHostKey);
      });

      test('shows the other key when the server offers one by then', () async {
        const other = SshHostKey(
          host: 'bastion',
          type: 'RSA',
          fingerprint: 'SHA256:other',
        );
        when(trustAnyHostKey)
            .thenAnswer((_) => Future.error(SshUnknownHostKeyException(other)));
        final manager = await loaded();
        await manager.toggle('a1');
        await manager.toggle('b2');

        await manager.trustHostKey('a1', hostKey.fingerprint);

        expect(
          manager.snapshot.statusOf('a1'),
          const UnknownHostKey(
            host: 'bastion',
            type: 'RSA',
            fingerprint: 'SHA256:other',
          ),
        );
        expect(manager.snapshot.statusOf('b2'), asking);
      });

      test('says why the key could not be added', () async {
        when(trustAnyHostKey).thenAnswer(
          (_) => Future.error(const SshException('known_hosts is read-only')),
        );
        final manager = await loaded();
        await manager.toggle('a1');

        await manager.trustHostKey('a1', hostKey.fingerprint);

        expect(
          manager.snapshot.statusOf('a1'),
          const Failed('known_hosts is read-only'),
        );
        verify(openAnyTunnel).called(1);
      });

      test('toggle while the key is added aborts it', () async {
        when(trustAnyHostKey).thenAnswer((invocation) async {
          await (invocation.namedArguments[#abortTrigger]! as Future<void>);
          throw const SshTunnelAbortedException();
        });
        final manager = await loaded();
        await manager.toggle('a1');
        final trusting = manager.trustHostKey('a1', hostKey.fingerprint);
        await pumpEventQueue();

        await manager.toggle('a1');
        await trusting;

        expect(manager.snapshot.statusOf('a1'), const Stopped());
        verify(openAnyTunnel).called(1);
      });

      test('connects the others even when the trusted one fails', () async {
        final manager = await loaded();
        await manager.toggle('a1');
        await manager.toggle('b2');
        when(
          openAnyTunnel,
        ).thenAnswer((_) => Future.error(const SshPortInUseException(15432)));

        await manager.trustHostKey('a1', hostKey.fingerprint);

        expect(manager.snapshot.statusOf('a1'), isA<Failed>());
        expect(manager.snapshot.statusOf('b2'), const Connected());
      });

      test('leaves a tunnel waiting on another key alone', () async {
        when(openAnySocksProxy).thenAnswer(
          (_) => Future.error(
            SshUnknownHostKeyException(
              const SshHostKey(
                host: 'bastion',
                type: 'RSA',
                fingerprint: 'SHA256:other',
              ),
            ),
          ),
        );
        final manager = await loaded();
        await manager.toggle('a1');
        await manager.toggle('b2');

        await manager.trustHostKey('a1', hostKey.fingerprint);

        expect(manager.snapshot.statusOf('a1'), const Connected());
        expect(manager.snapshot.statusOf('b2'), isA<UnknownHostKey>());
        verify(openAnySocksProxy).called(1);
      });

      test('a tunnel edited while waiting asks about its new server', () async {
        final manager = await loaded();
        await manager.toggle('a1');

        await manager.save(database.copyWith(sshHost: 'deploy@elsewhere'));

        verify(
          () => client.openTunnel(
            const SshTarget('elsewhere', user: 'deploy'),
            remoteHost: any(named: 'remoteHost'),
            remotePort: any(named: 'remotePort'),
            localPort: any(named: 'localPort'),
            onLog: any(named: 'onLog'),
            abortTrigger: any(named: 'abortTrigger'),
          ),
        ).called(1);
      });

      test('a tunnel renamed while waiting keeps waiting', () async {
        final manager = await loaded();
        await manager.toggle('a1');

        await manager.save(database.copyWith(name: 'Staging database'));

        expect(manager.snapshot.statusOf('a1'), asking);
        verify(openAnyTunnel).called(1);
      });

      test('remove while the key is added connects nothing', () async {
        final trusted = Completer<void>();
        when(trustAnyHostKey).thenAnswer((_) => trusted.future);
        final manager = await loaded();
        await manager.toggle('a1');
        final trusting = manager.trustHostKey('a1', hostKey.fingerprint);

        await manager.remove('a1');
        trusted.complete();
        await trusting;

        expect(manager.snapshot.statusOf('a1'), const Stopped());
        verify(openAnyTunnel).called(1);
      });

      test('toggle asks the server again', () async {
        final manager = await loaded();
        await manager.toggle('a1');

        await manager.toggle('a1');

        expect(manager.snapshot.statusOf('a1'), asking);
        verify(openAnyTunnel).called(2);
      });
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

  group('a dropped tunnel', () {
    const closed = SshTunnelException(
      'Connection to bastion closed by remote host.',
    );
    const denied = SshTunnelException(
      'deploy@bastion: Permission denied (publickey).',
      isPermanent: true,
    );
    const timedOut = SshTunnelException(
      'ssh: connect to host bastion port 22: Operation timed out',
    );
    late List<FakeTunnel> opened;
    late List<SshException> failures;

    // Runs [body] in fake time, with database connected once; [failures] are
    // what the next tries to open it throw.
    void dropped(
      void Function(TunnelManager manager, FakeAsync time) body, {
      Future<void> Function()? beforeConnect,
      Future<bool> Function()? isLocked,
      Future<void> Function(int localPort)? checkDestination,
    }) => fakeAsync((time) {
      opened = [];
      failures = [];
      when(openAnyTunnel).thenAnswer((_) async {
        if (failures.isNotEmpty) throw failures.removeAt(0);
        return (opened..add(FakeTunnel(15432))).last;
      });
      final manager = TunnelManager(
        store: store,
        client: client,
        beforeConnect: beforeConnect,
        isLocked: isLocked,
        checkDestination: checkDestination,
      );
      unawaited(manager.load().then((_) => manager.toggle('a1')));
      time.flushMicrotasks();

      body(manager, time);

      unawaited(manager.close());
      time.flushMicrotasks();
    });

    void drop(FakeAsync time, [Object? reason]) {
      reason == null ? opened.last.drop() : opened.last.dropWith(reason);
      time.flushMicrotasks();
    }

    test('says why, and connects again after a second', () {
      dropped((manager, time) {
        drop(time, closed);
        expect(manager.snapshot.statusOf('a1'), Reconnecting(closed.message));

        time.elapse(const Duration(seconds: 1));
        expect(opened, hasLength(2));
        expect(manager.snapshot.statusOf('a1'), const Connected());
      });
    });

    test('waits for the user when the server has a new key by then', () {
      dropped((manager, time) {
        failures.add(
          SshUnknownHostKeyException(
            const SshHostKey(host: 'bastion', type: 'RSA', fingerprint: 'new'),
          ),
        );
        drop(time, closed);

        time.elapse(const Duration(seconds: 1));

        expect(
          manager.snapshot.statusOf('a1'),
          const UnknownHostKey(
            host: 'bastion',
            type: 'RSA',
            fingerprint: 'new',
          ),
        );
        expect(time.pendingTimers, isEmpty);
      });
    });

    test('does not check where it leads again when it reconnects', () {
      final checked = <int>[];
      dropped((manager, time) {
        drop(time, closed);
        time.elapse(const Duration(seconds: 1));

        expect(opened, hasLength(2));
        expect(checked, [15432]);
      }, checkDestination: (port) async => checked.add(port));
    });

    test('says Disconnected when ssh gives no reason', () {
      dropped((manager, time) {
        drop(time);

        expect(
          manager.snapshot.statusOf('a1'),
          const Reconnecting('Disconnected'),
        );
      });
    });

    test('waits longer after each try that fails', () {
      dropped((manager, time) {
        failures = [timedOut, timedOut];
        drop(time, closed);

        time.elapse(const Duration(seconds: 1));
        expect(manager.snapshot.statusOf('a1'), Reconnecting(timedOut.message));
        time.elapse(const Duration(seconds: 2, milliseconds: 3999));
        expect(opened, hasLength(1));

        time.elapse(const Duration(milliseconds: 1));
        expect(opened, hasLength(2));
        expect(manager.snapshot.statusOf('a1'), const Connected());
      });
    });

    test('gives up after the last delay', () {
      dropped((manager, time) {
        failures = List.filled(10, timedOut, growable: true);
        drop(time, closed);

        time.elapse(const Duration(seconds: 1 + 2 + 4 + 8 + 15 + 30 + 60));
        expect(manager.snapshot.statusOf('a1'), Reconnecting(timedOut.message));

        time.elapse(const Duration(minutes: 2));
        expect(manager.snapshot.statusOf('a1'), Failed(timedOut.message));
        expect(failures, hasLength(2));

        time.elapse(const Duration(hours: 8));
        expect(failures, hasLength(2));
        expect(opened, hasLength(1));
      });
    });

    test('connects again when turned on after giving up', () {
      dropped((manager, time) {
        failures = List.filled(8, timedOut, growable: true);
        drop(time, closed);
        time.elapse(const Duration(minutes: 5));
        expect(manager.snapshot.statusOf('a1'), Failed(timedOut.message));

        unawaited(manager.toggle('a1'));
        time.flushMicrotasks();

        expect(manager.snapshot.statusOf('a1'), const Connected());
        expect(opened, hasLength(2));
      });
    });

    test('waits while the screen is locked, then connects once', () {
      var locked = true;
      dropped(isLocked: () async => locked, (manager, time) {
        failures = [timedOut];
        drop(time, closed);

        time.elapse(const Duration(hours: 8));
        expect(manager.snapshot.statusOf('a1'), Reconnecting(closed.message));
        expect(failures, hasLength(1));

        locked = false;
        time.elapse(const Duration(seconds: 5));
        expect(failures, isEmpty);

        time.elapse(const Duration(seconds: 2));
        expect(manager.snapshot.statusOf('a1'), const Connected());
        expect(opened, hasLength(2));
      });
    });

    test('uses no tries while the screen is locked', () {
      var locked = true;
      dropped(isLocked: () async => locked, (manager, time) {
        failures = List.filled(7, timedOut, growable: true);
        drop(time, closed);
        time.elapse(const Duration(hours: 8));

        locked = false;
        time.elapse(const Duration(minutes: 5));

        expect(manager.snapshot.statusOf('a1'), const Connected());
        expect(opened, hasLength(2));
      });
    });

    test('connects when it cannot tell whether the screen is locked', () {
      dropped(isLocked: () async => throw StateError('no session'), (
        manager,
        time,
      ) {
        drop(time, closed);

        time.elapse(const Duration(seconds: 1));

        expect(manager.snapshot.statusOf('a1'), const Connected());
        expect(opened, hasLength(2));
      });
    });

    test('stays off when turned off while the screen is locked', () {
      dropped(isLocked: () async => true, (manager, time) {
        drop(time, closed);
        time.elapse(const Duration(minutes: 1));

        unawaited(manager.toggle('a1'));
        time.elapse(const Duration(hours: 1));

        expect(manager.snapshot.statusOf('a1'), const Stopped());
        expect(opened, hasLength(1));
      });
    });

    test('starts over once a connection has held for a minute', () {
      dropped((manager, time) {
        failures = [timedOut];
        drop(time, closed);
        time.elapse(const Duration(seconds: 1 + 2));
        expect(opened, hasLength(2));

        time.elapse(const Duration(minutes: 1));
        drop(time, closed);
        time.elapse(const Duration(seconds: 1));

        expect(opened, hasLength(3));
      });
    });

    test('stops on a failure that waiting will not fix', () {
      dropped((manager, time) {
        failures = [denied];
        drop(time, closed);

        time.elapse(const Duration(minutes: 5));

        expect(manager.snapshot.statusOf('a1'), Failed(denied.message));
        expect(opened, hasLength(1));
      });
    });

    test('fails at once when it drops for good', () {
      dropped((manager, time) {
        drop(time, denied);

        time.elapse(const Duration(minutes: 5));

        expect(manager.snapshot.statusOf('a1'), Failed(denied.message));
        expect(opened, hasLength(1));
      });
    });

    test('reconnects when beforeConnect throws on the next try', () {
      var calls = 0;
      dropped(
        beforeConnect: () async {
          if (++calls > 1) throw StateError('no window');
        },
        (manager, time) {
          drop(time, closed);

          time.elapse(const Duration(seconds: 1));

          expect(manager.snapshot.statusOf('a1'), const Connected());
          expect(calls, 2);
          expect(opened, hasLength(2));
        },
      );
    });

    test('stays off when turned off while it waits', () {
      dropped((manager, time) {
        drop(time, closed);

        unawaited(manager.toggle('a1'));
        time.elapse(const Duration(minutes: 5));

        expect(manager.snapshot.statusOf('a1'), const Stopped());
        expect(opened, hasLength(1));
      });
    });

    test('tries no more once the manager closes', () {
      dropped((manager, time) {
        drop(time, closed);

        unawaited(manager.close());
        time.elapse(const Duration(minutes: 5));

        expect(opened, hasLength(1));
      });
    });
  });

  group('checking where a forward leads', () {
    late List<int> checked;

    Future<TunnelManager> checking({
      Future<void> Function(int localPort)? check,
    }) async {
      checked = [];
      final manager = TunnelManager(
        store: store,
        client: client,
        checkDestination: check ?? (port) async => checked.add(port),
      );
      addTearDown(manager.close);
      await manager.load();
      return manager;
    }

    test("checks a forward's local port once it connects", () async {
      final manager = await checking();

      await manager.toggle('a1');
      await pumpEventQueue();

      expect(checked, [15432]);
    });

    test('checks a forward to a socket', () async {
      store = FakeStore([docker]);
      when(
        () => client.openSocketTunnel(
          any(),
          remoteSocket: any(named: 'remoteSocket'),
          localPort: any(named: 'localPort'),
          onLog: any(named: 'onLog'),
          abortTrigger: any(named: 'abortTrigger'),
        ),
      ).thenAnswer((_) async => tunnel);
      final manager = await checking();

      await manager.toggle('s6');
      await pumpEventQueue();

      expect(checked, [2375]);
    });

    test('checks nothing for an exposed port', () async {
      store = FakeStore([preview]);
      when(
        () => client.openRemoteTunnel(
          any(),
          localHost: any(named: 'localHost'),
          localPort: any(named: 'localPort'),
          remotePort: any(named: 'remotePort'),
          onLog: any(named: 'onLog'),
          abortTrigger: any(named: 'abortTrigger'),
        ),
      ).thenAnswer((_) async => FakeRemoteTunnel(8080));
      final manager = await checking();

      await manager.toggle('r5');
      await pumpEventQueue();

      expect(checked, isEmpty);
    });

    test("a stopped tunnel's late refusal leaves the next one alone", () async {
      final said = <void Function(SshLog log)>[];
      when(openAnyTunnel).thenAnswer((invocation) async {
        said.add(
          invocation.namedArguments[#onLog]! as void Function(SshLog log),
        );
        return FakeTunnel(15432);
      });
      final check = Completer<void>();
      final manager = await checking(check: (_) => check.future);
      await manager.toggle('a1');
      await manager.toggle('a1');
      await manager.toggle('a1');

      said.first(
        const SshForwardFailed(
          'channel 2: open failed: connect failed: Connection refused',
          reason: 'Connection refused',
        ),
      );
      check.completeError(const SocketException('Connection refused'));
      await pumpEventQueue();

      expect(manager.snapshot.statusOf('a1'), const Connected());
    });

    test('checks again when the tunnel is turned off and on', () async {
      final manager = await checking();
      await manager.toggle('a1');
      await manager.toggle('a1');
      tunnel = FakeTunnel(15432);

      await manager.toggle('a1');
      await pumpEventQueue();

      expect(checked, [15432, 15432]);
    });

    test('checks nothing for a tunnel restored at login', () async {
      store = FakeStore([database], {'a1'});
      final manager = await checking();

      await manager.restore();
      await pumpEventQueue();

      expect(manager.snapshot.statusOf('a1'), const Connected());
      expect(checked, isEmpty);
    });

    test('checks nothing for a SOCKS proxy', () async {
      final manager = await checking();

      await manager.toggle('b2');
      await pumpEventQueue();

      expect(checked, isEmpty);
    });

    test('checks nothing when the tunnel fails to connect', () async {
      when(
        openAnyTunnel,
      ).thenAnswer((_) => Future.error(const SshTunnelException('Timed out')));
      final manager = await checking();

      await manager.toggle('a1');
      await pumpEventQueue();

      expect(checked, isEmpty);
    });

    test('shows the refusal the check brings out as a warning', () async {
      late void Function(SshLog log) sshSays;
      when(openAnyTunnel).thenAnswer((invocation) async {
        sshSays =
            invocation.namedArguments[#onLog]! as void Function(SshLog log);
        return tunnel;
      });
      final manager = await checking(
        check: (_) async => sshSays(
          const SshForwardFailed(
            'channel 2: open failed: connect failed: Connection refused',
            reason: 'Connection refused',
          ),
        ),
      );

      await manager.toggle('a1');
      await pumpEventQueue();

      expect(
        manager.snapshot.statusOf('a1'),
        const Connected(warning: 'Connection refused'),
      );
    });

    test('stays connected when the check itself fails', () async {
      final manager = await checking(
        check: (_) async => throw const SocketException('Connection refused'),
      );

      await manager.toggle('a1');
      await pumpEventQueue();

      expect(manager.snapshot.statusOf('a1'), const Connected());
    });
  });

  group('a warning from ssh', () {
    const refused = SshForwardFailed(
      'channel 2: open failed: connect failed: Connection refused',
      reason: 'Connection refused',
    );
    const lifetime = Duration(seconds: 30);
    late void Function(SshLog log) sshSays;

    void warned(
      Tunnel added,
      void Function(TunnelManager manager, FakeAsync time) body,
    ) => fakeAsync((time) {
      void capture(Invocation invocation) => sshSays =
          invocation.namedArguments[#onLog]! as void Function(SshLog log);
      when(openAnyTunnel).thenAnswer((invocation) async {
        capture(invocation);
        return tunnel;
      });
      when(openAnySocksProxy).thenAnswer((invocation) async {
        capture(invocation);
        return FakeTunnel(1080);
      });
      final manager = TunnelManager(store: store, client: client);
      unawaited(manager.load().then((_) => manager.toggle(added.id)));
      time.flushMicrotasks();

      body(manager, time);

      unawaited(manager.close());
      time.flushMicrotasks();
    });

    test("keeps the tunnel connected with ssh's reason", () {
      warned(database, (manager, _) {
        sshSays(refused);

        expect(
          manager.snapshot.statusOf('a1'),
          const Connected(warning: 'Connection refused'),
        );
      });
    });

    test("keeps a SOCKS proxy connected with ssh's reason", () {
      warned(proxy, (manager, _) {
        sshSays(refused);

        expect(
          manager.snapshot.statusOf('b2'),
          const Connected(warning: 'Connection refused'),
        );
      });
    });

    test('says when the SSH host forbids forwarding', () {
      warned(database, (manager, _) {
        sshSays(
          const SshForwardFailed(
            'channel 3: open failed: administratively prohibited: open failed',
            reason: 'administratively prohibited',
          ),
        );

        expect(
          manager.snapshot.statusOf('a1'),
          const Connected(warning: 'administratively prohibited'),
        );
      });
    });

    test('fades once ssh has said nothing more for a while', () {
      warned(database, (manager, time) {
        sshSays(refused);
        time.elapse(lifetime ~/ 2);
        sshSays(refused);

        time.elapse(lifetime ~/ 2);
        expect(manager.snapshot.statusOf('a1'), isNot(const Connected()));

        time.elapse(lifetime ~/ 2);
        expect(manager.snapshot.statusOf('a1'), const Connected());
      });
    });

    test('is announced once while ssh repeats it', () {
      warned(database, (manager, time) {
        final changes = <TunnelsSnapshot>[];
        manager.changes.listen(changes.add);

        sshSays(refused);
        sshSays(refused);
        time.flushMicrotasks();

        expect(changes, hasLength(1));
      });
    });

    test('is not kept for a tunnel that is stopped', () {
      warned(database, (manager, time) {
        unawaited(manager.toggle('a1'));
        time.flushMicrotasks();
        final changes = <TunnelsSnapshot>[];
        manager.changes.listen(changes.add);

        sshSays(refused);
        time.elapse(lifetime);

        expect(changes, isEmpty);
      });
    });

    test('ignores lines that are not open failures', () {
      warned(database, (manager, _) {
        sshSays(const SshProgress('debug1: channel 3: new direct-tcpip'));

        expect(manager.snapshot.statusOf('a1'), const Connected());
      });
    });
  });

  group('which tunnels are on', () {
    test('is saved as tunnels turn on and off', () async {
      final manager = await loaded();

      await manager.toggle('a1');
      expect(store.on, {'a1'});

      await manager.toggle('a1');
      expect(store.on, isEmpty);
    });

    test('is not saved again when only a status changes', () async {
      final manager = await loaded();

      await manager.toggle('a1');

      expect(manager.snapshot.statusOf('a1'), const Connected());
      expect(store.saveCount, 1);
    });

    test('stays saved when the manager closes', () async {
      final manager = await loaded();
      await manager.toggle('a1');

      await manager.close();

      expect(store.on, {'a1'});
    });

    test('stays saved when a tunnel that is on is edited or moved', () async {
      final manager = await loaded();
      await manager.toggle('a1');

      await manager.save(database.copyWith(localPort: 15433));
      expect(store.on, {'a1'});

      await manager.move('a1', 1);
      expect(store.on, {'a1'});
    });

    test('a tunnel that is edited while on is saved once', () async {
      final manager = await loaded();
      await manager.toggle('a1');
      final saves = store.saveCount;

      await manager.save(database.copyWith(localPort: 15433));

      expect(store.saveCount, saves + 1);
      expect(manager.snapshot.statusOf('a1'), const Connected());
    });

    test('a failed save is logged, and the tunnel stays on', () async {
      final lines = <String>[];
      Fimber.plantTree(_RecordingTree(lines));
      addTearDown(Fimber.clearAll);
      final manager = await loaded();
      store.saveError = const FileSystemException('read-only');

      await manager.toggle('a1');
      await pumpEventQueue();

      expect(manager.snapshot.statusOf('a1'), const Connected());
      expect(lines, contains(startsWith('W/Tunnels: Could not save which')));
    });

    test('drops a tunnel that is removed', () async {
      final manager = await loaded();
      await manager.toggle('a1');

      await manager.remove('a1');

      expect(store.on, isEmpty);
    });

    test('is not turned on by load alone', () async {
      store = FakeStore([database, proxy], {'a1'});

      final manager = await loaded();

      expect(manager.snapshot.statusOf('a1'), const Stopped());
      expect(store.on, {'a1'});
      expect(store.saveCount, 0);
    });

    test(
      'restore starts nothing already on, nor anything a second time',
      () async {
        store = FakeStore([database, proxy], {'a1', 'b2'});
        final manager = await loaded();
        await manager.toggle('a1');

        await manager.restore();
        await manager.toggle('b2');
        await manager.restore();

        verify(openAnyTunnel).called(1);
        expect(manager.snapshot.statusOf('b2'), const Stopped());
      },
    );

    test('restore turns on the saved tunnels that still exist', () async {
      store = FakeStore([database, proxy], {'b2', 'gone'});
      final manager = await loaded();

      await manager.restore();

      expect(manager.snapshot.statusOf('a1'), const Stopped());
      expect(manager.snapshot.statusOf('b2'), const Connected());
    });

    test('a restored tunnel tries again when its first try fails', () {
      fakeAsync((time) {
        store = FakeStore([database], {'a1'});
        var tries = 0;
        when(openAnyTunnel).thenAnswer((_) async {
          if (++tries == 1) {
            throw const SshTunnelException(
              'ssh: Could not resolve hostname bastion',
            );
          }
          return tunnel;
        });
        final manager = TunnelManager(store: store, client: client);
        unawaited(manager.load().then((_) => manager.restore()));
        time.flushMicrotasks();

        expect(
          manager.snapshot.statusOf('a1'),
          const Reconnecting('ssh: Could not resolve hostname bastion'),
        );
        expect(store.on, {'a1'});

        time.elapse(const Duration(seconds: 1));
        expect(manager.snapshot.statusOf('a1'), const Connected());

        unawaited(manager.close());
        time.flushMicrotasks();
      });
    });

    test('a restored tunnel connects when beforeConnect throws', () async {
      store = FakeStore([database], {'a1'});
      final manager = TunnelManager(
        store: store,
        client: client,
        beforeConnect: () async => throw StateError('no window'),
      );
      addTearDown(manager.close);
      await manager.load();

      await manager.restore();

      expect(manager.snapshot.statusOf('a1'), const Connected());
      expect(store.on, {'a1'});
    });

    test('a restored tunnel still stops on a permanent failure', () async {
      store = FakeStore([database], {'a1'});
      when(openAnyTunnel).thenThrow(
        const SshTunnelException(
          'deploy@bastion: Permission denied (publickey).',
          isPermanent: true,
        ),
      );
      final manager = await loaded();

      await manager.restore();

      expect(
        manager.snapshot.statusOf('a1'),
        const Failed('deploy@bastion: Permission denied (publickey).'),
      );
      expect(store.on, isEmpty);
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

    test('why where a forward leads could not be checked', () async {
      final manager = TunnelManager(
        store: store,
        client: client,
        checkDestination: (_) async =>
            throw const SocketException('Connection refused'),
      );
      addTearDown(manager.close);
      await manager.load();

      await manager.toggle('a1');
      await pumpEventQueue();

      expect(
        lines,
        contains(
          startsWith(
            'W/Tunnels: Production database: could not check where it leads',
          ),
        ),
      );
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
        'W/Tunnels: Production database dropped: Disconnected; reconnecting in 1s',
      ]);
    });

    test('why beforeConnect failed, before connecting anyway', () async {
      final manager = TunnelManager(
        store: store,
        client: client,
        beforeConnect: () async => throw StateError('no window'),
      );
      addTearDown(manager.close);
      await manager.load();

      await manager.toggle('a1');

      const warning =
          'W/Tunnels: Production database: beforeConnect failed, '
          'connecting anyway (Bad state: no window)';
      expect(lines, [
        connecting,
        warning,
        'I/Tunnels: Connected Production database',
      ]);
    });

    test("ssh's lines while it connects, then why it failed", () async {
      when(openAnyTunnel).thenAnswer((invocation) async {
        (invocation.namedArguments[#onLog]! as void Function(SshLog))
          ..call(const SshProgress('debug1: Connecting to bastion port 22.'))
          ..call(const SshMessage(denied));
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

  test('move reorders the tunnels and saves', () async {
    final manager = await loaded();

    await manager.move('b2', 0);

    expect(manager.snapshot.tunnels, [proxy, database]);
    expect(store.tunnels, [proxy, database]);
  });

  test('move saves nothing when nothing moves', () async {
    final manager = await loaded();
    final changes = <TunnelsSnapshot>[];
    manager.changes.listen(changes.add);

    await manager.move('a1', 0);
    await manager.move('gone', 1);

    expect(changes, isEmpty);
    expect(store.saveCount, 0);
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
