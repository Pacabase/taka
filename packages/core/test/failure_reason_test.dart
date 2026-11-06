@Tags(['unit'])
library;

import 'package:core/core.dart';
import 'package:test/test.dart';

void main() {
  for (final (message, reason) in [
    ('127.0.0.1:8080 is already in use', 'port 8080 in use'),
    (
      'ssh: connect to host bastion port 22: Connection refused',
      "can't reach the server",
    ),
    (
      'ssh: connect to host bastion port 22: Operation timed out',
      "can't reach the server",
    ),
    (
      'ssh: connect to host bastion port 22: No route to host',
      "can't reach the server",
    ),
    (
      'ssh: Could not resolve hostname bastion: nodename nor servname '
          'provided, or not known',
      'server not found',
    ),
    ('user@bastion: Permission denied (publickey).', 'login refused'),
    ('Host key verification failed.', 'host key changed'),
    (
      '@ WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED! @',
      'host key changed',
    ),
    ('Connection to bastion closed by remote host.', 'disconnected'),
    ('Connection reset by 10.0.0.1 port 22', 'disconnected'),
    ('client_loop: send disconnect: Broken pipe', 'disconnected'),
    ('Timeout, server bastion not responding.', 'server stopped answering'),
  ]) {
    test('says "$reason" for "$message"', () {
      expect(shortReason(message), reason);
    });
  }

  test('keeps an unknown message as ssh wrote it', () {
    expect(shortReason('  something new from ssh  '), 'something new from ssh');
  });
}
