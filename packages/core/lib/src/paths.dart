import 'dart:io';

const _appId = 'com.pacabase.taka';

Directory takaDirectory({Map<String, String>? environment}) {
  final variables = environment ?? Platform.environment;
  final home = variables['HOME'] ?? '';

  if (Platform.isMacOS) {
    return Directory('$home/Library/Application Support/$_appId');
  }
  if (Platform.isLinux) {
    final data = switch (variables['XDG_DATA_HOME']) {
      final String data when data.isNotEmpty => data,
      _ => '$home/.local/share',
    };
    return Directory('$data/$_appId');
  }
  throw UnsupportedError('Taka runs on macOS and Linux so far');
}

String agentSocketPath({Map<String, String>? environment}) =>
    '${takaDirectory(environment: environment).path}/agent.sock';

String agentIdentity(String executable) {
  final file = File(File(executable).resolveSymbolicLinksSync());
  return '${file.path}@${file.statSync().modified.millisecondsSinceEpoch}';
}
