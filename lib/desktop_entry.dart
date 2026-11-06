import 'dart:io';

import 'package:fimber/fimber.dart';

const _fileName = 'com.pacabase.taka.desktop';

/// Linux docks and app grids name and draw a window from the desktop entry
/// named after its app ID. A package installs one; an unpacked download
/// writes its own, pointing at [executable], unless a package's is there.
Future<void> writeDesktopEntry(
  String executable, {
  Map<String, String>? environment,
}) async {
  final variables = environment ?? Platform.environment;
  final home = variables['HOME'] ?? '';
  final systemDirectories = switch (variables['XDG_DATA_DIRS']) {
    final String dirs when dirs.isNotEmpty => dirs.split(':'),
    _ => ['/usr/local/share', '/usr/share'],
  };
  for (final directory in systemDirectories) {
    if (File('$directory/applications/$_fileName').existsSync()) return;
  }

  final data = switch (variables['XDG_DATA_HOME']) {
    final String data when data.isNotEmpty => data,
    _ => '$home/.local/share',
  };
  final file = File('$data/applications/$_fileName');
  final icon =
      '${File(executable).parent.path}/data/flutter_assets/assets/icon/icon.png';
  final entry = desktopEntry(executable: executable, icon: icon);
  try {
    if (file.existsSync() && await file.readAsString() == entry) return;
    await file.parent.create(recursive: true);
    await file.writeAsString(entry);
  } on FileSystemException catch (exception) {
    Fimber.w('Could not write ${file.path}', ex: exception);
  }
}

String desktopEntry({required String executable, required String icon}) =>
    '''
[Desktop Entry]
Type=Application
Name=Taka
Comment=SSH tunnels and SOCKS proxies
Exec=${_quote(executable)}
Icon=$icon
Categories=Network;
StartupWMClass=com.pacabase.taka
StartupNotify=true
''';

// The desktop entry spec's quoting for an Exec argument, where % starts a
// field code and the value's own \ escapes come on top of the quoting's.
String _quote(String path) {
  final argument = path.replaceAll('%', '%%');
  if (!argument.contains(RegExp(r'[\s"`$\\]'))) return argument;
  final escaped = argument.replaceAllMapped(
    RegExp(r'["`$\\]'),
    (match) => '\\\\${match[0]}',
  );
  return '"$escaped"';
}
