import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:core/src/agent_command.dart';
import 'package:core/src/tunnels_snapshot.dart';

abstract interface class AgentClient {
  /// Which build the agent is, or '' from an agent too old to say.
  Future<String> get identity;

  Stream<TunnelsSnapshot> get snapshots;

  Stream<void> get aboutRequests;

  void send(AgentCommand command);

  Future<void> close();
}

class SocketAgentClient(final Socket _socket) implements AgentClient {
  final _snapshots = StreamController<TunnelsSnapshot>();
  final _aboutRequests = StreamController<void>();
  final _identity = Completer<String>();

  this {
    _socket.done.ignore();
    // A socket error is always followed by done.
    utf8.decoder
        .bind(_socket)
        .transform(const LineSplitter())
        .listen(
          _receive,
          onError: (Object exception) => stderr.writeln('Ignoring $exception'),
          onDone: () {
            if (!_identity.isCompleted) _identity.complete('');
            unawaited(_snapshots.close());
            unawaited(_aboutRequests.close());
          },
        );
  }

  static Future<SocketAgentClient> connect(String path) async =>
      SocketAgentClient(
        await Socket.connect(
          InternetAddress(path, type: InternetAddressType.unix),
          0,
        ),
      );

  @override
  Future<String> get identity => _identity.future;

  @override
  Stream<TunnelsSnapshot> get snapshots => _snapshots.stream;

  @override
  Stream<void> get aboutRequests => _aboutRequests.stream;

  @override
  void send(AgentCommand command) =>
      _socket.writeln(jsonEncode(command.toJson()));

  @override
  Future<void> close() async => _socket.destroy();

  void _receive(String line) {
    try {
      switch (jsonDecode(line)) {
        case {'agent': final String identity} when !_identity.isCompleted:
          _identity.complete(identity);
        case {'show': 'about'}:
          _aboutRequests.add(null);
        case final json:
          _snapshots.add(TunnelsSnapshot.fromJson(json));
      }
    } on FormatException catch (exception) {
      stderr.writeln('Ignoring $exception');
    }
  }
}
