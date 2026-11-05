@Tags(['unit'])
library;

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taka/pages/tunnels/widgets/tunnel_form.dart';
import 'package:taka/theme/taka_theme.dart';

void main() {
  late List<Tunnel> saved;
  late int cancels;

  Future<void> pumpForm(
    WidgetTester tester, {
    Tunnel? initial,
    List<String> hosts = const [],
  }) async {
    saved = [];
    cancels = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: takaTheme(Brightness.light),
        home: Scaffold(
          body: TunnelForm(
            initial: initial,
            hosts: hosts,
            onSave: saved.add,
            onCancel: () => cancels++,
          ),
        ),
      ),
    );
  }

  Finder field(int index) => find.byType(TextField).at(index);

  bool addEnabled(WidgetTester tester) =>
      tester.widget<FilledButton>(find.byType(FilledButton)).enabled;

  Future<void> fillLocal(
    WidgetTester tester, {
    String remotePort = '5432',
  }) async {
    await tester.enterText(field(0), '15432');
    await tester.enterText(field(1), 'db');
    await tester.enterText(field(2), 'localhost');
    await tester.enterText(field(3), remotePort);
    await tester.pump();
  }

  testWidgets('Add is enabled only once every required field is valid', (
    tester,
  ) async {
    await pumpForm(tester);
    expect(addEnabled(tester), isFalse);

    await fillLocal(tester, remotePort: '70000');
    expect(addEnabled(tester), isFalse);

    await tester.enterText(field(3), '5432');
    await tester.pump();
    expect(addEnabled(tester), isTrue);

    await tester.tap(find.text('Add'));
    expect(
      saved.single,
      isA<Tunnel>()
          .having((tunnel) => tunnel.localPort, 'localPort', 15432)
          .having((tunnel) => tunnel.sshHost, 'sshHost', 'db')
          .having((tunnel) => tunnel.remoteHost, 'remoteHost', 'localhost')
          .having((tunnel) => tunnel.remotePort, 'remotePort', 5432),
    );
  });

  testWidgets('a SOCKS proxy, picked from the keyboard, needs no destination', (
    tester,
  ) async {
    await pumpForm(tester);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(find.text('To'), findsNothing);

    await tester.enterText(field(0), '1080');
    await tester.enterText(field(1), 'user@jump');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    expect(saved.single.kind, TunnelKind.socks);
    expect(saved.single.remoteHost, isNull);
  });

  testWidgets('Tab walks the fields in order', (tester) async {
    await pumpForm(tester);
    final fields = tester
        .widgetList<TextField>(find.byType(TextField))
        .map((field) => field.controller)
        .toList();

    for (final controller in fields) {
      expect(focusedController(tester), controller);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    }
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('Esc cancels', (tester) async {
    await pumpForm(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    expect(cancels, 1);
  });

  testWidgets('Enter does not save an invalid tunnel', (tester) async {
    await pumpForm(tester);
    await tester.enterText(field(0), '15432');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    expect(saved, isEmpty);
  });

  testWidgets('editing keeps the id and prefills every field', (tester) async {
    const tunnel = Tunnel(
      id: 'a',
      name: 'Prod',
      sshHost: 'db',
      localPort: 15432,
      remoteHost: 'localhost',
      remotePort: 5432,
    );
    await pumpForm(tester, initial: tunnel);
    await tester.tap(find.text('Save'));
    expect(saved.single, tunnel);
  });

  group('the SSH host', () {
    const hosts = ['dev', 'staging', 'prod'];
    final desktop = TargetPlatformVariant.only(TargetPlatform.macOS);

    testWidgets(
      'suggests the hosts from ~/.ssh/config that match',
      variant: desktop,
      (tester) async {
        await pumpForm(tester, hosts: hosts);

        await tester.enterText(field(1), 'a');
        await tester.pump();

        expect(find.text('staging'), findsOneWidget);
        expect(find.text('dev'), findsNothing);
        expect(find.text('prod'), findsNothing);
      },
    );

    testWidgets('takes a suggestion that is clicked', variant: desktop, (
      tester,
    ) async {
      await pumpForm(tester, hosts: hosts);
      await tester.enterText(field(1), 'pr');
      await tester.pump();

      await tester.tap(find.text('prod'));
      await tester.pump();

      expect(tester.widget<TextField>(field(1)).controller!.text, 'prod');
    });

    testWidgets('Enter picks the suggestion instead of adding', (tester) async {
      await pumpForm(tester, hosts: hosts);
      await tester.enterText(field(0), '15432');
      await tester.enterText(field(2), 'localhost');
      await tester.enterText(field(3), '5432');
      await tester.enterText(field(1), 'de');
      await tester.pump();

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(tester.widget<TextField>(field(1)).controller!.text, 'dev');
      expect(saved, isEmpty);
    });

    testWidgets('takes any host typed in, too', variant: desktop, (
      tester,
    ) async {
      await pumpForm(tester, hosts: hosts);
      await fillLocal(tester);
      await tester.enterText(field(1), 'me@elsewhere');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      expect(saved.single.sshHost, 'me@elsewhere');
    });
  });
}

TextEditingController? focusedController(WidgetTester tester) => tester
    .binding
    .focusManager
    .primaryFocus
    ?.context
    ?.findAncestorWidgetOfExactType<EditableText>()
    ?.controller;
