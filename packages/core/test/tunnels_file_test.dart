@Tags(['unit'])
library;

import 'dart:convert';

import 'package:core/core.dart';
import 'package:test/test.dart';

import 'fakes/fakes.dart';

void main() {
  Object? versionOf(List<Tunnel> tunnels) =>
      (jsonDecode(encodeTunnels(tunnels)) as Map<String, Object?>)['version'];

  test('stays at version 1 for tunnels a version 1 build can keep', () {
    expect(versionOf([database, proxy]), 1);
  });

  test('is version 2 once a remote or socket tunnel is in it', () {
    expect(versionOf([database, preview]), 2);
    expect(versionOf([proxy, docker]), 2);
  });

  for (final tunnels in [
    [database, proxy],
    [preview, docker],
  ]) {
    test('decodes what it encodes at version ${versionOf(tunnels)}, '
        'with the tunnels that were on', () {
      final decoded = decodeTunnels(
        encodeTunnels(tunnels, on: {tunnels.last.id}),
      );

      expect(decoded.tunnels, tunnels);
      expect(decoded.on, {tunnels.last.id});
    });
  }

  test('keeps each group\'s colour, and leaves out names it does not know', () {
    final text = encodeTunnels(
      [database.copyWith(group: 'Prod')],
      groupColours: {'Prod': TunnelColour.blue},
    );

    expect(decodeTunnels(text).groupColours, {'Prod': TunnelColour.blue});
    expect(
      decodeTunnels(
        '{"version": 1, "tunnels": [], "groupColours": {"Prod": "pink"}}',
      ).groupColours,
      isEmpty,
    );
    expect(
      jsonDecode(encodeTunnels([database])),
      isNot(contains('groupColours')),
    );
  });

  for (final text in [
    '[]',
    '{"version": 3, "tunnels": []}',
    '{"tunnels": 1}',
  ]) {
    test('$text is a FormatException', () {
      expect(() => decodeTunnels(text), throwsFormatException);
    });
  }
}
