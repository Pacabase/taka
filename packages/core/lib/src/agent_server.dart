import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:core/src/agent_command.dart';
import 'package:core/src/agent_message.dart';
import 'package:core/src/agent_settings.dart';
import 'package:core/src/agent_socket.dart';
import 'package:core/src/tunnel_manager.dart';
import 'package:core/src/tunnels_file.dart';
import 'package:core/src/tunnels_snapshot.dart';
import 'package:fimber/fimber.dart';

final _log = FimberLog('Socket');

class AgentServer(
  final ServerSocket _server,
  final TunnelManager _manager,
  final AgentPreferences _preferences,
  final String _identity, [
  final String? _ticketPath,
  final AgentTicket? _ticket,
]) {
  final Set<Socket> _clients = {};
  AgentMessage? _pending;
  late final StreamSubscription<TunnelsSnapshot> _changes;
  late final StreamSubscription<AgentSettings> _settingsChanges;

  this {
    _changes = _manager.stream.listen(
      (snapshot) => _sendAll(AgentMessage.snapshot(snapshot)),
    );
    _settingsChanges = _preferences.changes.listen(
      (settings) => _sendAll(AgentMessage.settings(settings)),
    );
    _server.listen(_accept);
  }

  static Future<AgentServer?> bind(
    String path,
    TunnelManager manager,
    AgentPreferences preferences, {
    String identity = '',
    bool? loopback,
  }) async {
    if (loopback ?? listensOnLoopback) {
      return _bindLoopback(path, manager, preferences, identity);
    }

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

  static Future<AgentServer?> _bindLoopback(
    String path,
    TunnelManager manager,
    AgentPreferences preferences,
    String identity,
  ) async {
    if (await _isAnsweredOverLoopback(path)) return null;

    final file = File(path);
    await file.parent.create(recursive: true);
    if (await file.exists()) await file.delete();
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final ticket = AgentTicket.random(server.port);
    try {
      await file.create(exclusive: true);
      await file.writeAsString(ticket.encoded, flush: true);
    } on FileSystemException catch (exception) {
      await server.close();
      // Another agent may have written its ticket a moment ago.
      if (await _isAnsweredOverLoopback(path)) return null;
      throw SocketException('Could not write $path: ${exception.message}');
    }
    return AgentServer(server, manager, preferences, identity, path, ticket);
  }

  // Another program may have the port of an agent that has since died.
  static Future<bool> _isAnsweredOverLoopback(String path) async {
    final Socket socket;
    try {
      socket = await connectAgentSocket(path, loopback: true);
    } on SocketException {
      return false;
    }

    try {
      await socket.first.timeout(const Duration(seconds: 1));
      return true;
    } on Object {
      return false;
    } finally {
      socket.destroy();
    }
  }

  bool show(AgentMessage request) {
    if (_clients.isEmpty) {
      _pending = request;
      return false;
    }

    _sendAll(request);
    return true;
  }

  void _accept(Socket client) {
    client.done.ignore();
    final ticket = _ticket;
    var isAdmitted = ticket == null;
    if (isAdmitted) _admit(client);

    utf8.decoder
        .bind(client)
        .transform(const LineSplitter())
        .listen(
          (line) {
            if (isAdmitted) {
              unawaited(_handle(line));
            } else if (ticket!.admits(line)) {
              isAdmitted = true;
              _admit(client);
            } else {
              _drop(client);
            }
          },
          onDone: () => _drop(client),
          onError: (Object _) => _drop(client),
          cancelOnError: true,
        );
  }

  void _admit(Socket client) {
    _clients.add(client);
    _send(client, AgentMessage.identity(_identity));
    _send(client, AgentMessage.snapshot(_manager.state));
    _send(client, AgentMessage.settings(_preferences.settings));
    if (_pending case final request?) {
      _pending = null;
      _send(client, request);
    }
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
    ArrangeTunnels(:final tunnels) => await _manager.arrange(tunnels),
    TrustHostKey(:final id, :final fingerprint) => await _manager.trustHostKey(
      id,
      fingerprint,
    ),
    EditGroup(:final group, :final name, :final colour) =>
      await _manager.editGroup(group, name: name, colour: colour),
    ImportTunnels(:final tunnels, :final groupColours) => await _manager.import(
      tunnels,
      groupColours: groupColours,
    ),
    ExportTunnels(:final path) => await File(
      path,
    ).writeAsString(encodeTunnels(_manager.book)),
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
    if (_ticketPath case final path?) {
      if ((await AgentTicket.read(path))?.token == _ticket?.token) {
        await File(path).delete();
      }
    }
  }
}
