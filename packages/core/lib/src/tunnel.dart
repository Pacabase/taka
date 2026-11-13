import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:system_ssh/system_ssh.dart';

part 'tunnel.freezed.dart';

enum TunnelKind { local, socks, remote }

@freezed
sealed class const Tunnel._() with _$Tunnel {
  /// [sshHost] is a `~/.ssh/config` alias, a host or `user@host`.
  ///
  /// A local tunnel leads to [remoteHost] and [remotePort], or to the Unix
  /// socket at [remoteSocket] on [sshHost] when that is set.
  ///
  /// A remote tunnel has [sshHost] listen on its own [remotePort], and brings
  /// each connection back to [localHost], or localhost when null, on
  /// [localPort].
  const factory({
    required String id,
    @Default('') String name,
    @Default(TunnelKind.local) TunnelKind kind,
    @Default('') String sshHost,
    String? localHost,
    required int localPort,
    String? remoteHost,
    int? remotePort,
    String? remoteSocket,
    String? group,
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
        localHost: field<String>('localHost'),
        localPort: localPort,
        remoteHost: field<String>('remoteHost'),
        remotePort: field<int>('remotePort'),
        remoteSocket: field<String>('remoteSocket'),
        group: field<String>('group'),
      );
    }

    throw FormatException('Not a tunnel: $json');
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'kind': kind.name,
    'sshHost': sshHost,
    'localHost': ?localHost,
    'localPort': localPort,
    'remoteHost': ?remoteHost,
    'remotePort': ?remotePort,
    'remoteSocket': ?remoteSocket,
    'group': ?group,
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
    TunnelKind.remote => 'localhost:$remotePort',
  };

  /// Null for a tunnel ssh can't open, such as a local port outside 1 to 65535.
  String? get sshCommand {
    try {
      return switch (kind) {
        TunnelKind.local => switch (remoteSocket) {
          final remoteSocket? => socketTunnelCommand(
            target,
            remoteSocket: remoteSocket,
            localPort: localPort,
          ),
          null => tunnelCommand(
            target,
            remoteHost: remoteHost ?? '',
            remotePort: remotePort ?? 0,
            localPort: localPort,
          ),
        },
        TunnelKind.socks => socksProxyCommand(target, localPort: localPort),
        TunnelKind.remote => remoteTunnelCommand(
          target,
          localHost: localHost ?? 'localhost',
          localPort: localPort,
          remotePort: remotePort ?? 0,
        ),
      };
    } on ArgumentError {
      return null;
    }
  }

  String get summary => switch (kind) {
    TunnelKind.local =>
      'localhost:$localPort → '
          '${remoteSocket ?? '$remoteHost:$remotePort'} via $sshHost',
    TunnelKind.socks => 'SOCKS on localhost:$localPort via $sshHost',
    TunnelKind.remote =>
      'port $remotePort on $sshHost → ${localHost ?? 'localhost'}:$localPort',
  };

  @override
  String toString() => 'Tunnel($id, $title)';
}

extension TunnelOrder on List<Tunnel> {
  List<String> get groups =>
      {for (final tunnel in this) ?tunnel.group}.sorted(compareAsciiLowerCase);

  /// As the window and tray list them: tunnels in no group, then each group.
  List<Tunnel> get shown => [
    ...where((tunnel) => tunnel.group == null),
    for (final group in groups) ...where((tunnel) => tunnel.group == group),
  ];

  /// The index for [moved] that puts tunnel [id] at [shownIndex] among the
  /// others as [shown] lists them.
  int moveIndexFor(String id, {required int shownIndex}) {
    final others = shown.where((tunnel) => tunnel.id != id).toList();
    final rest = where((tunnel) => tunnel.id != id).toList();
    if (shownIndex >= others.length) {
      return others.isEmpty ? 0 : rest.indexOf(others.last) + 1;
    }
    return rest.indexOf(others[shownIndex.clamp(0, others.length - 1)]);
  }

  List<Tunnel> moved(String id, int index) {
    final from = indexWhere((tunnel) => tunnel.id == id);
    final to = index.clamp(0, length - 1);
    if (from < 0 || from == to) return this;

    final tunnels = [...this];
    return tunnels..insert(to, tunnels.removeAt(from));
  }
}
