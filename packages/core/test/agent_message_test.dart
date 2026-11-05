@Tags(['unit'])
library;

import 'dart:convert';

import 'package:core/core.dart';
import 'package:test/test.dart';

import 'fakes/fakes.dart';

void main() {
  group('AgentMessage', () {
    const snapshot = TunnelsSnapshot(
      tunnels: [database, proxy],
      statuses: {'a1': Connected()},
    );

    for (final message in const [
      AgentMessage.identity('1.2.0+7'),
      AgentMessage.identity(''),
      AgentMessage.snapshot(snapshot),
      AgentMessage.snapshot(TunnelsSnapshot()),
      AgentMessage.showAbout(),
    ]) {
      test('$message round-trips', () {
        expect(
          AgentMessage.fromJson(jsonDecode(jsonEncode(message.toJson()))),
          message,
        );
      });
    }

    test('the identity is under agent', () {
      expect(const AgentMessage.identity('1.2.0+7').toJson(), {
        'agent': '1.2.0+7',
      });
    });

    test('a snapshot is sent untagged', () {
      expect(const AgentMessage.snapshot(snapshot).toJson(), snapshot.toJson());
    });

    test('showAbout is show about', () {
      expect(const AgentMessage.showAbout().toJson(), {'show': 'about'});
    });

    for (final json in [
      {'agent': 3},
      {'show': 'settings'},
      {'tunnels': <Object?>[]},
      ['agent'],
      null,
    ]) {
      test('$json is a FormatException', () {
        expect(() => AgentMessage.fromJson(json), throwsFormatException);
      });
    }
  });
}
