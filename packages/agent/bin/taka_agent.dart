import 'dart:async';
import 'dart:io';

import 'package:agent/src/agent_tray.dart';
import 'package:core/core.dart';
import 'package:fimber/fimber.dart';
import 'package:nativeapi/nativeapi.dart';
import 'package:system_ssh/system_ssh.dart';

void main() => runNativeApp(_run);

// An uncaught error still ends the agent, but is logged first.
void _run() => runZonedGuarded(() => unawaited(_start()), (error, stack) {
  Fimber.e('Uncaught error', ex: error, stacktrace: stack);
  Application.instance.quit(1);
});

Future<void> _start() async {
  Application.instance.setDockIconVisible(false);

  // Taka.app/Contents/Library/LoginItems/TakaAgent.app/Contents/MacOS/Taka on
  // macOS; agent/bin/taka_agent next to taka on Linux, and in development.
  final folder = File(Platform.resolvedExecutable).parent;
  final bundle = folder.parent.parent;
  final isAppBundle = bundle.path.endsWith('.app');
  final loginItems = folder.path.indexOf('/Contents/Library/LoginItems/');
  final app =
      Platform.environment['TAKA_APP'] ??
      (loginItems == -1
          ? '${bundle.path}/taka'
          : folder.path.substring(0, loginItems));

  if (!isAppBundle) Fimber.plantTree(DebugTree());
  final debugLogging = DebugLogging('agent')..start();
  final identity = agentIdentity(Platform.resolvedExecutable);
  Fimber.i('Agent $identity on ${Platform.operatingSystemVersion}');

  final manager = TunnelManager(
    store: LocalTunnelStore.inTakaDirectory(),
    client: const SystemSshClient(loginShell: true),
    // 1Password shows its approval prompt only while the app asking is in
    // front, and open brings the running agent there.
    beforeConnect: isAppBundle
        ? () => Process.run('open', [bundle.path])
        : null,
  );
  try {
    await manager.load();
  } on Object catch (exception) {
    Fimber.e('Could not load the saved tunnels', ex: exception);
  }

  final server = await AgentServer.bind(
    agentSocketPath(),
    manager,
    identity: identity,
  );
  if (server == null) {
    Fimber.i('Another Taka agent is running');
    Application.instance.quit(0);
    return;
  }

  // Closing the manager, from the tray or a window's quit command, quits.
  manager.changes.listen(
    null,
    onDone: () async {
      Fimber.i('Quitting');
      try {
        await manager.close();
        await server.close();
      } on Object catch (exception) {
        Fimber.e('Could not close the agent socket', ex: exception);
      } finally {
        Application.instance.quit(0);
      }
    },
  );

  AgentTray(
    manager: manager,
    debugLogging: debugLogging,
    assetsPath: isAppBundle
        ? '${folder.parent.path}/Resources'
        : folder.parent.path,
    onAbout: () {
      // On macOS, open also brings an open window to the front.
      if (!server.showAbout() || Platform.isMacOS) unawaited(_open(app));
    },
    onSettings: () => unawaited(_open(app)),
    onQuit: manager.close,
  ).show();
}

Future<void> _open(String app) async {
  final (executable, arguments) = Platform.isMacOS
      ? ('open', [app])
      : (app, <String>[]);
  try {
    await Process.start(executable, arguments, mode: ProcessStartMode.detached);
  } on ProcessException catch (exception) {
    Fimber.e('Could not open the window', ex: exception);
  }
}
