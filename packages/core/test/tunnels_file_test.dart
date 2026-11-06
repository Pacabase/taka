@Tags(['unit'])
library;

import 'package:core/core.dart';
import 'package:test/test.dart';

import 'fakes/fakes.dart';

void main() {
  test('decodes what it encodes, with the tunnels that were on', () {
    final decoded = decodeTunnels(encodeTunnels([database, proxy], on: {'b2'}));

    expect(decoded.tunnels, [database, proxy]);
    expect(decoded.on, {'b2'});
  });

  for (final text in [
    '[]',
    '{"version": 2, "tunnels": []}',
    '{"tunnels": 1}',
  ]) {
    test('$text is a FormatException', () {
      expect(() => decodeTunnels(text), throwsFormatException);
    });
  }
}
