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

  testWidgets('Trust sends the key the tunnel shows', (tester) async {
    final bloc = await pumpPage(
      tester,
      initialState: const Ready(
        TunnelsSnapshot(
          tunnels: [database, proxy],
          statuses: {
            'b2': UnknownHostKey(
              host: 'bastion',
              type: 'ED25519',
              fingerprint: 'SHA256:4Q0Hx2v6PZ9dW1yYk0r6hN1m1bGq9cY',
            ),
          },
        ),
      ),
    );

    await tester.tap(find.text('Trust'));

    verify(
      () => bloc.add(
        const TunnelsEvent.send(
          AgentCommand.trustHostKey(
            'b2',
            'SHA256:4Q0Hx2v6PZ9dW1yYk0r6hN1m1bGq9cY',
          ),
        ),
      ),
    ).called(1);
  });

  testWidgets('heads each group, where its first tunnel is', (tester) async {
    await pumpPage(
      tester,
      initialState: Ready(
        TunnelsSnapshot(
          tunnels: [
            database.copyWith(group: 'Prod'),
            proxy,
            const Tunnel(
              id: 'c3',
              name: 'Cache',
              localPort: 6379,
              group: 'Prod',
            ),
          ],
        ),
      ),
    );

    double top(String text) => tester.getTopLeft(find.text(text)).dy;

    expect(find.text('Prod'), findsOneWidget);
    expect(top('Prod'), lessThan(top('Database')));
    expect(top('Database'), lessThan(top('Cache')));
    expect(top('Cache'), lessThan(top('Proxy')));
  });

  testWidgets("a group's header carries its tunnels when dragged", (
    tester,
  ) async {
    const cache = Tunnel(
      id: 'c3',
      name: 'Cache',
      localPort: 6379,
      group: 'Prod',
    );
    final bloc = await pumpPage(
      tester,
      initialState: Ready(
        TunnelsSnapshot(
          tunnels: [
            database.copyWith(group: 'Prod'),
            cache,
            proxy,
          ],
        ),
      ),
    );

    final drag = await tester.startGesture(
      tester.getCenter(find.text('Prod')),
      kind: PointerDeviceKind.mouse,
    );
    for (var step = 0; step < 20; step++) {
      await drag.moveBy(const Offset(0, 10));
      await tester.pump();
    }
    // The lifted copy carries the group's tunnels too.
    expect(find.text('Cache'), findsNWidgets(2));
    await drag.up();
    await tester.pumpAndSettle();

    verify(
      () => bloc.add(
        const TunnelsEvent.send(
          AgentCommand.arrange([
            (id: 'b2', group: null),
            (id: 'a1', group: 'Prod'),
            (id: 'c3', group: 'Prod'),
          ]),
        ),
      ),
    ).called(1);
  });

  testWidgets("a tunnel dropped under a group's header joins the group", (
    tester,
  ) async {
    final bloc = await pumpPage(
      tester,
      initialState: Ready(
        TunnelsSnapshot(
          tunnels: [
            database.copyWith(group: 'Prod'),
            proxy,
          ],
        ),
      ),
    );

    double tileTop(String name) => tester
        .getTopLeft(
          find.ancestor(of: find.text(name), matching: find.byType(TunnelTile)),
        )
        .dy;
    // Proxy's top just under Database's: past the header, above Database.
    final distance = tileTop('Database') - tileTop('Proxy') + 4;

    final drag = await tester.startGesture(
      tester.getCenter(find.text('Proxy')),
      kind: PointerDeviceKind.mouse,
    );
    for (var step = 0; step < 10; step++) {
      await drag.moveBy(Offset(0, distance / 10));
      await tester.pump();
    }
    await drag.up();
    await tester.pumpAndSettle();

    verify(
      () => bloc.add(
        const TunnelsEvent.send(
          AgentCommand.arrange([
            (id: 'b2', group: 'Prod'),
            (id: 'a1', group: 'Prod'),
          ]),
        ),
      ),
    ).called(1);
  });

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
        () => bloc.add(
          const TunnelsEvent.send(
            AgentCommand.arrange([
              (id: 'b2', group: null),
              (id: 'a1', group: null),
            ]),
          ),
        ),
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

  testWidgets('with no tunnels, asks for one and opens the form for it', (
    tester,
  ) async {
    await pumpPage(tester, initialState: const Ready(TunnelsSnapshot()));

    expect(find.text('No tunnels yet'), findsOneWidget);
    expect(
      find.text('Add the SSH host, a local port, and where it leads.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Add Tunnel'));
    await tester.pumpAndSettle();
    expect(find.text('New tunnel'), findsOneWidget);
    expect(find.text('To'), findsOneWidget);
  });

  testWidgets('Add SOCKS Proxy opens the form on a SOCKS proxy', (
    tester,
  ) async {
    await pumpPage(tester, initialState: const Ready(TunnelsSnapshot()));

    await tester.tap(find.text('Add SOCKS Proxy'));
    await tester.pumpAndSettle();

    expect(find.text('New tunnel'), findsOneWidget);
    expect(find.text('To'), findsNothing);
  });
}

class _MockTunnelsBloc extends MockBloc<TunnelsEvent, TunnelsState>
    implements TunnelsBloc {}
