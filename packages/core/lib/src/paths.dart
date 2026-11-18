import 'dart:io';

import 'package:core/src/taka_build.dart';

Directory takaDirectory({Map<String, String>? environment, TakaBuild? build}) {
  final variables = environment ?? Platform.environment;
  final home = variables['HOME'] ?? '';
  final appId = (build ?? takaBuild).appId;

  if (Platform.isMacOS) {
    return Directory('$home/Library/Application Support/$appId');
  }
  if (Platform.isLinux) {
    final data = switch (variables['XDG_DATA_HOME']) {
      final String data when data.isNotEmpty => data,
      _ => '$home/.local/share',
    };
    return Directory('$data/$appId');
  }
  throw UnsupportedError('Taka runs on macOS and Linux so far');
}

String agentSocketPath({Map<String, String>? environment, TakaBuild? build}) =>
    '${takaDirectory(environment: environment, build: build).path}/agent.sock';

String agentIdentity(String executable) {
  final file = File(File(executable).resolveSymbolicLinksSync());
  return '${file.path}@${file.statSync().modified.millisecondsSinceEpoch}';
}

Directory logDirectory({Map<String, String>? environment, TakaBuild? build}) {
  final variables = environment ?? Platform.environment;
  final home = variables['HOME'] ?? '';
  final TakaBuild(:name, :folderName) = build ?? takaBuild;

  if (Platform.isMacOS) return Directory('$home/Library/Logs/$name');

  final state = switch (variables['XDG_STATE_HOME']) {
    final String state when state.isNotEmpty => state,
    _ => '$home/.local/state',
  };
  return Directory('$state/$folderName/logs');
}
