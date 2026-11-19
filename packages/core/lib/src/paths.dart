import 'dart:io';

import 'package:core/src/taka_build.dart';
import 'package:path/path.dart' as p;

Directory takaDirectory({
  Map<String, String>? environment,
  TakaBuild? build,
  String? operatingSystem,
}) {
  final variables = environment ?? Platform.environment;
  final home = variables['HOME'] ?? '';
  final TakaBuild(:appId, :name) = build ?? takaBuild;

  return switch (operatingSystem ?? Platform.operatingSystem) {
    'macos' => Directory('$home/Library/Application Support/$appId'),
    'linux' => Directory(
      '${_xdg(variables, 'XDG_DATA_HOME', '.local/share')}/$appId',
    ),
    'windows' => Directory(p.windows.join(variables['APPDATA'] ?? '', name)),
    _ => throw UnsupportedError('Taka runs on macOS, Linux and Windows'),
  };
}

/// On Windows, where Dart has no Unix sockets, the file holds an
/// `AgentTicket` instead.
String agentSocketPath({
  Map<String, String>? environment,
  TakaBuild? build,
  String? operatingSystem,
}) => switch (operatingSystem ?? Platform.operatingSystem) {
  'windows' => p.windows.join(
    (environment ?? Platform.environment)['LOCALAPPDATA'] ?? '',
    (build ?? takaBuild).name,
    'agent.port',
  ),
  final system =>
    '${takaDirectory(environment: environment, build: build, operatingSystem: system).path}/agent.sock',
};

String agentIdentity(String executable) {
  final file = File(File(executable).resolveSymbolicLinksSync());
  return '${file.path}@${file.statSync().modified.millisecondsSinceEpoch}';
}

Directory logDirectory({
  Map<String, String>? environment,
  TakaBuild? build,
  String? operatingSystem,
}) {
  final variables = environment ?? Platform.environment;
  final TakaBuild(:name, :folderName) = build ?? takaBuild;

  return switch (operatingSystem ?? Platform.operatingSystem) {
    'macos' => Directory('${variables['HOME'] ?? ''}/Library/Logs/$name'),
    'windows' => Directory(
      p.windows.join(variables['LOCALAPPDATA'] ?? '', name, 'logs'),
    ),
    _ => Directory(
      '${_xdg(variables, 'XDG_STATE_HOME', '.local/state')}/$folderName/logs',
    ),
  };
}

String _xdg(Map<String, String> variables, String name, String fallback) =>
    switch (variables[name]) {
      final String folder when folder.isNotEmpty => folder,
      _ => '${variables['HOME'] ?? ''}/$fallback',
    };
