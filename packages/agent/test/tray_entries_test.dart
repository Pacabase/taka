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
      '☐ Web — failed',
      '☑ Other — reconnecting…',
      '---',
    ]);
  });

  test('keeps each tunnel to its actions, and why it failed', () {
    const snapshot = TunnelsSnapshot(
      tunnels: [database, web],
      statuses: {'c3': Failed('127.0.0.1:8080 is already in use')},
    );

    expect(
      menu(snapshot).firstWhere((line) => line.startsWith('Tunnel Actions')),
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
      'Edit…',
    );
  });

  test('ends with Disconnect All while any is on, and the window', () {
    const snapshot = TunnelsSnapshot(
      tunnels: [database, proxy],
      statuses: {'a1': Connected()},
    );

    expect(menu(snapshot).skip(5).skip(1), [
      'Disconnect All',
      '---',
      'Manage Tunnels…',
      'Quit Taka ⌘q',
    ]);
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
    final reason = 'word ' * 30;

    final lines = menu(
      TunnelsSnapshot(tunnels: [long], statuses: {'e5': Failed(reason)}),
    );

    expect(lines[2], '☐ A very long tunnel name that would make the menu…');
    expect(wrapped(reason), everyElement(hasLength(lessThanOrEqualTo(50))));
    expect(wrapped(reason).join(' '), reason.trim());
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
}
