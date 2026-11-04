import 'dart:io';

const _appId = 'com.pacabase.taka';

/// Where Taka keeps its tunnels: the folder `path_provider` gives a Flutter
/// app as its support directory, so the app and the agent agree on it.
Directory takaDirectory({Map<String, String>? environment}) {
  final env = environment ?? Platform.environment;
  final home = env['HOME'] ?? '';

  if (Platform.isMacOS) {
    return Directory('$home/Library/Application Support/$_appId');
  }
  if (Platform.isLinux) {
    final data = env['XDG_DATA_HOME'] ?? '$home/.local/share';
    return Directory('$data/$_appId');
  }
  throw UnsupportedError('Taka runs on macOS and Linux so far');
}

/// The Unix socket the agent listens on.
String agentSocketPath({Map<String, String>? environment}) =>
    '${takaDirectory(environment: environment).path}/agent.sock';
