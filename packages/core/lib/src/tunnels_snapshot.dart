import 'package:core/src/tunnel.dart';
import 'package:core/src/tunnel_colour.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tunnels_snapshot.freezed.dart';

/// Why a tunnel failed or dropped, for Taka to put in its own words.
enum TunnelFailure {
  sshNotFound,
  config,
  portInUse,
  duplicateForward,
  addressUnavailable,
  hostNotFound,
  unreachable,
  loginRefused,
  hostKey,
  dropped,
  remotePortRefused,

  /// ssh connected, but the server couldn't make the connection the tunnel
  /// forwards to.
  forwardRefused,

  /// ssh connected, but the server's config forbids the forward.
  forwardProhibited,
  other,
}

TunnelFailure _failureOf(Object? json) =>
    TunnelFailure.values.asNameMap()[json] ?? TunnelFailure.other;

@freezed
sealed class const TunnelStatus._() with _$TunnelStatus {
  const factory stopped() = Stopped;

  const factory connecting() = Connecting;

  /// [warning] is ssh's reason, such as `Connection refused`; the tunnel stays up.
  const factory connected({@Default('') String warning}) = Connected;

  /// [message] is ssh's, for the details.
  const factory failed(
    String message, {
    @Default(TunnelFailure.other) TunnelFailure failure,
  }) = Failed;

  const factory reconnecting(
    String message, {
    @Default(TunnelFailure.other) TunnelFailure failure,
  }) = Reconnecting;

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
    {'status': 'failed', 'message': final String message} => Failed(
      message,
      failure: _failureOf(json['failure']),
    ),
    {'status': 'failed'} => const Failed(''),
    {'status': 'reconnecting', 'message': final String message} => Reconnecting(
      message,
      failure: _failureOf(json['failure']),
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
    Failed(:final message, :final failure) => {
      'status': 'failed',
      'message': message,
      'failure': failure.name,
    },
    Reconnecting(:final message, :final failure) => {
      'status': 'reconnecting',
      'message': message,
      'failure': failure.name,
    },
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
    @Default({}) Map<String, TunnelColour> groupColours,
  }) = _TunnelsSnapshot;

  static TunnelsSnapshot fromJson(Object? json) => switch (json) {
    {
          'tunnels': final List<Object?> tunnels,
          'statuses': final Map<String, Object?> statuses,
        } &&
        final Map<Object?, Object?> fields =>
      TunnelsSnapshot(
        tunnels: tunnels.map(Tunnel.fromJson).toList(),
        statuses: statuses.map(
          (id, status) => MapEntry(id, TunnelStatus.fromJson(status)),
        ),
        groupColours: groupColoursFromJson(fields['groupColours']),
      ),
    _ => throw FormatException('Not a snapshot: $json'),
  };

  Map<String, Object?> toJson() => {
    'tunnels': tunnels.map((tunnel) => tunnel.toJson()).toList(),
    'statuses': statuses.map((id, status) => MapEntry(id, status.toJson())),
    if (groupColours.isNotEmpty)
      'groupColours': groupColoursToJson(groupColours),
  };

  TunnelStatus statusOf(String id) => statuses[id] ?? const Stopped();

  /// A coloured group's colour, or else the tunnel's own.
  TunnelColour? colourOf(Tunnel tunnel) =>
      groupColours[tunnel.group] ?? tunnel.colour;

  int get connectedCount => statuses.values.whereType<Connected>().length;
}
