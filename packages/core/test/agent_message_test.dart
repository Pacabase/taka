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
      AgentMessage.openTunnel('a1'),
      AgentMessage.openTunnel(),
      AgentMessage.settings(AgentSettings(launchesAtLogin: true)),
      AgentMessage.settings(AgentSettings(isLogging: true)),
      AgentMessage.prompts([]),
      AgentMessage.prompts([
        LoginPrompt(
          id: 1,
          tunnelId: 'database',
          prompt: SshPassphrasePrompt(
            "Enter passphrase for key '/home/me/.ssh/id_ed25519': ",
            keyPath: '/home/me/.ssh/id_ed25519',
          ),
        ),
        LoginPrompt(
          id: 2,
          tunnelId: 'proxy',
          prompt: SshPasswordPrompt("me@bastion's password: "),
        ),
        LoginPrompt(
          id: 3,
          tunnelId: 'web',
          prompt: SshCodePrompt('(me@web) Verification code: '),
        ),
        LoginPrompt(
          id: 4,
          tunnelId: 'old',
          prompt: SshPasswordPrompt("me@old's password: ", isVerified: false),
        ),
      ]),
    ]) {
      test('$message round-trips', () {
        expect(
          AgentMessage.fromJson(jsonDecode(jsonEncode(message.toJson()))),
          message,
        );
      });
    }

    test('a login prompt says its kind, and a passphrase its key', () {
      expect(
        const LoginPrompt(
          id: 1,
          tunnelId: 'database',
          prompt: SshPassphrasePrompt(
            "Enter passphrase for key '/k': ",
            keyPath: '/k',
          ),
        ).toJson(),
        {
          'id': 1,
          'tunnel': 'database',
          'kind': 'passphrase',
          'keyPath': '/k',
          'text': "Enter passphrase for key '/k': ",
        },
      );
    });

    test('a login prompt ssh can vouch for says nothing of it', () {
      expect(
        const LoginPrompt(
          id: 1,
          tunnelId: 'web',
          prompt: SshCodePrompt('Code: '),
        ).toJson(),
        isNot(contains('verified')),
      );
      expect(
        const LoginPrompt(
          id: 1,
          tunnelId: 'web',
          prompt: SshCodePrompt('Code: ', isVerified: false),
        ).toJson()['verified'],
        false,
      );
    });

    test('a prompt of a kind this build does not know is a code', () {
      expect(
        LoginPrompt.fromJson({
          'id': 1,
          'tunnel': 'web',
          'kind': 'fingerprint',
          'text': 'Touch the key',
        }),
        const LoginPrompt(
          id: 1,
          tunnelId: 'web',
          prompt: SshCodePrompt('Touch the key'),
        ),
      );
    });

    test('a passphrase prompt without its key is a code', () {
      expect(
        LoginPrompt.fromJson({
          'id': 1,
          'tunnel': 'web',
          'kind': 'passphrase',
          'text': 'Enter passphrase',
        }).prompt,
        const SshCodePrompt('Enter passphrase'),
      );
    });

    test('a malformed login prompt is a FormatException', () {
      expect(
        () => AgentMessage.fromJson({
          'prompts': [
            {'id': '1', 'tunnel': 'web', 'kind': 'code', 'text': 'Code'},
          ],
        }),
        throwsFormatException,
      );
    });

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

    test('settings with a malformed launchAtLogin say it is not offered', () {
      expect(
        AgentMessage.fromJson({
          'settings': {'launchAtLogin': 'yes', 'debugLogging': true},
        }),
        const AgentMessage.settings(AgentSettings(isLogging: true)),
      );
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

    for (final json in [
      {'agent': 3},
      {'show': 'settings'},
      {'tunnels': <Object?>[]},
      {'settings': 1},
      {'settings': null},
      {'settings': <String, Object?>{}},
      {
        'settings': {'launchAtLogin': true},
      },
      {
        'settings': {'debugLogging': 'yes'},
      },
      ['agent'],
      null,
    ]) {
      test('$json is a FormatException', () {
        expect(() => AgentMessage.fromJson(json), throwsFormatException);
      });
    }
  });
}
