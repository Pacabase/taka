@Tags(['unit'])
library;

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taka/pages/tunnels/widgets/group_form.dart';
import 'package:taka/theme/taka_theme.dart';

void main() {
  late List<(String, TunnelColour?)> saved;
  late int cancels;

  Future<void> pumpForm(
    WidgetTester tester, {
    TunnelColour? colour = TunnelColour.green,
  }) async {
    saved = [];
    cancels = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: takaTheme(Brightness.light),
        home: Scaffold(
          body: GroupForm(
            group: 'Prod',
            colour: colour,
            onSave: (name, colour) => saved.add((name, colour)),
            onCancel: () => cancels++,
          ),
        ),
      ),
    );
  }

  testWidgets('A window shorter than the form scrolls to Save', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 80));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpForm(tester);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));

    expect(saved, [('Prod', TunnelColour.green)]);
  });

  testWidgets('No colour saves the group with none', (tester) async {
    await pumpForm(tester);

    await tester.tap(find.byTooltip('No colour'));
    await tester.pump();
    await tester.tap(find.text('Save'));

    expect(saved, [('Prod', null)]);
  });

  testWidgets('Enter in the name saves it', (tester) async {
    await pumpForm(tester);

    await tester.enterText(find.byType(TextField), 'Live');
    await tester.testTextInput.receiveAction(TextInputAction.done);

    expect(saved, [('Live', TunnelColour.green)]);
  });

  testWidgets('Enter on a blank name saves nothing', (tester) async {
    await pumpForm(tester);

    await tester.enterText(find.byType(TextField), '   ');
    await tester.testTextInput.receiveAction(TextInputAction.done);

    expect(saved, isEmpty);
  });

  testWidgets('Cancel saves nothing', (tester) async {
    await pumpForm(tester);

    await tester.enterText(find.byType(TextField), 'Live');
    await tester.tap(find.text('Cancel'));

    expect(saved, isEmpty);
    expect(cancels, 1);
  });
}
