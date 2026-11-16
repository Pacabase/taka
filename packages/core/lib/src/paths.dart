import 'dart:io';

import 'package:path/path.dart' as p;

const _appId = 'com.pacabase.taka';

Directory takaDirectory({
  Map<String, String>? environment,
  String? operatingSystem,
}) {
  final variables = environment ?? Platform.environment;
  final home = variables['HOME'] ?? '';

  return switch (operatingSystem ?? Platform.operatingSystem) {
    'macos' => Directory('$home/Library/Application Support/$_appId'),
    'linux' => Directory(
      '${_xdg(variables, 'XDG_DATA_HOME', '.local/share')}/$_appId',
    ),
    'windows' => Directory(p.windows.join(variables['APPDATA'] ?? '', 'Taka')),
    _ => throw UnsupportedError('Taka runs on macOS, Linux and Windows'),
  };
}

/// On Windows, where Dart has no Unix sockets, the file holds an
/// `AgentTicket` instead.
String agentSocketPath({
  Map<String, String>? environment,
  String? operatingSystem,
}) => switch (operatingSystem ?? Platform.operatingSystem) {
  'windows' => p.windows.join(
    (environment ?? Platform.environment)['LOCALAPPDATA'] ?? '',
    'Taka',
    'agent.port',
  ),
  final system =>
    '${takaDirectory(environment: environment, operatingSystem: system).path}/agent.sock',
};

String agentIdentity(String executable) {
  final file = File(File(executable).resolveSymbolicLinksSync());
  return '${file.path}@${file.statSync().modified.millisecondsSinceEpoch}';
}

Directory logDirectory({
  Map<String, String>? environment,
  String? operatingSystem,
}) {
  final variables = environment ?? Platform.environment;

  return switch (operatingSystem ?? Platform.operatingSystem) {
    'macos' => Directory('${variables['HOME'] ?? ''}/Library/Logs/Taka'),
    'windows' => Directory(
      p.windows.join(variables['LOCALAPPDATA'] ?? '', 'Taka', 'logs'),
    ),
    _ => Directory(
      '${_xdg(variables, 'XDG_STATE_HOME', '.local/state')}/taka/logs',
    ),
  };
}

String _xdg(Map<String, String> variables, String name, String fallback) =>
    switch (variables[name]) {
      final String folder when folder.isNotEmpty => folder,
      _ => '${variables['HOME'] ?? ''}/$fallback',
    };
