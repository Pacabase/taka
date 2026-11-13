@Tags(['unit'])
library;

import 'dart:async';
import 'dart:io';

import 'package:core/core.dart';
import 'package:test/test.dart';

void main() {
  test('connects once', () async {
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(server.close);
    final accepted = <Socket>[];
    server.listen(accepted.add);

    await probeLocalPort(server.port);
    await pumpEventQueue();

    expect(accepted, hasLength(1));
  });

  test('closes the connection at once', () async {
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(server.close);
    final closed = Completer<void>();
    void close([Object? _]) {
      if (!closed.isCompleted) closed.complete();
    }

    server.listen(
      (socket) => socket
        ..done.ignore()
        ..listen(null, onError: close, onDone: close),
    );

    await probeLocalPort(server.port).timeout(const Duration(seconds: 2));

    await closed.future.timeout(const Duration(seconds: 2));
  });

  test('throws when nothing listens on the port', () async {
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final port = server.port;
    await server.close();

    await expectLater(probeLocalPort(port), throwsA(isA<SocketException>()));
  });
}
