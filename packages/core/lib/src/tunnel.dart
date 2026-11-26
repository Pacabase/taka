import 'package:collection/collection.dart';
import 'package:core/src/tunnel_colour.dart';
import 'package:core/src/tunnel_forward.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:system_ssh/system_ssh.dart';

export 'package:core/src/tunnel_forward.dart';

part 'tunnel.freezed.dart';

@freezed
sealed class const Tunnel._() with _$Tunnel {
  /// [sshHost] is a `~/.ssh/config` alias, a host or `user@host`.
  const factory({
    required String id,
    @Default('') String name,
    @Default('') String sshHost,
    required TunnelForward forward,
    String? group,

    /// Shown when its group has no colour of its own.
    TunnelColour? colour,
  }) = _Tunnel;

  static Tunnel fromJson(Object? json) {
    if (json
        case {'id': final String id} && final Map<Object?, Object?> fields) {
      T? field<T>(String key) => switch (fields[key]) {
        final T value => value,
        _ => null,
      };

      return Tunnel(
        id: id,
        name: field<String>('name') ?? '',
        sshHost: field<String>('sshHost') ?? '',
        forward: TunnelForward.fromJson(fields),
        group: groupNamed(field<String>('group')),
        colour: TunnelColour.fromName(fields['colour']),
      );
    }

    throw FormatException('Not a tunnel: $json');
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'sshHost': sshHost,
    ...forward.toJson(),
    'group': ?group,
    'colour': ?colour?.name,
  };

  TunnelKind get kind => forward.kind;

  SshTarget get target {
    final at = sshHost.lastIndexOf('@');
    return at == -1
        ? SshTarget(sshHost)
        : SshTarget(sshHost.substring(at + 1), user: sshHost.substring(0, at));
  }

  String get title => name.isNotEmpty ? name : summary;

  String get address => forward.address;

  /// Null for a tunnel ssh can't open, such as a local port outside 1 to 65535.
  String? get sshCommand {
    try {
      return forward.sshCommand(target);
    } on ArgumentError {
      return null;
    }
  }

  String get summary => forward.summary(sshHost);

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

/// The group in [groups] that [typed] names in another case, other than
/// [except], or [typed] itself, so one group never shows up twice.
String groupLike(Iterable<String> groups, String typed, {String? except}) =>
    groups
        .where(
          (group) =>
              group != except && group.toLowerCase() == typed.toLowerCase(),
        )
        .firstOrNull ??
    typed;

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

  /// The group tunnel row [from] of [rows] would be in, dropped at [to].
  String? groupOnDrop(int from, int to) {
    final rows = this.rows;
    final others = _without(rows, from);
    return _groupAt(others, _landing(rows, others, from, to));
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
