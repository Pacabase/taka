import 'dart:io';

import 'package:core/core.dart';
import 'package:fimber/fimber.dart';

const _fileName = 'com.pacabase.taka.desktop';
const _mark = '# Written by Taka, which rewrites it when Taka moves.';

/// Linux docks and app grids name and draw a window from the desktop entry
/// named after its app ID. A package installs one; an unpacked download
/// writes its own, pointing at [executable], unless a package's is there.
/// An entry Taka didn't write is the user's, and stays as it is.
Future<void> writeDesktopEntry(
  String executable, {
  Map<String, String>? environment,
}) async {
  final variables = environment ?? Platform.environment;
  final userData = dataHome(environment: variables);
  final file = File('$userData/applications/$_fileName');
  final systemDirectories = switch (variables['XDG_DATA_DIRS']) {
    final String dirs when dirs.isNotEmpty => dirs.split(':'),
    _ => ['/usr/local/share', '/usr/share'],
  };

  try {
    final existing = await file.exists() ? await file.readAsString() : null;
    if (existing != null && !existing.startsWith(_mark)) return;

    // Taka's entry would hide the package's, which knows where Taka is.
    for (final directory in systemDirectories) {
      if (!directory.startsWith('/') || directory == userData) continue;
      if (await File('$directory/applications/$_fileName').exists()) {
        if (existing != null) await file.delete();
        return;
      }
    }

    final icon =
        '${File(executable).parent.path}/data/flutter_assets/assets/icon/icon.png';
    final entry = desktopEntry(executable: executable, icon: icon);
    if (existing == entry) return;

    // Docks watch the folder, so they never see a half-written file.
    await file.parent.create(recursive: true);
    final draft = File('${file.path}.tmp');
    await draft.writeAsString(entry);
    await draft.rename(file.path);
  } on FileSystemException catch (exception) {
    Fimber.w('Could not write ${file.path}', ex: exception);
  }
}

/// TryExec hides the entry once the bundle is gone.
String desktopEntry({required String executable, required String icon}) =>
    '''
$_mark
[Desktop Entry]
Type=Application
Name=Taka
Comment=SSH tunnels and SOCKS proxies
Exec=${_quote(executable)}
TryExec=${_escape(executable)}
Icon=${_escape(icon)}
Categories=Network;
StartupWMClass=com.pacabase.taka
StartupNotify=true
''';

// The desktop entry spec's escaping for a string value.
String _escape(String value) => value
    .replaceAll(r'\', r'\\')
    .replaceAll('\n', r'\n')
    .replaceAll('\t', r'\t')
    .replaceAll('\r', r'\r');

// Its quoting for an Exec argument, before that escaping; % starts a field code.
String _quote(String path) {
  final quoted = path.replaceAllMapped(
    RegExp(r'["`$\\]'),
    (match) => '\\${match[0]}',
  );
  return '"${_escape(quoted).replaceAll('%', '%%')}"';
}
