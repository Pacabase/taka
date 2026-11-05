import 'dart:async';
import 'dart:io';

import 'package:core/core.dart';

Future<AgentClient> connectToAgent() async {
  final path = agentSocketPath();
  try {
    return await SocketAgentClient.connect(path);
  } on SocketException {
    await _startAgent();
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

// Taka.app/Contents/MacOS/Taka on macOS, taka on Linux; the agent ships inside
// or beside it unless TAKA_AGENT points at another build.
Future<Process> _startAgent() {
  final executable = File(Platform.resolvedExecutable);
  final (agent, app) = Platform.isMacOS
      ? (
          '${executable.parent.parent.path}/Library/LoginItems/TakaAgent.app/Contents/MacOS/Taka',
          executable.parent.parent.parent.path,
        )
      : ('${executable.parent.path}/agent/bin/taka_agent', executable.path);

  return Process.start(
    Platform.environment['TAKA_AGENT'] ?? agent,
    [],
    mode: ProcessStartMode.detached,
    environment: {'TAKA_APP': app},
  );
}
