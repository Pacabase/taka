import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:core/src/agent_command.dart';
import 'package:core/src/agent_message.dart';
import 'package:core/src/agent_settings.dart';
import 'package:core/src/tunnels_snapshot.dart';
import 'package:fimber/fimber.dart';

final _log = FimberLog('Socket');

abstract interface class AgentClient {
  /// Which build the agent is, or '' from an agent too old to say.
  Future<String> get identity;

  Stream<TunnelsSnapshot> get snapshots;

  Stream<OpenTunnel> get tunnelRequests;

  Stream<AgentSettings> get settings;

  void send(AgentCommand command);

  Future<void> close();
}

class SocketAgentClient(final Socket _socket) implements AgentClient {
  final _snapshots = StreamController<TunnelsSnapshot>();
  final _tunnelRequests = StreamController<OpenTunnel>();
  final _settings = StreamController<AgentSettings>();
  final _identity = Completer<String>();

  this {
    _socket.done.ignore();
    // A socket error is always followed by done.
    utf8.decoder
        .bind(_socket)
        .transform(const LineSplitter())
        .listen(
          _receive,
          onError: (Object exception) =>
              _log.w('Ignoring a broken message', ex: exception),
          onDone: () {
            _identify('');
            unawaited(_snapshots.close());
            unawaited(_tunnelRequests.close());
            unawaited(_settings.close());
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
  Stream<OpenTunnel> get tunnelRequests => _tunnelRequests.stream;

  @override
  Stream<AgentSettings> get settings => _settings.stream;

  @override
  void send(AgentCommand command) =>
      _socket.writeln(jsonEncode(command.toJson()));

  @override
  Future<void> close() async => _socket.destroy();

  void _receive(String line) {
    try {
      switch (AgentMessage.fromJson(jsonDecode(line))) {
        case AgentIdentity(:final identity):
          _identify(identity);
        case final OpenTunnel request:
          _tunnelRequests.add(request);
        case SettingsChanged(:final settings):
          _settings.add(settings);
        case AgentSnapshot(:final snapshot):
          // An agent that sends a snapshot first is too old to say.
          _identify('');
          _snapshots.add(snapshot);
      }
    } on FormatException catch (exception) {
      _log.w('Ignoring $line', ex: exception);
    }
  }

  void _identify(String identity) {
    if (!_identity.isCompleted) _identity.complete(identity);
  }
}
