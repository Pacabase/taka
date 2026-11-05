import 'dart:async';

import 'package:core/core.dart';

class FakeAgent implements AgentClient {
  final controller = StreamController<TunnelsSnapshot>();
  final settingsController = StreamController<AgentSettings>();
  final sent = <AgentCommand>[];

  @override
  Stream<TunnelsSnapshot> get snapshots => controller.stream;

  @override
  Stream<void> get aboutRequests => const Stream.empty();

  @override
  Stream<AgentSettings> get settings => settingsController.stream;

  @override
  Future<String> get identity => Future.value('');

  @override
  void send(AgentCommand command) => sent.add(command);

  @override
  Future<void> close() {
    unawaited(settingsController.close());
    return controller.close();
  }
}
