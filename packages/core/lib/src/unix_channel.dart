import 'dart:io';

import 'package:core/src/agent_channel.dart';

final class UnixChannel(final String path) extends AgentChannel {
  InternetAddress get _address =>
      InternetAddress(path, type: InternetAddressType.unix);

  @override
  Future<Socket> connect() => Socket.connect(_address, 0);

  @override
  Future<AgentListener?> listen() async {
    final file = File(path);
    if (await file.exists()) {
      if (await _isAnswered()) return null;
      await file.delete();
    }

    await file.parent.create(recursive: true);
    try {
      return _UnixListener(await ServerSocket.bind(_address, 0));
    } on SocketException {
      // Another agent may have bound it a moment ago.
      if (await _isAnswered()) return null;
      rethrow;
    }
  }

  Future<bool> _isAnswered() async {
    try {
      (await connect()).destroy();
      return true;
    } on SocketException {
      return false;
    }
  }
}

final class _UnixListener(final ServerSocket _server) implements AgentListener {
  @override
  Stream<AgentLink> get links => _server.map(AgentLink.over);

  @override
  Future<void> close() => _server.close();
}
