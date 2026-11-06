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
      Connected(warning: 'db.internal:5432: Connection refused'),
      Reconnecting('Connection to bastion closed by remote host.'),
      Failed('127.0.0.1:5432 is already in use'),
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
      ({'status': 'reconnecting'}, const Stopped()),
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
        ].map((status) => status.isOn),
        [false, true, true, false],
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
