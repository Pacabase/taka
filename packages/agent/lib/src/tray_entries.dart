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

List<TrayEntry> trayEntries(TunnelsSnapshot snapshot) {
  final tunnels = snapshot.tunnels;
  if (tunnels.isEmpty) {
    return const [
      InfoEntry('No tunnels yet'),
      SeparatorEntry(),
      ActionEntry(TrayAction.addTunnel, 'Add Tunnel…'),
      SeparatorEntry(),
      ActionEntry(TrayAction.quit, 'Quit Taka', shortcut: 'q'),
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
    for (final tunnel in tunnels.where((tunnel) => tunnel.group == null))
      _tunnelEntry(tunnel, snapshot.statusOf(tunnel.id)),
    for (final group in tunnels.groups) _groupEntry(group, snapshot),
    const SeparatorEntry(),
    SubmenuEntry('Tunnel Actions', [
      for (final tunnel in tunnels.shown)
        SubmenuEntry(
          _shortened(tunnel.title),
          _tunnelActions(tunnel, snapshot.statusOf(tunnel.id)),
        ),
    ]),
    if (tunnels.length > 1)
      statuses.any((status) => status.isOn)
          ? const ActionEntry(TrayAction.disconnectAll, 'Disconnect All')
          : const ActionEntry(TrayAction.connectAll, 'Connect All'),
    const SeparatorEntry(),
    const ActionEntry(TrayAction.manageTunnels, 'Manage Tunnels…'),
    const ActionEntry(TrayAction.quit, 'Quit Taka', shortcut: 'q'),
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
    _shortened('$group — $connected of ${members.length} connected'),
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
    Connected() when tunnel.kind == TunnelKind.remote =>
      '${tunnel.title} — port ${tunnel.remotePort} on the server',
    Connected() => '${tunnel.title} — ${tunnel.address}',
    Failed(:final message) => '${tunnel.title} — ${shortReason(message)}',
    Reconnecting() => '${tunnel.title} — reconnecting…',
    UnknownHostKey() => "${tunnel.title} — check the server's key",
  }),
  isChecked: status.isOn,
);

List<TrayEntry> _tunnelActions(Tunnel tunnel, TunnelStatus status) {
  final whyDown = [
    if (status
        case Failed(message: final reason) || Reconnecting(:final reason))
      InfoEntry(plainReason(reason)),
    if (status is Failed)
      TunnelActionEntry(tunnel, TunnelAction.tryAgain, 'Try Again'),
    if (status case UnknownHostKey(:final host))
      InfoEntry("Open Taka to check $host's key."),
  ];
  return [
    ...whyDown,
    if (whyDown.isNotEmpty) const SeparatorEntry(),
    CopyEntry(
      tunnel.kind == TunnelKind.remote
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
String _shortened(String label) => label.length <= _width
    ? label
    : '${label.substring(0, _width - 1).trimRight()}…';

String trayTooltip(TunnelsSnapshot snapshot) =>
    switch (snapshot.connectedCount) {
      0 => 'Taka',
      final count => 'Taka · $count connected',
    };
