@Tags(['unit'])
library;

import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:taka/pages/about/about_page.dart';
import 'package:taka/pages/settings/settings_bloc.dart';
import 'package:taka/pages/settings/settings_page.dart';
import 'package:taka/pages/tunnels/widgets/native_switch.dart';
import 'package:taka/theme/taka_theme.dart';

void main() {
  late _MockSettingsBloc bloc;

  setUpAll(() => registerFallbackValue(const SettingsEvent.started()));

  Future<void> pumpPage(WidgetTester tester, AgentSettings settings) async {
    bloc = _MockSettingsBloc();
    whenListen(
      bloc,
      const Stream<SettingsState>.empty(),
      initialState: Ready(settings),
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

  _FakeFileSelector pickFiles() =>
      FileSelectorPlatform.instance = _FakeFileSelector();

  testWidgets('Export saves the tunnels to the chosen file', (tester) async {
    pickFiles().savePath = '/Users/me/Taka tunnels.json';
    await pumpPage(tester, const AgentSettings());

    await tester.tap(find.text('Export…'));
    await tester.pump();

    sends(const AgentCommand.exportTunnels('/Users/me/Taka tunnels.json'));
  });

  testWidgets('Import adds the tunnels in the chosen file', (tester) async {
    const tunnel = Tunnel(id: 'a1', sshHost: 'bastion', localPort: 1080);
    pickFiles().opened = XFile.fromData(
      utf8.encode(encodeTunnels([tunnel])),
      path: '/Users/me/Taka tunnels.json',
    );
    await pumpPage(tester, const AgentSettings());

    await tester.tap(find.text('Import…'));
    await tester.pump();

    sends(const AgentCommand.importTunnels([tunnel]));
  });

  testWidgets('Import of another file says so, and adds nothing', (
    tester,
  ) async {
    pickFiles().opened = XFile.fromData(
      utf8.encode('{"name": "taka"}'),
      path: '/Users/me/package.json',
    );
    await pumpPage(tester, const AgentSettings());

    await tester.tap(find.text('Import…'));
    await tester.pumpAndSettle();

    expect(
      find.text("package.json isn't a file of Taka tunnels."),
      findsOneWidget,
    );
    verifyNever(() => bloc.add(any()));
  });

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

class _FakeFileSelector extends FileSelectorPlatform
    with MockPlatformInterfaceMixin {
  String? savePath;
  XFile? opened;

  @override
  Future<FileSaveLocation?> getSaveLocation({
    List<XTypeGroup>? acceptedTypeGroups,
    SaveDialogOptions options = const SaveDialogOptions(),
  }) async => switch (savePath) {
    final path? => FileSaveLocation(path),
    null => null,
  };

  @override
  Future<XFile?> openFile({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) async => opened;
}
