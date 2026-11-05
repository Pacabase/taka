@Tags(['unit'])
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taka/pages/tunnels/widgets/native_switch.dart';

void main() {
  testWidgets('a click on a switch focused by Tab toggles it and drops the '
      'ring', (tester) async {
    var toggles = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: NativeSwitch(
              value: false,
              color: Colors.green,
              label: 'Dev',
              onToggle: () => toggles++,
            ),
          ),
        ),
      ),
    );
    bool ringShows() => tester
        .widgetList<Container>(
          find.descendant(
            of: find.byType(NativeSwitch),
            matching: find.byType(Container),
          ),
        )
        .any((container) => container.foregroundDecoration != null);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(ringShows(), isTrue);

    await tester.tap(find.byType(NativeSwitch), kind: PointerDeviceKind.mouse);
    await tester.pump();

    expect(toggles, 1);
    expect(ringShows(), isFalse);
  });
}
