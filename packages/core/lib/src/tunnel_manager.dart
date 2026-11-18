import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:core/src/tunnel.dart';
import 'package:core/src/tunnel_colour.dart';
import 'package:core/src/tunnel_session.dart';
import 'package:core/src/tunnel_store.dart';
import 'package:core/src/tunnels_snapshot.dart';
import 'package:fimber/fimber.dart';
import 'package:system_ssh/system_ssh.dart';

final _log = FimberLog('Tunnels');

class TunnelManager({
  required final TunnelStore store,
  required final SshClient client,

  /// Runs as ssh connects for a tunnel that hasn't been up yet.
  final Future<HandBack> Function()? comeForward,
  final Future<bool> Function()? isLocked,
  final Future<void> Function(String address, int localPort)? checkDestination,
  final Duration warningLifetime = const Duration(seconds: 30),

  /// How long after the check ssh may still say the destination refused it.
  final Duration checkWindow = const Duration(seconds: 2),

  /// A dropped tunnel fails once a try after the last delay fails too.
  final List<Duration> retryDelays = const [
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 4),
    Duration(seconds: 8),
    Duration(seconds: 15),
    Duration(seconds: 30),
    Duration(minutes: 1),
    Duration(minutes: 2),
  ],
  final Duration lockedRecheck = const Duration(seconds: 5),
  final Duration stableAfter = const Duration(minutes: 1),
}) extends Cubit<TunnelsSnapshot> {
  final Map<String, TunnelSession> _sessions = {};
  Future<void>? _closing;
  Set<String> _savedOn = const {};
  Set<String> _wasOn = const {};

  @override
  String toString() => 'TunnelManager';

  this : super(const TunnelsSnapshot());

  Future<void> load() async {
    final (:tunnels, :on, :groupColours) = await store.load();
    _wasOn = on;
    _emit(tunnels: tunnels, groupColours: _inUse(groupColours, tunnels));
  }

  /// Restored tunnels retry on failure: at login, the network may not be up yet.
  Future<void> restore() {
    final wasOn = _wasOn;
    _wasOn = const {};

    return Future.wait([
      for (final tunnel in state.tunnels)
        if (wasOn.contains(tunnel.id) && !_isOn(tunnel.id))
          _start(tunnel, isRestored: true),
    ]);
  }

  Future<void> save(Tunnel tunnel) async {
    final previous = state.tunnels.firstWhereOrNull(
      (saved) => saved.id == tunnel.id,
    );
    var tunnels = [
      for (final saved in state.tunnels) saved.id == tunnel.id ? tunnel : saved,
      if (previous == null) tunnel,
    ];
    // Otherwise a group shows where its first tunnel is, so it could jump.
    if (tunnel.group case final group? when previous?.group != group) {
      final others = tunnels.where((saved) => saved.id != tunnel.id).toList();
      final last = others.lastIndexWhere((saved) => saved.group == group);
      if (last != -1) tunnels = others..insert(last + 1, tunnel);
    }
    await _persist(tunnels: tunnels);

    final isWanted =
        _isOn(tunnel.id) || _sessions[tunnel.id]?.status is UnknownHostKey;
    final isRelabelled =
        previous?.copyWith(
          name: tunnel.name,
          group: tunnel.group,
          colour: tunnel.colour,
        ) ==
        tunnel;
    if (isWanted && !isRelabelled) {
      final running = _sessions.remove(tunnel.id)!;
      _log.i('Stopping ${running.tunnel.title}');
      await running.stop();
      await _start(tunnel);
    }
  }

  /// Gives [group] the [name], or the spelling of a group in use like it,
  /// and the [colour], in one save.
  Future<void> editGroup(
    String group, {
    required String name,
    required TunnelColour? colour,
  }) async {
    if (!state.tunnels.any((tunnel) => tunnel.group == group)) return;
    final renamed = switch (groupNamed(name)) {
      final typed? when typed != group => groupLike(
        state.tunnels.groups,
        typed,
        except: group,
      ),
      _ => group,
    };
    final regrouped = [
      for (final tunnel in state.tunnels)
        tunnel.group == group ? tunnel.copyWith(group: renamed) : tunnel,
    ];
    final coloured = {
      for (final MapEntry(key: named, value: kept)
          in state.groupColours.entries)
        if (named != group && named != renamed) named: kept,
      // A group joined with no colour picked keeps its own.
      renamed:
          ?(colour ?? (renamed == group ? null : state.groupColours[renamed])),
    };
    if (const ListEquality<Tunnel>().equals(regrouped, state.tunnels) &&
        const MapEquality<String, TunnelColour>().equals(
          coloured,
          state.groupColours,
        )) {
      return;
    }

    await _persist(tunnels: regrouped, groupColours: coloured);
  }

  Future<void> import(
    List<Tunnel> tunnels, {
    Map<String, TunnelColour> groupColours = const {},
  }) async {
    final imported = [...state.tunnels];
    final ids = {for (final saved in imported) saved.id};
    for (final read in tunnels) {
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
    // A group that has a colour here keeps it.
    final coloured = {
      for (final MapEntry(key: group, value: colour) in groupColours.entries)
        if (groupNamed(group) case final named?)
          groupLike(imported.groups, named): colour,
      ...state.groupColours,
    };
    if (imported.length == state.tunnels.length &&
        const MapEquality<String, TunnelColour>().equals(
          _inUse(coloured, imported),
          state.groupColours,
        )) {
      return;
    }

    await _persist(tunnels: imported, groupColours: coloured);
  }

  Future<void> remove(String id) async {
    await _sessions.remove(id)?.stop();
    await _persist(
      tunnels: state.tunnels.where((tunnel) => tunnel.id != id).toList(),
    );
  }

  Future<void> arrange(List<({String id, String? group})> order) async {
    final arranged = state.tunnels.arranged(order);
    if (const ListEquality<Tunnel>().equals(arranged, state.tunnels)) return;

    await _persist(tunnels: arranged);
  }

  Future<void> toggle(String id) async {
    if (_sessions[id] case final running? when running.status.isOn) {
      _sessions.remove(id);
      _emit();
      _log.i('Stopping ${running.tunnel.title}');
      return running.stop();
    }

    if (state.tunnels.firstWhereOrNull((tunnel) => tunnel.id == id)
        case final tunnel?) {
      return _start(tunnel);
    }
  }

  /// [fingerprint] is the one the user saw; another key by now isn't trusted.
  Future<void> trustHostKey(String id, String fingerprint) async {
    final asked = _sessions[id];
    final status = asked?.status;
    if (asked == null ||
        status is! UnknownHostKey ||
        status.fingerprint != fingerprint) {
      return;
    }

    if (!await asked.trust()) return;

    await Future.wait([
      asked.connect(),
      for (final session in [..._sessions.values])
        if (session.status == status) _start(session.tunnel),
    ]);
  }

  Future<void> connectAll({String? group}) =>
      Future.wait(_idsIn(group).whereNot(_isOn).map(toggle));

  Future<void> disconnectAll({String? group}) =>
      Future.wait(_idsIn(group).where(_isOn).map(toggle));

  List<String> _idsIn(String? group) => [
    for (final tunnel in state.tunnels)
      if (group == null || tunnel.group == group) tunnel.id,
  ];

  // A listener may call close again from inside this call.
  @override
  Future<void> close() async {
    final isFirst = _closing == null;
    await (_closing ??= _stopAll());
    if (isFirst) await super.close();
  }

  Future<void> _stopAll() async {
    await Future.wait(
      _sessions.values.map(
        (session) => session.stop().catchError(
          (Object exception) => _log.w(
            '${session.tunnel.title}: could not close ssh ($exception)',
          ),
        ),
      ),
    );
  }

  // Another call may have started it while this one waited, such as a toggle
  // while save stopped it: a second session would leave ssh running untracked.
  Future<void> _start(Tunnel tunnel, {bool isRestored = false}) {
    if (_closing != null || _isOn(tunnel.id)) return Future.value();

    if (_sessions[tunnel.id] case final replaced?) {
      unawaited(
        replaced.stop().catchError(
          (Object exception) =>
              _log.w('${tunnel.title}: could not close ssh ($exception)'),
        ),
      );
    }
    final session = _sessions[tunnel.id] = TunnelSession(
      tunnel: tunnel,
      client: client,
      notify: _emit,
      comeForward: comeForward,
      isLocked: isLocked,
      checkDestination: checkDestination,
      warningLifetime: warningLifetime,
      checkWindow: checkWindow,
      retryDelays: retryDelays,
      lockedRecheck: lockedRecheck,
      stableAfter: stableAfter,
      isRestored: isRestored,
    );
    _emit();
    _log.i('Connecting ${tunnel.title}: ${tunnel.summary}');
    return session.connect();
  }

  // An emptied group's colour goes, so a new one of its name starts with none.
  Map<String, TunnelColour> _inUse(
    Map<String, TunnelColour> colours, [
    List<Tunnel>? tunnels,
  ]) {
    final groups = (tunnels ?? state.tunnels)
        .map((tunnel) => tunnel.group)
        .toSet();
    return {
      for (final MapEntry(key: group, value: colour) in colours.entries)
        if (groups.contains(group)) group: colour,
    };
  }

  bool _isOn(String id) => _sessions[id]?.status.isOn ?? false;

  Set<String> get _on => {
    for (final MapEntry(key: id, value: session) in _sessions.entries)
      if (session.status.isOn) id,
  };

  Future<void> _persist({
    List<Tunnel>? tunnels,
    Map<String, TunnelColour>? groupColours,
  }) {
    final kept = tunnels ?? state.tunnels;
    final colours = _inUse(groupColours ?? state.groupColours, kept);
    _savedOn = _on;
    _emit(tunnels: kept, groupColours: colours);
    return store.save(kept, on: _savedOn, groupColours: colours);
  }

  void _emit({List<Tunnel>? tunnels, Map<String, TunnelColour>? groupColours}) {
    if (_closing != null) return;

    emit(
      TunnelsSnapshot(
        tunnels: tunnels ?? state.tunnels,
        statuses: _sessions.map((id, session) => MapEntry(id, session.status)),
        groupColours: groupColours ?? state.groupColours,
      ),
    );
  }

  // Which tunnels are on is saved when it changes, so a crash restores them too.
  @override
  void onChange(Change<TunnelsSnapshot> change) {
    super.onChange(change);
    final TunnelsSnapshot(:tunnels, :statuses, :groupColours) =
        change.nextState;
    final on = {
      for (final MapEntry(key: id, value: status) in statuses.entries)
        if (status.isOn) id,
    };
    if (const SetEquality<String>().equals(on, _savedOn)) return;

    _savedOn = on;
    unawaited(
      store
          .save(tunnels, on: on, groupColours: groupColours)
          .catchError(
            (Object exception) =>
                _log.w('Could not save which tunnels are on', ex: exception),
          ),
    );
  }
}
