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

  test("says which tunnel waits for its server's key to be checked", () {
    const waiting = UnknownHostKey(
      host: 'web',
      type: 'ED25519',
      fingerprint: 'SHA256:4Q0Hx2v6PZ9dW1yYk0r6hN1m1bGq9cY',
    );
    const snapshot = TunnelsSnapshot(
      tunnels: [database, web],
      statuses: {'c3': waiting},
    );

    expect(menu(snapshot).take(4), [
      '0 of 2 connected · 1 key to check',
      '---',
      '☐ Production database',
      "☐ Web — check the server's key",
    ]);
    expect(
      menu(
        snapshot.copyWith(
          statuses: {
            'a1': waiting,
            'c3': waiting,
            'd4': waiting.copyWith(fingerprint: 'SHA256:other'),
          },
        ),
      ).first,
      '0 of 2 connected · 2 keys to check',
    );
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
      'Port 8080 is already in use. | '
      'Try Again | '
      '--- | '
      'Copy Address ⧉ localhost:8080 | '
      'Copy SSH Command ⧉ ssh -N -L 127.0.0.1:8080::0 web | '
      'Edit… | '
      'Other ▸ '
      'The connection dropped. | '
      '--- | '
      'Copy Address ⧉ localhost:8081 | '
      'Copy SSH Command ⧉ ssh -N -L 127.0.0.1:8081::0 web | '
      'Edit…',
    );
  });

  test("says plainly why a tunnel is down, never in ssh's words", () {
    String actionsWhen(TunnelStatus status) => tunnelActions(
      TunnelsSnapshot(tunnels: [web], statuses: {'c3': status}),
    );

    expect(
      actionsWhen(const Failed('Bad state: boom')),
      startsWith("Tunnel Actions ▸ Web ▸ It couldn't connect. | Try Again"),
    );
    expect(
      actionsWhen(const Failed('')),
      startsWith("Tunnel Actions ▸ Web ▸ It couldn't connect. | Try Again"),
    );
    expect(
      actionsWhen(
        const UnknownHostKey(
          host: 'web',
          type: 'ED25519',
          fingerprint: 'SHA256:4Q0Hx2v6PZ9dW1yYk0r6hN1m1bGq9cY',
        ),
      ),
      startsWith(
        "Tunnel Actions ▸ Web ▸ Open Taka to check web's key. | --- | Copy",
      ),
    );
    expect(
      actionsWhen(const Reconnecting('Timeout, server web not responding.')),
      startsWith(
        'Tunnel Actions ▸ Web ▸ The server stopped answering. | --- | Copy',
      ),
    );
  });

  test('offers no ssh command for a tunnel ssh cannot open', () {
    const snapshot = TunnelsSnapshot(
      tunnels: [Tunnel(id: 'd4', name: 'Broken', sshHost: 'web', localPort: 0)],
    );

    expect(
      tunnelActions(snapshot),
      'Tunnel Actions ▸ Broken ▸ Copy Address ⧉ localhost:0 | Edit…',
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

  test('cuts a long title to fit', () {
    const long = Tunnel(
      id: 'e5',
      name: 'A very long tunnel name that would make the menu wide',
      sshHost: 'web',
      localPort: 8082,
    );

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
        "It couldn't connect. | Try Again",
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
