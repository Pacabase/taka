import 'package:collection/collection.dart';
import 'package:core/src/tunnel.dart';
import 'package:core/src/tunnel_colour.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tunnel_book.freezed.dart';

/// The saved tunnels and each group's colour. Every edit leaves out the
/// colour of a group no tunnel is in.
@freezed
sealed class const TunnelBook._() with _$TunnelBook {
  const factory({
    @Default([]) List<Tunnel> tunnels,
    @Default({}) Map<String, TunnelColour> groupColours,
  }) = _TunnelBook;

  // An emptied group's colour goes, so a new one of its name starts with none.
  TunnelBook get pruned {
    final groups = {for (final tunnel in tunnels) ?tunnel.group};
    return copyWith(
      groupColours: {
        for (final MapEntry(key: group, value: colour) in groupColours.entries)
          if (groups.contains(group)) group: colour,
      },
    );
  }

  TunnelBook saved(Tunnel tunnel) {
    final previous = tunnels.firstWhereOrNull((saved) => saved.id == tunnel.id);
    var placed = [
      for (final saved in tunnels) saved.id == tunnel.id ? tunnel : saved,
      if (previous == null) tunnel,
    ];
    // Otherwise a group shows where its first tunnel is, so it could jump.
    if (tunnel.group case final group? when previous?.group != group) {
      final others = placed.where((saved) => saved.id != tunnel.id).toList();
      final last = others.lastIndexWhere((saved) => saved.group == group);
      if (last != -1) placed = others..insert(last + 1, tunnel);
    }
    return copyWith(tunnels: placed).pruned;
  }

  TunnelBook removed(String id) =>
      copyWith(tunnels: tunnels.where((tunnel) => tunnel.id != id).toList())
          .pruned;

  /// Gives [group] the [name], or the spelling of a group in use like it,
  /// and the [colour].
  TunnelBook groupEdited(
    String group, {
    required String name,
    required TunnelColour? colour,
  }) {
    if (!tunnels.any((tunnel) => tunnel.group == group)) return this;
    final renamed = switch (groupNamed(name)) {
      final typed? when typed != group => groupLike(
        tunnels.groups,
        typed,
        except: group,
      ),
      _ => group,
    };
    return TunnelBook(
      tunnels: [
        for (final tunnel in tunnels)
          tunnel.group == group ? tunnel.copyWith(group: renamed) : tunnel,
      ],
      groupColours: {
        for (final MapEntry(key: named, value: kept) in groupColours.entries)
          if (named != group && named != renamed) named: kept,
        // A group joined with no colour picked keeps its own.
        renamed: ?(colour ?? (renamed == group ? null : groupColours[renamed])),
      },
    ).pruned;
  }

  /// With the tunnels of [other] not saved here yet, each in the group here
  /// of its name in any case.
  TunnelBook imported(TunnelBook other) {
    final imported = [...tunnels];
    final ids = {for (final saved in imported) saved.id};
    for (final read in other.tunnels) {
      final tunnel = read.copyWith(
        group: switch (read.group) {
          final group? => groupLike(imported.groups, group),
          null => null,
        },
      );
      // A tunnel already saved stays in the group it has here.
      if (imported.any(
        (saved) =>
            tunnel.copyWith(
              id: saved.id,
              group: saved.group,
              colour: saved.colour,
            ) ==
            saved,
      )) {
        continue;
      }
      var id = tunnel.id;
      for (var copy = 2; ids.contains(id); copy++) {
        id = '${tunnel.id}-$copy';
      }
      ids.add(id);
      imported.add(tunnel.copyWith(id: id));
    }
    return TunnelBook(
      tunnels: imported,
      // A group that has a colour here keeps it.
      groupColours: {
        for (final MapEntry(key: group, value: colour)
            in other.groupColours.entries)
          if (groupNamed(group) case final named?)
            groupLike(imported.groups, named): colour,
        ...groupColours,
      },
    ).pruned;
  }

  /// In [order]'s order and groups; tunnels it leaves out keep theirs, after.
  TunnelBook arranged(List<({String id, String? group})> order) =>
      copyWith(tunnels: tunnels.arranged(order)).pruned;
}
