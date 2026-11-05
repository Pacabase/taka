import 'dart:async';
import 'dart:io';

import 'package:agent/src/agent_tray.dart';
import 'package:agent/src/process_name.dart';
import 'package:core/core.dart';
import 'package:fimber/fimber.dart';
import 'package:nativeapi/nativeapi.dart';
import 'package:system_ssh/system_ssh.dart';

void main() => runNativeApp(_run);

void _run() => runZonedGuarded(() => unawaited(_start()), (error, stack) {
  Fimber.e('Uncaught error', ex: error, stacktrace: stack);
  Application.instance.quit(1);
});

Future<void> _start() async {
  Application.instance.setDockIconVisible(false);

  final TakaInstall(:app, :agentBundle, :agentAssets) = TakaInstall.fromAgent(
    Platform.resolvedExecutable,
  );

  if (agentBundle == null) Fimber.plantTree(DebugTree());
  final debugLogging = DebugLogging('agent')..start();
  if (Platform.isMacOS) restoreProcessName('Taka');
  final identity = agentIdentity(Platform.resolvedExecutable);
  Fimber.i('Agent $identity on ${Platform.operatingSystemVersion}');

  final manager = TunnelManager(
    store: LocalTunnelStore.inTakaDirectory(),
    client: const SystemSshClient(loginShell: true),
    // 1Password shows its approval prompt only while the app asking is in
    // front, and open brings the running agent there.
    beforeConnect: agentBundle == null
        ? null
        : () => Process.run('open', [agentBundle]),
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
  // Only once this agent owns the socket, so a second one starts no ssh.
  unawaited(manager.restore());

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
    // macOS registers the running app, so a build outside a bundle can't.
    launchAtLogin:
        LaunchAtLogin.isSupported() &&
            (agentBundle != null || !Platform.isMacOS)
        ? LaunchAtLogin.create()
        : null,
    assetsPath: agentAssets,
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
