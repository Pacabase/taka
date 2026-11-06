import 'dart:io';

const _appId = 'com.pacabase.taka';

Directory takaDirectory({Map<String, String>? environment}) {
  final variables = environment ?? Platform.environment;
  final home = variables['HOME'] ?? '';

  if (Platform.isMacOS) {
    return Directory('$home/Library/Application Support/$_appId');
  }
  if (Platform.isLinux) {
    return Directory('${dataHome(environment: environment)}/$_appId');
  }
  throw UnsupportedError('Taka runs on macOS and Linux so far');
}

String dataHome({Map<String, String>? environment}) => _xdgHome(
  environment ?? Platform.environment,
  'XDG_DATA_HOME',
  '.local/share',
);

String _xdgHome(Map<String, String> variables, String name, String fallback) =>
    switch (variables[name]) {
      final String path when path.isNotEmpty => path,
      _ => '${variables['HOME'] ?? ''}/$fallback',
    };

String agentSocketPath({Map<String, String>? environment}) =>
    '${takaDirectory(environment: environment).path}/agent.sock';

String agentIdentity(String executable) {
  final file = File(File(executable).resolveSymbolicLinksSync());
  return '${file.path}@${file.statSync().modified.millisecondsSinceEpoch}';
}

Directory logDirectory({Map<String, String>? environment}) {
  final variables = environment ?? Platform.environment;
  final home = variables['HOME'] ?? '';

  if (Platform.isMacOS) return Directory('$home/Library/Logs/Taka');

  return Directory(
    '${_xdgHome(variables, 'XDG_STATE_HOME', '.local/state')}/taka/logs',
  );
}
