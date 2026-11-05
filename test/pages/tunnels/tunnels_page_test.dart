@Tags(['unit'])
library;

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taka/pages/tunnels/tunnels_bloc.dart';
import 'package:taka/pages/tunnels/tunnels_page.dart';
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

  testWidgets('dragging a tunnel moves it', (tester) async {
    final bloc = _MockTunnelsBloc();
    whenListen(
      bloc,
      const Stream<TunnelsState>.empty(),
      initialState: const Ready(TunnelsSnapshot(tunnels: [database, proxy])),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: takaTheme(Brightness.light),
        home: BlocProvider<TunnelsBloc>.value(
          value: bloc,
          child: const TunnelsPage(),
        ),
      ),
    );

    final drag = await tester.startGesture(
      tester.getCenter(find.text('Database')),
    );
    for (var step = 0; step < 8; step++) {
      await drag.moveBy(const Offset(0, 10));
      await tester.pump();
    }
    await drag.up();
    await tester.pumpAndSettle();

    verify(() => bloc.add(const TunnelsEvent.send(AgentCommand.move('a1', 1))))
        .called(1);
  });
}

class _MockTunnelsBloc extends MockBloc<TunnelsEvent, TunnelsState>
    implements TunnelsBloc {}
