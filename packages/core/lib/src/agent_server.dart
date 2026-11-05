import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:core/src/agent_command.dart';
import 'package:core/src/tunnel_manager.dart';
import 'package:core/src/tunnels_snapshot.dart';
import 'package:fimber/fimber.dart';

final _log = FimberLog('Socket');

/// One JSON object per line each way: the agent's identity, snapshots and
/// About requests out, commands in.
class AgentServer(
  final ServerSocket _server,
  final TunnelManager _manager,
  final String _identity,
) {
  final Set<Socket> _clients = {};
  var _isAboutPending = false;
  late final StreamSubscription<TunnelsSnapshot> _changes;

  this {
    _changes = _manager.changes.listen((snapshot) {
      for (final client in _clients) {
        _send(client, snapshot);
      }
    });
    _server.listen(_accept);
  }

  /// Listens on [path], or returns null when another agent already does.
  static Future<AgentServer?> bind(
    String path,
    TunnelManager manager, {
    String identity = '',
  }) async {
    final address = InternetAddress(path, type: InternetAddressType.unix);
    final file = File(path);
    if (await file.exists()) {
      try {
        (await Socket.connect(address, 0)).destroy();
        return null;
      } on SocketException {
        await file.delete();
      }
    }

    await file.parent.create(recursive: true);
    try {
      return AgentServer(
        await ServerSocket.bind(address, 0),
        manager,
        identity,
      );
    } on SocketException {
      return null;
    }
  }

  /// Asks every open window to show About, or the next one to connect when
  /// none is open; returns whether one was open.
  bool showAbout() {
    _isAboutPending = _clients.isEmpty;
    _clients.forEach(_sendAbout);
    return !_isAboutPending;
  }

  void _accept(Socket client) {
    _clients.add(client);
    client.done.ignore();
    client.writeln(jsonEncode({'agent': _identity}));
    _send(client, _manager.snapshot);
    if (_isAboutPending) {
      _isAboutPending = false;
      _sendAbout(client);
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
    try {
      await _manager.handle(AgentCommand.fromJson(jsonDecode(line)));
    } on Object catch (exception) {
      _log.w('Ignoring $line', ex: exception);
    }
  }

  void _send(Socket client, TunnelsSnapshot snapshot) =>
      client.writeln(jsonEncode(snapshot.toJson()));

  void _sendAbout(Socket client) => client.writeln(jsonEncode(_about));

  static const _about = {'show': 'about'};

  void _drop(Socket client) {
    _clients.remove(client);
    client.destroy();
  }

  Future<void> close() async {
    await _changes.cancel();
    await _server.close();
    [..._clients].forEach(_drop);
  }
}
