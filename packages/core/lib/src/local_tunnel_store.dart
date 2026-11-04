import 'dart:convert';
import 'dart:io';

import 'package:core/src/paths.dart';
import 'package:core/src/tunnel.dart';
import 'package:core/src/tunnel_store.dart';

class LocalTunnelStore({required final File file}) implements TunnelStore {
  static const _version = 1;

  Future<void> _previousSave = Future.value();

  static LocalTunnelStore inTakaDirectory() => LocalTunnelStore(
    file: File('${takaDirectory().path}${Platform.pathSeparator}tunnels.json'),
  );

  @override
  Future<List<Tunnel>> load() async {
    if (!await file.exists()) return [];

    final json = jsonDecode(await file.readAsString()) as Map<String, Object?>;
    final version = json['version'];
    if (version != _version) {
      throw FormatException('Unsupported tunnels file version: $version');
    }

    return (json['tunnels']! as List<Object?>)
        .cast<Map<String, Object?>>()
        .map(Tunnel.fromJson)
        .toList();
  }

  @override
  Future<void> save(List<Tunnel> tunnels) {
    final saved = _previousSave.then((_) => _save(tunnels));
    _previousSave = saved.then<void>((_) {}, onError: (Object _) {});

    return saved;
  }

  Future<void> _save(List<Tunnel> tunnels) async {
    await file.parent.create(recursive: true);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert({
        'version': _version,
        'tunnels': tunnels.map((tunnel) => tunnel.toJson()).toList(),
      }),
    );
  }
}
