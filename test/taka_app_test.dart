@Tags(['unit'])
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taka/pages/about/about_page.dart';
import 'package:taka/pages/settings/settings_bloc.dart';
import 'package:taka/pages/settings/settings_page.dart';
import 'package:taka/pages/tunnels/widgets/native_switch.dart';
import 'package:taka/taka_app.dart';

import 'pages/tunnels/fake_agent.dart';

void main() {
  testWidgets('About in the menu opens About, once however often it comes', (
    tester,
  ) async {
    await tester.pumpWidget(
      const TakaApp(version: '1.2.3', home: Text('Tunnels')),
    );

    await _menuCall(tester, 'about');
    await _menuCall(tester, 'about');
    await tester.pumpAndSettle();

    expect(find.byType(AboutPage), findsOneWidget);
    expect(find.text('Version 1.2.3'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.byType(AboutPage), findsNothing);
    expect(find.text('Tunnels'), findsOneWidget);
  });

  testWidgets('Settings in the menu opens Settings, and leaves it open', (
    tester,
  ) async {
    final settings = SettingsBloc(agent: FakeAgent());
    addTearDown(settings.close);
    await tester.pumpWidget(
      TakaApp(
        version: '1.2.3',
        settings: settings,
        home: const Text('Tunnels'),
      ),
    );

    await _menuCall(tester, 'settings');
    await tester.pumpAndSettle();
    final page = tester.element(find.byType(SettingsPage));
    await _menuCall(tester, 'settings');
    await tester.pumpAndSettle();

    expect(tester.element(find.byType(SettingsPage)), same(page));

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Tunnels'), findsOneWidget);
  });

  testWidgets('Settings in the menu does nothing without settings', (
    tester,
  ) async {
    await tester.pumpWidget(
      const TakaApp(version: '1.2.3', home: Text('Tunnels')),
    );

    await _menuCall(tester, 'settings');
    await tester.pumpAndSettle();

    expect(find.text('Tunnels'), findsOneWidget);
  });

  testWidgets('a click on empty space takes focus away', (tester) async {
    var toggles = 0;
    await tester.pumpWidget(
      TakaApp(
        version: '1.2.3',
        home: Scaffold(
          body: Column(
            children: [
              NativeSwitch(
                value: false,
                color: Colors.green,
                label: 'Dev',
                onToggle: () => toggles++,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(
      FocusManager.instance.primaryFocus?.context?.widget,
      isNot(isA<Scaffold>()),
    );

    await tester.tapAt(const Offset(400, 500), kind: PointerDeviceKind.mouse);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);

    expect(toggles, 0);
  });

  testWidgets('Esc takes focus away', (tester) async {
    var toggles = 0;
    await tester.pumpWidget(
      TakaApp(
        version: '1.2.3',
        home: Scaffold(
          body: NativeSwitch(
            value: false,
            color: Colors.green,
            label: 'Dev',
            onToggle: () => toggles++,
          ),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);

    expect(toggles, 0);
  });

  testWidgets('Tab still finds the switch after focus was cleared twice', (
    tester,
  ) async {
    var toggles = 0;
    await tester.pumpWidget(
      TakaApp(
        version: '1.2.3',
        home: Scaffold(
          body: Column(
            children: [
              NativeSwitch(
                value: false,
                color: Colors.green,
                label: 'Dev',
                onToggle: () => toggles++,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.tapAt(const Offset(400, 500), kind: PointerDeviceKind.mouse);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);

    expect(toggles, 1);
  });
}

Future<void> _menuCall(WidgetTester tester, String method) =>
    tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      'taka/menu',
      const StandardMethodCodec().encodeMethodCall(MethodCall(method)),
      (_) {},
    );
