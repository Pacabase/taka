@Tags(['unit'])
@TestOn('!windows')
library;

import 'dart:io';

import 'package:core/core.dart';
import 'package:test/test.dart';

void main() {
  test('a socket left behind by a dead agent is replaced', () async {
    final directory = await Directory.systemTemp.createTemp('taka_unix');
    addTearDown(() => directory.delete(recursive: true));
    final channel = UnixChannel('${directory.path}/agent.sock');
    final stale = await ServerSocket.bind(
      InternetAddress(
        '${directory.path}/agent.sock',
        type: InternetAddressType.unix,
      ),
      0,
    );
    await stale.close();
    File('${directory.path}/agent.sock').createSync();

    final listener = await channel.listen();
    addTearDown(() => listener?.close());
    final client = await channel.connect();
    addTearDown(client.close);

    expect(listener, isNotNull);
  });

  test('a path too long for a socket is an error, not another agent', () async {
    final directory = await Directory.systemTemp.createTemp('taka_unix');
    addTearDown(() => directory.delete(recursive: true));

    expect(
      UnixChannel('${directory.path}/${'x' * 200}.sock').listen(),
      throwsA(isA<SocketException>()),
    );
  });
}
