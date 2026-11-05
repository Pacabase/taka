import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'taka_install.freezed.dart';

/// Where the window and its agent are, found from either one.
///
/// On macOS the window is Taka.app/Contents/MacOS/Taka and the agent
/// Taka.app/Contents/Library/LoginItems/Taka.app/Contents/MacOS/Taka; on
/// Linux and in development the agent is agent/bin/taka_agent beside taka.
/// TAKA_AGENT and TAKA_APP point either at another build.
@freezed
sealed class const TakaInstall._() with _$TakaInstall {
  /// [agentBundle] is the agent's Taka.app, or null outside an app bundle;
  /// [agentAssets] holds the tray icons.
  const factory({
    required String app,
    required String agent,
    String? agentBundle,
    required String agentAssets,
  }) = _TakaInstall;

  static TakaInstall fromWindow(
    String executable, {
    Map<String, String>? environment,
    String? operatingSystem,
  }) {
    final window = File(executable);
    final (
      agent,
      app,
    ) = (operatingSystem ?? Platform.operatingSystem) == 'macos'
        ? (
            '${window.parent.parent.path}/Library/LoginItems/Taka.app/Contents/MacOS/Taka',
            window.parent.parent.parent.path,
          )
        : ('${window.parent.path}/agent/bin/taka_agent', executable);

    return _around(
      (environment ?? Platform.environment)['TAKA_AGENT'] ?? agent,
      app: app,
    );
  }

  static TakaInstall fromAgent(
    String executable, {
    Map<String, String>? environment,
  }) {
    final folder = File(executable).parent.path;
    final loginItems = folder.indexOf('/Contents/Library/LoginItems/');

    return _around(
      executable,
      app:
          (environment ?? Platform.environment)['TAKA_APP'] ??
          (loginItems == -1
              ? '${File(folder).parent.parent.path}/taka'
              : folder.substring(0, loginItems)),
    );
  }

  static TakaInstall _around(String agent, {required String app}) {
    final folder = File(agent).parent;
    final bundle = folder.parent.parent.path;
    final isBundle = bundle.endsWith('.app');

    return TakaInstall(
      app: app,
      agent: agent,
      agentBundle: isBundle ? bundle : null,
      agentAssets: isBundle
          ? '${folder.parent.path}/Resources'
          : folder.parent.path,
    );
  }
}
