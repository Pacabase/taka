import 'dart:async';

import 'package:core/core.dart';

class FakeAgent implements AgentClient {
  final controller = StreamController<TunnelsSnapshot>();
  final settingsController = StreamController<AgentSettings>();
  final tunnelRequestsController = StreamController<OpenTunnel>();
  final promptsController = StreamController<List<LoginPrompt>>();
  final sent = <AgentCommand>[];

  @override
  Stream<TunnelsSnapshot> get snapshots => controller.stream;

  @override
  Stream<AgentSettings> get settings => settingsController.stream;

  @override
  Stream<OpenTunnel> get tunnelRequests => tunnelRequestsController.stream;

  @override
  Stream<List<LoginPrompt>> get prompts => promptsController.stream;

  @override
  Future<String> get identity => Future.value('');

  @override
  void send(AgentCommand command) => sent.add(command);

  @override
  // Like the socket's, it doesn't wait for listeners that never came.
  Future<void> close() async {
    unawaited(settingsController.close());
    unawaited(tunnelRequestsController.close());
    unawaited(promptsController.close());
    unawaited(controller.close());
  }
}
