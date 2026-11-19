import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:async/async.dart';
import 'package:core/src/agent_channel.dart';

/// Windows' channel: the agent listens on a loopback port, which any local
/// program can reach, so a client must first send the token from the ticket
/// the agent keeps in the user's own folder.
final class LoopbackChannel(final String path) extends AgentChannel {
  @override
  Future<Socket> connect() async {
    final ticket = await AgentTicket.read(path);
    if (ticket == null) throw SocketException('No agent ticket at $path');
    return (await Socket.connect(InternetAddress.loopbackIPv4, ticket.port))
      ..writeln(ticket.token);
  }

  @override
  Future<AgentListener?> listen() async {
    await File(path).parent.create(recursive: true);
    // Held for the agent's life; the system frees it if the agent dies.
    final lock = await File('$path.lock').open(mode: FileMode.write);
    try {
      await lock.lock();
    } on FileSystemException {
      await lock.close();
      return null;
    }

    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final ticket = AgentTicket.random(server.port);
    // Renamed into place, so a window never reads it half-written.
    final draft = await File('$path.new')
        .writeAsString(ticket.encoded, flush: true);
    await draft.rename(path);
    return _LoopbackListener(server, path, ticket, lock);
  }
}

final class _LoopbackListener(
  final ServerSocket _server,
  final String _path,
  final AgentTicket _ticket,
  final RandomAccessFile _lock,
) implements AgentListener {
  final _links = StreamController<AgentLink>();

  this {
    _server.listen((socket) => unawaited(_check(socket)));
  }

  @override
  Stream<AgentLink> get links => _links.stream;

  Future<void> _check(Socket socket) async {
    socket.done.ignore();
    final lines = StreamQueue(linesOf(socket));
    try {
      final token = await lines.next.timeout(const Duration(seconds: 2));
      if (_ticket.admits(token) && !_links.isClosed) {
        return _links.add(AgentLink(socket, lines.rest));
      }
    } on Object {
      // It left or stayed silent.
    }
    socket.destroy();
  }

  @override
  Future<void> close() async {
    await _links.close();
    await _server.close();
    await File(_path).delete();
    await _lock.close();
  }
}

/// A loopback agent's port and the token a client sends as its first line,
/// kept in a file in the user's own folder.
final class const AgentTicket(final int port, final String token) {
  static AgentTicket random(int port) {
    final random = Random.secure();
    return AgentTicket(
      port,
      base64Url.encode([
        for (var index = 0; index < 32; index++) random.nextInt(256),
      ]),
    );
  }

  /// The ticket in the file at [path], or null with no agent's ticket there.
  static Future<AgentTicket?> read(String path) async {
    final String text;
    try {
      text = await File(path).readAsString();
    } on FileSystemException {
      return null;
    }

    final match = RegExp(r'^(\d+) (\S+)$').firstMatch(text.trim());
    final port = int.tryParse(match?.group(1) ?? '');
    final token = match?.group(2);
    return port == null || token == null ? null : AgentTicket(port, token);
  }

  String get encoded => '$port $token';

  // In constant time, so the token can't be guessed a byte at a time.
  bool admits(String line) {
    final given = utf8.encode(line);
    final expected = utf8.encode(token);
    var difference = given.length ^ expected.length;
    for (var index = 0; index < expected.length; index++) {
      difference |= expected[index] ^ (index < given.length ? given[index] : 0);
    }
    return difference == 0;
  }
}
