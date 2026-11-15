import 'dart:io';

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
    'windows' => Directory(
      '${_windowsFolder(variables, 'APPDATA', 'Roaming')}\\Taka',
    ),
    _ => throw UnsupportedError('Taka runs on macOS, Linux and Windows'),
  };
}

/// On Windows, where Dart has no Unix sockets, the file holds an
/// `AgentTicket` instead.
String agentSocketPath({
  Map<String, String>? environment,
  String? operatingSystem,
}) => switch (operatingSystem ?? Platform.operatingSystem) {
  'windows' =>
    '${_windowsFolder(environment ?? Platform.environment, 'LOCALAPPDATA', 'Local')}\\Taka\\agent.port',
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
      '${_windowsFolder(variables, 'LOCALAPPDATA', 'Local')}\\Taka\\logs',
    ),
    _ => Directory(
      '${_xdg(variables, 'XDG_STATE_HOME', '.local/state')}/taka/logs',
    ),
  };
}

/// Windows' own OpenSSH, so another ssh earlier on the `PATH` never runs.
String sshExecutable({
  Map<String, String>? environment,
  String? operatingSystem,
}) => switch (operatingSystem ?? Platform.operatingSystem) {
  'windows' =>
    '${_windowsVariable(environment ?? Platform.environment, 'SystemRoot') ?? r'C:\Windows'}\\System32\\OpenSSH\\ssh.exe',
  _ => 'ssh',
};

String _xdg(Map<String, String> variables, String name, String fallback) =>
    switch (variables[name]) {
      final String folder when folder.isNotEmpty => folder,
      _ => '${variables['HOME'] ?? ''}/$fallback',
    };

String _windowsFolder(
  Map<String, String> variables,
  String name,
  String fallback,
) =>
    _windowsVariable(variables, name) ??
    '${_windowsVariable(variables, 'USERPROFILE') ?? ''}\\AppData\\$fallback';

// Windows variable names are case-insensitive, but a map passed in isn't.
String? _windowsVariable(Map<String, String> variables, String name) =>
    variables.entries
        .where(
          (entry) =>
              entry.key.toUpperCase() == name.toUpperCase() &&
              entry.value.isNotEmpty,
        )
        .map((entry) => entry.value)
        .firstOrNull;
