import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:core/src/agent_command.dart';
import 'package:core/src/tunnels_snapshot.dart';

abstract interface class AgentClient {
  /// Done when the agent goes away.
  Stream<TunnelsSnapshot> get snapshots;

  void send(AgentCommand command);

  Future<void> close();
}

class SocketAgentClient(final Socket _socket) implements AgentClient {
  final _snapshots = StreamController<TunnelsSnapshot>();
  StreamSubscription<String>? _lines;

  static Future<SocketAgentClient> connect(String path) async =>
      SocketAgentClient(
        await Socket.connect(
          InternetAddress(path, type: InternetAddressType.unix),
          0,
        ),
      ).._listen();

  void _listen() => _lines = utf8.decoder
      .bind(_socket)
      .transform(const LineSplitter())
      .listen(
        _read,
        onError: (Object _) => unawaited(close()),
        onDone: () => unawaited(close()),
        cancelOnError: true,
      );

  @override
  Stream<TunnelsSnapshot> get snapshots => _snapshots.stream;

  void _read(String line) {
    try {
      _snapshots.add(TunnelsSnapshot.fromJson(jsonDecode(line)));
    } on FormatException catch (exception) {
      stderr.writeln('Ignoring a bad snapshot: $exception');
    }
  }

  @override
  void send(AgentCommand command) =>
      _socket.writeln(jsonEncode(command.toJson()));

  @override
  Future<void> close() async {
    unawaited(_socket.done.catchError((Object _) => _socket));
    _socket.destroy();
    await _lines?.cancel();
    // Closing a controller waits for its listener, which may never come.
    unawaited(_snapshots.close());
  }
}
