import 'dart:convert';

import 'package:core/src/tunnel.dart';
import 'package:core/src/tunnel_book.dart';
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

String encodeTunnels(TunnelBook book, {Set<String> on = const {}}) =>
    const JsonEncoder.withIndent('  ').convert({
      'version': _versionOf(book.tunnels),
      'tunnels': book.tunnels.map((tunnel) => tunnel.toJson()).toList(),
      'on': [
        for (final tunnel in book.tunnels)
          if (on.contains(tunnel.id)) tunnel.id,
      ],
      if (book.groupColours.isNotEmpty)
        'groupColours': groupColoursToJson(book.groupColours),
    });

/// Reads what [encodeTunnels] wrote, or throws a [FormatException].
SavedTunnels decodeTunnels(String text) => switch (jsonDecode(text)) {
  {'version': 1 || 2, 'tunnels': final List<Object?> tunnels} &&
      final Map<Object?, Object?> saved =>
    (
      book: TunnelBook(
        tunnels: tunnels.map(Tunnel.fromJson).toList(),
        groupColours: groupColoursFromJson(saved['groupColours']),
      ),
      on: switch (saved['on']) {
        final List<Object?> on => on.whereType<String>().toSet(),
        _ => <String>{},
      },
    ),
  {'version': final version} => throw FormatException(
    'Unsupported tunnels file version: $version',
  ),
  _ => throw const FormatException('Not a tunnels file'),
};
