import 'dart:async';

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
  final Future<void> Function()? beforeConnect,
  final Future<bool> Function()? isLocked,
  final Duration warningLifetime = const Duration(seconds: 30),

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
}) {
  final _changes = StreamController<TunnelsSnapshot>.broadcast(sync: true);
  final Map<String, TunnelSession> _sessions = {};
  final _closed = Completer<void>();
  List<Tunnel> _tunnels = const [];
  Map<String, TunnelColour> _groupColours = const {};
  Set<String> _savedOn = const {};
  Set<String> _wasOn = const {};

  TunnelsSnapshot get snapshot => TunnelsSnapshot(
    tunnels: _tunnels,
    statuses: _sessions.map((id, session) => MapEntry(id, session.status)),
    groupColours: _coloursInUse,
  );

  Stream<TunnelsSnapshot> get changes => _changes.stream;

  Future<void> load() async {
    final (:tunnels, :on, :groupColours) = await store.load();
    _tunnels = tunnels;
    _groupColours = groupColours;
    _wasOn = on;
    _emit();
  }

  /// Restored tunnels retry on failure: at login, the network may not be up yet.
  Future<void> restore() {
    final wasOn = _wasOn;
    _wasOn = const {};

    return Future.wait([
      for (final tunnel in _tunnels)
        if (wasOn.contains(tunnel.id) && !_isOn(tunnel.id))
          _start(tunnel, isRestored: true),
    ]);
  }

  Future<void> save(Tunnel tunnel) async {
    final previous = _tunnels.firstWhereOrNull(
      (saved) => saved.id == tunnel.id,
    );
    _tunnels = [
      for (final saved in _tunnels) saved.id == tunnel.id ? tunnel : saved,
      if (previous == null) tunnel,
    ];
    await _persist();

    final isWanted =
        _isOn(tunnel.id) || _sessions[tunnel.id]?.status is UnknownHostKey;
    final isRenamed =
        previous?.copyWith(name: tunnel.name, group: tunnel.group) == tunnel;
    if (isWanted && !isRenamed) {
      final running = _sessions.remove(tunnel.id)!;
      _log.i('Stopping ${running.tunnel.title}');
      await running.stop();
      await _start(tunnel);
    }
  }

  Future<void> setGroupColour(String group, TunnelColour? colour) async {
    _groupColours = {
      for (final MapEntry(key: named, value: kept) in _groupColours.entries)
        if (named != group) named: kept,
      group: ?colour,
    };
    await _persist();
  }

  Future<void> import(List<Tunnel> tunnels) async {
    final imported = [..._tunnels];
    final ids = {for (final saved in imported) saved.id};
    for (final tunnel in tunnels) {
      if (imported.any((saved) => tunnel.copyWith(id: saved.id) == saved)) {
        continue;
      }
      var id = tunnel.id;
      for (var copy = 2; ids.contains(id); copy++) {
        id = '${tunnel.id}-$copy';
      }
      ids.add(id);
      imported.add(tunnel.copyWith(id: id));
    }
    if (imported.length == _tunnels.length) return;

    _tunnels = imported;
    await _persist();
  }

  Future<void> remove(String id) async {
    await _sessions.remove(id)?.stop();
    _tunnels = _tunnels.where((tunnel) => tunnel.id != id).toList();
    await _persist();
  }

  Future<void> move(String id, int index) async {
    final moved = _tunnels.moved(id, index);
    if (identical(moved, _tunnels)) return;

    _tunnels = moved;
    await _persist();
  }

  Future<void> toggle(String id) async {
    if (_sessions[id] case final running? when running.status.isOn) {
      _sessions.remove(id);
      _emit();
      _log.i('Stopping ${running.tunnel.title}');
      return running.stop();
    }

    if (_tunnels.firstWhereOrNull((tunnel) => tunnel.id == id)
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

  /// Every tunnel, or only those in [group].
  Future<void> connectAll({String? group}) =>
      Future.wait(_idsIn(group).whereNot(_isOn).map(toggle));

  Future<void> disconnectAll({String? group}) =>
      Future.wait(_idsIn(group).where(_isOn).map(toggle));

  List<String> _idsIn(String? group) => [
    for (final tunnel in _tunnels)
      if (group == null || tunnel.group == group) tunnel.id,
  ];

  // A changes listener may call close again from inside this call.
  Future<void> close() async {
    if (!_changes.isClosed) {
      final changesClosed = _changes.close();
      await Future.wait(_sessions.values.map((session) => session.stop()));
      await changesClosed;
      _closed.complete();
    }
    return _closed.future;
  }

  Future<void> _start(Tunnel tunnel, {bool isRestored = false}) {
    if (_changes.isClosed) return Future.value();

    final session = _sessions[tunnel.id] = TunnelSession(
      tunnel: tunnel,
      client: client,
      onChange: _emit,
      beforeConnect: beforeConnect,
      isLocked: isLocked,
      warningLifetime: warningLifetime,
      retryDelays: retryDelays,
      lockedRecheck: lockedRecheck,
      stableAfter: stableAfter,
      isRestored: isRestored,
    );
    _emit();
    _log.i('Connecting ${tunnel.title}: ${tunnel.summary}');
    return session.connect();
  }

  // A group with no tunnels left loses its colour.
  Map<String, TunnelColour> get _coloursInUse {
    final groups = _tunnels.groups.toSet();
    return {
      for (final MapEntry(key: group, value: colour) in _groupColours.entries)
        if (groups.contains(group)) group: colour,
    };
  }

  bool _isOn(String id) => _sessions[id]?.status.isOn ?? false;

  Set<String> get _on => {
    for (final MapEntry(key: id, value: session) in _sessions.entries)
      if (session.status.isOn) id,
  };

  Future<void> _persist() {
    _savedOn = _on;
    _emit();
    return store.save(_tunnels, on: _savedOn, groupColours: _coloursInUse);
  }

  // Which tunnels are on is saved when it changes, so a crash restores them too.
  void _emit() {
    if (_changes.isClosed) return;

    _changes.add(snapshot);
    if (_on case final on
        when !const SetEquality<String>().equals(on, _savedOn)) {
      _savedOn = on;
      unawaited(
        store
            .save(_tunnels, on: _savedOn, groupColours: _coloursInUse)
            .catchError(
              (Object exception) =>
                  _log.w('Could not save which tunnels are on', ex: exception),
            ),
      );
    }
  }
}
