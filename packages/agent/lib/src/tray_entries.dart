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

enum TrayAction { connectAll, disconnectAll, about, settings, quit }

class const ActionEntry(
  final TrayAction action,
  final String label, {
  final bool isEnabled = true,
  final String? shortcut,
}) extends TrayEntry {
  @override
  String toString() =>
      '$label${shortcut == null ? '' : ' ⌘$shortcut'}${isEnabled ? '' : ' (off)'}';
}

List<TrayEntry> trayEntries(TunnelsSnapshot snapshot) {
  final tunnels = snapshot.tunnels;
  final connected = tunnels
      .where((tunnel) => snapshot.statusOf(tunnel.id) is Connected)
      .toList();
  bool isOn(Tunnel tunnel) => snapshot.statusOf(tunnel.id).isOn;

  return [
    for (final tunnel in tunnels)
      ..._tunnelEntries(tunnel, snapshot.statusOf(tunnel.id)),
    if (tunnels.isEmpty) const InfoEntry('No tunnels yet'),
    const SeparatorEntry(),
    SubmenuEntry('Copy Address', [
      for (final tunnel in connected)
        CopyEntry('${tunnel.title} — ${tunnel.address}', tunnel.address),
      if (connected.isEmpty) const InfoEntry('Nothing connected'),
    ]),
    ActionEntry(
      TrayAction.connectAll,
      'Connect All',
      isEnabled: !tunnels.every(isOn),
    ),
    ActionEntry(
      TrayAction.disconnectAll,
      'Disconnect All',
      isEnabled: tunnels.any(isOn),
    ),
    const SeparatorEntry(),
    const ActionEntry(TrayAction.about, 'About Taka'),
    const ActionEntry(TrayAction.settings, 'Settings…', shortcut: ','),
    const ActionEntry(TrayAction.quit, 'Quit Taka', shortcut: 'q'),
  ];
}

List<TrayEntry> _tunnelEntries(Tunnel tunnel, TunnelStatus status) => [
  TunnelEntry(tunnel, switch (status) {
    Stopped() => tunnel.title,
    Connecting() => '${tunnel.title} — connecting…',
    Connected() => '${tunnel.title} — ${tunnel.address}',
    Failed() => '${tunnel.title} — failed',
  }, isChecked: status.isOn),
  if (status case Failed(:final message)) InfoEntry('    $message'),
];

String trayTooltip(TunnelsSnapshot snapshot) =>
    switch (snapshot.connectedCount) {
      0 => 'Taka',
      final count => 'Taka · $count connected',
    };
