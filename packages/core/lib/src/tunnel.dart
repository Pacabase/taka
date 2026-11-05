import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:system_ssh/system_ssh.dart';

part 'tunnel.freezed.dart';

enum TunnelKind { local, socks }

@freezed
sealed class const Tunnel._() with _$Tunnel {
  /// [sshHost] is a `~/.ssh/config` alias, a host or `user@host`.
  const factory({
    required String id,
    @Default('') String name,
    @Default(TunnelKind.local) TunnelKind kind,
    @Default('') String sshHost,
    required int localPort,
    String? remoteHost,
    int? remotePort,
  }) = _Tunnel;

  static Tunnel fromJson(Object? json) {
    if (json
        case {'id': final String id, 'localPort': final int localPort} &&
            final Map<Object?, Object?> fields) {
      T? field<T>(String key) => switch (fields[key]) {
        final T value => value,
        _ => null,
      };

      return Tunnel(
        id: id,
        name: field<String>('name') ?? '',
        kind: TunnelKind.values.asNameMap()[fields['kind']] ?? TunnelKind.local,
        sshHost: field<String>('sshHost') ?? '',
        localPort: localPort,
        remoteHost: field<String>('remoteHost'),
        remotePort: field<int>('remotePort'),
      );
    }

    throw FormatException('Not a tunnel: $json');
  }

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

  String get address => switch (kind) {
    TunnelKind.local => 'localhost:$localPort',
    TunnelKind.socks => 'socks5h://localhost:$localPort',
  };

  /// The command that opens this tunnel from a terminal.
  String get sshCommand => switch (kind) {
    TunnelKind.local => tunnelCommand(
      target,
      remoteHost: remoteHost ?? '',
      remotePort: remotePort ?? 0,
      localPort: localPort,
    ),
    TunnelKind.socks => socksProxyCommand(target, localPort: localPort),
  };

  String get summary => switch (kind) {
    TunnelKind.local =>
      'localhost:$localPort → $remoteHost:$remotePort via $sshHost',
    TunnelKind.socks => 'SOCKS on localhost:$localPort via $sshHost',
  };

  @override
  String toString() => 'Tunnel($id, $title)';
}

extension TunnelOrder on List<Tunnel> {
  /// Puts tunnel [id] at [index] among the others.
  List<Tunnel> moved(String id, int index) {
    final from = indexWhere((tunnel) => tunnel.id == id);
    final to = index.clamp(0, length - 1);
    if (from < 0 || from == to) return this;

    final tunnels = [...this];
    return tunnels..insert(to, tunnels.removeAt(from));
  }
}
