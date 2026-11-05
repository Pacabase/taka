@Tags(['unit'])
library;

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taka/pages/tunnels/tunnels_bloc.dart';

import 'fake_agent.dart';

void main() {
  const database = Tunnel(
    id: 'a1',
    sshHost: 'bastion',
    localPort: 15432,
    remoteHost: 'db.internal',
    remotePort: 5432,
  );
  const proxy = Tunnel(
    id: 'b2',
    kind: TunnelKind.socks,
    sshHost: 'bastion',
    localPort: 1080,
  );
  const connected = TunnelsSnapshot(
    tunnels: [database],
    statuses: {'a1': Connected()},
  );

  late FakeAgent agent;

  setUp(() => agent = FakeAgent());

  test('starts Loading and names itself', () async {
    final bloc = TunnelsBloc(agent: agent);
    addTearDown(bloc.close);

    expect(bloc.state, const Loading());
    expect('$bloc', 'TunnelsBloc');
  });

  blocTest<TunnelsBloc, TunnelsState>(
    'shows each snapshot the agent sends',
    build: () => TunnelsBloc(agent: agent),
    act: (bloc) {
      bloc.add(const TunnelsEvent.started());
      agent.controller
        ..add(const TunnelsSnapshot(tunnels: [database]))
        ..add(connected);
    },
    expect: () => const [
      Ready(TunnelsSnapshot(tunnels: [database])),
      Ready(connected),
    ],
  );

  blocTest<TunnelsBloc, TunnelsState>(
    'is Closed once the agent goes away',
    build: () => TunnelsBloc(agent: agent),
    act: (bloc) async {
      bloc.add(const TunnelsEvent.started());
      agent.controller.add(connected);
      await agent.close();
    },
    expect: () => const [Ready(connected), Closed()],
  );

  blocTest<TunnelsBloc, TunnelsState>(
    'hands each command to the agent in order',
    build: () => TunnelsBloc(agent: agent),
    act: (bloc) => bloc
      ..add(const TunnelsEvent.send(AgentCommand.save(database)))
      ..add(const TunnelsEvent.send(AgentCommand.toggle('a1')))
      ..add(const TunnelsEvent.send(AgentCommand.remove('a1'))),
    expect: () => const <TunnelsState>[],
    verify: (_) => expect(agent.sent, const [
      AgentCommand.save(database),
      AgentCommand.toggle('a1'),
      AgentCommand.remove('a1'),
    ]),
  );

  blocTest<TunnelsBloc, TunnelsState>(
    'shows a moved tunnel in its new place before the agent replies',
    build: () => TunnelsBloc(agent: agent),
    seed: () => const Ready(TunnelsSnapshot(tunnels: [database, proxy])),
    act: (bloc) =>
        bloc.add(const TunnelsEvent.send(AgentCommand.move('b2', 0))),
    expect: () => const [
      Ready(TunnelsSnapshot(tunnels: [proxy, database])),
    ],
    verify: (_) => expect(agent.sent, const [AgentCommand.move('b2', 0)]),
  );

  blocTest<TunnelsBloc, TunnelsState>(
    'is Closed when the agent goes away before its first snapshot',
    build: () => TunnelsBloc(agent: agent),
    act: (bloc) async {
      bloc.add(const TunnelsEvent.started());
      await agent.close();
    },
    expect: () => const [Closed()],
  );

  test('closing the bloc stops listening to the agent', () async {
    final bloc = TunnelsBloc(agent: agent)..add(const TunnelsEvent.started());
    agent.controller.add(connected);
    await pumpEventQueue();
    await bloc.close();

    expect(bloc.state, const Ready(connected));
    expect(agent.controller.hasListener, isFalse);
  });
}
