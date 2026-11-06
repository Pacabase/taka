import 'dart:async';
import 'dart:io';

import 'package:core/core.dart';
import 'package:fimber/fimber.dart';

final class const AgentTimeoutException() implements Exception {
  @override
  String toString() => 'AgentTimeoutException: no answer on its socket';
}

Future<AgentClient> connectToAgent({
  String? socketPath,
  TakaInstall? install,
  Future<ProcessResult> Function(String executable, List<String> arguments)
      run =
      Process.run,
  Duration answerTimeout = const Duration(seconds: 5),
  Duration quitTimeout = const Duration(seconds: 3),
  Duration identityTimeout = const Duration(seconds: 1),
}) async {
  final path = socketPath ?? agentSocketPath();
  final TakaInstall(:agent, :app, :agentBundle) =
      install ?? TakaInstall.fromWindow(Platform.resolvedExecutable);
  if (await _connect(path) case final running?) {
    if (await _isCurrent(running, agent, identityTimeout)) return running;

    Fimber.i('Replacing an agent from another build');
    running.send(const AgentCommand.quit());
    await running.snapshots.drain<void>().timeout(
      quitTimeout,
      onTimeout: () {},
    );
    await running.close();
  }

  // Started by open, the agent is its own app, so Taka leaves the Dock on quit.
  if (agentBundle case final bundle?) {
    final result = await run('open', ['-n', '-g', bundle]);
    if (result.exitCode != 0) {
      throw ProcessException('open', [bundle], '${result.stderr}'.trim());
    }
  } else {
    await Process.start(
      agent,
      [],
      mode: ProcessStartMode.detached,
      environment: {'TAKA_APP': app},
    );
  }
  final deadline = DateTime.now().add(answerTimeout);
  while (DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (await _connect(path) case final started?) return started;
  }
  throw const AgentTimeoutException();
}

Future<SocketAgentClient?> _connect(String path) async {
  try {
    return await SocketAgentClient.connect(path);
  } on SocketException {
    return null;
  }
}

Future<bool> _isCurrent(
  AgentClient running,
  String agent,
  Duration timeout,
) async {
  final String expected;
  try {
    expected = agentIdentity(agent);
  } on FileSystemException {
    return true;
  }

  final identity = await running.identity.timeout(timeout, onTimeout: () => '');
  return identity == expected;
}
