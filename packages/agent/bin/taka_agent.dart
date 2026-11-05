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

  final bundle = File(Platform.resolvedExecutable).parent.parent.parent;
  final manager = TunnelManager(
    store: LocalTunnelStore.inTakaDirectory(),
    client: const SystemSshClient(loginShell: true),
    // 1Password shows its approval prompt only while the app asking is in
    // front, and open brings the running agent there.
    beforeConnect: bundle.path.endsWith('.app')
        ? () => Process.run('open', [bundle.path])
        : null,
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

  // Taka.app/Contents/Library/LoginItems/TakaAgent.app/Contents/MacOS/Taka on
  // macOS; agent/bin/taka_agent next to taka on Linux, and in development.
  final folder = File(Platform.resolvedExecutable).parent;
  final loginItems = folder.path.indexOf('/Contents/Library/LoginItems/');
  final isAppBundle = folder.path.endsWith('.app/Contents/MacOS');
  final app =
      Platform.environment['TAKA_APP'] ??
      (loginItems == -1
          ? '${folder.parent.parent.path}/taka'
          : folder.path.substring(0, loginItems));

  AgentTray(
    manager: manager,
    assetsPath: isAppBundle
        ? '${folder.parent.path}/Resources'
        : folder.parent.path,
    onAbout: () {
      // On macOS, open also brings an open window to the front.
      if (!server.showAbout() || Platform.isMacOS) unawaited(_open(app));
    },
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
