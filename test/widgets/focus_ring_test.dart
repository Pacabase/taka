@Tags(['unit'])
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taka/pages/tunnels/widgets/native_switch.dart';
import 'package:taka/widgets/focus_ring.dart';

void main() {
  setUpAll(watchInputKind);

  bool ringShows(WidgetTester tester) => tester
      .widgetList<DecoratedBox>(
        find.descendant(
          of: find.byType(FocusRing),
          matching: find.byType(DecoratedBox),
        ),
      )
      .any(
        (box) => switch (box.decoration) {
          BoxDecoration(:final border?) => border.top.width > 0,
          _ => false,
        },
      );

  testWidgets('the ring shows after Tab and hides after a click', (
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

    await tester.tapAt(const Offset(10, 10), kind: PointerDeviceKind.mouse);
    await tester.pump();
    expect(ringShows(tester), isFalse);
  });
}
