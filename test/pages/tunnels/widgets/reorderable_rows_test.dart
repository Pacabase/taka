@Tags(['unit'])
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taka/pages/tunnels/widgets/reorderable_rows.dart';
import 'package:taka/theme/taka_theme.dart';

void main() {
  late List<(int, int)> moves;
  late List<String> names;
  late void Function(void Function()) setNames;

  Future<void> pumpRows(
    WidgetTester tester, {
    Map<String, double> heights = const {},
  }) async {
    moves = [];
    names = ['one', 'two', 'three'];
    await tester.pumpWidget(
      MaterialApp(
        theme: takaTheme(Brightness.light),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              setNames = setState;
              return ReorderableRows(
                onReorder: (from, to) => setState(() {
                  moves.add((from, to));
                  names.insert(to, names.removeAt(from));
                }),
                children: [
                  for (final name in names)
                    SizedBox(
                      key: ValueKey(name),
                      height: heights[name] ?? 40,
                      child: Text(name),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  double topOf(WidgetTester tester, String name) =>
      tester.getTopLeft(find.text(name)).dy;

  bool isLifted(WidgetTester tester, String name) =>
      ReorderableRows.isLifted(tester.element(find.text(name).last));

  Future<TestGesture> lift(WidgetTester tester, String name, double dy) async {
    final gesture = await tester.startGesture(
      tester.getCenter(find.text(name)),
      kind: PointerDeviceKind.mouse,
    );
    for (var step = 0; step < 10; step++) {
      await gesture.moveBy(Offset(0, dy / 10));
      await tester.pump();
    }
    return gesture;
  }

  Future<void> drag(WidgetTester tester, String name, double dy) async {
    final gesture = await lift(tester, name, dy);
    await gesture.up();
    await tester.pumpAndSettle();
  }

  testWidgets('a row dragged to the bottom moves after the others', (
    tester,
  ) async {
    await pumpRows(tester);

    await drag(tester, 'one', 100);

    expect(moves, [(0, 2)]);
    expect(names, ['two', 'three', 'one']);
    expect(topOf(tester, 'one'), 80);
  });

  testWidgets('a row dragged up moves before the rows it passes', (
    tester,
  ) async {
    await pumpRows(tester);

    await drag(tester, 'three', -100);

    expect(moves, [(2, 0)]);
    expect(topOf(tester, 'three'), 0);
  });

  testWidgets('a row dragged past half its neighbour swaps with it', (
    tester,
  ) async {
    await pumpRows(tester);

    await drag(tester, 'one', 40);

    expect(moves, [(0, 1)]);
    expect(topOf(tester, 'one'), 40);
  });

  testWidgets('a row dragged a little stays where it is', (tester) async {
    await pumpRows(tester);

    await drag(tester, 'two', 15);

    expect(moves, isEmpty);
    expect(topOf(tester, 'two'), 40);
  });

  testWidgets('rows of different heights land in the right place', (
    tester,
  ) async {
    await pumpRows(tester, heights: {'two': 100});

    await drag(tester, 'three', -60);

    expect(moves, [(2, 1)]);
    expect(topOf(tester, 'three'), 40);
    expect(topOf(tester, 'two'), 80);
  });

  testWidgets('the dragged row, and then the dropped one until the pointer '
      'moves, shows as lifted', (tester) async {
    await pumpRows(tester);

    final gesture = await lift(tester, 'one', 100);
    expect(isLifted(tester, 'one'), isTrue);
    expect(isLifted(tester, 'two'), isFalse);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(isLifted(tester, 'one'), isTrue);

    await gesture.moveBy(const Offset(0, 1));
    await tester.pump();
    expect(isLifted(tester, 'one'), isFalse);
  });

  testWidgets('a second drag works right after the first', (tester) async {
    await pumpRows(tester);

    await drag(tester, 'one', 100);
    await drag(tester, 'one', -100);

    expect(moves, [(0, 2), (2, 0)]);
  });

  testWidgets('a row removed during a drag ends the drag', (tester) async {
    await pumpRows(tester);
    final gesture = await lift(tester, 'three', -100);

    setNames(() => names.remove('one'));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(moves, isEmpty);
    expect(topOf(tester, 'three'), 40);
  });

  testWidgets('a trackpad swipe scrolls instead of moving a row', (
    tester,
  ) async {
    await pumpRows(tester);
    final swipe = await tester.createGesture(kind: PointerDeviceKind.trackpad);

    await swipe.panZoomStart(tester.getCenter(find.text('one')));
    await swipe.panZoomUpdate(
      tester.getCenter(find.text('one')),
      pan: const Offset(0, 100),
    );
    await swipe.panZoomEnd();
    await tester.pumpAndSettle();

    expect(moves, isEmpty);
  });
}
