import 'dart:io';

/// A release, or a debug or profile build, which keeps its tunnels, socket,
/// logs and login item apart from an installed release's.
enum TakaBuild {
  release(
    appId: 'com.pacabase.taka',
    name: 'Taka',
    windowName: 'Taka Settings',
    folderName: 'taka',
  ),
  development(
    appId: 'com.pacabase.taka.dev',
    name: 'Taka Dev',
    windowName: 'Taka Settings Dev',
    folderName: 'taka-dev',
  );

  const TakaBuild({
    required this.appId,
    required this.name,
    required this.windowName,
    required this.folderName,
  });

  final String appId;

  /// The background agent's name, and the app's.
  final String name;

  /// The window's, which macOS shows in the menu bar and Activity Monitor.
  final String windowName;

  /// Linux's lower-case log folder.
  final String folderName;

  String get agentId => '$appId.agent';

  /// The build an embed script wrote into [agentAssets]; one with no such
  /// file wasn't packaged.
  static TakaBuild inAgentAssets(String agentAssets) {
    final file = File('$agentAssets/app_id');
    final appId = file.existsSync() ? file.readAsStringSync().trim() : null;
    return appId == release.appId ? release : development;
  }
}

/// Set by each process's `main` before anything reads Taka's folders.
late final TakaBuild takaBuild;
