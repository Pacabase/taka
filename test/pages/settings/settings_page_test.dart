@Tags(['unit'])
library;

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taka/pages/about/about_page.dart';
import 'package:taka/pages/settings/settings_bloc.dart';
import 'package:taka/pages/settings/settings_page.dart';
import 'package:taka/pages/tunnels/widgets/native_switch.dart';
import 'package:taka/theme/taka_theme.dart';

void main() {
  late _MockSettingsBloc bloc;

  Future<void> pumpPage(WidgetTester tester, AgentSettings settings) async {
    bloc = _MockSettingsBloc();
    whenListen(
      bloc,
      const Stream<SettingsState>.empty(),
      initialState: SettingsReady(settings),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: takaTheme(Brightness.light),
        home: BlocProvider<SettingsBloc>.value(
          value: bloc,
          child: const SettingsPage(version: '1.0.0'),
        ),
      ),
    );
  }

  void sends(AgentCommand command) =>
      verify(() => bloc.add(SettingsEvent.send(command))).called(1);

  testWidgets('switching Launch at Login and Debug Logging asks the agent', (
    tester,
  ) async {
    await pumpPage(tester, const AgentSettings(launchesAtLogin: false));

    await tester.tap(find.byType(NativeSwitch).first);
    await tester.tap(find.byType(NativeSwitch).last);

    sends(const AgentCommand.setLaunchAtLogin(on: true));
    sends(const AgentCommand.setDebugLogging(on: true));
  });

  testWidgets('switching them off asks the agent to turn them off', (
    tester,
  ) async {
    await pumpPage(
      tester,
      const AgentSettings(launchesAtLogin: true, isLogging: true),
    );

    await tester.tap(find.byType(NativeSwitch).first);
    await tester.tap(find.byType(NativeSwitch).last);

    sends(const AgentCommand.setLaunchAtLogin(on: false));
    sends(const AgentCommand.setDebugLogging(on: false));
  });

  testWidgets('Launch at Login is left out where the agent cannot', (
    tester,
  ) async {
    await pumpPage(tester, const AgentSettings());

    expect(find.text('Launch at Login'), findsNothing);
    expect(find.text('Debug Logging'), findsOneWidget);
  });

  testWidgets('Show Logs appears while logging, and asks the agent', (
    tester,
  ) async {
    await pumpPage(tester, const AgentSettings());
    expect(find.text('Show Logs'), findsNothing);

    await pumpPage(tester, const AgentSettings(isLogging: true));
    await tester.tap(find.text('Show Logs'));

    sends(const AgentCommand.showLogs());
  });

  testWidgets('About Taka opens the About page', (tester) async {
    await pumpPage(tester, const AgentSettings());

    await tester.tap(find.text('About Taka'));
    await tester.pumpAndSettle();

    expect(find.byType(AboutPage), findsOneWidget);
  });
}

class _MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState>
    implements SettingsBloc {}
