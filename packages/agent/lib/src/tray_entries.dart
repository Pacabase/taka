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

  final failed = tunnels
      .where((tunnel) => snapshot.statusOf(tunnel.id) is Failed)
      .length;

  return [
    InfoEntry(
      [
        '${snapshot.connectedCount} of ${tunnels.length} connected',
        if (failed > 0) '$failed failed',
      ].join(' · '),
    ),
    const SeparatorEntry(),
    for (final tunnel in tunnels)
      _tunnelEntry(tunnel, snapshot.statusOf(tunnel.id)),
    const SeparatorEntry(),
    SubmenuEntry('Tunnel Actions', [
      for (final tunnel in tunnels)
        SubmenuEntry(
          _shortened(tunnel.title),
          _tunnelActions(tunnel, snapshot.statusOf(tunnel.id)),
        ),
    ]),
    if (tunnels.length > 1)
      tunnels.any((tunnel) => snapshot.statusOf(tunnel.id).isOn)
          ? const ActionEntry(TrayAction.disconnectAll, 'Disconnect All')
          : const ActionEntry(TrayAction.connectAll, 'Connect All'),
    const SeparatorEntry(),
    const ActionEntry(TrayAction.manageTunnels, 'Manage Tunnels…'),
    const ActionEntry(TrayAction.quit, 'Quit Taka', shortcut: 'q'),
  ];
}

TrayEntry _tunnelEntry(Tunnel tunnel, TunnelStatus status) => TunnelEntry(
  tunnel,
  _shortened(switch (status) {
    Stopped() => tunnel.title,
    Connecting() => '${tunnel.title} — connecting…',
    Connected() => '${tunnel.title} — ${tunnel.address}',
    Failed() => '${tunnel.title} — failed',
    Reconnecting() => '${tunnel.title} — reconnecting…',
  }),
  isChecked: status.isOn,
);

List<TrayEntry> _tunnelActions(Tunnel tunnel, TunnelStatus status) => [
  if (status
      case Failed(message: final reason) || Reconnecting(:final reason)) ...[
    for (final line in wrapped(reason)) InfoEntry(line),
    if (status is Failed)
      TunnelActionEntry(tunnel, TunnelAction.tryAgain, 'Try Again'),
    const SeparatorEntry(),
  ],
  CopyEntry('Copy Address', tunnel.address),
  CopyEntry('Copy SSH Command', tunnel.sshCommand),
  TunnelActionEntry(tunnel, TunnelAction.edit, 'Edit…'),
];

const _width = 50;

// A menu is as wide as its longest item, and wraps none.
String _shortened(String label) => label.length <= _width
    ? label
    : '${label.substring(0, _width - 1).trimRight()}…';

/// [text] in lines of at most [width] characters, broken between words.
List<String> wrapped(String text, {int width = _width}) => text
    .split(RegExp(r'\s+'))
    .where((word) => word.isNotEmpty)
    .fold<List<String>>([], (lines, word) {
      final last = lines.isEmpty ? null : lines.last;
      return last != null && last.length + 1 + word.length <= width
          ? [...lines.take(lines.length - 1), '$last $word']
          : [...lines, _shortened(word)];
    });

String trayTooltip(TunnelsSnapshot snapshot) =>
    switch (snapshot.connectedCount) {
      0 => 'Taka',
      final count => 'Taka · $count connected',
    };
