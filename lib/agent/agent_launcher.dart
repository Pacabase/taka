import 'dart:async';
import 'dart:io';

import 'package:core/core.dart';

/// The agent ships inside the app (`Contents/Helpers/agent` on macOS, `agent`
/// next to the executable on Linux); `TAKA_AGENT` points elsewhere while
/// developing.
Future<AgentClient> connectToAgent() async {
  final path = agentSocketPath();
  try {
    return await SocketAgentClient.connect(path);
  } on SocketException {
    await Process.start(
      _agentExecutable(),
      [],
      mode: ProcessStartMode.detached,
      environment: {'TAKA_APP': _appPath()},
    );
  }

  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (true) {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    try {
      return await SocketAgentClient.connect(path);
    } on SocketException {
      if (DateTime.now().isAfter(deadline)) rethrow;
    }
  }
}

String _agentExecutable() {
  if (Platform.environment['TAKA_AGENT'] case final agent?) return agent;

  final executable = File(Platform.resolvedExecutable);
  return Platform.isMacOS
      ? '${executable.parent.parent.path}/Helpers/agent/bin/taka_agent'
      : '${executable.parent.path}/agent/bin/taka_agent';
}

String _appPath() => Platform.isMacOS
    ? File(Platform.resolvedExecutable).parent.parent.parent.path
    : Platform.resolvedExecutable;
