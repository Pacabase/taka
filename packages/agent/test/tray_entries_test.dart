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

  test('with no tunnels says so, and has nothing to connect', () {
    expect(menu(const TunnelsSnapshot()), [
      'No tunnels yet',
      '---',
      'Copy Address ▸ Nothing connected',
      'Connect All (off)',
      'Disconnect All (off)',
      '---',
      'About Taka',
      '☐ Debug Logging',
      'Settings… ⌘,',
      'Quit Taka ⌘q',
    ]);
  });

  test('shows each tunnel with how it is doing', () {
    const snapshot = TunnelsSnapshot(
      tunnels: [database, proxy, web, other],
      statuses: {
        'a1': Connected(),
        'b2': Connecting(),
        'c3': Failed('127.0.0.1:8080 is already in use'),
        'd4': Reconnecting('Connection to bastion closed by remote host.'),
      },
    );

    expect(menu(snapshot), [
      '☑ Production database — localhost:15432',
      '☑ Proxy — connecting…',
      '☐ Web — failed',
      '    127.0.0.1:8080 is already in use',
      '☑ Other — reconnecting…',
      '    Connection to bastion closed by remote host.',
      '---',
      'Copy Address ▸ Production database — localhost:15432 ⧉ localhost:15432',
      'Copy SSH Command ▸ ${['Production database ⧉ ssh -N -L 127.0.0.1:15432:db.internal:5432 bastion', 'Proxy ⧉ ssh -N -D 127.0.0.1:1080 bastion', 'Web ⧉ ssh -N -L 127.0.0.1:8080::0 web', 'Other ⧉ ssh -N -L 127.0.0.1:8081::0 web'].join(' | ')}',
      'Connect All',
      'Disconnect All',
      '---',
      'About Taka',
      '☐ Debug Logging',
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

  test('with debug logging on, it is checked and Show Logs appears', () {
    final entries = trayEntries(const TunnelsSnapshot(), isLogging: true);

    expect(
      entries
          .map((entry) => '$entry')
          .skipWhile((line) => line != 'About Taka'),
      [
        'About Taka',
        '☑ Debug Logging',
        'Show Logs',
        'Settings… ⌘,',
        'Quit Taka ⌘q',
      ],
    );
  });

  test('Launch at Login shows whether it is on, where it is offered', () {
    List<String> withLaunch(bool? launches) => [
      for (final entry in trayEntries(
        const TunnelsSnapshot(),
        launchesAtLogin: launches,
      ))
        if ('$entry'.contains('Launch at Login')) '$entry',
    ];

    expect(withLaunch(null), isEmpty);
    expect(withLaunch(false), ['☐ Launch at Login']);
    expect(withLaunch(true), ['☑ Launch at Login']);
  });

  test('Launch at Login comes right after About', () {
    final labels = [
      for (final entry in trayEntries(
        const TunnelsSnapshot(),
        launchesAtLogin: false,
      ))
        '$entry',
    ];

    expect(
      labels.indexOf('☐ Launch at Login'),
      labels.indexOf('About Taka') + 1,
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
