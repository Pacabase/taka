@Tags(['unit'])
library;

import 'package:core/core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taka/pages/tunnels/widgets/native_switch.dart';
import 'package:taka/pages/tunnels/widgets/tunnel_tile.dart';
import 'package:taka/taka_app.dart';
import 'package:taka/theme/taka_theme.dart';

void main() {
  const unnamed = Tunnel(
    id: 'a',
    sshHost: 'db',
    localPort: 15432,
    remoteHost: 'localhost',
    remotePort: 5432,
  );
  late int toggles;

  Future<void> pumpTile(
    WidgetTester tester, {
    Tunnel tunnel = unnamed,
    TunnelStatus status = const Stopped(),
  }) async {
    toggles = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: takaTheme(Brightness.light),
        home: Scaffold(
          body: TunnelTile(
            tunnel: tunnel,
            status: status,
            onToggle: () => toggles++,
            onEdit: () {},
            onDelete: () {},
          ),
        ),
      ),
    );
  }

  testWidgets('an unnamed tunnel shows its summary once', (tester) async {
    await pumpTile(tester);
    expect(find.text(unnamed.summary), findsOneWidget);
    expect(find.byType(Text), findsOneWidget);
  });

  testWidgets('a named tunnel shows its summary under the name', (
    tester,
  ) async {
    await pumpTile(tester, tunnel: unnamed.copyWith(name: 'Prod'));
    expect(find.text('Prod'), findsOneWidget);
    expect(find.text(unnamed.summary), findsOneWidget);
  });

  testWidgets('the switch is a labelled toggle', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpTile(tester, status: const Connected());
    expect(
      tester.getSemantics(find.byType(NativeSwitch)),
      isSemantics(
        label: unnamed.summary,
        hasToggledState: true,
        isToggled: true,
        hasTapAction: true,
        isFocusable: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('Tab reaches the switch, Space toggles it, and Edit and Delete '
      'appear', (tester) async {
    await pumpTile(tester);
    expect(find.byTooltip('Edit'), findsNothing);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    expect(toggles, 1);
    expect(find.byTooltip('Edit'), findsOneWidget);
    expect(find.byTooltip('Delete'), findsOneWidget);
  });

  testWidgets('Edit and Delete shown by Tab go after a click elsewhere', (
    tester,
  ) async {
    await tester.pumpWidget(
      TakaApp(
        version: '1.2.3',
        home: Scaffold(
          body: Column(
            children: [
              TunnelTile(
                tunnel: unnamed,
                status: const Stopped(),
                onToggle: () {},
                onEdit: () {},
                onDelete: () {},
              ),
            ],
          ),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(find.byTooltip('Edit'), findsOneWidget);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.down(const Offset(400, 500));
    await mouse.up();
    await mouse.removePointer();
    await tester.pump();

    expect(find.byTooltip('Edit'), findsNothing);
    expect(find.byTooltip('Delete'), findsNothing);
  });

  testWidgets('hovering a row keeps the keyboard focus on its switch', (
    tester,
  ) async {
    await pumpTile(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    final focused = FocusManager.instance.primaryFocus;

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: tester.getCenter(find.byType(TunnelTile)));
    await tester.pump();

    expect(FocusManager.instance.primaryFocus, same(focused));
    expect(focused?.hasPrimaryFocus, isTrue);
  });
}
