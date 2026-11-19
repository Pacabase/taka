import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:core/src/agent_channel.dart';

const _tokenWait = Duration(seconds: 2);

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
    // Held for the agent's life, so no second agent starts between check and ticket.
    final lock = await File('$path.lock').open(mode: FileMode.write);
    try {
      await lock.lock();
    } on FileSystemException {
      await lock.close();
      return null;
    }
    if (await _isAgentListening()) {
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

  // Another program may have the port of an agent that has since died.
  Future<bool> _isAgentListening() async {
    final Socket socket;
    try {
      socket = await connect();
    } on SocketException {
      return false;
    }

    socket.done.ignore();
    try {
      final line = await linesOf(socket).first
          .timeout(const Duration(seconds: 1));
      return switch (jsonDecode(line)) {
        {'agent': String _} => true,
        _ => false,
      };
    } on Object {
      return false;
    } finally {
      socket.destroy();
    }
  }
}

final class _LoopbackListener(
  final ServerSocket _server,
  final String _path,
  final AgentTicket _ticket,
  final RandomAccessFile _lock,
) implements AgentListener {
  final _links = StreamController<AgentLink>();
  final Set<Socket> _strangers = {};
  bool _isClosed = false;

  this {
    _server.listen(_check, onDone: _links.close);
  }

  @override
  Stream<AgentLink> get links => _links.stream;

  void _check(Socket socket) {
    socket.done.ignore();
    _strangers.add(socket);
    void drop() {
      _strangers.remove(socket);
      socket.destroy();
    }

    final wait = Timer(_tokenWait, drop);
    StreamController<String>? rest;
    var firstLineLength = 0;
    var hasFirstLine = false;
    linesOf(
      socket.map((bytes) {
        if (!hasFirstLine) {
          final end = bytes.indexOf(10);
          hasFirstLine = end != -1;
          firstLineLength += hasFirstLine ? end : bytes.length;
          if (firstLineLength > _ticket.token.length) drop();
        }
        return bytes;
      }),
    ).listen(
      (line) {
        if (rest case final rest?) return rest.add(line);
        wait.cancel();
        _strangers.remove(socket);
        if (!_ticket.admits(line)) return socket.destroy();
        rest = StreamController<String>();
        _links.add(AgentLink(socket, rest!.stream));
      },
      onError: (Object exception) =>
          rest == null ? drop() : (rest!..addError(exception)).close(),
      onDone: () => rest == null ? drop() : rest!.close(),
      cancelOnError: true,
    );
  }

  @override
  Future<void> close() async {
    if (_isClosed) return;
    _isClosed = true;
    await _server.close();
    for (final socket in [..._strangers]) {
      socket.destroy();
    }
    _strangers.clear();
    if ((await AgentTicket.read(_path))?.token == _ticket.token) {
      try {
        await File(_path).delete();
      } on PathNotFoundException {
        // A newer agent removed it first.
      }
    }
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
