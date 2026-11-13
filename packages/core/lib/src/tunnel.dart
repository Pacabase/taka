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

/// A row of the tunnel list: a group's header, or a tunnel.
sealed class const TunnelListRow() {}

class const GroupHeaderRow(final String group, final int size)
    extends TunnelListRow {}

class const TunnelRow(final Tunnel tunnel) extends TunnelListRow {}

extension TunnelOrder on List<Tunnel> {
  /// Every group in use, by name.
  List<String> get groups =>
      {for (final tunnel in this) ?tunnel.group}.sorted(compareAsciiLowerCase);

  /// As the window and tray list them: each group where its first tunnel is,
  /// with all its tunnels together.
  List<Tunnel> get shown {
    final seen = <String>{};
    return [
      for (final tunnel in this)
        if (tunnel.group == null)
          tunnel
        else if (seen.add(tunnel.group!))
          ...where((member) => member.group == tunnel.group),
    ];
  }

  /// [shown], with a header before each group.
  List<TunnelListRow> get rows {
    final tunnels = shown;
    return [
      for (final (index, tunnel) in tunnels.indexed) ...[
        if (tunnel.group case final group?
            when index == 0 || tunnels[index - 1].group != group)
          GroupHeaderRow(
            group,
            tunnels.where((member) => member.group == group).length,
          ),
        TunnelRow(tunnel),
      ],
    ];
  }

  /// The tunnels once [rows] row [from] is dropped at [to] among the others:
  /// a header moves its whole group, and a tunnel takes the group of the
  /// tunnel it lands above, so one dropped below a group's last tunnel is out.
  List<Tunnel> droppedAt(int from, int to) {
    final rows = this.rows;
    final moving = rows[from];
    final span = switch (moving) {
      GroupHeaderRow(:final size) => 1 + size,
      TunnelRow() => 1,
    };
    final others = [...rows]..removeRange(from, from + span);
    String? groupAt(int index) =>
        switch (index < others.length ? others[index] : null) {
          TunnelRow(:final tunnel) => tunnel.group,
          _ => null,
        };

    var at = to.clamp(0, others.length);
    // A group can't land inside another, so it goes after that one.
    if (moving is GroupHeaderRow) {
      if (groupAt(at) case final inside?) {
        while (groupAt(at) == inside) {
          at++;
        }
      }
    }
    final regrouped = switch (moving) {
      TunnelRow(:final tunnel) => tunnel.copyWith(group: groupAt(at)),
      GroupHeaderRow() => null,
    };

    return [
      for (final row in [
        ...others.take(at),
        ...rows.skip(from).take(span),
        ...others.skip(at),
      ])
        if (row case TunnelRow(:final tunnel))
          if (regrouped != null && tunnel.id == regrouped.id)
            regrouped
          else
            tunnel,
    ];
  }

  /// In [order]'s order and groups; tunnels it leaves out keep theirs, after.
  List<Tunnel> arranged(List<({String id, String? group})> order) {
    final byId = {for (final tunnel in this) tunnel.id: tunnel};
    return [
      for (final (:id, :group) in order)
        if (byId.remove(id) case final tunnel?) tunnel.copyWith(group: group),
      ...byId.values,
    ];
  }

  List<Tunnel> moved(String id, int index) {
    final from = indexWhere((tunnel) => tunnel.id == id);
    final to = index.clamp(0, length - 1);
    if (from < 0 || from == to) return this;

    final tunnels = [...this];
    return tunnels..insert(to, tunnels.removeAt(from));
  }
}
