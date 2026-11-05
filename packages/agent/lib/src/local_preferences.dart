import 'dart:async';
import 'dart:io';

import 'package:core/core.dart';
import 'package:fimber/fimber.dart';
import 'package:nativeapi/nativeapi.dart';

class LocalPreferences({
  required final DebugLogging debugLogging,
  final LaunchAtLogin? launchAtLogin,
}) implements AgentPreferences {
  final _changes = StreamController<AgentSettings>.broadcast(sync: true);

  @override
  AgentSettings get settings => AgentSettings(
    launchesAtLogin: launchAtLogin?.isEnabled,
    isLogging: debugLogging.isOn,
  );

  @override
  Stream<AgentSettings> get changes => _changes.stream;

  // macOS may want the login item approved in System Settings first.
  @override
  void setLaunchAtLogin({required bool on}) {
    final login = launchAtLogin;
    if (login == null) return;

    on ? login.enable() : login.disable();
    if (login.isEnabled != on) {
      Fimber.w('Could not turn launch at login ${on ? 'on' : 'off'}');
      if (on && Platform.isMacOS) {
        unawaited(
          Process.run('open', [
            'x-apple.systempreferences:com.apple.LoginItems-Settings.extension',
          ]).then(
            (_) {},
            onError: (Object exception) =>
                Fimber.w('Could not open Login Items', ex: exception),
          ),
        );
      }
    }
    _changes.add(settings);
  }

  @override
  void setDebugLogging({required bool on}) {
    debugLogging.turn(on: on);
    _changes.add(settings);
  }

  @override
  Future<void> showLogs() => debugLogging.reveal();
}
