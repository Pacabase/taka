@Tags(['unit'])
@TestOn('!windows')
library;

import 'dart:io';

import 'package:core/core.dart';
import 'package:test/test.dart';

void main() {
  test('a path too long for a socket is an error, not another agent', () async {
    final directory = await Directory.systemTemp.createTemp('taka_unix');
    addTearDown(() => directory.delete(recursive: true));

    expect(
      UnixChannel('${directory.path}/${'x' * 200}.sock').listen(),
      throwsA(isA<SocketException>()),
    );
  });
}
