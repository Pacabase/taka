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
  this {
    _socket.done.ignore();
  }

  static Future<SocketAgentClient> connect(String path) async =>
      SocketAgentClient(
        await Socket.connect(
          InternetAddress(path, type: InternetAddressType.unix),
          0,
        ),
      );

  // A socket error is always followed by done, so this only skips bad lines.
  @override
  late final Stream<TunnelsSnapshot> snapshots = utf8.decoder
      .bind(_socket)
      .transform(const LineSplitter())
      .map((line) => TunnelsSnapshot.fromJson(jsonDecode(line)))
      .handleError((Object exception) => stderr.writeln('Ignoring $exception'));

  @override
  void send(AgentCommand command) =>
      _socket.writeln(jsonEncode(command.toJson()));

  @override
  Future<void> close() async => _socket.destroy();
}
