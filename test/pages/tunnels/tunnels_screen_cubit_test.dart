@Tags(['unit'])
library;

import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taka/pages/tunnels/tunnels_bloc.dart';
import 'package:taka/pages/tunnels/tunnels_screen_cubit.dart';

import 'fake_agent.dart';

void main() {
  const database = Tunnel(
    id: 'a1',
    sshHost: 'bastion',
    localPort: 15432,
    remoteHost: 'db.internal',
    remotePort: 5432,
    group: 'Work',
  );
  late FakeAgent agent;
  late TunnelsBloc tunnels;
  late StreamController<OpenTunnel> requests;
  late TunnelsScreenCubit cubit;

  setUp(() {
    agent = FakeAgent();
    tunnels = TunnelsBloc(agent: agent)..add(const TunnelsEvent.started());
    requests = StreamController<OpenTunnel>();
    cubit = TunnelsScreenCubit(
      tunnels: tunnels,
      tunnelRequests: requests.stream,
      sshHosts: () async => ['bastion', 'web'],
    );
    addTearDown(() async {
      await cubit.close();
      await requests.close();
      await tunnels.close();
    });
  });

  Future<void> snapshot(List<Tunnel> list) async {
    agent.controller.add(TunnelsSnapshot(tunnels: list));
    await pumpEventQueue();
  }

  test('starts on the list and names itself', () {
    expect(cubit.state, const TunnelsScreenState());
    expect('$cubit', 'TunnelsScreenCubit');
  });

  test('opening a form reads the SSH hosts for it', () async {
    cubit.openTunnel(null, TunnelKind.socks);
    await pumpEventQueue();

    expect(cubit.state.screen, const NewTunnelScreen(TunnelKind.socks));
    expect(cubit.state.hosts, ['bastion', 'web']);
  });

  test('closing a form goes back to the list', () {
    cubit
      ..openTunnel(database)
      ..closeForm();

    expect(cubit.state.screen, const ListScreen());
  });

  test("the tray's request opens a tunnel's form and counts", () async {
    await snapshot([database]);

    requests.add(const OpenTunnel('a1'));
    await pumpEventQueue();

    expect(cubit.state.screen, const EditTunnelScreen(database));
    expect(cubit.state.requests, 1);
  });

  test("the tray's request for a new tunnel opens a new form", () async {
    await snapshot([database]);

    requests.add(const OpenTunnel());
    await pumpEventQueue();

    expect(cubit.state.screen, const NewTunnelScreen(TunnelKind.local));
    expect(cubit.state.requests, 1);
  });

  test('hosts read after it closes are dropped', () async {
    final hosts = Completer<List<String>>();
    final closing = TunnelsScreenCubit(
      tunnels: tunnels,
      tunnelRequests: const Stream.empty(),
      sshHosts: () => hosts.future,
    )..openTunnel();

    await closing.close();
    hosts.complete(['bastion']);
    await pumpEventQueue();

    expect(closing.state.hosts, isEmpty);
  });

  test('a request before the first snapshot opens once it comes', () async {
    requests.add(const OpenTunnel('a1'));
    await pumpEventQueue();
    expect(cubit.state.screen, const ListScreen());

    await snapshot([database]);

    expect(cubit.state.screen, const EditTunnelScreen(database));
  });

  test('a request for a tunnel that is gone changes nothing', () async {
    await snapshot([database]);

    requests.add(const OpenTunnel('gone'));
    await pumpEventQueue();

    expect(cubit.state, const TunnelsScreenState());
  });

  test("a group's form closes when its last tunnel goes", () async {
    await snapshot([database]);
    cubit.editGroup('Work', null);

    await snapshot([database.copyWith(group: 'Home')]);

    expect(cubit.state.screen, const ListScreen());
  });

  test("a group's form stays while the group has tunnels", () async {
    await snapshot([database]);
    cubit.editGroup('Work', null);

    await snapshot([database.copyWith(name: 'Renamed')]);

    expect(cubit.state.screen, const EditGroupScreen('Work', null));
  });
}
