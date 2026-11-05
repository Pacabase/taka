@Tags(['unit'])
library;

import 'dart:io';

import 'package:agent/src/local_preferences.dart';
import 'package:core/core.dart';
import 'package:nativeapi/nativeapi.dart';
import 'package:test/test.dart';

void main() {
  late Directory directory;
  late List<AgentSettings> changes;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('taka_preferences');
    changes = [];
  });

  tearDown(() => directory.delete(recursive: true));

  LocalPreferences preferencesWith({File? flag, LaunchAtLogin? login}) {
    final preferences = LocalPreferences(
      debugLogging: DebugLogging(
        'agent',
        logs: Directory('${directory.path}/logs'),
        flag: flag ?? File('${directory.path}/debug-logging'),
      ),
      launchAtLogin: login,
    );
    preferences.changes.listen(changes.add);
    addTearDown(() => preferences.setDebugLogging(on: false));
    return preferences;
  }

  test('turning debug logging on and off says so', () {
    final preferences = preferencesWith()..setDebugLogging(on: true);
    expect(preferences.settings.isLogging, isTrue);

    preferences.setDebugLogging(on: false);

    expect(changes, const [AgentSettings(isLogging: true), AgentSettings()]);
  });

  test('debug logging that cannot be turned on says it is off', () {
    final blocker = File('${directory.path}/blocker')..createSync();
    final preferences = preferencesWith(
      flag: File('${blocker.path}/debug-logging'),
    )..setDebugLogging(on: true);

    expect(preferences.settings.isLogging, isFalse);
    expect(changes.first, const AgentSettings());
  });

  test('without launch at login, it is not offered and stays off', () {
    final preferences = preferencesWith()..setLaunchAtLogin(on: true);

    expect(preferences.settings.launchesAtLogin, isNull);
    expect(changes, isEmpty);
  });

  test('turning launch at login on and off says so', () {
    final preferences = preferencesWith(login: _FakeLogin())
      ..setLaunchAtLogin(on: true)
      ..setLaunchAtLogin(on: false);

    expect(preferences.settings.launchesAtLogin, isFalse);
    expect(changes, const [
      AgentSettings(launchesAtLogin: true),
      AgentSettings(launchesAtLogin: false),
    ]);
  });

  test('a request the login item already matches still says where it is', () {
    preferencesWith(login: _FakeLogin()).setLaunchAtLogin(on: false);

    expect(changes, const [AgentSettings(launchesAtLogin: false)]);
  });
}

class _FakeLogin implements LaunchAtLogin {
  @override
  bool isEnabled = false;

  @override
  bool enable() => isEnabled = true;

  @override
  bool disable() => !(isEnabled = false);

  @override
  Object? noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
