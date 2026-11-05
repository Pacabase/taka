@Tags(['unit'])
library;

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taka/pages/settings/settings_bloc.dart';

import '../tunnels/fake_agent.dart';

void main() {
  late FakeAgent agent;

  setUp(() => agent = FakeAgent());

  test('starts Loading and names itself', () async {
    final bloc = SettingsBloc(agent: agent);
    addTearDown(bloc.close);

    expect(bloc.state, const SettingsLoading());
    expect('$bloc', 'SettingsBloc');
  });

  blocTest<SettingsBloc, SettingsState>(
    'shows the settings the agent sends',
    build: () => SettingsBloc(agent: agent),
    act: (bloc) {
      bloc.add(const SettingsEvent.started());
      agent.settingsController
        ..add(const AgentSettings(launchesAtLogin: false))
        ..add(const AgentSettings(launchesAtLogin: true, isLogging: true));
    },
    expect: () => const [
      SettingsReady(AgentSettings(launchesAtLogin: false)),
      SettingsReady(AgentSettings(launchesAtLogin: true, isLogging: true)),
    ],
  );

  blocTest<SettingsBloc, SettingsState>(
    'hands a change to the agent',
    build: () => SettingsBloc(agent: agent),
    act: (bloc) => bloc.add(
      const SettingsEvent.send(AgentCommand.setDebugLogging(on: true)),
    ),
    expect: () => const <SettingsState>[],
    verify: (_) =>
        expect(agent.sent, const [AgentCommand.setDebugLogging(on: true)]),
  );
}
