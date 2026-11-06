import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:core/src/agent_command.dart';
import 'package:core/src/agent_message.dart';
import 'package:core/src/agent_settings.dart';
import 'package:core/src/tunnel_manager.dart';
import 'package:core/src/tunnels_snapshot.dart';
import 'package:fimber/fimber.dart';

final _log = FimberLog('Socket');

/// One JSON object per line each way: the agent's identity, snapshots,
/// settings and About requests out, commands in.
class AgentServer(
  final ServerSocket _server,
  final TunnelManager _manager,
  final AgentPreferences _preferences,
  final String _identity,
) {
  final Set<Socket> _clients = {};
  AgentMessage? _pending;
  late final StreamSubscription<TunnelsSnapshot> _changes;
  late final StreamSubscription<AgentSettings> _settingsChanges;

  this {
    _changes = _manager.changes.listen(
      (snapshot) => _sendAll(AgentMessage.snapshot(snapshot)),
    );
    _settingsChanges = _preferences.changes.listen(
      (settings) => _sendAll(AgentMessage.settings(settings)),
    );
    _server.listen(_accept);
  }

  /// Listens on [path], or returns null when another agent already does.
  /// Throws a [SocketException] when it can't listen for another reason,
  /// such as a path too long for a socket.
  static Future<AgentServer?> bind(
    String path,
    TunnelManager manager,
    AgentPreferences preferences, {
    String identity = '',
  }) async {
    final address = InternetAddress(path, type: InternetAddressType.unix);
    final file = File(path);
    Future<bool> isAnswered() async {
      try {
        (await Socket.connect(address, 0)).destroy();
        return true;
      } on SocketException {
        return false;
      }
    }

    if (await file.exists()) {
      if (await isAnswered()) return null;
      await file.delete();
    }

    await file.parent.create(recursive: true);
    try {
      return AgentServer(
        await ServerSocket.bind(address, 0),
        manager,
        preferences,
        identity,
      );
    } on SocketException {
      // Another agent may have bound it a moment ago.
      if (await isAnswered()) return null;
      rethrow;
    }
  }

  /// Sends a request such as [AgentMessage.openTunnel] to every open window,
  /// or to the next one to connect when none is open; returns whether one was
  /// open.
  bool show(AgentMessage request) {
    if (_clients.isEmpty) {
      _pending = request;
      return false;
    }

    _sendAll(request);
    return true;
  }

  void _accept(Socket client) {
    _clients.add(client);
    client.done.ignore();
    _send(client, AgentMessage.identity(_identity));
    _send(client, AgentMessage.snapshot(_manager.snapshot));
    _send(client, AgentMessage.settings(_preferences.settings));
    if (_pending case final request?) {
      _pending = null;
      _send(client, request);
    }

    utf8.decoder
        .bind(client)
        .transform(const LineSplitter())
        .listen(
          _handle,
          onDone: () => _drop(client),
          onError: (Object _) => _drop(client),
          cancelOnError: true,
        );
  }

  Future<void> _handle(String line) async {
    final AgentCommand command;
    try {
      command = AgentCommand.fromJson(jsonDecode(line));
    } on FormatException catch (exception) {
      _log.w('Ignoring $line', ex: exception);
      return;
    }

    try {
      await _run(command);
    } on Object catch (exception) {
      _log.e('Could not run $line', ex: exception);
    }
  }

  Future<void> _run(AgentCommand command) async => switch (command) {
    SaveTunnel(:final tunnel) => await _manager.save(tunnel),
    RemoveTunnel(:final id) => await _manager.remove(id),
    ToggleTunnel(:final id) => await _manager.toggle(id),
    MoveTunnel(:final id, :final index) => await _manager.move(id, index),
    QuitAgent() => await _manager.close(),
    SetLaunchAtLogin(:final on) => _preferences.setLaunchAtLogin(on: on),
    SetDebugLogging(:final on) => _preferences.setDebugLogging(on: on),
    ShowLogs() => await _preferences.showLogs(),
  };

  void _sendAll(AgentMessage message) {
    for (final client in _clients) {
      _send(client, message);
    }
  }

  void _send(Socket client, AgentMessage message) =>
      client.writeln(jsonEncode(message.toJson()));

  void _drop(Socket client) {
    _clients.remove(client);
    client.destroy();
  }

  Future<void> close() async {
    await _changes.cancel();
    await _settingsChanges.cancel();
    await _server.close();
    [..._clients].forEach(_drop);
  }
}
