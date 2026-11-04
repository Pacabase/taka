import 'package:core/src/tunnel.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'agent_command.freezed.dart';

@freezed
sealed class const AgentCommand._() with _$AgentCommand {
  const factory save(Tunnel tunnel) = SaveTunnel;

  const factory remove(String id) = RemoveTunnel;

  const factory toggle(String id) = ToggleTunnel;

  static AgentCommand fromJson(Object? json) => switch (json) {
    {'command': 'save', 'tunnel': final tunnel} => SaveTunnel(
      Tunnel.fromJson(tunnel),
    ),
    {'command': 'remove', 'id': final String id} => RemoveTunnel(id),
    {'command': 'toggle', 'id': final String id} => ToggleTunnel(id),
    _ => throw FormatException('Not a command: $json'),
  };

  Map<String, Object?> toJson() => switch (this) {
    SaveTunnel(:final tunnel) => {'command': 'save', 'tunnel': tunnel.toJson()},
    RemoveTunnel(:final id) => {'command': 'remove', 'id': id},
    ToggleTunnel(:final id) => {'command': 'toggle', 'id': id},
  };
}
