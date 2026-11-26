@Tags(['unit'])
library;

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taka/pages/login_prompt/login_prompt_cubit.dart';
import 'package:taka/pages/login_prompt/login_prompt_form.dart';
import 'package:taka/pages/tunnels/tunnels_bloc.dart';
import 'package:taka/pages/tunnels/tunnels_page.dart';
import 'package:taka/pages/tunnels/widgets/tunnel_tile.dart';
import 'package:taka/pages/tunnels/widgets/tunnels_header.dart';
import 'package:taka/theme/app_theme.dart';
import 'package:taka/theme/taka_theme.dart';
import 'package:taka/theme/tunnel_colours.dart';
import 'package:taka/widgets/colour_dot.dart';

import 'fake_agent.dart';

void main() {
  const database = Tunnel(
    id: 'a1',
    name: 'Database',
    sshHost: 'bastion',
    forward: LocalForward(
      localPort: 15432,
      remoteHost: 'db.internal',
      remotePort: 5432,
    ),
  );
  const proxy = Tunnel(
    id: 'b2',
    name: 'Proxy',
    sshHost: 'bastion',
    forward: SocksProxy(localPort: 1080),
  );

  Future<_MockTunnelsBloc> pumpPage(
    WidgetTester tester, {
    TunnelsState initialState = const Ready(
      TunnelsSnapshot(tunnels: [database, proxy]),
    ),
    Stream<TunnelsState> states = const Stream.empty(),
    Stream<OpenTunnel> tunnelRequests = const Stream.empty(),
    FakeAgent? agent,
  }) async {
    final bloc = _MockTunnelsBloc();
    whenListen(bloc, states, initialState: initialState);
    await tester.pumpWidget(
      MaterialApp(
        theme: takaTheme(Brightness.light),
        home: MultiBlocProvider(
          providers: [
            BlocProvider<TunnelsBloc>.value(value: bloc),
            BlocProvider(
              create: (_) => LoginPromptCubit(agent: agent ?? FakeAgent()),
            ),
          ],
          child: TunnelsPage(tunnelRequests: tunnelRequests),
        ),
      ),
    );
    return bloc;
  }

  group('a login prompt', () {
    const passphrase = LoginPrompt(
      id: 1,
      tunnelId: 'b2',
      prompt: SshPassphrasePrompt(
        "Enter passphrase for key '/home/me/.ssh/id_ed25519': ",
        keyPath: '/home/me/.ssh/id_ed25519',
      ),
    );

    Finder formUnder(String tunnel) => find.descendant(
      of: find.widgetWithText(TunnelTile, tunnel),
      matching: find.byType(LoginPromptForm),
    );

    testWidgets('opens under its tunnel, and goes once answered', (
      tester,
    ) async {
      final agent = FakeAgent();
      await pumpPage(tester, agent: agent);

      agent.promptsController.add(const [passphrase]);
      await tester.pumpAndSettle();
      expect(formUnder('Proxy'), findsOneWidget);
      expect(formUnder('Database'), findsNothing);
      expect(find.text('Passphrase for id_ed25519'), findsOneWidget);

      await tester.enterText(
        find.descendant(
          of: formUnder('Proxy'),
          matching: find.byType(TextField),
        ),
        'hunter2',
      );
      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle();

      expect(agent.sent.whereType<AnswerPrompt>(), const [
        AgentCommand.answer(1, 'hunter2'),
      ]);
      expect(find.byType(LoginPromptForm), findsNothing);
    });

    testWidgets('starts empty for the next prompt, and answers that one', (
      tester,
    ) async {
      final agent = FakeAgent();
      await pumpPage(tester, agent: agent);
      agent.promptsController.add(const [passphrase]);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'hunter2');

      agent.promptsController.add([passphrase.copyWith(id: 2)]);
      await tester.pumpAndSettle();

      expect(find.text('hunter2'), findsNothing);
      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle();
      expect(agent.sent.whereType<AnswerPrompt>(), const [
        AgentCommand.answer(2, ''),
      ]);
    });

    testWidgets('keeps what was typed when a form opens over the list', (
      tester,
    ) async {
      final agent = FakeAgent();
      await pumpPage(tester, agent: agent);
      agent.promptsController.add(const [passphrase]);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'hunt');

      await tester.tap(find.byTooltip('Add tunnel'));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(LoginPromptForm),
          matching: find.text('hunt'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('goes when the agent closes it', (tester) async {
      final agent = FakeAgent();
      await pumpPage(tester, agent: agent);
      agent.promptsController.add(const [passphrase]);
      await tester.pumpAndSettle();

      agent.promptsController.add(const []);
      await tester.pumpAndSettle();

      expect(find.byType(LoginPromptForm), findsNothing);
    });

    testWidgets('shows under the header, naming the tunnel, while a form '
        'is open, which stays as it was', (tester) async {
      final agent = FakeAgent();
      await pumpPage(tester, agent: agent);
      await tester.tap(find.byTooltip('Add tunnel'));
      await tester.pumpAndSettle();

      agent.promptsController.add(const [passphrase]);
      await tester.pumpAndSettle();

      expect(find.text('Log in to open Proxy'), findsOneWidget);
      expect(find.text('New tunnel'), findsOneWidget);

      await tester.tap(find.text('Cancel').first);
      await tester.pumpAndSettle();

      expect(agent.sent.whereType<AnswerPrompt>(), const [
        AgentCommand.answer(1, null),
      ]);
      expect(find.byType(LoginPromptForm), findsNothing);
      expect(find.text('New tunnel'), findsOneWidget);
    });

    testWidgets('for a tunnel not in the list, shows under the header', (
      tester,
    ) async {
      final agent = FakeAgent();
      await pumpPage(tester, agent: agent);

      agent.promptsController.add([passphrase.copyWith(tunnelId: 'gone')]);
      await tester.pumpAndSettle();

      expect(find.text('Log in to open a tunnel'), findsOneWidget);
      expect(formUnder('Proxy'), findsNothing);
    });
  });

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
              forward: SocksProxy(localPort: 6379),
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

    bool isInGroup(String name) =>
        tester
            .widget<TunnelTile>(
              find.ancestor(
                of: find.text(name),
                matching: find.byType(TunnelTile),
              ),
            )
            .guide !=
        null;
    expect(isInGroup('Database'), isTrue);
    expect(isInGroup('Cache'), isTrue);
    expect(isInGroup('Proxy'), isFalse);
  });

  group("a group's Edit", () {
    Future<_MockTunnelsBloc> pumpGrouped(WidgetTester tester) => pumpPage(
      tester,
      initialState: Ready(
        TunnelsSnapshot(
          tunnels: [
            database.copyWith(group: 'monolith'),
            proxy,
            const Tunnel(
              id: 'c3',
              name: 'Cache',
              forward: SocksProxy(localPort: 6379),
              group: 'monolith',
            ),
          ],
          groupColours: const {'monolith': TunnelColour.green},
        ),
      ),
    );

    Future<void> openEdit(WidgetTester tester) async {
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.text('monolith')));
      await tester.pump();
      await tester.tap(find.byTooltip('Edit monolith'));
      await tester.pumpAndSettle();
    }

    testWidgets('shows only while the header is hovered', (tester) async {
      await pumpGrouped(tester);
      bool shown() => tester
          .widget<Visibility>(
            find
                .ancestor(
                  of: find.byTooltip('Edit monolith'),
                  matching: find.byType(Visibility),
                )
                .first,
          )
          .visible;

      expect(shown(), isFalse);
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.text('monolith')));
      await tester.pump();
      expect(shown(), isTrue);

      await mouse.moveTo(Offset.zero);
      await tester.pump();
      expect(shown(), isFalse);
    });

    testWidgets('is reached from the keyboard', (tester) async {
      await pumpGrouped(tester);
      final edit = find.byTooltip('Edit monolith');
      bool focused() => Focus.of(tester.element(edit)).hasFocus;

      for (var press = 0; press < 20 && !focused(); press++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
      }
      expect(focused(), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(find.text('Edit group'), findsOneWidget);
    });

    testWidgets('closes when the group goes away', (tester) async {
      final states = StreamController<TunnelsState>();
      addTearDown(states.close);
      await pumpPage(
        tester,
        initialState: const Ready(
          TunnelsSnapshot(
            tunnels: [
              Tunnel(
                id: 'a1',
                forward: SocksProxy(localPort: 1),
                group: 'monolith',
              ),
            ],
          ),
        ),
        states: states.stream,
      );
      await openEdit(tester);
      expect(find.text('Edit group'), findsOneWidget);

      states.add(const Ready(TunnelsSnapshot(tunnels: [proxy])));
      await tester.pumpAndSettle();

      expect(find.text('Tunnels'), findsOneWidget);
    });

    testWidgets('names and colours the group in one save', (tester) async {
      final bloc = await pumpGrouped(tester);
      await openEdit(tester);

      expect(find.text('Edit group'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Monolith');
      await tester.tap(find.byTooltip('Blue'));
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      verify(
        () => bloc.add(
          const TunnelsEvent.send(
            AgentCommand.editGroup(
              'monolith',
              name: 'Monolith',
              colour: TunnelColour.blue,
            ),
          ),
        ),
      ).called(1);
      expect(find.text('Tunnels'), findsOneWidget);
    });

    testWidgets('opens on the group as it is', (tester) async {
      await pumpGrouped(tester);
      await openEdit(tester);

      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'monolith',
      );
      final selected = tester
          .widgetList<Semantics>(find.byType(Semantics))
          .where((semantics) => semantics.properties.selected ?? false);
      expect(selected, hasLength(1));
      expect(
        find.ancestor(
          of: find.byWidget(selected.single),
          matching: find.byTooltip('Green'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Esc or Cancel changes nothing', (tester) async {
      final bloc = await pumpGrouped(tester);
      await openEdit(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Tunnels'), findsOneWidget);

      await openEdit(tester);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Tunnels'), findsOneWidget);
      verifyNever(
        () => bloc.add(
          const TunnelsEvent.send(
            AgentCommand.editGroup(
              'monolith',
              name: 'monolith',
              colour: TunnelColour.green,
            ),
          ),
        ),
      );
    });

    testWidgets('a blank name turns Save off', (tester) async {
      await pumpGrouped(tester);
      await openEdit(tester);

      await tester.enterText(find.byType(TextField), '  ');
      await tester.pump();

      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).enabled,
        isFalse,
      );
    });

    testWidgets("the header's name isn't edited in place", (tester) async {
      await pumpGrouped(tester);

      await tester.tap(find.text('monolith'));
      await tester.pump();

      expect(find.byType(TextField), findsNothing);
    });
  });

  testWidgets("a group's guide line rounds at its first and last tunnel", (
    tester,
  ) async {
    await pumpPage(
      tester,
      initialState: Ready(
        TunnelsSnapshot(
          tunnels: [
            database.copyWith(group: 'Prod'),
            const Tunnel(
              id: 'c3',
              name: 'Cache',
              forward: SocksProxy(localPort: 1),
              group: 'Prod',
            ),
            const Tunnel(
              id: 'd4',
              name: 'Docs',
              forward: SocksProxy(localPort: 2),
              group: 'Prod',
            ),
            proxy.copyWith(group: 'Solo'),
          ],
        ),
      ),
    );
    (bool, bool)? endsOf(String name) => switch (tester
        .widget<TunnelTile>(
          find.ancestor(of: find.text(name), matching: find.byType(TunnelTile)),
        )
        .guide) {
      (:final isFirst, :final isLast, colour: _) => (isFirst, isLast),
      null => null,
    };

    expect(endsOf('Database'), (true, false));
    expect(endsOf('Cache'), (false, false));
    expect(endsOf('Docs'), (false, true));
    expect(endsOf('Proxy'), (true, true));
  });

  testWidgets("a group's header carries its tunnels when dragged", (
    tester,
  ) async {
    const cache = Tunnel(
      id: 'c3',
      name: 'Cache',
      forward: SocksProxy(localPort: 6379),
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

  testWidgets('a dragged tunnel shows the group it would land in', (
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
          groupColours: const {'Prod': TunnelColour.blue},
        ),
      ),
    );
    Finder tile(String name) =>
        find.ancestor(of: find.text(name), matching: find.byType(TunnelTile));
    TunnelTile lifted() => tester.widget<TunnelTile>(tile('Proxy').last);
    bool liftedIsInGroup() => lifted().guide != null;
    final colors = tester.element(find.byType(TunnelTile).first).theme;
    final into =
        tester.getCenter(find.byKey(const ValueKey('end Prod')).last).dy -
        1 -
        tester.getTopLeft(tile('Proxy')).dy;

    final drag = await tester.startGesture(
      tester.getCenter(find.text('Proxy')),
      kind: PointerDeviceKind.mouse,
    );
    for (var step = 0; step < 10; step++) {
      await drag.moveBy(Offset(0, into / 10));
      await tester.pump();
    }
    expect(liftedIsInGroup(), isTrue);
    // It takes the group's colour as its guide line, with no dot of its own.
    expect(lifted().guide?.colour, colors.tunnel(TunnelColour.blue));
    expect((lifted().guide?.isFirst, lifted().guide?.isLast), (false, false));
    expect(lifted().colour, isNull);

    for (var step = 0; step < 10; step++) {
      await drag.moveBy(Offset(0, -into / 10));
      await tester.pump();
    }
    expect(liftedIsInGroup(), isFalse);
    expect(lifted().colour, isNull);
    await drag.up();
    await tester.pumpAndSettle();

    verifyNever(
      () => bloc.add(
        const TunnelsEvent.send(
          AgentCommand.arrange([
            (id: 'a1', group: 'Prod'),
            (id: 'b2', group: 'Prod'),
          ]),
        ),
      ),
    );
  });

  testWidgets("a tunnel dropped above a group's gap joins it as its last", (
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
    Finder tile(String name) =>
        find.ancestor(of: find.text(name), matching: find.byType(TunnelTile));
    // Proxy's top just above the middle of the gap under Database.
    final distance =
        tester.getCenter(find.byKey(const ValueKey('end Prod')).last).dy -
        1 -
        tester.getTopLeft(tile('Proxy')).dy;

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
            (id: 'a1', group: 'Prod'),
            (id: 'b2', group: 'Prod'),
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
    "a coloured group's dot sits on its guide line, and its tunnels have none",
    (tester) async {
      await pumpPage(
        tester,
        initialState: Ready(
          TunnelsSnapshot(
            tunnels: [
              database.copyWith(group: 'Prod', colour: TunnelColour.red),
              proxy.copyWith(colour: TunnelColour.green),
            ],
            groupColours: const {'Prod': TunnelColour.blue},
          ),
        ),
      );
      final guide = find.descendant(
        of: find.ancestor(
          of: find.text('Database'),
          matching: find.byType(TunnelTile),
        ),
        matching: find.byType(GuideLine),
      );

      // The guide line is 2px wide.
      expect(
        tester
            .getCenter(
              find.descendant(
                of: find.byKey(const ValueKey('group Prod')),
                matching: find.byType(ColourDot),
              ),
            )
            .dx,
        tester.getTopLeft(guide).dx + 1,
      );
      final dots = tester.widgetList<ColourDot>(find.byType(ColourDot));
      expect(dots.map((dot) => dot.colour), [
        TunnelColour.blue,
        TunnelColour.green,
      ]);
    },
  );

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
