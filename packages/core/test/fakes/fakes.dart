import 'dart:async';
import 'dart:io';

import 'package:core/core.dart';
import 'package:mocktail/mocktail.dart';
import 'package:system_ssh/system_ssh.dart';

class MockSshClient extends Mock implements SshClient {}

class FakeStore([
  var List<Tunnel> tunnels = const [],
  var Set<String> on = const {},
]) implements TunnelStore {
  int saveCount = 0;
  Exception? saveError;

  @override
  Future<({List<Tunnel> tunnels, Set<String> on})> load() async =>
      (tunnels: tunnels, on: on);

  @override
  Future<void> save(List<Tunnel> tunnels, {required Set<String> on}) async {
    if (saveError case final error?) throw error;
    this.tunnels = tunnels;
    this.on = on;
    saveCount++;
  }
}

class FakeTunnel(@override final int localPort) implements SshTunnel {
  final _done = Completer<void>();
  int closeCount = 0;

  void drop() => _done.complete();

  void dropWith(Object reason) => _done.completeError(reason);

  @override
  Future<void> get done => _done.future;

  @override
  Future<void> close() async {
    closeCount++;
    if (!_done.isCompleted) _done.complete();
  }
}

class FakeRemoteTunnel(@override final int remotePort)
    implements SshRemoteTunnel {
  final _done = Completer<void>();
  int closeCount = 0;

  void drop() => _done.complete();

  @override
  Future<void> get done => _done.future;

  @override
  Future<void> close() async {
    closeCount++;
    if (!_done.isCompleted) _done.complete();
  }
}

const database = Tunnel(
  id: 'a1',
  name: 'Production database',
  sshHost: 'deploy@bastion',
  localPort: 15432,
  remoteHost: 'db.internal',
  remotePort: 5432,
);

const proxy = Tunnel(
  id: 'b2',
  kind: TunnelKind.socks,
  sshHost: 'bastion',
  localPort: 1080,
);

const preview = Tunnel(
  id: 'r5',
  kind: TunnelKind.remote,
  sshHost: 'bastion',
  localPort: 3000,
  remotePort: 8080,
);

class FakePreferences implements AgentPreferences {
  final _changes = StreamController<AgentSettings>.broadcast();
  final _calls = StreamController<String>();
  bool logsFail = false;

  Stream<String> get calls => _calls.stream;

  @override
  AgentSettings settings = const AgentSettings(launchesAtLogin: false);

  @override
  Stream<AgentSettings> get changes => _changes.stream;

  void change(AgentSettings changed) => _changes.add(settings = changed);

  @override
  void setLaunchAtLogin({required bool on}) => _calls.add('launchAtLogin $on');

  @override
  void setDebugLogging({required bool on}) => _calls.add('debugLogging $on');

  @override
  Future<void> showLogs() async {
    _calls.add('showLogs');
    if (logsFail) throw const FileSystemException('No logs');
  }
}
