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
      AgentMessage.openTunnel('a1'),
      AgentMessage.openTunnel(),
      AgentMessage.settings(AgentSettings(launchesAtLogin: true)),
      AgentMessage.settings(AgentSettings(isLogging: true)),
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

    test('settings say whether launch at login is offered and on', () {
      expect(
        const AgentMessage.settings(
          AgentSettings(launchesAtLogin: true, isLogging: true),
        ).toJson(),
        {
          'settings': {'launchAtLogin': true, 'debugLogging': true},
        },
      );
      expect(const AgentMessage.settings(AgentSettings()).toJson(), {
        'settings': {'launchAtLogin': null, 'debugLogging': false},
      });
    });

    test('openTunnel names the tunnel, or none for a new one', () {
      expect(const AgentMessage.openTunnel('a1').toJson(), {
        'show': 'tunnel',
        'id': 'a1',
      });
      expect(const AgentMessage.openTunnel().toJson(), {
        'show': 'tunnel',
        'id': null,
      });
    });

    test('openTunnel with a malformed id is not read as a new tunnel', () {
      expect(
        () => AgentMessage.fromJson({'show': 'tunnel', 'id': 5}),
        throwsFormatException,
      );
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
