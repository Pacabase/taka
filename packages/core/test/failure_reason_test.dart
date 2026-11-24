@Tags(['unit'])
library;

import 'package:core/core.dart';
import 'package:test/test.dart';

void main() {
  const database = Tunnel(
    id: 'a1',
    sshHost: 'bastion',
    localPort: 15432,
    remoteHost: 'db.internal',
    remotePort: 5432,
  );
  const docker = Tunnel(
    id: 's6',
    sshHost: 'bastion',
    localPort: 2375,
    remoteSocket: '/var/run/docker.sock',
  );
  const web = Tunnel(
    id: 'r5',
    kind: TunnelKind.remote,
    sshHost: 'bastion',
    localPort: 3000,
    remotePort: 8080,
  );

  for (final (tunnel, failure, short, sentence) in [
    (
      database,
      TunnelFailure.sshNotFound,
      'ssh not found',
      "Can't find ssh on this computer.",
    ),
    (
      database,
      TunnelFailure.config,
      "SSH settings don't work",
      "The SSH settings for this server don't work.",
    ),
    (
      database,
      TunnelFailure.portInUse,
      'port 15432 in use',
      'Port 15432 is already in use.',
    ),
    (
      web,
      TunnelFailure.duplicateForward,
      'port 8080 already open',
      'Another tunnel already opens port 8080 on the server.',
    ),
    (
      database,
      TunnelFailure.addressUnavailable,
      'address not on this computer',
      "This computer doesn't have the From address.",
    ),
    (
      database,
      TunnelFailure.hostNotFound,
      'server not found',
      "Can't find the server.",
    ),
    (
      database,
      TunnelFailure.unreachable,
      "can't reach the server",
      "Can't reach the server.",
    ),
    (
      database,
      TunnelFailure.loginRefused,
      'login refused',
      'The server refused the login.',
    ),
    (
      database,
      TunnelFailure.hostKey,
      'host key changed',
      "The server's host key changed.",
    ),
    (
      database,
      TunnelFailure.dropped,
      'disconnected',
      'The connection dropped.',
    ),
    (
      web,
      TunnelFailure.remotePortRefused,
      "server won't open port 8080",
      "The server won't open port 8080: it's taken there, "
          "or forwarding isn't allowed.",
    ),
    (
      database,
      TunnelFailure.forwardProhibited,
      "server won't forward",
      "The server doesn't allow this tunnel.",
    ),
    (
      database,
      TunnelFailure.forwardRefused,
      "can't reach db.internal:5432",
      "Can't reach db.internal:5432 through the server.",
    ),
    (
      database,
      TunnelFailure.oldSsh,
      'ssh too old',
      "This computer's ssh is too old to ask for a password or passphrase. "
          'It needs OpenSSH 8.5 or newer.',
    ),
    (
      docker,
      TunnelFailure.forwardRefused,
      "can't open /var/run/docker.sock",
      "Can't open /var/run/docker.sock on the server.",
    ),
  ]) {
    test('says "$short" for ${failure.name}', () {
      expect(failureShort(tunnel, Failed('ssh said', failure: failure)), short);
    });

    test('says "$sentence" for ${failure.name}', () {
      expect(failureSentence(tunnel, failure), sentence);
    });
  }

  test('keeps an unknown failure as ssh wrote it, when short', () {
    expect(
      failureShort(database, const Failed('  something new from ssh  ')),
      'something new from ssh',
    );
  });

  test("says only that it couldn't connect for an unknown failure", () {
    expect(
      failureSentence(database, TunnelFailure.other),
      "It couldn't connect.",
    );
  });

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

    test('names the socket a tunnel could not open', () {
      expect(
        forwardWarning(
          const Tunnel(
            id: 's6',
            sshHost: 'bastion',
            localPort: 2375,
            remoteSocket: '/var/run/docker.sock',
          ),
        ),
        "Can't open /var/run/docker.sock on the server.",
      );
    });

    test('names where a remote tunnel leads on this computer', () {
      expect(
        forwardWarning(
          const Tunnel(
            id: 'r5',
            kind: TunnelKind.remote,
            sshHost: 'bastion',
            localPort: 3000,
            remotePort: 8080,
          ),
        ),
        "Can't reach localhost:3000 from this computer.",
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
