@Tags(['unit'])
library;

import 'dart:convert';

import 'package:core/core.dart';
import 'package:test/test.dart';

import 'fakes/fakes.dart';

void main() {
  Object? throughJson(Object? json) => jsonDecode(jsonEncode(json));

  group('AgentCommand', () {
    for (final command in const [
      AgentCommand.save(database),
      AgentCommand.remove('a1'),
      AgentCommand.toggle('b2'),
    ]) {
      test('$command round-trips', () {
        expect(
          AgentCommand.fromJson(
            throughJson(command.toJson())! as Map<String, Object?>,
          ),
          command,
        );
      });
    }

    for (final json in [
      {'command': 'remove'},
      {'command': 'toggle', 'id': 3},
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

    test('an unknown command is a FormatException', () {
      expect(
        () => AgentCommand.fromJson({'command': 'reboot'}),
        throwsFormatException,
      );
    });
  });
}
