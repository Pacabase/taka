import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:system_ssh/system_ssh.dart';

part 'tunnel.freezed.dart';

enum TunnelKind { local, socks }

@freezed
sealed class const Tunnel._() with _$Tunnel {
  /// [sshHost] is a `~/.ssh/config` alias, a host or `user@host`.
  /// [remoteHost] and [remotePort] are for [TunnelKind.local] only.
  const factory({
    required String id,
    @Default('') String name,
    @Default(TunnelKind.local) TunnelKind kind,
    @Default('') String sshHost,
    required int localPort,
    String? remoteHost,
    int? remotePort,
  }) = _Tunnel;

  static Tunnel fromJson(Map<String, Object?> json) => Tunnel(
    id: json['id']! as String,
    name: json['name'] as String? ?? '',
    kind: TunnelKind.values.asNameMap()[json['kind']] ?? TunnelKind.local,
    sshHost: json['sshHost'] as String? ?? '',
    localPort: json['localPort']! as int,
    remoteHost: json['remoteHost'] as String?,
    remotePort: json['remotePort'] as int?,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'kind': kind.name,
    'sshHost': sshHost,
    'localPort': localPort,
    'remoteHost': ?remoteHost,
    'remotePort': ?remotePort,
  };

  SshTarget get target {
    final at = sshHost.lastIndexOf('@');

    return at == -1
        ? SshTarget(sshHost)
        : SshTarget(sshHost.substring(at + 1), user: sshHost.substring(0, at));
  }

  String get title => name.isNotEmpty ? name : summary;

  /// What to point a client at once the tunnel is up.
  String get address => switch (kind) {
    TunnelKind.local => 'localhost:$localPort',
    TunnelKind.socks => 'socks5h://localhost:$localPort',
  };

  String get summary => switch (kind) {
    TunnelKind.local =>
      'localhost:$localPort → $remoteHost:$remotePort via $sshHost',
    TunnelKind.socks => 'SOCKS on localhost:$localPort via $sshHost',
  };

  @override
  String toString() => 'Tunnel($id, $title)';
}
