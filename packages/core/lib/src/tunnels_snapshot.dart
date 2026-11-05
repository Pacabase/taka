import 'package:core/src/tunnel.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tunnels_snapshot.freezed.dart';

@freezed
sealed class const TunnelStatus._() with _$TunnelStatus {
  const factory stopped() = Stopped;

  const factory connecting() = Connecting;

  /// [warning] says what ssh last couldn't forward, such as a destination
  /// that refused, while the tunnel itself stays up.
  const factory connected({@Default('') String warning}) = Connected;

  const factory failed(String message) = Failed;

  static TunnelStatus fromJson(Object? json) => switch (json) {
    {'status': 'connecting'} => const Connecting(),
    {'status': 'connected', 'warning': final String warning} => Connected(
      warning: warning,
    ),
    {'status': 'connected'} => const Connected(),
    {'status': 'failed', 'message': final String message} => Failed(message),
    {'status': 'failed'} => const Failed(''),
    _ => const Stopped(),
  };

  Map<String, Object?> toJson() => switch (this) {
    Stopped() => {'status': 'stopped'},
    Connecting() => {'status': 'connecting'},
    Connected(:final warning) => {
      'status': 'connected',
      if (warning.isNotEmpty) 'warning': warning,
    },
    Failed(:final message) => {'status': 'failed', 'message': message},
  };

  bool get isOn => switch (this) {
    Connecting() || Connected() => true,
    Stopped() || Failed() => false,
  };
}

@freezed
sealed class const TunnelsSnapshot._() with _$TunnelsSnapshot {
  const factory({
    @Default([]) List<Tunnel> tunnels,
    @Default({}) Map<String, TunnelStatus> statuses,
  }) = _TunnelsSnapshot;

  static TunnelsSnapshot fromJson(Object? json) => switch (json) {
    {
      'tunnels': final List<Object?> tunnels,
      'statuses': final Map<String, Object?> statuses,
    } =>
      TunnelsSnapshot(
        tunnels: tunnels.map(Tunnel.fromJson).toList(),
        statuses: statuses.map(
          (id, status) => MapEntry(id, TunnelStatus.fromJson(status)),
        ),
      ),
    _ => throw FormatException('Not a snapshot: $json'),
  };

  Map<String, Object?> toJson() => {
    'tunnels': tunnels.map((tunnel) => tunnel.toJson()).toList(),
    'statuses': statuses.map((id, status) => MapEntry(id, status.toJson())),
  };

  TunnelStatus statusOf(String id) => statuses[id] ?? const Stopped();

  int get connectedCount => statuses.values.whereType<Connected>().length;
}
