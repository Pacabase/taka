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

import '../fake_agent.dart';

void main() {
  const unnamed = Tunnel(
    id: 'a',
    sshHost: 'db',
    localPort: 15432,
    remoteHost: 'localhost',
    remotePort: 5432,
  );
  late int toggles;
  late List<String> trusted;

  Future<void> pumpTile(
    WidgetTester tester, {
    Tunnel tunnel = unnamed,
    TunnelStatus status = const Stopped(),
  }) async {
    toggles = 0;
    trusted = [];
    await tester.pumpWidget(
      MaterialApp(
        theme: takaTheme(Brightness.light),
        home: Scaffold(
          body: TunnelTile(
            tunnel: tunnel,
            status: status,
            onToggle: () => toggles++,
            onTrust: trusted.add,
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
        connect: () async => FakeAgent(),
        home: (_) => Scaffold(
          body: Column(
            children: [
              TunnelTile(
                tunnel: unnamed,
                status: const Stopped(),
                onToggle: () {},
                onTrust: (_) {},
                onEdit: () {},
                onDelete: () {},
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
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

  testWidgets('a connected tunnel says what it could not reach', (
    tester,
  ) async {
    await pumpTile(
      tester,
      status: const Connected(warning: 'Connection refused'),
    );

    expect(
      find.text("Can't reach localhost:5432 through the server."),
      findsOneWidget,
    );
    expect(find.byTooltip('Connection refused'), findsOneWidget);
  });

  testWidgets("a failed tunnel says why plainly, with ssh's words on hover", (
    tester,
  ) async {
    const message = 'user@db: Permission denied (publickey).';
    await pumpTile(tester, status: const Failed(message));

    expect(find.text('The server refused the login.'), findsOneWidget);
    expect(find.byTooltip(message), findsOneWidget);
  });

  testWidgets('a tunnel to a new server shows its key, and Trust sends it', (
    tester,
  ) async {
    const fingerprint = 'SHA256:4Q0Hx2v6PZ9dW1yYk0r6hN1m1bGq9cYw8u2bq3Jm8sY';
    await pumpTile(
      tester,
      status: const UnknownHostKey(
        host: 'db',
        type: 'ED25519',
        fingerprint: fingerprint,
      ),
    );

    expect(
      find.text(
        'First connection to db. '
        'Trust it only if its owner gave you this ED25519 key:',
      ),
      findsOneWidget,
    );
    expect(find.text(fingerprint), findsOneWidget);
    expect(tester.widget<NativeSwitch>(find.byType(NativeSwitch)).value, false);
    expect(trusted, isEmpty);

    await tester.tap(find.text('Trust'));

    expect(trusted, [fingerprint]);
  });

  testWidgets('no other tunnel offers Trust', (tester) async {
    await pumpTile(tester, status: const Failed('Timed out'));

    expect(find.text('Trust'), findsNothing);
  });

  testWidgets('a failure with no message has no tooltip', (tester) async {
    await pumpTile(tester, status: const Failed(''));

    expect(find.text("It couldn't connect."), findsOneWidget);
    expect(find.byType(Tooltip), findsNothing);
  });

  testWidgets('a reconnecting tunnel says why it dropped and stays on', (
    tester,
  ) async {
    const reason = 'Connection to bastion closed by remote host.';
    await pumpTile(tester, status: const Reconnecting(reason));

    expect(find.text('Reconnecting — The connection dropped.'), findsOneWidget);
    expect(find.byTooltip(reason), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('the copy button copies the SSH command, and says so', (
    tester,
  ) async {
    final copied = <Object?>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') copied.add(call.arguments);
        return null;
      },
    );
    await pumpTile(tester);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: tester.getCenter(find.byType(TunnelTile)));
    await tester.pump();

    await tester.tap(find.byTooltip('Copy SSH command'));
    await tester.pump();

    expect(copied, [
      {'text': unnamed.sshCommand},
    ]);
    expect(find.byTooltip('Copied'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1500));
    expect(find.byTooltip('Copy SSH command'), findsOneWidget);
  });

  testWidgets('offers no copy button for a tunnel ssh cannot open', (
    tester,
  ) async {
    await pumpTile(tester, tunnel: unnamed.copyWith(localPort: 0));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: tester.getCenter(find.byType(TunnelTile)));
    await tester.pump();

    expect(find.byTooltip('Edit'), findsOneWidget);
    expect(find.byTooltip('Copy SSH command'), findsNothing);
  });
}
