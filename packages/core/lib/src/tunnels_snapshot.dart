import 'package:core/src/tunnel.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tunnels_snapshot.freezed.dart';

@freezed
sealed class const TunnelStatus._() with _$TunnelStatus {
  const factory stopped() = Stopped;

  const factory connecting() = Connecting;

  /// [warning] is ssh's reason, such as `Connection refused`; the tunnel stays up.
  const factory connected({@Default('') String warning}) = Connected;

  const factory failed(String message) = Failed;

  const factory reconnecting(String reason) = Reconnecting;

  /// The server's key isn't in `known_hosts` yet; the user decides.
  const factory unknownHostKey({
    required String host,
    required String type,
    required String fingerprint,
  }) = UnknownHostKey;

  static TunnelStatus fromJson(Object? json) => switch (json) {
    {'status': 'connecting'} => const Connecting(),
    {'status': 'connected', 'warning': final String warning} => Connected(
      warning: warning,
    ),
    {'status': 'connected'} => const Connected(),
    {'status': 'failed', 'message': final String message} => Failed(message),
    {'status': 'failed'} => const Failed(''),
    {'status': 'reconnecting', 'reason': final String reason} => Reconnecting(
      reason,
    ),
    {'status': 'reconnecting'} => const Reconnecting(''),
    {
      'status': 'unknownHostKey',
      'host': final String host,
      'type': final String type,
      'fingerprint': final String fingerprint,
    } =>
      UnknownHostKey(host: host, type: type, fingerprint: fingerprint),
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
    Reconnecting(:final reason) => {'status': 'reconnecting', 'reason': reason},
    UnknownHostKey(:final host, :final type, :final fingerprint) => {
      'status': 'unknownHostKey',
      'host': host,
      'type': type,
      'fingerprint': fingerprint,
    },
  };

  bool get isOn => switch (this) {
    Connecting() || Connected() || Reconnecting() => true,
    Stopped() || Failed() || UnknownHostKey() => false,
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
