import 'dart:io';

Future<void> probeLocalPort(String address, int port) async {
  final socket = await Socket.connect(
    InternetAddress(address),
    port,
    timeout: const Duration(seconds: 3),
  );
  socket
    ..done.ignore()
    ..destroy();
}
