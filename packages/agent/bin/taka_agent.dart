import 'dart:async';
import 'dart:io';

import 'package:agent/src/agent_tray.dart';
import 'package:core/core.dart';
import 'package:nativeapi/nativeapi.dart';
import 'package:system_ssh/system_ssh.dart';

/// While developing, `TAKA_APP` is the app Settings… opens.
void main() => runNativeApp(_run);

void _run() => unawaited(_start());

Future<void> _start() async {
  Application.instance.setDockIconVisible(false);

  final manager = TunnelManager(
    store: LocalTunnelStore.inTakaDirectory(),
    client: const SystemSshClient(loginShell: true),
  );
  final server = await AgentServer.bind(agentSocketPath(), manager);
  if (server == null) {
    stdout.writeln('Another Taka agent is running');
    Application.instance.quit(0);
    return;
  }

  try {
    await manager.load();
  } on Object catch (exception) {
    stderr.writeln('Could not load the saved tunnels: $exception');
  }

  AgentTray(
    manager: manager,
    assetsPath: File(Platform.resolvedExecutable).parent.parent.path,
    onSettings: _openSettings,
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

void _openSettings() => unawaited(_open());

Future<void> _open() async {
  final app = Platform.environment['TAKA_APP'] ?? _bundledApp();
  try {
    if (Platform.isMacOS) {
      await Process.run('open', [app]);
    } else {
      await Process.start(app, [], mode: ProcessStartMode.detached);
    }
  } on ProcessException catch (exception) {
    stderr.writeln('Could not open Settings: $exception');
  }
}

/// The app this agent ships in: `Taka.app/Contents/Helpers/agent/bin` on
/// macOS, `agent/bin` next to the executable on Linux.
String _bundledApp() {
  final agent = File(Platform.resolvedExecutable).parent.parent;

  return Platform.isMacOS
      ? agent.parent.parent.parent.path
      : '${agent.parent.path}/taka';
}
