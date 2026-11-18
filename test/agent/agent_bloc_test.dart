@Tags(['unit'])
library;

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taka/agent/agent_bloc.dart';

import '../pages/tunnels/fake_agent.dart';

void main() {
  late FakeAgent helper;

  setUp(() => helper = FakeAgent());

  test('starts connecting and names itself', () async {
    final bloc = AgentBloc(connect: () async => FakeAgent());
    addTearDown(bloc.close);

    expect(bloc.state, const AgentConnecting());
    expect('$bloc', 'AgentBloc');
  });

  blocTest<AgentBloc, AgentState>(
    'is connected once the helper answers',
    build: () => AgentBloc(connect: () async => helper),
    act: (bloc) => bloc.add(const AgentEvent.connect()),
    expect: () => [
      isA<AgentConnected>().having(
        (state) => state.agent,
        'agent',
        same(helper),
      ),
    ],
  );

  final failure = StateError('no helper');
  blocTest<AgentBloc, AgentState>(
    'says why the helper did not start',
    build: () => AgentBloc(connect: () async => throw failure),
    act: (bloc) => bloc.add(const AgentEvent.connect()),
    expect: () => [AgentFailed(failure)],
  );

  var tries = 0;
  blocTest<AgentBloc, AgentState>(
    'connects on trying again after a failure',
    setUp: () => tries = 0,
    build: () => AgentBloc(
      connect: () async => ++tries == 1 ? throw failure : FakeAgent(),
    ),
    act: (bloc) async {
      bloc.add(const AgentEvent.connect());
      await pumpEventQueue();
      bloc.add(const AgentEvent.connect());
    },
    expect: () => [
      AgentFailed(failure),
      const AgentConnecting(),
      isA<AgentConnected>(),
    ],
  );

  blocTest<AgentBloc, AgentState>(
    'does not connect again once connected',
    setUp: () => tries = 0,
    build: () => AgentBloc(
      connect: () async {
        tries++;
        return FakeAgent();
      },
    ),
    act: (bloc) async {
      bloc.add(const AgentEvent.connect());
      await pumpEventQueue();
      bloc.add(const AgentEvent.connect());
    },
    expect: () => [isA<AgentConnected>()],
    verify: (_) => expect(tries, 1),
  );

  test('connects once for two tries in a row', () async {
    final connecting = Completer<AgentClient>();
    var tries = 0;
    final bloc =
        AgentBloc(
            connect: () {
              tries++;
              return connecting.future;
            },
          )
          ..add(const AgentEvent.connect())
          ..add(const AgentEvent.connect());
    addTearDown(bloc.close);
    await pumpEventQueue();

    connecting.complete(helper);
    await pumpEventQueue();

    expect(tries, 1);
    expect(bloc.state, isA<AgentConnected>());
  });

  test('closing while it connects closes the helper link it gets', () async {
    final agent = FakeAgent();
    final connecting = Completer<AgentClient>();
    final bloc = AgentBloc(connect: () => connecting.future)
      ..add(const AgentEvent.connect());
    await pumpEventQueue();

    final closed = bloc.close();
    connecting.complete(agent);
    await closed;
    await pumpEventQueue();

    expect(agent.controller.isClosed, isTrue);
  });

  test('closing it closes the helper link', () async {
    final bloc = AgentBloc(connect: () async => helper)
      ..add(const AgentEvent.connect());
    await pumpEventQueue();

    await bloc.close();

    expect(helper.controller.isClosed, isTrue);
  });
}
