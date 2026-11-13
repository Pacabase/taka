@Tags(['unit'])
library;

import 'dart:convert';

import 'package:core/core.dart';
import 'package:test/test.dart';

import 'fakes/fakes.dart';

void main() {
  group('AgentCommand', () {
    for (final command in const [
      AgentCommand.save(database),
      AgentCommand.remove('a1'),
      AgentCommand.toggle('b2'),
      AgentCommand.move('b2', 0),
      AgentCommand.arrange([
        (id: 'b2', group: 'Prod'),
        (id: 'a1', group: null),
      ]),
      AgentCommand.trustHostKey('a1', 'SHA256:4Q0Hx2v6PZ9dW1yYk0r6hN1m1bGq9cY'),
      AgentCommand.setLaunchAtLogin(on: true),
      AgentCommand.setDebugLogging(on: false),
      AgentCommand.showLogs(),
      AgentCommand.importTunnels([database, proxy]),
      AgentCommand.exportTunnels('/Users/me/tunnels.json'),
      AgentCommand.quit(),
    ]) {
      test('$command round-trips', () {
        expect(
          AgentCommand.fromJson(jsonDecode(jsonEncode(command.toJson()))),
          command,
        );
      });
    }

    for (final json in [
      {'command': 'reboot'},
      {'command': 'remove'},
      {'command': 'toggle', 'id': 3},
      {'command': 'move', 'id': 'b2'},
      {'command': 'debugLogging'},
      {'command': 'import', 'tunnels': 'all'},
      {'command': 'export'},
      {
        'command': 'save',
        'tunnel': {'id': 'a1'},
      },
      ['remove'],
    ]) {
      test('$json is a FormatException', () {
        expect(() => AgentCommand.fromJson(json), throwsFormatException);
      });
    }
  });
}
