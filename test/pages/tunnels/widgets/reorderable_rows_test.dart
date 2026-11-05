@Tags(['unit'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taka/pages/tunnels/widgets/reorderable_rows.dart';
import 'package:taka/theme/taka_theme.dart';

void main() {
  late List<(int, int)> moves;

  Future<void> pumpRows(WidgetTester tester) async {
    moves = [];
    await tester.pumpWidget(
      MaterialApp(
        theme: takaTheme(Brightness.light),
        home: Scaffold(
          body: ReorderableRows(
            onReorder: (from, to) => moves.add((from, to)),
            children: [
              for (final name in ['one', 'two', 'three'])
                SizedBox(key: ValueKey(name), height: 40, child: Text(name)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> drag(WidgetTester tester, String name, double dy) async {
    final gesture = await tester.startGesture(
      tester.getCenter(find.text(name)),
    );
    for (var step = 0; step < 10; step++) {
      await gesture.moveBy(Offset(0, dy / 10));
      await tester.pump();
    }
    await gesture.up();
    await tester.pumpAndSettle();
  }

  testWidgets('a row dragged down past a neighbour moves after it', (
    tester,
  ) async {
    await pumpRows(tester);

    await drag(tester, 'one', 100);

    expect(moves, [(0, 2)]);
  });

  testWidgets('a row dragged up moves before the rows it passes', (
    tester,
  ) async {
    await pumpRows(tester);

    await drag(tester, 'three', -100);

    expect(moves, [(2, 0)]);
  });

  testWidgets('a row dragged a little stays where it is', (tester) async {
    await pumpRows(tester);

    await drag(tester, 'two', 15);

    expect(moves, isEmpty);
    expect(tester.getTopLeft(find.text('two')).dy, 40);
  });
}
