import 'dart:async';
import 'dart:io';

import 'package:core/core.dart';

Future<AgentClient> connectToAgent() async {
  final path = agentSocketPath();
  final (agent, app) = _bundledAgent();
  try {
    final running = await SocketAgentClient.connect(path);
    if (await _isCurrent(running, agent)) return running;

    running.send(const AgentCommand.quit());
    await running.snapshots.drain<void>().timeout(
      const Duration(seconds: 3),
      onTimeout: () {},
    );
  } on SocketException {
    // No agent is running yet.
  }

  // Through open, macOS starts the agent as an app of its own, so Taka doesn't
  // stay in the Dock "running in the background" once this window quits.
  if (agent.indexOf('.app/Contents/MacOS/') case final bundleEnd
      when bundleEnd != -1) {
    await Process.run('open', ['-g', agent.substring(0, bundleEnd + 4)]);
  } else {
    await Process.start(
      agent,
      [],
      mode: ProcessStartMode.detached,
      environment: {'TAKA_APP': app},
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

// An agent left running from before an update is a different build than the
// one this window ships with.
Future<bool> _isCurrent(AgentClient running, String agent) async {
  final String expected;
  try {
    expected = agentIdentity(agent);
  } on FileSystemException {
    return true;
  }

  return await running.identity.timeout(
        const Duration(seconds: 1),
        onTimeout: () => '',
      ) ==
      expected;
}

// Taka.app/Contents/MacOS/Taka on macOS, taka on Linux; the agent ships inside
// or beside it unless TAKA_AGENT points at another build.
(String, String) _bundledAgent() {
  final executable = File(Platform.resolvedExecutable);
  final (agent, app) = Platform.isMacOS
      ? (
          '${executable.parent.parent.path}/Library/LoginItems/TakaAgent.app/Contents/MacOS/Taka',
          executable.parent.parent.parent.path,
        )
      : ('${executable.parent.path}/agent/bin/taka_agent', executable.path);

  return (Platform.environment['TAKA_AGENT'] ?? agent, app);
}
