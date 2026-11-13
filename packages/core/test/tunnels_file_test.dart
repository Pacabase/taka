@Tags(['unit'])
library;

import 'dart:convert';

import 'package:core/core.dart';
import 'package:test/test.dart';

import 'fakes/fakes.dart';

void main() {
  test('decodes what it encodes, with the tunnels that were on', () {
    final decoded = decodeTunnels(encodeTunnels([database, proxy], on: {'b2'}));

    expect(decoded.tunnels, [database, proxy]);
    expect(decoded.on, {'b2'});
  });

  Object? versionOf(List<Tunnel> tunnels) =>
      (jsonDecode(encodeTunnels(tunnels)) as Map<String, Object?>)['version'];

  test('stays at version 1 for tunnels a version 1 build can keep', () {
    expect(versionOf([database, proxy]), 1);
  });

  test('is version 2 once a remote or socket tunnel is in it', () {
    expect(versionOf([database, preview]), 2);
    expect(versionOf([proxy, docker]), 2);
  });

  test('decodes version 2', () {
    final decoded = decodeTunnels(encodeTunnels([preview, docker]));

    expect(decoded.tunnels, [preview, docker]);
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
