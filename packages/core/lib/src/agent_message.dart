import 'package:core/src/tunnels_snapshot.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'agent_message.freezed.dart';

/// A snapshot goes untagged, as it always has, so a window and an agent from
/// different builds still understand each other.
@freezed
sealed class const AgentMessage._() with _$AgentMessage {
  /// Which build the agent is.
  const factory identity(String identity) = AgentIdentity;

  const factory snapshot(TunnelsSnapshot snapshot) = AgentSnapshot;

  const factory showAbout() = ShowAbout;

  static AgentMessage fromJson(Object? json) => switch (json) {
    {'agent': final String identity} => AgentIdentity(identity),
    {'show': 'about'} => const ShowAbout(),
    _ => AgentSnapshot(TunnelsSnapshot.fromJson(json)),
  };

  Map<String, Object?> toJson() => switch (this) {
    AgentIdentity(:final identity) => {'agent': identity},
    AgentSnapshot(:final snapshot) => snapshot.toJson(),
    ShowAbout() => {'show': 'about'},
  };
}
