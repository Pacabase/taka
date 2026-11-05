import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:core/src/agent_command.dart';
import 'package:core/src/tunnel.dart';
import 'package:core/src/tunnel_store.dart';
import 'package:core/src/tunnels_snapshot.dart';
import 'package:fimber/fimber.dart';
import 'package:system_ssh/system_ssh.dart';

final _log = FimberLog('Tunnels');
final _sshLog = FimberLog('ssh');

// "channel 2: open failed: connect failed: Connection refused", or
// "channel 3: open failed: administratively prohibited: open failed".
final _openFailed = RegExp(
  r'open failed: (?:connect failed: )?(.+?)(?:: open failed)?$',
);

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
  final Map<String, _Session> _sessions = {};
  final _closed = Completer<void>();
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
      _log.i('Stopping ${running.title}');
      return running.stop();
    }

    final tunnel = _tunnels.firstWhereOrNull((tunnel) => tunnel.id == id);
    if (_changes.isClosed || tunnel == null) return;

    final session = _sessions[id] = _Session(tunnel.title);
    _emit();
    _log.i('Connecting ${tunnel.title}: ${tunnel.summary}');
    return _connect(tunnel, session);
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

  bool _isOn(String id) => _sessions[id]?.status.isOn ?? false;

  Future<SshTunnel> _open(Tunnel tunnel, _Session session) {
    final abortTrigger = session.abort.future;
    // ssh's lines, named since tunnels connect at once.
    void onLog(String line) {
      _sshLog.d('${tunnel.title}: $line');
      if (_openFailed.firstMatch(line)?[1] case final reason?) {
        _warn(session, tunnel, reason);
      }
    }

    return switch (tunnel) {
      Tunnel(kind: TunnelKind.socks) => client.openSocksProxy(
        tunnel.target,
        localPort: tunnel.localPort,
        onLog: onLog,
        abortTrigger: abortTrigger,
      ),
      Tunnel(:final remoteHost?, :final remotePort?) => client.openTunnel(
        tunnel.target,
        remoteHost: remoteHost,
        remotePort: remotePort,
        localPort: tunnel.localPort,
        onLog: onLog,
        abortTrigger: abortTrigger,
      ),
      _ => throw ArgumentError('A local tunnel needs a remote host and port'),
    };
  }

  Future<void> _connect(Tunnel tunnel, _Session session) async {
    final SshTunnel opened;
    try {
      await beforeConnect?.call();
      opened = session.tunnel = await _open(tunnel, session);
    } on Object catch (exception) {
      return _drop(tunnel, session, exception);
    }
    if (session.isStopped) return opened.close();

    session
      ..status = const Connected()
      ..hasConnected = true
      ..stable = Timer(stableAfter, () => session.attempts = 0);
    _emit();
    _log.i('Connected ${tunnel.title}');
    unawaited(
      opened.done.then(
        (_) => _drop(tunnel, session, null),
        onError: (Object exception) => _drop(tunnel, session, exception),
      ),
    );
  }

  // Only a tunnel that has connected comes back; a first try that fails stays
  // failed, as the user is watching.
  void _drop(Tunnel tunnel, _Session session, Object? exception) {
    if (session.isStopped) return;

    session.stable?.cancel();
    final message = exception == null ? 'Disconnected' : _messageOf(exception);
    final isPermanent = switch (exception) {
      SshException(:final isPermanent) => isPermanent,
      null => false,
      _ => true,
    };
    if (!session.hasConnected || isPermanent) return _fail(session, message);

    final delay = retryDelays[min(session.attempts++, retryDelays.length - 1)];
    _log.w(
      '${tunnel.title} dropped: $message; reconnecting in ${delay.inSeconds}s',
    );
    session
      ..status = Reconnecting(message)
      ..retry = Timer(delay, () => unawaited(_connect(tunnel, session)));
    _emit();
  }

  String _messageOf(Object exception) => switch (exception) {
    SshException(:final message) => message,
    ArgumentError(:final message) => '$message',
    _ => '$exception',
  };

  void _fail(_Session session, String message) {
    if (session.isStopped) return;

    _log.w('${session.title} failed: $message');
    session.status = Failed(message);
    _emit();
  }

  Future<void> _persist() {
    _emit();
    return store.save(_tunnels);
  }

  // A stopping session is already out of _sessions but still Connected.
  void _warn(_Session session, Tunnel tunnel, String reason) {
    if (session.isStopped || session.status is! Connected) return;

    final destination = switch (tunnel) {
      Tunnel(kind: TunnelKind.socks) => 'A SOCKS destination',
      Tunnel(:final remoteHost, :final remotePort) => '$remoteHost:$remotePort',
    };
    final warning = '$destination: $reason';
    session
      ..clearWarning?.cancel()
      ..clearWarning = Timer(warningLifetime, () {
        if (session.status is Connected) {
          session.status = const Connected();
          _emit();
        }
      });
    if (session.status == Connected(warning: warning)) return;

    _log.w('${tunnel.title}: $warning');
    session.status = Connected(warning: warning);
    _emit();
  }

  void _emit() {
    if (!_changes.isClosed) _changes.add(snapshot);
  }
}

class _Session(final String title) {
  final abort = Completer<void>();
  TunnelStatus status = const Connecting();
  SshTunnel? tunnel;
  Timer? clearWarning;
  Timer? retry;
  Timer? stable;
  bool hasConnected = false;
  int attempts = 0;

  bool get isStopped => abort.isCompleted;

  Future<void> stop() async {
    clearWarning?.cancel();
    retry?.cancel();
    stable?.cancel();
    if (!isStopped) abort.complete();
    await tunnel?.close();
  }
}
