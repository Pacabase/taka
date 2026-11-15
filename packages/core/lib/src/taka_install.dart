import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';

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
    final folder = _parent(executable, system);
    final (agent, app) = switch (system) {
      'macos' => (
        '${_parent(folder, system)}/Library/LoginItems/Taka.app/Contents/MacOS/Taka',
        _parent(_parent(folder, system), system),
      ),
      'windows' => ('$folder\\agent\\bin\\taka_agent.exe', executable),
      _ => ('$folder/agent/bin/taka_agent', executable),
    };

    return _around(
      (environment ?? Platform.environment)['TAKA_AGENT'] ?? agent,
      app: app,
      system: system,
    );
  }

  static TakaInstall fromAgent(
    String executable, {
    Map<String, String>? environment,
    String? operatingSystem,
  }) {
    final system = operatingSystem ?? Platform.operatingSystem;
    final folder = _parent(executable, system);
    final loginItems = folder.indexOf('/Contents/Library/LoginItems/');
    final root = _parent(_parent(folder, system), system);

    return _around(
      executable,
      app:
          (environment ?? Platform.environment)['TAKA_APP'] ??
          switch (system) {
            _ when loginItems != -1 => folder.substring(0, loginItems),
            'windows' => '$root\\taka.exe',
            _ => '$root/taka',
          },
      system: system,
    );
  }

  static TakaInstall _around(
    String agent, {
    required String app,
    required String system,
  }) {
    final folder = _parent(agent, system);
    final bundle = _parent(_parent(folder, system), system);
    final isBundle = bundle.endsWith('.app');

    return TakaInstall(
      app: app,
      agent: agent,
      agentBundle: isBundle ? bundle : null,
      agentAssets: isBundle
          ? '${_parent(folder, system)}/Resources'
          : _parent(folder, system),
    );
  }

  // Not File.parent, so a Windows install can be worked out on any system.
  static String _parent(String path, String system) {
    final separator = path.lastIndexOf(
      system == 'windows' ? RegExp(r'[\\/]') : RegExp('/'),
    );
    return separator == -1 ? '.' : path.substring(0, separator);
  }
}
