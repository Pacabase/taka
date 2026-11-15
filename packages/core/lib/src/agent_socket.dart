import 'dart:convert';
import 'dart:io';
import 'dart:math';

/// Whether the agent listens on loopback, as on Windows, where Dart has no
/// Unix sockets.
bool get listensOnLoopback => Platform.isWindows;

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

Future<Socket> connectAgentSocket(String path, {bool? loopback}) async {
  if (!(loopback ?? listensOnLoopback)) {
    return Socket.connect(
      InternetAddress(path, type: InternetAddressType.unix),
      0,
    );
  }

  final ticket = await AgentTicket.read(path);
  if (ticket == null) throw SocketException('No agent ticket at $path');
  return (await Socket.connect(InternetAddress.loopbackIPv4, ticket.port))
    ..writeln(ticket.token);
}
