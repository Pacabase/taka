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

Directory logDirectory({Map<String, String>? environment}) {
  final variables = environment ?? Platform.environment;
  final home = variables['HOME'] ?? '';

  if (Platform.isMacOS) return Directory('$home/Library/Logs/Taka');

  final state = switch (variables['XDG_STATE_HOME']) {
    final String state when state.isNotEmpty => state,
    _ => '$home/.local/state',
  };
  return Directory('$state/taka/logs');
}

/// Where the window finds its agent, from Taka.app/Contents/MacOS/Taka on
/// macOS or taka on Linux; TAKA_AGENT points at another build.
({String agent, String app, String? agentBundle}) windowLayout(
  String executable, {
  Map<String, String>? environment,
  String? operatingSystem,
}) {
  final file = File(executable);
  final isMacOS = (operatingSystem ?? Platform.operatingSystem) == 'macos';
  final (bundled, app) = isMacOS
      ? (
          '${file.parent.parent.path}/Library/LoginItems/TakaAgent.app/Contents/MacOS/Taka',
          file.parent.parent.parent.path,
        )
      : ('${file.parent.path}/agent/bin/taka_agent', executable);
  final agent = (environment ?? Platform.environment)['TAKA_AGENT'] ?? bundled;
  final agentBundle = File(agent).parent.parent.parent.path;

  return (
    agent: agent,
    app: app,
    agentBundle: agentBundle.endsWith('.app') ? agentBundle : null,
  );
}

/// Where the agent finds the window and its assets, from
/// Taka.app/Contents/Library/LoginItems/TakaAgent.app/Contents/MacOS/Taka on
/// macOS, or agent/bin/taka_agent beside taka on Linux and in development;
/// TAKA_APP points at another window.
({String app, String? bundle, String assets}) agentLayout(
  String executable, {
  Map<String, String>? environment,
}) {
  final folder = File(executable).parent;
  final bundle = folder.parent.parent.path;
  final isAppBundle = bundle.endsWith('.app');
  final loginItems = folder.path.indexOf('/Contents/Library/LoginItems/');

  return (
    app:
        (environment ?? Platform.environment)['TAKA_APP'] ??
        (loginItems == -1
            ? '$bundle/taka'
            : folder.path.substring(0, loginItems)),
    bundle: isAppBundle ? bundle : null,
    assets: isAppBundle
        ? '${folder.parent.path}/Resources'
        : folder.parent.path,
  );
}
