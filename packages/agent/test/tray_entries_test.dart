@Tags(['unit'])
library;

import 'package:agent/src/tray_entries.dart';
import 'package:core/core.dart';
import 'package:test/test.dart';

void main() {
  const database = Tunnel(
    id: 'a1',
    name: 'Production database',
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
  const web = Tunnel(id: 'c3', name: 'Web', sshHost: 'web', localPort: 8080);
  const other = Tunnel(
    id: 'd4',
    name: 'Other',
    sshHost: 'web',
    localPort: 8081,
  );

  List<String> menu(TunnelsSnapshot snapshot) =>
      trayEntries(snapshot).map((entry) => '$entry').toList();

  String tunnelActions(TunnelsSnapshot snapshot) =>
      menu(snapshot).firstWhere((line) => line.startsWith('Tunnel Actions'));

  test('with no tunnels, offers only to add one', () {
    expect(menu(const TunnelsSnapshot()), [
      'No tunnels yet',
      '---',
      'Add Tunnel…',
      '---',
      'Quit Taka ⌘q',
    ]);
  });

  test('says how the tunnels are doing, one line each', () {
    const snapshot = TunnelsSnapshot(
      tunnels: [database, proxy, web, other],
      statuses: {
        'a1': Connected(),
        'b2': Connecting(),
        'c3': Failed('127.0.0.1:8080 is already in use'),
        'd4': Reconnecting('Connection to bastion closed by remote host.'),
      },
    );

    expect(menu(snapshot).take(7), [
      '1 of 4 connected · 1 failed',
      '---',
      '☑ Production database — localhost:15432',
      '☑ Proxy — connecting…',
      '☐ Web — port 8080 in use',
      '☑ Other — reconnecting…',
      '---',
    ]);
  });

  test('keeps each tunnel to its actions, and why it is down', () {
    const snapshot = TunnelsSnapshot(
      tunnels: [database, web, other],
      statuses: {
        'c3': Failed('127.0.0.1:8080 is already in use'),
        'd4': Reconnecting('Connection to bastion closed by remote host.'),
      },
    );

    expect(
      tunnelActions(snapshot),
      'Tunnel Actions ▸ '
      'Production database ▸ '
      'Copy Address ⧉ localhost:15432 | '
      'Copy SSH Command ⧉ '
      'ssh -N -L 127.0.0.1:15432:db.internal:5432 bastion | '
      'Edit… | '
      'Web ▸ '
      '127.0.0.1:8080 is already in use | '
      'Try Again | '
      '--- | '
      'Copy Address ⧉ localhost:8080 | '
      'Copy SSH Command ⧉ ssh -N -L 127.0.0.1:8080::0 web | '
      'Edit… | '
      'Other ▸ '
      'Connection to bastion closed by remote host. | '
      '--- | '
      'Copy Address ⧉ localhost:8081 | '
      'Copy SSH Command ⧉ ssh -N -L 127.0.0.1:8081::0 web | '
      'Edit…',
    );
  });

  test('a tunnel down for no stated reason starts its actions plainly', () {
    String actionsWhen(TunnelStatus status) => tunnelActions(
      TunnelsSnapshot(tunnels: [web], statuses: {'c3': status}),
    );

    expect(
      actionsWhen(const Reconnecting('')),
      startsWith('Tunnel Actions ▸ Web ▸ Copy Address'),
    );
    expect(
      actionsWhen(const Failed('')),
      startsWith('Tunnel Actions ▸ Web ▸ Try Again | --- | Copy Address'),
    );
  });

  test('ends with Disconnect All while any is on, and the window', () {
    const snapshot = TunnelsSnapshot(
      tunnels: [database, proxy],
      statuses: {'a1': Connected()},
    );

    expect(
      menu(snapshot)
          .skipWhile((line) => !line.startsWith('Tunnel Actions'))
          .skip(1),
      ['Disconnect All', '---', 'Manage Tunnels…', 'Quit Taka ⌘q'],
    );
  });

  test('offers Connect All while all are off, and neither for one', () {
    expect(
      menu(const TunnelsSnapshot(tunnels: [database, proxy])),
      contains('Connect All'),
    );
    expect(
      menu(const TunnelsSnapshot(tunnels: [database])),
      isNot(anyOf(contains('Connect All'), contains('Disconnect All'))),
    );
  });

  test('cuts a long title to fit, and wraps a long reason', () {
    const long = Tunnel(
      id: 'e5',
      name: 'A very long tunnel name that would make the menu wide',
      sshHost: 'web',
      localPort: 8082,
    );
    final line = List.filled(10, 'word').join(' ');

    final snapshot = TunnelsSnapshot(
      tunnels: [long],
      statuses: {'e5': Failed('word ' * 30)},
    );

    expect(
      menu(snapshot)[2],
      '☐ A very long tunnel name that would make the menu…',
    );
    expect(
      tunnelActions(snapshot),
      startsWith(
        'Tunnel Actions ▸ A very long tunnel name that would make the menu… ▸ '
        '$line | $line | $line | Try Again',
      ),
    );
  });

  test('splits a word too long for a line, rather than cutting it', () {
    final host = 'a' * 60;

    expect(
      tunnelActions(
        TunnelsSnapshot(
          tunnels: [web],
          statuses: {'c3': Failed('Could not resolve $host')},
        ),
      ),
      startsWith(
        'Tunnel Actions ▸ Web ▸ Could not resolve | ${'a' * 50} | ${'a' * 10} |',
      ),
    );
  });

  test('the tooltip counts connected tunnels', () {
    expect(trayTooltip(const TunnelsSnapshot()), 'Taka');
    expect(
      trayTooltip(
        const TunnelsSnapshot(
          tunnels: [database],
          statuses: {'a1': Connected()},
        ),
      ),
      'Taka · 1 connected',
    );
  });

  test('each tunnel line toggles its own tunnel', () {
    final entries = trayEntries(
      const TunnelsSnapshot(tunnels: [database, proxy]),
    );

    expect(entries.whereType<TunnelEntry>().map((entry) => entry.tunnel.id), [
      'a1',
      'b2',
    ]);
  });

  test("each tunnel's Edit… opens its own tunnel", () {
    final entries = trayEntries(
      const TunnelsSnapshot(tunnels: [database, proxy]),
    );

    expect(
      [
        for (final SubmenuEntry(:entries) in entries.whereType<SubmenuEntry>())
          for (final SubmenuEntry(:entries)
              in entries.whereType<SubmenuEntry>())
            for (final entry in entries.whereType<TunnelActionEntry>())
              if (entry.action == TunnelAction.edit) entry.tunnel.id,
      ],
      ['a1', 'b2'],
    );
  });
}
