import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path/path.dart' as p;

part 'taka_install.freezed.dart';

@freezed
sealed class const TakaInstall._() with _$TakaInstall {
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
    final system = operatingSystem ?? Platform.operatingSystem;
    final path = _style(system);
    final folder = path.dirname(executable);
    final (agent, app) = switch (system) {
      'macos' => (
        path.join(
          path.dirname(folder),
          'Library/LoginItems/Taka.app/Contents/MacOS/Taka',
        ),
        path.dirname(path.dirname(folder)),
      ),
      'windows' => (path.join(folder, 'agent', 'bin', 'Taka.exe'), executable),
      _ => (path.join(folder, 'agent', 'bin', 'taka_agent'), executable),
    };

    return _around(
      (environment ?? Platform.environment)['TAKA_AGENT'] ?? agent,
      app: app,
      path: path,
    );
  }

  static TakaInstall fromAgent(
    String executable, {
    Map<String, String>? environment,
    String? operatingSystem,
  }) {
    final system = operatingSystem ?? Platform.operatingSystem;
    final path = _style(system);
    final folder = path.dirname(executable);
    final loginItems = folder.indexOf('/Contents/Library/LoginItems/');
    final root = path.dirname(path.dirname(folder));

    return _around(
      executable,
      app:
          (environment ?? Platform.environment)['TAKA_APP'] ??
          switch (system) {
            _ when loginItems != -1 => folder.substring(0, loginItems),
            'windows' => path.join(root, 'taka.exe'),
            _ => path.join(root, 'taka'),
          },
      path: path,
    );
  }

  static TakaInstall _around(
    String agent, {
    required String app,
    required p.Context path,
  }) {
    final folder = path.dirname(agent);
    final bundle = path.dirname(path.dirname(folder));
    final isBundle = bundle.endsWith('.app');

    return TakaInstall(
      app: app,
      agent: agent,
      agentBundle: isBundle ? bundle : null,
      agentAssets: isBundle
          ? path.join(path.dirname(folder), 'Resources')
          : path.dirname(folder),
    );
  }

  // Not the host's style, so a Windows install can be worked out on any system.
  static p.Context _style(String system) =>
      system == 'windows' ? p.windows : p.posix;
}
