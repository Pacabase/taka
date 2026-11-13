import 'package:core/src/tunnel.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'agent_command.freezed.dart';

@freezed
sealed class const AgentCommand._() with _$AgentCommand {
  const factory save(Tunnel tunnel) = SaveTunnel;

  const factory remove(String id) = RemoveTunnel;

  const factory toggle(String id) = ToggleTunnel;

  const factory arrange(List<({String id, String? group})> tunnels) =
      ArrangeTunnels;

  const factory trustHostKey(String id, String fingerprint) = TrustHostKey;

  const factory importTunnels(List<Tunnel> tunnels) = ImportTunnels;

  const factory exportTunnels(String path) = ExportTunnels;

  const factory quit() = QuitAgent;

  const factory setLaunchAtLogin({required bool on}) = SetLaunchAtLogin;

  const factory setDebugLogging({required bool on}) = SetDebugLogging;

  const factory showLogs() = ShowLogs;

  static AgentCommand fromJson(Object? json) => switch (json) {
    {'command': 'save', 'tunnel': final tunnel} => SaveTunnel(
      Tunnel.fromJson(tunnel),
    ),
    {'command': 'remove', 'id': final String id} => RemoveTunnel(id),
    {'command': 'toggle', 'id': final String id} => ToggleTunnel(id),
    {'command': 'arrange', 'tunnels': final List<Object?> tunnels} =>
      ArrangeTunnels([
        for (final tunnel in tunnels)
          switch (tunnel) {
            {'id': final String id} && final Map<Object?, Object?> fields => (
              id: id,
              group: switch (fields['group']) {
                final String group => groupNamed(group),
                _ => null,
              },
            ),
            _ => throw FormatException('Not a tunnel to arrange: $tunnel'),
          },
      ]),
    {
      'command': 'trustHostKey',
      'id': final String id,
      'fingerprint': final String fingerprint,
    } =>
      TrustHostKey(id, fingerprint),
    {'command': 'import', 'tunnels': final List<Object?> tunnels} =>
      ImportTunnels(tunnels.map(Tunnel.fromJson).toList()),
    {'command': 'export', 'path': final String path} => ExportTunnels(path),
    {'command': 'quit'} => const QuitAgent(),
    {'command': 'launchAtLogin', 'on': final bool on} => SetLaunchAtLogin(
      on: on,
    ),
    {'command': 'debugLogging', 'on': final bool on} => SetDebugLogging(on: on),
    {'command': 'showLogs'} => const ShowLogs(),
    _ => throw FormatException('Not a command: $json'),
  };

  Map<String, Object?> toJson() => switch (this) {
    SaveTunnel(:final tunnel) => {'command': 'save', 'tunnel': tunnel.toJson()},
    RemoveTunnel(:final id) => {'command': 'remove', 'id': id},
    ToggleTunnel(:final id) => {'command': 'toggle', 'id': id},
    ArrangeTunnels(:final tunnels) => {
      'command': 'arrange',
      'tunnels': [
        for (final (:id, :group) in tunnels) {'id': id, 'group': ?group},
      ],
    },
    TrustHostKey(:final id, :final fingerprint) => {
      'command': 'trustHostKey',
      'id': id,
      'fingerprint': fingerprint,
    },
    ImportTunnels(:final tunnels) => {
      'command': 'import',
      'tunnels': tunnels.map((tunnel) => tunnel.toJson()).toList(),
    },
    ExportTunnels(:final path) => {'command': 'export', 'path': path},
    QuitAgent() => {'command': 'quit'},
    SetLaunchAtLogin(:final on) => {'command': 'launchAtLogin', 'on': on},
    SetDebugLogging(:final on) => {'command': 'debugLogging', 'on': on},
    ShowLogs() => {'command': 'showLogs'},
  };
}
