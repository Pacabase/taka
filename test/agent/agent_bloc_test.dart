@Tags(['unit'])
library;

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taka/agent/agent_bloc.dart';

import '../pages/tunnels/fake_agent.dart';

void main() {
  test('starts connecting and names itself', () async {
    final bloc = AgentBloc(connect: () async => FakeAgent());
    addTearDown(bloc.close);

    expect(bloc.state, const AgentConnecting());
    expect('$bloc', 'AgentBloc');
  });

  blocTest<AgentBloc, AgentState>(
    'is connected once the helper answers',
    build: () => AgentBloc(connect: () async => FakeAgent()),
    act: (bloc) => bloc.add(const AgentEvent.connect()),
    expect: () => [isA<AgentConnected>()],
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

  test('closing it closes the helper link and its settings', () async {
    final agent = FakeAgent();
    final bloc = AgentBloc(connect: () async => agent)
      ..add(const AgentEvent.connect());
    await pumpEventQueue();
    final AgentConnected(:settings) = bloc.state as AgentConnected;

    await bloc.close();

    expect(agent.controller.isClosed, isTrue);
    expect(settings.isClosed, isTrue);
  });
}
