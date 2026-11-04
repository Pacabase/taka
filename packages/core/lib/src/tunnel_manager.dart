import 'dart:async';

import 'package:collection/collection.dart';
import 'package:core/src/tunnel.dart';
import 'package:core/src/tunnel_store.dart';
import 'package:core/src/tunnels_snapshot.dart';
import 'package:system_ssh/system_ssh.dart';

class TunnelManager({
  required final TunnelStore store,
  required final SshClient client,
}) {
  final _changes = StreamController<TunnelsSnapshot>.broadcast(sync: true);
  final Map<String, _Session> _sessions = {};
  TunnelsSnapshot _snapshot = const TunnelsSnapshot();
  bool _isClosed = false;

  TunnelsSnapshot get snapshot => _snapshot;

  Stream<TunnelsSnapshot> get changes => _changes.stream;

  Future<void> load() async =>
      _emit(_snapshot.copyWith(tunnels: await store.load()));

  Future<void> save(Tunnel tunnel) async {
    final exists = _snapshot.tunnels.any((saved) => saved.id == tunnel.id);
    final tunnels = exists
        ? [
            for (final saved in _snapshot.tunnels)
              saved.id == tunnel.id ? tunnel : saved,
          ]
        : [..._snapshot.tunnels, tunnel];
    _emit(_snapshot.copyWith(tunnels: tunnels));
    await store.save(tunnels);
  }

  Future<void> remove(String id) async {
    await _sessions.remove(id)?.stop();
    final tunnels = _snapshot.tunnels
        .where((tunnel) => tunnel.id != id)
        .toList();
    _emit(
      _snapshot.copyWith(
        tunnels: tunnels,
        statuses: {..._snapshot.statuses}..remove(id),
      ),
    );
    await store.save(tunnels);
  }

  Future<void> toggle(String id) async {
    if (_sessions.remove(id) case final session?) {
      _emit(_snapshot.withStatus(id, const Stopped()));
      return session.stop();
    }

    final tunnel = _snapshot.tunnels.firstWhereOrNull(
      (tunnel) => tunnel.id == id,
    );
    if (tunnel == null || _isClosed) return;

    final session = _sessions[id] = _Session();
    _emit(_snapshot.withStatus(id, const Connecting()));
    try {
      final opened = await _open(tunnel, session.abort.future);
      if (_sessions[id] != session) {
        await opened.close();
        return;
      }

      session.tunnel = opened;
      _emit(_snapshot.withStatus(id, const Connected()));
      unawaited(opened.done.then((_) => _fail(id, session, 'Disconnected')));
    } on Object catch (exception) {
      _fail(id, session, switch (exception) {
        SshException(:final message) => message,
        ArgumentError(:final message) => '$message',
        _ => '$exception',
      });
    }
  }

  /// Only for the session still current, so a stale one can't touch the snapshot.
  void _fail(String id, _Session session, String message) {
    if (_sessions[id] != session) return;

    _sessions.remove(id);
    _emit(_snapshot.withStatus(id, Failed(message)));
  }

  Future<void> connectAll() => Future.wait(
    _snapshot.tunnels
        .where((tunnel) => !_snapshot.statusOf(tunnel.id).isOn)
        .map((tunnel) => toggle(tunnel.id)),
  );

  Future<void> disconnectAll() => Future.wait(
    _snapshot.tunnels
        .where((tunnel) => _snapshot.statusOf(tunnel.id).isOn)
        .map((tunnel) => toggle(tunnel.id)),
  );

  Future<void> close() async {
    if (_isClosed) return;
    _isClosed = true;

    final sessions = [..._sessions.values];
    _sessions.clear();
    await Future.wait(sessions.map((session) => session.stop()));
    await _changes.close();
  }

  Future<SshTunnel> _open(Tunnel tunnel, Future<void> abortTrigger) =>
      switch (tunnel) {
        Tunnel(
          kind: TunnelKind.local,
          :final remoteHost?,
          :final remotePort?,
        ) =>
          client.openTunnel(
            tunnel.target,
            remoteHost: remoteHost,
            remotePort: remotePort,
            localPort: tunnel.localPort,
            abortTrigger: abortTrigger,
          ),
        Tunnel(kind: TunnelKind.local) => throw ArgumentError(
          'A local tunnel needs a remote host and port',
        ),
        Tunnel(kind: TunnelKind.socks) => client.openSocksProxy(
          tunnel.target,
          localPort: tunnel.localPort,
          abortTrigger: abortTrigger,
        ),
      };

  void _emit(TunnelsSnapshot snapshot) {
    _snapshot = snapshot;
    if (!_changes.isClosed) _changes.add(snapshot);
  }
}

class _Session {
  final abort = Completer<void>();
  SshTunnel? tunnel;

  Future<void> stop() async {
    if (!abort.isCompleted) abort.complete();
    await tunnel?.close();
  }
}
