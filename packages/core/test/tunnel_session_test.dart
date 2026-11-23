@Tags(['unit'])
library;

import 'dart:async';

import 'package:core/core.dart';
import 'package:core/src/tunnel_session.dart';
import 'package:fake_async/fake_async.dart';
import 'package:mocktail/mocktail.dart';
import 'package:system_ssh/system_ssh.dart';
import 'package:test/test.dart';

import 'fakes/fakes.dart';

void main() {
  const database = Tunnel(
    id: 'a1',
    sshHost: 'bastion',
    localPort: 15432,
    remoteHost: 'db.internal',
    remotePort: 5432,
  );
  const dropped = SshDroppedException('Connection reset by 10.0.0.1 port 22');
  const retryDelays = [Duration(seconds: 1), Duration(seconds: 2)];
  late MockSshClient client;
  late List<TunnelStatus> shown;

  Future<SshTunnel> openAnyTunnel() => client.openTunnel(
    any(),
    remoteHost: any(named: 'remoteHost'),
    remotePort: any(named: 'remotePort'),
    bindAddress: any(named: 'bindAddress'),
    localPort: any(named: 'localPort'),
    onLog: any(named: 'onLog'),
    abortTrigger: any(named: 'abortTrigger'),
  );

  setUpAll(() => registerFallbackValue(const SshTarget('fallback')));

  setUp(() {
    client = MockSshClient();
    shown = [];
  });

  // [shown] gets each status the window would see, once per change.
  TunnelSession session({
    bool isRestored = false,
    bool Function()? locked,
    Future<HandBack> Function()? comeForward,
    DateTime Function()? clock,
  }) {
    final session = TunnelSession(
      tunnel: database,
      client: client,
      comeForward: comeForward,
      isLocked: locked == null ? null : () async => locked(),
      checkDestination: null,
      warningLifetime: const Duration(seconds: 30),
      checkWindow: const Duration(seconds: 3),
      retryDelays: retryDelays,
      lockedRecheck: const Duration(seconds: 5),
      stableAfter: const Duration(minutes: 1),
      isRestored: isRestored,
      clock: clock ?? DateTime.now,
    );
    var last = session.status;
    session.stream.map((state) => state.status).listen((status) {
      if (status != last) shown.add(last = status);
    });
    return session;
  }

  test('is up once ssh opens, and someone is no longer watching', () {
    fakeAsync((time) {
      when(openAnyTunnel).thenAnswer((_) async => FakeTunnel(15432));
      final up = session();

      unawaited(up.connect());
      time.flushMicrotasks();

      expect(up.state.phase, isA<Up>());
      expect(up.state.hasConnected, isTrue);
      expect(up.state.isWatched, isFalse);
      expect(shown, [const Connected()]);
    });
  });

  test('gives up on a first try that fails, with no retry', () {
    fakeAsync((time) {
      when(openAnyTunnel).thenAnswer((_) => Future.error(dropped));
      final failing = session();

      unawaited(failing.connect());
      time
        ..flushMicrotasks()
        ..elapse(const Duration(minutes: 1));

      expect(
        failing.status,
        const Failed(
          'Connection reset by 10.0.0.1 port 22',
          failure: TunnelFailure.dropped,
        ),
      );
      verify(openAnyTunnel).called(1);
    });
  });

  test('a restored tunnel retries its first try, counting the attempt', () {
    fakeAsync((time) {
      when(openAnyTunnel).thenAnswer((_) => Future.error(dropped));
      final restored = session(isRestored: true);

      unawaited(restored.connect());
      time.flushMicrotasks();

      expect(restored.state.phase, isA<Waiting>());
      expect(restored.state.attempts, 1);
      expect(
        restored.status,
        const Reconnecting(
          'Connection reset by 10.0.0.1 port 22',
          failure: TunnelFailure.dropped,
        ),
      );

      when(openAnyTunnel).thenAnswer((_) async => FakeTunnel(15432));
      time.elapse(retryDelays.first);

      expect(restored.state.phase, isA<Up>());
    });
  });

  test('a drop reconnects, and the stable timer resets the count', () {
    fakeAsync((time) {
      var tunnel = FakeTunnel(15432);
      when(openAnyTunnel).thenAnswer((_) async => tunnel);
      final up = session();
      unawaited(up.connect());
      time.flushMicrotasks();

      tunnel.dropWith(dropped);
      tunnel = FakeTunnel(15432);
      time.flushMicrotasks();
      expect(up.state.phase, isA<Waiting>());

      time.elapse(retryDelays.first);
      expect(up.state.phase, isA<Up>());
      expect(up.state.attempts, 1);

      time.elapse(const Duration(minutes: 1));
      expect(up.state.attempts, 0);
      expect(shown, [
        const Connected(),
        const Reconnecting(
          'Connection reset by 10.0.0.1 port 22',
          failure: TunnelFailure.dropped,
        ),
        const Connected(),
      ]);
    });
  });

  test('waits while the screen is locked, then connects once', () {
    fakeAsync((time) {
      var isLocked = true;
      final tunnel = FakeTunnel(15432);
      when(openAnyTunnel).thenAnswer((_) async => tunnel);
      final up = session(locked: () => isLocked);
      unawaited(up.connect());
      time.flushMicrotasks();
      tunnel.dropWith(dropped);
      time
        ..flushMicrotasks()
        ..elapse(retryDelays.first);

      expect(
        up.state.phase,
        const Waiting(
          Reconnecting(
            'Connection reset by 10.0.0.1 port 22',
            failure: TunnelFailure.dropped,
          ),
          forUnlock: true,
        ),
      );

      isLocked = false;
      when(openAnyTunnel).thenAnswer((_) async => FakeTunnel(15432));
      time.elapse(const Duration(seconds: 5));

      expect(up.state.phase, isA<Up>());
      verify(openAnyTunnel).called(2);
    });
  });

  test('comes forward on the first try after a drop, once it was locked', () {
    fakeAsync((time) {
      var isLocked = false;
      var checks = 0;
      final tunnel = FakeTunnel(15432);
      when(openAnyTunnel).thenAnswer((_) async => tunnel);
      final up = session(
        locked: () {
          checks++;
          return isLocked;
        },
      );
      unawaited(up.connect());
      time
        ..flushMicrotasks()
        ..elapse(const Duration(seconds: 5));
      expect(up.state.wasAway, isFalse);
      isLocked = true;
      time.elapse(const Duration(seconds: 5));
      isLocked = false;
      time.elapse(const Duration(minutes: 1));
      expect(up.state.wasAway, isTrue);
      expect(checks, 2);

      when(openAnyTunnel).thenAnswer((_) => Future.error(dropped));
      tunnel.dropWith(dropped);
      time.flushMicrotasks();
      expect(up.state.isWatched, isTrue);
      expect(up.state.wasAway, isFalse);

      time.elapse(retryDelays.first);
      expect(up.state.phase, isA<Waiting>());
      expect(up.state.isWatched, isFalse);
    });
  });

  test('comes forward on the first try after a drop, once the Mac slept', () {
    fakeAsync((time) {
      var now = DateTime(2026, 11, 24);
      final tunnel = FakeTunnel(15432);
      when(openAnyTunnel).thenAnswer((_) async => tunnel);
      final up = session(locked: () => false, clock: () => now);
      unawaited(up.connect());
      time.flushMicrotasks();

      now = now.add(const Duration(hours: 2));
      time.elapse(const Duration(seconds: 5));
      expect(up.state.wasAway, isTrue);

      tunnel.dropWith(dropped);
      time.flushMicrotasks();
      expect(up.state.isWatched, isTrue);
    });
  });

  test('retries without coming forward when it was never away', () {
    fakeAsync((time) {
      var now = DateTime(2026, 11, 24);
      final tunnel = FakeTunnel(15432);
      when(openAnyTunnel).thenAnswer((_) async => tunnel);
      final up = session(locked: () => false, clock: () => now);
      unawaited(up.connect());
      time.flushMicrotasks();

      for (var check = 0; check < 3; check++) {
        now = now.add(const Duration(seconds: 5));
        time.elapse(const Duration(seconds: 5));
      }
      tunnel.dropWith(dropped);
      time.flushMicrotasks();

      expect(up.state.phase, isA<Waiting>());
      expect(up.state.isWatched, isFalse);
    });
  });

  test('a reconnect forgets that it was away before', () {
    fakeAsync((time) {
      var isLocked = true;
      final tunnel = FakeTunnel(15432);
      when(openAnyTunnel).thenAnswer((_) async => tunnel);
      final up = session(locked: () => isLocked);
      unawaited(up.connect());
      time
        ..flushMicrotasks()
        ..elapse(const Duration(seconds: 5));
      expect(up.state.wasAway, isTrue);

      isLocked = false;
      final again = FakeTunnel(15432);
      when(openAnyTunnel).thenAnswer((_) async => again);
      tunnel.dropWith(dropped);
      time
        ..flushMicrotasks()
        ..elapse(retryDelays.first);
      expect(up.state.phase, isA<Up>());

      again.dropWith(dropped);
      time.flushMicrotasks();
      expect(up.state.isWatched, isFalse);
    });
  });

  test(
    'stopping while ssh opens aborts ssh, closes what it opens, and ends',
    () {
      fakeAsync((time) {
        final opened = Completer<SshTunnel>();
        late Future<void> abortTrigger;
        final tunnel = FakeTunnel(15432);
        when(openAnyTunnel).thenAnswer((invocation) {
          abortTrigger =
              invocation.namedArguments[#abortTrigger]! as Future<void>;
          return opened.future;
        });
        final opening = session();
        unawaited(opening.connect());
        time.flushMicrotasks();
        var isAborted = false;
        unawaited(abortTrigger.then((_) => isAborted = true));

        unawaited(opening.stop());
        time.flushMicrotasks();
        expect(isAborted, isTrue);
        opened.complete(tunnel);
        time.flushMicrotasks();

        expect(opening.state.phase, isA<Ended>());
        expect(tunnel.closeCount, 1);
      });
    },
  );

  test('stopping while ssh opens finishes once ssh is closed', () {
    fakeAsync((time) {
      final opened = Completer<SshTunnel>();
      final tunnel = FakeTunnel(15432);
      when(openAnyTunnel).thenAnswer((_) => opened.future);
      final opening = session();
      unawaited(opening.connect());
      time.flushMicrotasks();
      var isStopped = false;

      unawaited(opening.stop().then((_) => isStopped = true));
      time.flushMicrotasks();
      expect(isStopped, isFalse);

      opened.complete(tunnel);
      time.flushMicrotasks();
      expect(isStopped, isTrue);
      expect(tunnel.closeCount, 1);
    });
  });

  test('stopping while ssh logs in hands focus back', () {
    fakeAsync((time) {
      final calls = <String>[];
      late void Function(SshLog log) sshSays;
      when(openAnyTunnel).thenAnswer((invocation) {
        sshSays =
            invocation.namedArguments[#onLog]! as void Function(SshLog log);
        return Completer<SshTunnel>().future;
      });
      final opening = session(
        comeForward: () async {
          calls.add('forward');
          return () async => calls.add('back');
        },
      );
      unawaited(opening.connect());
      time.flushMicrotasks();
      sshSays(const SshLoginStarted('debug1: Connecting to bastion port 22.'));
      time.flushMicrotasks();

      unawaited(opening.stop());
      time.flushMicrotasks();

      expect(calls, ['forward', 'back']);
    });
  });

  test('two stops close ssh once and finish together', () {
    fakeAsync((time) {
      final tunnel = FakeTunnel(15432);
      when(openAnyTunnel).thenAnswer((_) async => tunnel);
      final up = session();
      unawaited(up.connect());
      time.flushMicrotasks();
      var stopped = 0;

      unawaited(up.stop().then((_) => stopped++));
      unawaited(up.stop().then((_) => stopped++));
      time.flushMicrotasks();

      expect(stopped, 2);
      expect(tunnel.closeCount, 1);
    });
  });

  test('trusting with no key to trust does nothing', () {
    fakeAsync((time) {
      when(openAnyTunnel).thenAnswer((_) async => FakeTunnel(15432));
      final up = session();
      unawaited(up.connect());
      time.flushMicrotasks();
      bool? trusted;

      unawaited(up.trust().then((result) => trusted = result));
      time.flushMicrotasks();

      expect(trusted, isFalse);
      expect(up.state.phase, isA<Up>());
    });
  });

  test('ignores a drop once it has stopped', () {
    fakeAsync((time) {
      final tunnel = _DropsLater();
      when(openAnyTunnel).thenAnswer((_) async => tunnel);
      final up = session();
      unawaited(up.connect());
      time.flushMicrotasks();
      unawaited(up.stop());
      time.flushMicrotasks();

      tunnel.dropped.completeError(dropped);
      time
        ..flushMicrotasks()
        ..elapse(const Duration(minutes: 5));

      expect(up.state.phase, isA<Ended>());
      expect(shown.last, const Connected());
      verify(openAnyTunnel).called(1);
    });
  });
}

// Closes at once, and drops only when the test says, as ssh may after a stop.
class _DropsLater implements SshTunnel {
  final dropped = Completer<void>();

  @override
  int get localPort => 15432;

  @override
  Future<void> get done => dropped.future;

  @override
  Future<void> close() async {}
}
