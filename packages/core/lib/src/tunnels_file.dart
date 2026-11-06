import 'dart:convert';

import 'package:core/src/tunnel.dart';

const _version = 1;

String encodeTunnels(List<Tunnel> tunnels, {Set<String> on = const {}}) =>
    const JsonEncoder.withIndent('  ').convert({
      'version': _version,
      'tunnels': tunnels.map((tunnel) => tunnel.toJson()).toList(),
      'on': [
        for (final tunnel in tunnels)
          if (on.contains(tunnel.id)) tunnel.id,
      ],
    });

/// Reads what [encodeTunnels] wrote, or throws a [FormatException].
({List<Tunnel> tunnels, Set<String> on}) decodeTunnels(String text) =>
    switch (jsonDecode(text)) {
      {'version': _version, 'tunnels': final List<Object?> tunnels} &&
          final Map<Object?, Object?> saved =>
        (
          tunnels: tunnels.map(Tunnel.fromJson).toList(),
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
