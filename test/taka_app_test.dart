@Tags(['unit'])
library;

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taka/pages/about/about_page.dart';
import 'package:taka/pages/tunnels/widgets/native_switch.dart';
import 'package:taka/taka_app.dart';

void main() {
  testWidgets('an About request opens About, once however often it comes', (
    tester,
  ) async {
    final requests = StreamController<void>();
    addTearDown(requests.close);
    await tester.pumpWidget(
      TakaApp(
        version: '1.2.3',
        aboutRequests: requests.stream,
        home: const Text('Tunnels'),
      ),
    );

    requests
      ..add(null)
      ..add(null);
    await tester.pumpAndSettle();

    expect(find.byType(AboutPage), findsOneWidget);
    expect(find.text('Version 1.2.3'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.byType(AboutPage), findsNothing);
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
