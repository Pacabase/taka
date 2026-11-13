import 'dart:async';
import 'dart:io';

/// Opens one connection to `127.0.0.1:`[port], then closes it once the other
/// end does or [wait] has passed.
Future<void> probeLocalPort(
  int port, {
  Duration wait = const Duration(seconds: 3),
}) async {
  final socket = await Socket.connect(
    InternetAddress.loopbackIPv4,
    port,
    timeout: wait,
  );
  try {
    await socket.drain<void>().timeout(wait, onTimeout: () {});
  } finally {
    socket.destroy();
  }
}
