@Tags(['unit'])
library;

import 'package:core/core.dart';
import 'package:test/test.dart';

void main() {
  for (final (message, short, sentence) in [
    (
      '127.0.0.1:8080 is already in use',
      'port 8080 in use',
      'Port 8080 is already in use.',
    ),
    (
      'ssh: connect to host bastion port 22: Connection refused',
      "can't reach the server",
      "Can't reach the server.",
    ),
    (
      'ssh: connect to host bastion port 22: Operation timed out',
      "can't reach the server",
      "Can't reach the server.",
    ),
    (
      'ssh: connect to host bastion port 22: No route to host',
      "can't reach the server",
      "Can't reach the server.",
    ),
    (
      'ssh: Could not resolve hostname bastion: nodename nor servname '
          'provided, or not known',
      'server not found',
      "Can't find the server.",
    ),
    (
      'user@bastion: Permission denied (publickey).',
      'login refused',
      'The server refused the login.',
    ),
    (
      'Host key verification failed.',
      'host key changed',
      "The server's host key changed.",
    ),
    (
      '@ WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED! @',
      'host key changed',
      "The server's host key changed.",
    ),
    (
      'the host key for bastion has changed; it now offers the ED25519 key '
          'SHA256:4Q0Hx2v6PZ9dW1yYk0r6hN1m1bGq9cYw8u2bq3Jm8sY',
      'host key changed',
      "The server's host key changed.",
    ),
    (
      'Connection to bastion closed by remote host.',
      'disconnected',
      'The connection dropped.',
    ),
    (
      'Connection reset by 10.0.0.1 port 22',
      'disconnected',
      'The connection dropped.',
    ),
    (
      'client_loop: send disconnect: Broken pipe',
      'disconnected',
      'The connection dropped.',
    ),
    ('Disconnected', 'disconnected', 'The connection dropped.'),
    (
      'Timeout, server bastion not responding.',
      'server stopped answering',
      'The server stopped answering.',
    ),
  ]) {
    test('says "$short" for "$message"', () {
      expect(shortReason(message), short);
    });

    test('says "$sentence" for "$message"', () {
      expect(plainReason(message), sentence);
    });
  }

  test('keeps an unknown message as ssh wrote it, when short', () {
    expect(shortReason('  something new from ssh  '), 'something new from ssh');
  });

  for (final message in ['something new from ssh', 'Bad state: boom', '']) {
    test('says only that it couldn\'t connect for "$message"', () {
      expect(plainReason(message), "It couldn't connect.");
    });
  }

  group('forwardWarning', () {
    test('names the destination a local tunnel could not reach', () {
      expect(
        forwardWarning(
          const Tunnel(
            id: 'a1',
            sshHost: 'bastion',
            localPort: 15432,
            remoteHost: 'db.example.com',
            remotePort: 5432,
          ),
        ),
        "Can't reach db.example.com:5432 through the server.",
      );
    });

    test('says a site through a SOCKS proxy could not be reached', () {
      expect(
        forwardWarning(
          const Tunnel(
            id: 'b2',
            kind: TunnelKind.socks,
            sshHost: 'bastion',
            localPort: 1080,
          ),
        ),
        "A site through the SOCKS proxy couldn't be reached.",
      );
    });
  });
}
