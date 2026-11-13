import 'dart:io';

Future<void> probeLocalPort(int port) async {
  final socket = await Socket.connect(
    InternetAddress.loopbackIPv4,
    port,
    timeout: const Duration(seconds: 3),
  );
  socket
    ..done.ignore()
    ..destroy();
}
