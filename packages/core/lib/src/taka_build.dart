import 'dart:io';

/// Which Taka this is: a release, or a debug or profile build, which keeps
/// its tunnels, socket, logs and login item apart from an installed release's.
enum TakaBuild {
  release(appId: 'com.pacabase.taka', name: 'Taka', folderName: 'taka'),
  development(
    appId: 'com.pacabase.taka.dev',
    name: 'Taka Dev',
    folderName: 'taka-dev',
  );

  const TakaBuild({
    required this.appId,
    required this.name,
    required this.folderName,
  });

  /// The window's bundle ID on macOS and application ID on Linux.
  final String appId;

  /// What the menu bar, the Dock and Login Items call it.
  final String name;

  /// The lower-case name of Linux's log folder.
  final String folderName;

  /// The background helper's bundle ID on macOS and login item ID on Linux.
  String get agentId => '$appId.agent';

  /// The build that `macos/embed_agent.sh` or `linux/embed_agent.sh` wrote
  /// into [agentAssets]. One with no such file wasn't packaged, so it's
  /// [development].
  static TakaBuild inAgentAssets(String agentAssets) {
    final file = File('$agentAssets/$appIdFileName');
    final appId = file.existsSync() ? file.readAsStringSync().trim() : null;
    return appId == release.appId ? release : development;
  }

  static const appIdFileName = 'app_id';
}

/// The running Taka's build, which each process's `main` sets from its
/// install before anything reads Taka's folders.
late final TakaBuild takaBuild;
