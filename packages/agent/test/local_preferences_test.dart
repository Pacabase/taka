@Tags(['unit'])
library;

import 'dart:io';

import 'package:agent/src/local_preferences.dart';
import 'package:core/core.dart';
import 'package:test/test.dart';

void main() {
  late Directory directory;
  late LocalPreferences preferences;
  late List<AgentSettings> changes;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('taka_preferences');
    preferences = LocalPreferences(
      debugLogging: DebugLogging(
        'agent',
        logs: Directory('${directory.path}/logs'),
        flag: File('${directory.path}/debug-logging'),
      ),
    );
    changes = [];
    preferences.changes.listen(changes.add);
  });

  tearDown(() async {
    preferences.setDebugLogging(on: false);
    await directory.delete(recursive: true);
  });

  test('turning debug logging on and off says so', () {
    preferences.setDebugLogging(on: true);
    expect(preferences.settings.isLogging, isTrue);

    preferences.setDebugLogging(on: false);

    expect(changes, const [AgentSettings(isLogging: true), AgentSettings()]);
  });

  test('without launch at login, it is not offered and stays off', () {
    preferences.setLaunchAtLogin(on: true);

    expect(preferences.settings.launchesAtLogin, isNull);
    expect(changes, isEmpty);
  });
}
