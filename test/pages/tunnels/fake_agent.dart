import 'dart:async';

import 'package:core/core.dart';

class FakeAgent implements AgentClient {
  final controller = StreamController<TunnelsSnapshot>();
  final sent = <AgentCommand>[];

  @override
  Stream<TunnelsSnapshot> get snapshots => controller.stream;

  @override
  Stream<void> get aboutRequests => const Stream.empty();

  @override
  Future<String> get identity => Future.value('');

  @override
  void send(AgentCommand command) => sent.add(command);

  @override
  Future<void> close() => controller.close();
}
