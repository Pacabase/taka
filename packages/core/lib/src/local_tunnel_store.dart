import 'dart:io';

import 'package:core/src/paths.dart';
import 'package:core/src/tunnel_book.dart';
import 'package:core/src/tunnel_store.dart';
import 'package:core/src/tunnels_file.dart';

class LocalTunnelStore({required final File file}) implements TunnelStore {
  Future<void> _lastSave = Future.value();
  bool _isUnreadable = false;

  static LocalTunnelStore inTakaDirectory() =>
      LocalTunnelStore(file: File('${takaDirectory().path}/tunnels.json'));

  @override
  Future<SavedTunnels> load() async {
    if (!await file.exists()) {
      return (book: const TunnelBook(), on: <String>{});
    }

    try {
      return decodeTunnels(await file.readAsString());
    } on FormatException {
      _isUnreadable = true;
      rethrow;
    }
  }

  @override
  Future<void> save(TunnelBook book, {required Set<String> on}) {
    final saved = _lastSave.then((_) => _save(book, on));
    _lastSave = saved.catchError((Object _) {});

    return saved;
  }

  Future<void> _save(TunnelBook book, Set<String> on) async {
    // A newer Taka may have written it; losing its tunnels is worse than not saving.
    if (_isUnreadable) {
      throw FileSystemException(
        'Not overwriting a file Taka could not read',
        file.path,
      );
    }

    await file.parent.create(recursive: true);
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(encodeTunnels(book, on: on), flush: true);
    await temporary.rename(file.path);
  }
}
