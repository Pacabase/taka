@Tags(['unit'])
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taka/pages/tunnels/widgets/native_switch.dart';
import 'package:taka/widgets/input_kind.dart';

void main() {
  setUp(watchInputKind);

  bool ringShows(WidgetTester tester) => tester
      .widgetList<Container>(
        find.descendant(
          of: find.byType(NativeSwitch),
          matching: find.byType(Container),
        ),
      )
      .any((container) => container.foregroundDecoration != null);

  Future<void> click(WidgetTester tester) async {
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.down(const Offset(10, 10));
    await mouse.up();
    await mouse.removePointer();
    await tester.pump();
  }

  testWidgets('the ring shows after Tab, not after a click or Shift alone', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: NativeSwitch(
              value: false,
              color: Colors.green,
              label: 'Dev',
              onToggle: () {},
            ),
          ),
        ),
      ),
    );
    expect(ringShows(tester), isFalse);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(ringShows(tester), isTrue);

    await click(tester);
    expect(ringShows(tester), isFalse);
    expect(showsFocus, isFalse);

    await tester.sendKeyEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pump();
    expect(ringShows(tester), isFalse);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pump();
    expect(showsFocus, isTrue);
  });
}
