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

  List<String> menu(TunnelsSnapshot snapshot) =>
      trayEntries(snapshot).map((entry) => '$entry').toList();

  test('with no tunnels says so, and has nothing to connect', () {
    expect(menu(const TunnelsSnapshot()), [
      'No tunnels yet',
      '---',
      'Copy Address ▸ Nothing connected',
      'Connect All (off)',
      'Disconnect All (off)',
      '---',
      'Settings… ⌘,',
      'Quit Taka ⌘q',
    ]);
  });

  test('shows each tunnel with how it is doing', () {
    const snapshot = TunnelsSnapshot(
      tunnels: [database, proxy, web],
      statuses: {
        'a1': Connected(),
        'b2': Connecting(),
        'c3': Failed('127.0.0.1:8080 is already in use'),
      },
    );

    expect(menu(snapshot), [
      '☑ Production database — localhost:15432',
      '☑ Proxy — connecting…',
      '☐ Web — failed',
      '    127.0.0.1:8080 is already in use',
      '---',
      'Copy Address ▸ Production database — localhost:15432 ⧉ localhost:15432',
      'Connect All',
      'Disconnect All',
      '---',
      'Settings… ⌘,',
      'Quit Taka ⌘q',
    ]);
  });

  test('a stopped tunnel shows only its title', () {
    expect(menu(const TunnelsSnapshot(tunnels: [proxy])).first, '☐ Proxy');
  });

  test('Connect All is off once everything is on', () {
    const snapshot = TunnelsSnapshot(
      tunnels: [database, proxy],
      statuses: {'a1': Connected(), 'b2': Connected()},
    );

    expect(
      menu(snapshot),
      containsAll(['Connect All (off)', 'Disconnect All']),
    );
    expect(
      menu(snapshot),
      contains(
        'Copy Address ▸ Production database — localhost:15432 ⧉ localhost:15432'
        ' | Proxy — socks5h://localhost:1080 ⧉ socks5h://localhost:1080',
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
}
