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
        group: groupNamed(field<String>('group')),
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

sealed class const TunnelListRow() {
  /// How many rows dragging this one carries, itself included.
  int get span;
}

class const GroupHeaderRow(final String group, final int size)
    extends TunnelListRow {
  @override
  int get span => size + 2;
}

/// The gap after a group's last tunnel. A tunnel dropped above it joins the
/// group as its last one; one dropped below it lands after the group.
class const GroupEndRow(final String group) extends TunnelListRow {
  @override
  int get span => 0;
}

class const TunnelRow(final Tunnel tunnel) extends TunnelListRow {
  @override
  int get span => 1;
}

String? groupNamed(String? group) => switch (group?.trim()) {
  null || '' => null,
  final named => named,
};

List<TunnelListRow> _without(List<TunnelListRow> rows, int from) =>
    [...rows]..removeRange(from, from + rows[from].span);

int _landing(
  List<TunnelListRow> rows,
  List<TunnelListRow> others,
  int from,
  int to,
) {
  final at = to.clamp(0, others.length);
  if (rows[from] is! GroupHeaderRow) return at;
  final inside = _groupAt(others, at);
  if (inside == null) return at;

  // Before the other group's header or after its last tunnel, the nearer.
  var start = at;
  while (_groupAt(others, start - 1) == inside) {
    start--;
  }
  final header = start - 1;
  var end = at;
  while (_groupAt(others, end) == inside) {
    end++;
  }
  return at - header <= end - at ? header : end;
}

String? _groupAt(List<TunnelListRow> rows, int index) =>
    switch (index >= 0 && index < rows.length ? rows[index] : null) {
      TunnelRow(:final tunnel) => tunnel.group,
      GroupEndRow(:final group) => group,
      _ => null,
    };

extension TunnelOrder on List<Tunnel> {
  List<String> get groups =>
      {for (final tunnel in this) ?tunnel.group}.sorted(compareAsciiLowerCase);

  /// As the window and tray list them: each group where its first tunnel is,
  /// after a header, with all its tunnels together.
  List<TunnelListRow> get rows {
    final members = where((tunnel) => tunnel.group != null)
        .groupListsBy((tunnel) => tunnel.group!);
    final seen = <String>{};
    return [
      for (final tunnel in this)
        if (tunnel.group case final group?) ...[
          if (seen.add(group)) ...[
            GroupHeaderRow(group, members[group]!.length),
            for (final member in members[group]!) TunnelRow(member),
            GroupEndRow(group),
          ],
        ] else
          TunnelRow(tunnel),
    ];
  }

  List<Tunnel> get shown => [
    for (final row in rows)
      if (row case TunnelRow(:final tunnel)) tunnel,
  ];

  /// Where among the other rows [rows] row [from] lands when dropped at
  /// [to]: a group can't land inside another, so it goes just before or just
  /// after that one, whichever is nearer.
  int landingOf(int from, int to) {
    final rows = this.rows;
    return _landing(rows, _without(rows, from), from, to);
  }

  /// The tunnels once [rows] row [from] is dropped at [to] among the others.
  /// A header carries its whole group, and a tunnel takes the group of the
  /// row it lands above.
  List<Tunnel> droppedAt(int from, int to) {
    final rows = this.rows;
    final moving = rows[from];
    final others = _without(rows, from);
    final at = _landing(rows, others, from, to);
    final regrouped = switch (moving) {
      TunnelRow(:final tunnel) => tunnel.copyWith(group: _groupAt(others, at)),
      GroupHeaderRow() || GroupEndRow() => null,
    };

    return [
      for (final row in [
        ...others.take(at),
        ...rows.skip(from).take(moving.span),
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
}
