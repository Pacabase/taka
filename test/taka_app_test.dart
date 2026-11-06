@Tags(['unit'])
library;

import 'dart:async';
import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taka/pages/about/about_page.dart';
import 'package:taka/pages/settings/settings_page.dart';
import 'package:taka/pages/tunnels/widgets/native_switch.dart';
import 'package:taka/taka_app.dart';

import 'pages/tunnels/fake_agent.dart';

void main() {
  testWidgets('shows a spinner while the helper starts, then the app', (
    tester,
  ) async {
    final connecting = Completer<AgentClient>();
    await tester.pumpWidget(
      TakaApp(
        version: '1.2.3',
        connect: () => connecting.future,
        home: (_) => const Text('Tunnels'),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    connecting.complete(FakeAgent());
    await tester.pump();

    expect(find.text('Tunnels'), findsOneWidget);
  });

  testWidgets('shows why it failed, and Try Again opens the app once it '
      'answers', (tester) async {
    var tries = 0;
    await tester.pumpWidget(
      TakaApp(
        version: '1.2.3',
        connect: () async {
          if (++tries == 1) {
            throw const SocketException(
              'no answer on its socket within 5 seconds',
            );
          }
          return FakeAgent();
        },
        home: (_) => const Text('Tunnels'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("Taka's background helper didn't start"), findsOneWidget);
    expect(
      find.text("It started but didn't answer within 5 seconds."),
      findsOneWidget,
    );

    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();

    expect(find.text('Tunnels'), findsOneWidget);
    expect(tries, 2);
  });

  testWidgets('while it connects, About opens and Settings does nothing', (
    tester,
  ) async {
    await tester.pumpWidget(
      TakaApp(
        version: '1.2.3',
        connect: () => Completer<AgentClient>().future,
        home: (_) => const Text('Tunnels'),
      ),
    );

    await _menuCall(tester, 'settings');
    await tester.pump();
    expect(find.byType(SettingsPage), findsNothing);

    await _menuCall(tester, 'about');
    await tester.pumpAndSettle();
    expect(find.byType(AboutPage), findsOneWidget);
  });

  testWidgets('About in the menu opens About, once however often it comes', (
    tester,
  ) async {
    await _pumpApp(tester, const Text('Tunnels'));

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

  testWidgets("Settings in the menu opens Settings with the helper's "
      'settings, and leaves it open', (tester) async {
    final agent = FakeAgent();
    await _pumpApp(tester, const Text('Tunnels'), agent: agent);
    agent.settingsController.add(const AgentSettings(launchesAtLogin: true));

    await _menuCall(tester, 'settings');
    await tester.pumpAndSettle();
    final page = tester.element(find.byType(SettingsPage));
    await _menuCall(tester, 'settings');
    await tester.pumpAndSettle();

    expect(tester.element(find.byType(SettingsPage)), same(page));
    expect(find.text('Launch at Login'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Tunnels'), findsOneWidget);
  });

  testWidgets('a click on empty space takes focus away', (tester) async {
    var toggles = 0;
    await _pumpApp(
      tester,
      Scaffold(
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
    );
    expect(find.byType(NativeSwitch), findsOneWidget);
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
    await _pumpApp(
      tester,
      Scaffold(
        body: NativeSwitch(
          value: false,
          color: Colors.green,
          label: 'Dev',
          onToggle: () => toggles++,
        ),
      ),
    );
    expect(find.byType(NativeSwitch), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);

    expect(toggles, 0);
  });

  testWidgets('Tab still finds the switch after focus was cleared twice', (
    tester,
  ) async {
    var toggles = 0;
    await _pumpApp(
      tester,
      Scaffold(
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
    );
    await tester.tapAt(const Offset(400, 500), kind: PointerDeviceKind.mouse);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);

    expect(toggles, 1);
  });
}

Future<void> _pumpApp(
  WidgetTester tester,
  Widget home, {
  FakeAgent? agent,
}) async {
  await tester.pumpWidget(
    TakaApp(
      version: '1.2.3',
      connect: () async => agent ?? FakeAgent(),
      home: (_) => home,
    ),
  );
  await tester.pump();
}

Future<void> _menuCall(WidgetTester tester, String method) =>
    tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      'taka/menu',
      const StandardMethodCodec().encodeMethodCall(MethodCall(method)),
      (_) {},
    );
