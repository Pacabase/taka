import 'dart:async';
import 'dart:io';

import 'package:agent/src/agent_tray.dart';
import 'package:core/core.dart';
import 'package:nativeapi/nativeapi.dart';
import 'package:system_ssh/system_ssh.dart';

void main() => runNativeApp(_run);

void _run() => unawaited(_start());

Future<void> _start() async {
  Application.instance.setDockIconVisible(false);

  final manager = TunnelManager(
    store: LocalTunnelStore.inTakaDirectory(),
    client: const SystemSshClient(loginShell: true),
  );
  try {
    await manager.load();
  } on Object catch (exception) {
    stderr.writeln('Could not load the saved tunnels: $exception');
  }

  final server = await AgentServer.bind(agentSocketPath(), manager);
  if (server == null) {
    stdout.writeln('Another Taka agent is running');
    Application.instance.quit(0);
    return;
  }

  // Taka.app/Contents/Helpers/agent/bin/taka_agent on macOS,
  // agent/bin/taka_agent next to taka on Linux.
  final agent = File(Platform.resolvedExecutable).parent.parent;
  final app =
      Platform.environment['TAKA_APP'] ??
      (Platform.isMacOS
          ? agent.parent.parent.parent.path
          : '${agent.parent.path}/taka');

  AgentTray(
    manager: manager,
    assetsPath: agent.path,
    onSettings: () => unawaited(_open(app)),
    onQuit: () async {
      try {
        await server.close();
        await manager.close();
      } finally {
        Application.instance.quit(0);
      }
    },
  ).show();
}

Future<void> _open(String app) async {
  final (executable, arguments) = Platform.isMacOS
      ? ('open', [app])
      : (app, <String>[]);
  try {
    await Process.start(executable, arguments, mode: ProcessStartMode.detached);
  } on ProcessException catch (exception) {
    stderr.writeln('Could not open Settings: $exception');
  }
}
