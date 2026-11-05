import 'dart:async';

import 'package:collection/collection.dart';
import 'package:core/src/agent_command.dart';
import 'package:core/src/tunnel.dart';
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
  final Duration warningLifetime = const Duration(seconds: 30),
  final List<Duration> retryDelays = const [
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 4),
    Duration(seconds: 8),
    Duration(seconds: 15),
    Duration(seconds: 30),
  ],
  final Duration stableAfter = const Duration(minutes: 1),
}) {
  final _changes = StreamController<TunnelsSnapshot>.broadcast(sync: true);
  final Map<String, TunnelSession> _sessions = {};
  final _closed = Completer<void>();
  List<Tunnel> _tunnels = const [];
  Set<String> _savedOn = const {};
  Set<String> _wasOn = const {};

  TunnelsSnapshot get snapshot => TunnelsSnapshot(
    tunnels: _tunnels,
    statuses: _sessions.map((id, session) => MapEntry(id, session.status)),
  );

  Stream<TunnelsSnapshot> get changes => _changes.stream;

  Future<void> load() async {
    final (:tunnels, :on) = await store.load();
    _tunnels = tunnels;
    _wasOn = on;
    _emit();
  }

  /// Turns back on the tunnels that were on when Taka last stopped. Unlike a
  /// tunnel the user just turned on, one that fails to connect tries again:
  /// at login, the network may not be up yet.
  Future<void> restore() => Future.wait([
    for (final tunnel in _tunnels)
      if (_wasOn.contains(tunnel.id) && !_isOn(tunnel.id))
        _start(tunnel, isRestored: true),
  ]);

  Future<void> handle(AgentCommand command) => switch (command) {
    SaveTunnel(:final tunnel) => save(tunnel),
    RemoveTunnel(:final id) => remove(id),
    ToggleTunnel(:final id) => toggle(id),
    MoveTunnel(:final id, :final index) => move(id, index),
    QuitAgent() => close(),
  };

  Future<void> save(Tunnel tunnel) async {
    final previous = _tunnels.firstWhereOrNull(
      (saved) => saved.id == tunnel.id,
    );
    _tunnels = [
      for (final saved in _tunnels) saved.id == tunnel.id ? tunnel : saved,
      if (previous == null) tunnel,
    ];
    await _persist();

    if (_isOn(tunnel.id) && previous?.copyWith(name: tunnel.name) != tunnel) {
      await toggle(tunnel.id);
      await toggle(tunnel.id);
    }
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

  Future<void> connectAll() => Future.wait(
    _tunnels.map((tunnel) => tunnel.id).whereNot(_isOn).map(toggle),
  );

  Future<void> disconnectAll() =>
      Future.wait([..._sessions.keys].where(_isOn).map(toggle));

  // A listener of changes may call close again from inside the first call,
  // and waits for the same tunnels to stop.
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
      warningLifetime: warningLifetime,
      retryDelays: retryDelays,
      stableAfter: stableAfter,
      isRestored: isRestored,
    );
    _emit();
    _log.i('Connecting ${tunnel.title}: ${tunnel.summary}');
    return session.connect();
  }

  bool _isOn(String id) => _sessions[id]?.status.isOn ?? false;

  Set<String> get _on => {
    for (final MapEntry(key: id, value: session) in _sessions.entries)
      if (session.status.isOn) id,
  };

  Future<void> _persist() {
    _savedOn = _on;
    _emit();
    return store.save(_tunnels, on: _savedOn);
  }

  // Which tunnels are on is saved when it changes, so a crash restores them too.
  void _emit() {
    if (_changes.isClosed) return;

    _changes.add(snapshot);
    if (!const SetEquality<String>().equals(_on, _savedOn)) {
      _savedOn = _on;
      unawaited(
        store
            .save(_tunnels, on: _savedOn)
            .catchError(
              (Object exception) =>
                  _log.w('Could not save which tunnels are on', ex: exception),
            ),
      );
    }
  }
}
