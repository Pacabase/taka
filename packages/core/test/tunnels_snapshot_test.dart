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

    test('an unknown status reads as stopped', () {
      expect(TunnelStatus.fromJson({'status': 'paused'}), const Stopped());
    });

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
