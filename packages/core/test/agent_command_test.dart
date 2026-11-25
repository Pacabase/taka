@Tags(['unit'])
library;

import 'dart:convert';

import 'package:core/core.dart';
import 'package:test/test.dart';

import 'fakes/fakes.dart';

void main() {
  test('arrange with a tunnel that is not one is a FormatException', () {
    expect(
      () => AgentCommand.fromJson({
        'command': 'arrange',
        'tunnels': [42],
      }),
      throwsFormatException,
    );
  });

  test('arrange reads a blank group as none', () {
    expect(
      AgentCommand.fromJson({
        'command': 'arrange',
        'tunnels': [
          {'id': 'a1', 'group': ' '},
        ],
      }),
      const AgentCommand.arrange([(id: 'a1', group: null)]),
    );
  });

  test('a cancel is an answer without one', () {
    expect(const AgentCommand.answer(3, null).toJson(), {
      'command': 'answer',
      'prompt': 3,
    });
    expect(
      AgentCommand.fromJson({'command': 'answer', 'prompt': 3, 'answer': 7}),
      const AgentCommand.answer(3, null),
    );
  });

  test('an answer never shows in its description', () {
    expect(
      '${const AgentCommand.answer(1, 'hunter2')}',
      isNot(contains('hunter2')),
    );
  });

  group('AgentCommand', () {
    for (final command in const [
      AgentCommand.save(database),
      AgentCommand.remove('a1'),
      AgentCommand.toggle('b2'),
      AgentCommand.arrange([
        (id: 'b2', group: 'Prod'),
        (id: 'a1', group: null),
      ]),
      AgentCommand.trustHostKey('a1', 'SHA256:4Q0Hx2v6PZ9dW1yYk0r6hN1m1bGq9cY'),
      AgentCommand.editGroup('Prod', name: 'Live', colour: TunnelColour.purple),
      AgentCommand.editGroup('Prod', name: 'Prod', colour: null),
      AgentCommand.setLaunchAtLogin(on: true),
      AgentCommand.setDebugLogging(on: false),
      AgentCommand.showLogs(),
      AgentCommand.importTunnels([database, proxy]),
      AgentCommand.importTunnels(
        [database],
        groupColours: {'Prod': TunnelColour.green},
      ),
      AgentCommand.exportTunnels('/Users/me/tunnels.json'),
      AgentCommand.quit(),
      AgentCommand.answer(1, 'hunter2'),
      AgentCommand.answer(2, ''),
      AgentCommand.answer(3, null),
      AgentCommand.sawPrompts([1, 2]),
    ]) {
      // Named by its JSON: its description leaves most of it out.
      test('${jsonEncode(command.toJson())} round-trips', () {
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
