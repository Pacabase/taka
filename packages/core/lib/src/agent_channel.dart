import 'dart:convert';
import 'dart:io';

import 'package:core/src/loopback_channel.dart';
import 'package:core/src/unix_channel.dart';

/// Where the window and the agent meet: a Unix socket on macOS and Linux, and
/// a loopback port on Windows, where Dart has no Unix sockets.
abstract class AgentChannel {
  static AgentChannel at(String path) =>
      Platform.isWindows ? LoopbackChannel(path) : UnixChannel(path);

  /// Null when another agent already answers here.
  Future<AgentListener?> listen();

  Future<Socket> connect();
}

abstract interface class AgentListener {
  Stream<AgentLink> get links;

  Future<void> close();
}

/// A client that reached the agent: the lines it sends, and a way to answer.
final class AgentLink(final Socket _socket, final Stream<String> lines) {
  this {
    _socket.done.ignore();
  }

  static AgentLink over(Socket socket) => AgentLink(socket, linesOf(socket));

  void send(String line) => _socket.writeln(line);

  void close() => _socket.destroy();
}

Stream<String> linesOf(Stream<List<int>> bytes) =>
    utf8.decoder.bind(bytes).transform(const LineSplitter());
