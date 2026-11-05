import 'dart:async';

import 'package:collection/collection.dart';
import 'package:core/src/agent_command.dart';
import 'package:core/src/tunnel.dart';
import 'package:core/src/tunnel_store.dart';
import 'package:core/src/tunnels_snapshot.dart';
import 'package:system_ssh/system_ssh.dart';

class TunnelManager({
  required final TunnelStore store,
  required final SshClient client,
  final Future<void> Function()? beforeConnect,
}) {
  final _changes = StreamController<TunnelsSnapshot>.broadcast(sync: true);
  final Map<String, _Session> _sessions = {};
  List<Tunnel> _tunnels = const [];

  TunnelsSnapshot get snapshot => TunnelsSnapshot(
    tunnels: _tunnels,
    statuses: _sessions.map((id, session) => MapEntry(id, session.status)),
  );

  Stream<TunnelsSnapshot> get changes => _changes.stream;

  Future<void> load() async {
    _tunnels = await store.load();
    _emit();
  }

  Future<void> handle(AgentCommand command) => switch (command) {
    SaveTunnel(:final tunnel) => save(tunnel),
    RemoveTunnel(:final id) => remove(id),
    ToggleTunnel(:final id) => toggle(id),
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

  Future<void> toggle(String id) async {
    if (_sessions[id] case final running? when running.status.isOn) {
      _sessions.remove(id);
      _emit();
      return running.stop();
    }

    final tunnel = _tunnels.firstWhereOrNull((tunnel) => tunnel.id == id);
    if (_changes.isClosed || tunnel == null) return;

    final session = _sessions[id] = _Session();
    _emit();
    final SshTunnel opened;
    try {
      await beforeConnect?.call();
      opened = session.tunnel = await _open(tunnel, session.abort.future);
    } on Object catch (exception) {
      return _fail(session, _messageOf(exception));
    }
    if (session.isStopped) return opened.close();

    session.status = const Connected();
    _emit();
    unawaited(opened.done.then((_) => _fail(session, 'Disconnected')));
  }

  Future<void> connectAll() => Future.wait(
    _tunnels.map((tunnel) => tunnel.id).whereNot(_isOn).map(toggle),
  );

  Future<void> disconnectAll() =>
      Future.wait([..._sessions.keys].where(_isOn).map(toggle));

  Future<void> close() async {
    if (_changes.isClosed) return;

    final changesClosed = _changes.close();
    await Future.wait(_sessions.values.map((session) => session.stop()));
    await changesClosed;
  }

  bool _isOn(String id) => _sessions[id]?.status.isOn ?? false;

  Future<SshTunnel> _open(Tunnel tunnel, Future<void> abortTrigger) =>
      switch (tunnel) {
        Tunnel(kind: TunnelKind.socks) => client.openSocksProxy(
          tunnel.target,
          localPort: tunnel.localPort,
          abortTrigger: abortTrigger,
        ),
        Tunnel(:final remoteHost?, :final remotePort?) => client.openTunnel(
          tunnel.target,
          remoteHost: remoteHost,
          remotePort: remotePort,
          localPort: tunnel.localPort,
          abortTrigger: abortTrigger,
        ),
        _ => throw ArgumentError('A local tunnel needs a remote host and port'),
      };

  String _messageOf(Object exception) => switch (exception) {
    SshException(:final message) => message,
    ArgumentError(:final message) => '$message',
    _ => '$exception',
  };

  void _fail(_Session session, String message) {
    if (session.isStopped) return;

    session.status = Failed(message);
    _emit();
  }

  Future<void> _persist() {
    _emit();
    return store.save(_tunnels);
  }

  void _emit() {
    if (!_changes.isClosed) _changes.add(snapshot);
  }
}

class _Session {
  final abort = Completer<void>();
  TunnelStatus status = const Connecting();
  SshTunnel? tunnel;

  bool get isStopped => abort.isCompleted;

  Future<void> stop() async {
    if (!isStopped) abort.complete();
    await tunnel?.close();
  }
}
