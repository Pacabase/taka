import 'dart:convert';
import 'dart:io';

import 'package:core/src/paths.dart';
import 'package:core/src/tunnel.dart';
import 'package:core/src/tunnel_store.dart';

class LocalTunnelStore({required final File file}) implements TunnelStore {
  static const _version = 1;

  Future<void> _lastSave = Future.value();
  bool _isUnreadable = false;

  static LocalTunnelStore inTakaDirectory() =>
      LocalTunnelStore(file: File('${takaDirectory().path}/tunnels.json'));

  @override
  Future<({List<Tunnel> tunnels, Set<String> on})> load() async {
    if (!await file.exists()) return (tunnels: <Tunnel>[], on: <String>{});

    try {
      return switch (jsonDecode(await file.readAsString())) {
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
    } on FormatException {
      _isUnreadable = true;
      rethrow;
    }
  }

  @override
  Future<void> save(List<Tunnel> tunnels, {required Set<String> on}) {
    final saved = _lastSave.then((_) => _save(tunnels, on));
    _lastSave = saved.catchError((Object _) {});

    return saved;
  }

  Future<void> _save(List<Tunnel> tunnels, Set<String> on) async {
    // A newer Taka may have written it; losing its tunnels is worse than not saving.
    if (_isUnreadable) {
      throw FileSystemException(
        'Not overwriting a file Taka could not read',
        file.path,
      );
    }

    await file.parent.create(recursive: true);
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(
      const JsonEncoder.withIndent('  ').convert({
        'version': _version,
        'tunnels': tunnels.map((tunnel) => tunnel.toJson()).toList(),
        'on': [
          for (final tunnel in tunnels)
            if (on.contains(tunnel.id)) tunnel.id,
        ],
      }),
      flush: true,
    );
    await temporary.rename(file.path);
  }
}
