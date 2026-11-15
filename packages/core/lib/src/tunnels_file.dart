import 'dart:convert';

import 'package:core/src/tunnel.dart';
import 'package:core/src/tunnel_colour.dart';
import 'package:core/src/tunnel_store.dart';

// Version 1 builds would save remote and socket tunnels back as local ones.
int _versionOf(List<Tunnel> tunnels) =>
    tunnels.any(
      (tunnel) =>
          tunnel.kind == TunnelKind.remote || tunnel.remoteSocket != null,
    )
    ? 2
    : 1;

String encodeTunnels(
  List<Tunnel> tunnels, {
  Set<String> on = const {},
  Map<String, TunnelColour> groupColours = const {},
}) => const JsonEncoder.withIndent('  ').convert({
  'version': _versionOf(tunnels),
  'tunnels': tunnels.map((tunnel) => tunnel.toJson()).toList(),
  'on': [
    for (final tunnel in tunnels)
      if (on.contains(tunnel.id)) tunnel.id,
  ],
  if (groupColours.isNotEmpty) 'groupColours': groupColoursToJson(groupColours),
});

/// Reads what [encodeTunnels] wrote, or throws a [FormatException].
SavedTunnels decodeTunnels(String text) => switch (jsonDecode(text)) {
  {'version': 1 || 2, 'tunnels': final List<Object?> tunnels} &&
      final Map<Object?, Object?> saved =>
    (
      tunnels: tunnels.map(Tunnel.fromJson).toList(),
      on: switch (saved['on']) {
        final List<Object?> on => on.whereType<String>().toSet(),
        _ => <String>{},
      },
      groupColours: groupColoursFromJson(saved['groupColours']),
    ),
  {'version': final version} => throw FormatException(
    'Unsupported tunnels file version: $version',
  ),
  _ => throw const FormatException('Not a tunnels file'),
};
