@Tags(['unit'])
library;

import 'dart:io';

import 'package:core/core.dart';
import 'package:test/test.dart';

void main() {
  test('connects once, and returns when the other end closes', () async {
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(server.close);
    var accepted = 0;
    server.listen((socket) {
      accepted++;
      socket.destroy();
    });

    await probeLocalPort(server.port);

    expect(accepted, 1);
  });

  test('stops waiting for a service that keeps the connection open', () async {
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(server.close);
    final held = <Socket>[];
    server.listen(held.add);
    addTearDown(() {
      for (final socket in held) {
        socket.destroy();
      }
    });

    await probeLocalPort(
      server.port,
      wait: const Duration(milliseconds: 50),
    ).timeout(const Duration(seconds: 2));

    expect(held, hasLength(1));
  });

  test('throws when nothing listens on the port', () async {
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final port = server.port;
    await server.close();

    await expectLater(probeLocalPort(port), throwsA(isA<SocketException>()));
  });
}
