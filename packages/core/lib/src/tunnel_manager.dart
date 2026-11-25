import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:core/src/tunnel.dart';
import 'package:core/src/tunnel_book.dart';
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

  /// Answers what ssh asks while [Tunnel] logs in; without it, ssh asks
  /// nothing.
  final Future<String?> Function(Tunnel tunnel, SshPrompt prompt)? onPrompt,
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

  TunnelBook get book =>
      TunnelBook(tunnels: state.tunnels, groupColours: state.groupColours);

  Future<void> load() async {
    final (:book, :on) = await store.load();
    _wasOn = on;
    _emit(book.pruned);
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
    await _persist(book.saved(tunnel));

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
    final edited = book.groupEdited(group, name: name, colour: colour);
    if (edited != book) await _persist(edited);
  }

  Future<void> import(
    List<Tunnel> tunnels, {
    Map<String, TunnelColour> groupColours = const {},
  }) async {
    final imported = book.imported(
      TunnelBook(tunnels: tunnels, groupColours: groupColours),
    );
    if (imported != book) await _persist(imported);
  }

  Future<void> remove(String id) async {
    await _sessions.remove(id)?.stop();
    await _persist(book.removed(id));
  }

  Future<void> arrange(List<({String id, String? group})> order) async {
    final arranged = book.arranged(order);
    if (arranged != book) await _persist(arranged);
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
  Future<void> close() => _closing ??= () async {
    await Future.wait(_sessions.values.map((session) => session.stop()));
    await super.close();
  }();

  // Another call may have started it while this one waited, such as a toggle
  // while save stopped it: a second session would leave ssh running untracked.
  Future<void> _start(Tunnel tunnel, {bool isRestored = false}) {
    if (_closing != null || _isOn(tunnel.id)) return Future.value();

    if (_sessions[tunnel.id] case final replaced?) unawaited(replaced.stop());
    final session = _sessions[tunnel.id] = TunnelSession(
      tunnel: tunnel,
      client: client,
      comeForward: comeForward,
      onPrompt: switch (onPrompt) {
        final ask? => (prompt) => ask(tunnel, prompt),
        null => null,
      },
      isLocked: isLocked,
      checkDestination: checkDestination,
      warningLifetime: warningLifetime,
      checkWindow: checkWindow,
      retryDelays: retryDelays,
      lockedRecheck: lockedRecheck,
      stableAfter: stableAfter,
      isRestored: isRestored,
    );
    session.stream
        .map((state) => state.status)
        .distinct()
        .listen((_) => _emit());
    _emit();
    _log.i('Connecting ${tunnel.title}: ${tunnel.summary}');
    return session.connect();
  }

  bool _isOn(String id) => _sessions[id]?.status.isOn ?? false;

  Set<String> get _on => {
    for (final MapEntry(key: id, value: session) in _sessions.entries)
      if (session.status.isOn) id,
  };

  Future<void> _persist(TunnelBook book) {
    _savedOn = _on;
    _emit(book);
    return store.save(book, on: _savedOn);
  }

  void _emit([TunnelBook? book]) {
    if (_closing != null) return;

    final TunnelBook(:tunnels, :groupColours) = book ?? this.book;
    emit(
      TunnelsSnapshot(
        tunnels: tunnels,
        statuses: _sessions.map((id, session) => MapEntry(id, session.status)),
        groupColours: groupColours,
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
          .save(
            TunnelBook(tunnels: tunnels, groupColours: groupColours),
            on: on,
          )
          .catchError(
            (Object exception) =>
                _log.w('Could not save which tunnels are on', ex: exception),
          ),
    );
  }
}
