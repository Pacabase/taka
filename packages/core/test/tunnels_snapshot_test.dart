@Tags(['unit'])
library;

import 'dart:convert';

import 'package:core/core.dart';
import 'package:test/test.dart';

import 'fakes/fakes.dart';

void main() {
  Object? throughJson(Object? json) => jsonDecode(jsonEncode(json));

  group('TunnelStatus', () {
    for (final status in const [
      Stopped(),
      Connecting(),
      Connected(),
      Connected(warning: 'Connection refused'),
      Reconnecting('Connection to bastion closed by remote host.'),
      Failed('127.0.0.1:5432 is already in use'),
      UnknownHostKey(
        host: 'bastion',
        type: 'ED25519',
        fingerprint: 'SHA256:4Q0Hx2v6PZ9dW1yYk0r6hN1m1bGq9cYw8u2bq3Jm8sY',
      ),
    ]) {
      test('$status round-trips', () {
        expect(
          TunnelStatus.fromJson(
            throughJson(status.toJson())! as Map<String, Object?>,
          ),
          status,
        );
      });
    }

    for (final (json, status) in [
      ({'status': 'paused'}, const Stopped()),
      ({'status': 'failed'}, const Failed('')),
      ({'status': 'failed', 'message': 3}, const Failed('')),
      ({'status': 'connected', 'warning': 3}, const Connected()),
      ({'status': 'reconnecting'}, const Reconnecting('')),
      ({'status': 'reconnecting', 'reason': 3}, const Reconnecting('')),
      ({'status': 'unknownHostKey', 'host': 'bastion'}, const Stopped()),
      (<String, Object?>{}, const Stopped()),
      (null, const Stopped()),
    ]) {
      test('$json reads as $status', () {
        expect(TunnelStatus.fromJson(json), status);
      });
    }

    test('isOn while connecting or connected', () {
      expect(
        [
          const Stopped(),
          const Connecting(),
          const Connected(),
          const Failed(''),
          const UnknownHostKey(host: '', type: '', fingerprint: ''),
        ].map((status) => status.isOn),
        [false, true, true, false, false],
      );
    });
  });

  test('a snapshot round-trips', () {
    const snapshot = TunnelsSnapshot(
      tunnels: [database, proxy],
      statuses: {'a1': Connected(), 'b2': Failed('Disconnected')},
    );

    expect(
      TunnelsSnapshot.fromJson(
        throughJson(snapshot.toJson())! as Map<String, Object?>,
      ),
      snapshot,
    );
  });

  test('a snapshot with group colours round-trips', () {
    final snapshot = TunnelsSnapshot(
      tunnels: [database.copyWith(group: 'Prod')],
      groupColours: const {'Prod': TunnelColour.green},
    );

    expect(
      TunnelsSnapshot.fromJson(
        throughJson(snapshot.toJson())! as Map<String, Object?>,
      ),
      snapshot,
    );
  });

  test("a tunnel's own colour wins over its group's", () {
    final grouped = database.copyWith(group: 'Prod');
    const snapshot = TunnelsSnapshot(
      groupColours: {'Prod': TunnelColour.green},
    );

    expect(snapshot.colourOf(grouped), TunnelColour.green);
    expect(
      snapshot.colourOf(grouped.copyWith(colour: TunnelColour.red)),
      TunnelColour.red,
    );
    expect(snapshot.colourOf(proxy), isNull);
  });

  test('a malformed snapshot is a FormatException', () {
    expect(
      () => TunnelsSnapshot.fromJson({
        'tunnels': 3,
        'statuses': <String, Object?>{},
      }),
      throwsFormatException,
    );
  });
}
