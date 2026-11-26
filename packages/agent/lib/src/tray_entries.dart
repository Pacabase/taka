import 'package:core/core.dart';

/// `toString` reads like the menu, so tests can compare whole menus.
sealed class const TrayEntry() {}

class const TunnelEntry(
  final Tunnel tunnel,
  final String label, {
  required final bool isChecked,
}) extends TrayEntry {
  @override
  String toString() => '${isChecked ? '☑' : '☐'} $label';
}

class const InfoEntry(final String label) extends TrayEntry {
  @override
  String toString() => label;
}

class const SeparatorEntry() extends TrayEntry {
  @override
  String toString() => '---';
}

class const CopyEntry(final String label, final String text) extends TrayEntry {
  @override
  String toString() => '$label ⧉ $text';
}

class const SubmenuEntry(final String label, final List<TrayEntry> entries)
    extends TrayEntry {
  @override
  String toString() => '$label ▸ ${entries.join(' | ')}';
}

enum TrayAction { connectAll, disconnectAll, addTunnel, manageTunnels, quit }

class const ActionEntry(
  final TrayAction action,
  final String label, {
  final String? shortcut,
}) extends TrayEntry {
  @override
  String toString() => [label, if (shortcut != null) '⌘$shortcut'].join(' ');
}

class const GroupActionEntry(
  final String group,
  final String label, {
  required final bool connects,
}) extends TrayEntry {
  @override
  String toString() => label;
}

enum TunnelAction { edit, tryAgain }

class const TunnelActionEntry(
  final Tunnel tunnel,
  final TunnelAction action,
  final String label,
) extends TrayEntry {
  @override
  String toString() => label;
}

/// [name] is the build's, so a dev build's menu says Quit Taka Dev.
List<TrayEntry> trayEntries(TunnelsSnapshot snapshot, {String name = 'Taka'}) {
  final tunnels = snapshot.tunnels;
  if (tunnels.isEmpty) {
    return [
      const InfoEntry('No tunnels yet'),
      const SeparatorEntry(),
      const ActionEntry(TrayAction.addTunnel, 'Add Tunnel…'),
      const SeparatorEntry(),
      ActionEntry(TrayAction.quit, 'Quit $name', shortcut: 'q'),
    ];
  }

  final statuses = snapshot.statuses.values;
  final failed = statuses.whereType<Failed>().length;
  final unknown = statuses
      .whereType<UnknownHostKey>()
      .map((status) => status.fingerprint)
      .toSet()
      .length;

  return [
    InfoEntry(
      [
        '${snapshot.connectedCount} of ${tunnels.length} connected',
        if (failed > 0) '$failed failed',
        if (unknown > 0) '$unknown ${unknown == 1 ? 'key' : 'keys'} to check',
      ].join(' · '),
    ),
    const SeparatorEntry(),
    for (final row in tunnels.rows)
      if (row case GroupHeaderRow(:final group))
        _groupEntry(group, snapshot)
      else if (row case TunnelRow(:final tunnel) when tunnel.group == null)
        _tunnelEntry(tunnel, snapshot.statusOf(tunnel.id)),
    const SeparatorEntry(),
    SubmenuEntry('Tunnel Actions', [
      for (final tunnel in tunnels.shown)
        SubmenuEntry(
          _shortened(tunnel.title),
          _tunnelActions(tunnel, snapshot.statusOf(tunnel.id), name),
        ),
    ]),
    if (tunnels.length > 1)
      statuses.any((status) => status.isOn)
          ? const ActionEntry(TrayAction.disconnectAll, 'Disconnect All')
          : const ActionEntry(TrayAction.connectAll, 'Connect All'),
    const SeparatorEntry(),
    const ActionEntry(TrayAction.manageTunnels, 'Manage Tunnels…'),
    ActionEntry(TrayAction.quit, 'Quit $name', shortcut: 'q'),
  ];
}

TrayEntry _groupEntry(String group, TunnelsSnapshot snapshot) {
  final members = snapshot.tunnels
      .where((tunnel) => tunnel.group == group)
      .toList();
  final connected = members
      .where((tunnel) => snapshot.statusOf(tunnel.id) is Connected)
      .length;

  return SubmenuEntry(
    // A long name gives way, not the count.
    switch (' — $connected of ${members.length} connected') {
      final count => '${_shortened(group, _width - count.length)}$count',
    },
    [
      for (final tunnel in members)
        _tunnelEntry(tunnel, snapshot.statusOf(tunnel.id)),
      if (members.length > 1) ...[
        const SeparatorEntry(),
        if (members.any((tunnel) => snapshot.statusOf(tunnel.id).isOn))
          GroupActionEntry(group, 'Disconnect All', connects: false)
        else
          GroupActionEntry(group, 'Connect All', connects: true),
      ],
    ],
  );
}

TrayEntry _tunnelEntry(Tunnel tunnel, TunnelStatus status) => TunnelEntry(
  tunnel,
  _shortened(switch (status) {
    Stopped() => tunnel.title,
    Connecting() => '${tunnel.title} — connecting…',
    Cancelled() => '${tunnel.title} — login cancelled',
    Connected() => switch (tunnel.forward) {
      RemoteForward(:final remotePort) =>
        '${tunnel.title} — port $remotePort on the server',
      LocalForward() ||
      SocketForward() ||
      SocksProxy() => '${tunnel.title} — ${tunnel.address}',
    },
    final Failed failure =>
      '${tunnel.title} — ${failureShort(tunnel, failure)}',
    Reconnecting() => '${tunnel.title} — reconnecting…',
    UnknownHostKey() => "${tunnel.title} — check the server's key",
  }),
  isChecked: status.isOn,
);

List<TrayEntry> _tunnelActions(
  Tunnel tunnel,
  TunnelStatus status,
  String name,
) {
  final whyDown = [
    if (status case Failed(:final failure) || Reconnecting(:final failure))
      InfoEntry(failureSentence(tunnel, failure)),
    if (status is Failed)
      TunnelActionEntry(tunnel, TunnelAction.tryAgain, 'Try Again'),
    if (status case UnknownHostKey(:final host))
      InfoEntry("Open $name to check $host's key."),
  ];
  return [
    ...whyDown,
    if (whyDown.isNotEmpty) const SeparatorEntry(),
    CopyEntry(
      tunnel.forward is RemoteForward
          ? 'Copy Address on the Server'
          : 'Copy Address',
      tunnel.address,
    ),
    if (tunnel.sshCommand case final command?)
      CopyEntry('Copy SSH Command', command),
    TunnelActionEntry(tunnel, TunnelAction.edit, 'Edit…'),
  ];
}

const _width = 50;

// A menu is as wide as its longest item, and wraps none.
String _shortened(String label, [int width = _width]) => label.length <= width
    ? label
    : '${label.substring(0, width - 1).trimRight()}…';

/// [name] tells a release's tray icon from a dev build's.
String trayTooltip(TunnelsSnapshot snapshot, {String name = 'Taka'}) =>
    switch (snapshot.connectedCount) {
      0 => name,
      final count => '$name · $count connected',
    };
