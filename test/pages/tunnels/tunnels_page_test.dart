@Tags(['unit'])
library;

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taka/pages/tunnels/tunnels_bloc.dart';
import 'package:taka/pages/tunnels/tunnels_page.dart';
import 'package:taka/pages/tunnels/widgets/tunnel_tile.dart';
import 'package:taka/pages/tunnels/widgets/tunnels_header.dart';
import 'package:taka/theme/taka_theme.dart';

void main() {
  const database = Tunnel(
    id: 'a1',
    name: 'Database',
    sshHost: 'bastion',
    localPort: 15432,
    remoteHost: 'db.internal',
    remotePort: 5432,
  );
  const proxy = Tunnel(
    id: 'b2',
    name: 'Proxy',
    kind: TunnelKind.socks,
    sshHost: 'bastion',
    localPort: 1080,
  );

  Future<_MockTunnelsBloc> pumpPage(
    WidgetTester tester, {
    TunnelsState initialState = const Ready(
      TunnelsSnapshot(tunnels: [database, proxy]),
    ),
    Stream<TunnelsState> states = const Stream.empty(),
    Stream<OpenTunnel> tunnelRequests = const Stream.empty(),
  }) async {
    final bloc = _MockTunnelsBloc();
    whenListen(bloc, states, initialState: initialState);
    await tester.pumpWidget(
      MaterialApp(
        theme: takaTheme(Brightness.light),
        home: BlocProvider<TunnelsBloc>.value(
          value: bloc,
          child: TunnelsPage(tunnelRequests: tunnelRequests),
        ),
      ),
    );
    return bloc;
  }

  testWidgets(
    'lists the tunnels from the top, and dragging one moves it, shown as hovered',
    (tester) async {
      final bloc = await pumpPage(tester);

      expect(
        tester.getBottomLeft(find.byType(TunnelsHeader)).dy,
        tester.getTopLeft(find.byType(TunnelTile).first).dy,
      );

      final drag = await tester.startGesture(
        tester.getCenter(find.text('Database')),
        kind: PointerDeviceKind.mouse,
      );
      for (var step = 0; step < 12; step++) {
        await drag.moveBy(const Offset(0, 10));
        await tester.pump();
      }
      expect(find.byTooltip('Edit'), findsOneWidget);
      await drag.up();
      await tester.pumpAndSettle();

      verify(
        () => bloc.add(const TunnelsEvent.send(AgentCommand.move('a1', 1))),
      ).called(1);
    },
  );

  testWidgets(
    "the tray asks for a tunnel's form, or a new one, over a dialog",
    (tester) async {
      final requests = StreamController<OpenTunnel>();
      addTearDown(requests.close);
      await pumpPage(tester, tunnelRequests: requests.stream);
      unawaited(
        showDialog<void>(
          context: tester.element(find.byType(TunnelsPage)),
          builder: (_) => const Text('A dialog'),
        ),
      );
      await tester.pumpAndSettle();

      requests.add(const OpenTunnel('b2'));
      await tester.pumpAndSettle();
      expect(find.text('A dialog'), findsNothing);
      expect(find.text('Edit tunnel'), findsOneWidget);
      expect(find.text('bastion'), findsOneWidget);

      requests.add(const OpenTunnel());
      await tester.pumpAndSettle();
      expect(find.text('New tunnel'), findsOneWidget);
    },
  );

  testWidgets('a request that comes while loading opens once the tunnels do', (
    tester,
  ) async {
    final states = StreamController<TunnelsState>();
    addTearDown(states.close);
    await pumpPage(
      tester,
      initialState: const Loading(),
      states: states.stream,
      tunnelRequests: Stream.value(const OpenTunnel('b2')),
    );
    await tester.pump();

    states.add(const Ready(TunnelsSnapshot(tunnels: [database, proxy])));
    await tester.pumpAndSettle();

    expect(find.text('Edit tunnel'), findsOneWidget);
  });

  testWidgets('a request for a tunnel that is gone leaves the screen alone', (
    tester,
  ) async {
    final requests = StreamController<OpenTunnel>();
    addTearDown(requests.close);
    await pumpPage(tester, tunnelRequests: requests.stream);
    unawaited(
      showDialog<void>(
        context: tester.element(find.byType(TunnelsPage)),
        builder: (_) => const Text('A dialog'),
      ),
    );
    await tester.pumpAndSettle();

    requests.add(const OpenTunnel('gone'));
    await tester.pumpAndSettle();

    expect(find.text('A dialog'), findsOneWidget);
    expect(find.text('Tunnels'), findsOneWidget);
  });
}

class _MockTunnelsBloc extends MockBloc<TunnelsEvent, TunnelsState>
    implements TunnelsBloc {}
