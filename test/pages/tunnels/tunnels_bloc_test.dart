@Tags(['unit'])
library;

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taka/pages/tunnels/tunnels_bloc.dart';

class FakeAgent implements AgentClient {
  final controller = StreamController<TunnelsSnapshot>();
  final sent = <AgentCommand>[];

  @override
  Stream<TunnelsSnapshot> get snapshots => controller.stream;

  @override
  void send(AgentCommand command) => sent.add(command);

  @override
  Future<void> close() => controller.close();
}

void main() {
  const database = Tunnel(
    id: 'a1',
    sshHost: 'bastion',
    localPort: 15432,
    remoteHost: 'db.internal',
    remotePort: 5432,
  );
  const connected = TunnelsSnapshot(
    tunnels: [database],
    statuses: {'a1': Connected()},
  );

  late FakeAgent agent;

  setUp(() => agent = FakeAgent());

  test('toString is the class name', () async {
    final bloc = TunnelsBloc(agent: agent);
    addTearDown(bloc.close);

    expect('$bloc', 'TunnelsBloc');
  });

  test('starts Loading', () async {
    final bloc = TunnelsBloc(agent: agent);
    addTearDown(bloc.close);

    expect(bloc.state, const Loading());
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
    'hands save, remove and toggle to the agent',
    build: () => TunnelsBloc(agent: agent),
    act: (bloc) => bloc
      ..add(const TunnelsEvent.save(database))
      ..add(const TunnelsEvent.toggle('a1'))
      ..add(const TunnelsEvent.remove('a1')),
    expect: () => const <TunnelsState>[],
    verify: (_) => expect(agent.sent, const [
      AgentCommand.save(database),
      AgentCommand.toggle('a1'),
      AgentCommand.remove('a1'),
    ]),
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
