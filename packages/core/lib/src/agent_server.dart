import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:core/src/agent_command.dart';
import 'package:core/src/tunnel_manager.dart';
import 'package:core/src/tunnels_snapshot.dart';

/// One JSON object per line each way: snapshots out, commands in.
class AgentServer(
  final ServerSocket _server,
  final TunnelManager _manager,
  final String _path,
) {
  final Set<Socket> _clients = {};
  StreamSubscription<TunnelsSnapshot>? _changes;

  /// Listens on [path], or returns null when another agent already does.
  static Future<AgentServer?> bind(String path, TunnelManager manager) async {
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
      return AgentServer(await ServerSocket.bind(address, 0), manager, path)
        .._start();
    } on SocketException {
      return null;
    }
  }

  void _start() {
    _changes = _manager.changes.listen((snapshot) {
      for (final client in _clients) {
        _send(client, snapshot);
      }
    });
    _server.listen(_accept);
  }

  void _accept(Socket client) {
    _clients.add(client);
    unawaited(client.done.catchError((Object _) => client));
    _send(client, _manager.snapshot);

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

  void _handle(String line) {
    final AgentCommand command;
    try {
      command = AgentCommand.fromJson(jsonDecode(line));
    } on FormatException catch (exception) {
      stderr.writeln('Ignoring a bad command: $exception');
      return;
    }

    unawaited(
      _manager.handle(command).catchError((Object exception) {
        stderr.writeln('$command failed: $exception');
      }),
    );
  }

  void _send(Socket client, TunnelsSnapshot snapshot) =>
      client.writeln(jsonEncode(snapshot.toJson()));

  void _drop(Socket client) {
    _clients.remove(client);
    client.destroy();
  }

  Future<void> close() async {
    await _changes?.cancel();
    await _server.close();
    final clients = [..._clients];
    _clients.clear();
    for (final client in clients) {
      client.destroy();
    }
    try {
      await File(_path).delete();
    } on FileSystemException {
      return;
    }
  }
}
