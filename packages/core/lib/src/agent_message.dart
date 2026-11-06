import 'package:core/src/agent_settings.dart';
import 'package:core/src/tunnels_snapshot.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'agent_message.freezed.dart';

/// Snapshots stay untagged, so a window and an agent from other builds agree.
@freezed
sealed class const AgentMessage._() with _$AgentMessage {
  /// Which build the agent is.
  const factory identity(String identity) = AgentIdentity;

  const factory snapshot(TunnelsSnapshot snapshot) = AgentSnapshot;

  /// Opens the window on tunnel [id]'s form, or a new tunnel's when null.
  const factory openTunnel([String? id]) = OpenTunnel;

  const factory settings(AgentSettings settings) = SettingsChanged;

  static AgentMessage fromJson(Object? json) => switch (json) {
    {'agent': final String identity} => AgentIdentity(identity),
    {'show': 'tunnel', 'id': final String? id} => OpenTunnel(id),
    {'settings': final settings} => SettingsChanged(
      AgentSettings.fromJson(settings),
    ),
    _ => AgentSnapshot(TunnelsSnapshot.fromJson(json)),
  };

  Map<String, Object?> toJson() => switch (this) {
    AgentIdentity(:final identity) => {'agent': identity},
    AgentSnapshot(:final snapshot) => snapshot.toJson(),
    OpenTunnel(:final id) => {'show': 'tunnel', 'id': id},
    SettingsChanged(:final settings) => {'settings': settings.toJson()},
  };
}
