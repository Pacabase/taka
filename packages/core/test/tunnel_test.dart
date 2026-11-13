@Tags(['unit'])
library;

import 'package:core/core.dart';
import 'package:system_ssh/system_ssh.dart';
import 'package:test/test.dart';

void main() {
  const database = Tunnel(
    id: 'a1',
    name: 'Production database',
    sshHost: 'deploy@bastion.example.com',
    localPort: 15432,
    remoteHost: 'db.internal',
    remotePort: 5432,
  );
  const proxy = Tunnel(
    id: 'b2',
    kind: TunnelKind.socks,
    sshHost: 'bastion',
    localPort: 1080,
  );

  const preview = Tunnel(
    id: 'r5',
    kind: TunnelKind.remote,
    sshHost: 'bastion',
    localPort: 3000,
    remotePort: 8080,
  );

  const docker = Tunnel(
    id: 's6',
    sshHost: 'bastion',
    localPort: 2375,
    remoteSocket: '/var/run/docker.sock',
  );

  group('JSON', () {
    test('a local tunnel round-trips', () {
      expect(Tunnel.fromJson(database.toJson()), database);
    });

    test('a SOCKS proxy round-trips without remote fields', () {
      expect(proxy.toJson(), {
        'id': 'b2',
        'name': '',
        'kind': 'socks',
        'sshHost': 'bastion',
        'localPort': 1080,
      });
      expect(Tunnel.fromJson(proxy.toJson()), proxy);
    });

    test('a remote tunnel round-trips, with its local host when set', () {
      expect(preview.toJson(), {
        'id': 'r5',
        'name': '',
        'kind': 'remote',
        'sshHost': 'bastion',
        'localPort': 3000,
        'remotePort': 8080,
      });
      expect(Tunnel.fromJson(preview.toJson()), preview);

      final toRouter = preview.copyWith(localHost: '192.168.1.1');
      expect(toRouter.toJson()['localHost'], '192.168.1.1');
      expect(Tunnel.fromJson(toRouter.toJson()), toRouter);
    });

    test('a tunnel to a socket round-trips', () {
      expect(docker.toJson(), {
        'id': 's6',
        'name': '',
        'kind': 'local',
        'sshHost': 'bastion',
        'localPort': 2375,
        'remoteSocket': '/var/run/docker.sock',
      });
      expect(Tunnel.fromJson(docker.toJson()), docker);
    });

    test('missing optional fields fall back to their defaults', () {
      expect(
        Tunnel.fromJson({'id': 'c3', 'localPort': 8080}),
        const Tunnel(id: 'c3', localPort: 8080),
      );
    });

    test('an unknown kind falls back to local', () {
      expect(
        Tunnel.fromJson({'id': 'c3', 'localPort': 8080, 'kind': 'vpn'}).kind,
        TunnelKind.local,
      );
    });
  });

  group('target', () {
    test('splits user@host', () {
      expect(
        database.target,
        const SshTarget('bastion.example.com', user: 'deploy'),
      );
    });

    test('keeps an alias as the host', () {
      expect(proxy.target, const SshTarget('bastion'));
    });

    test('splits at the last @', () {
      expect(
        const Tunnel(id: 'x', sshHost: 'a@b@host', localPort: 1).target,
        const SshTarget('host', user: 'a@b'),
      );
    });
  });

  group('text', () {
    test('summary describes a local tunnel', () {
      expect(
        database.summary,
        'localhost:15432 → db.internal:5432 via deploy@bastion.example.com',
      );
    });

    test('summary describes a SOCKS proxy', () {
      expect(proxy.summary, 'SOCKS on localhost:1080 via bastion');
    });

    test('summary describes a tunnel to a socket', () {
      expect(
        docker.summary,
        'localhost:2375 → /var/run/docker.sock via bastion',
      );
    });

    test('summary describes a remote tunnel', () {
      expect(preview.summary, 'port 8080 on bastion → localhost:3000');
      expect(
        preview.copyWith(localHost: '192.168.1.1').summary,
        'port 8080 on bastion → 192.168.1.1:3000',
      );
    });

    test('title is the name, or the summary without one', () {
      expect(database.title, 'Production database');
      expect(proxy.title, proxy.summary);
    });

    test('address is where a client connects', () {
      expect(database.address, 'localhost:15432');
      expect(proxy.address, 'socks5h://localhost:1080');
      expect(preview.address, 'localhost:8080');
    });

    test('toString names the id and title', () {
      expect('$database', 'Tunnel(a1, Production database)');
    });
  });

  group('moved', () {
    const web = Tunnel(id: 'c3', sshHost: 'web', localPort: 8080);
    const tunnels = [database, proxy, web];

    test('puts a tunnel at the index among the others', () {
      expect(tunnels.moved('a1', 2), [proxy, web, database]);
      expect(tunnels.moved('c3', 0), [web, database, proxy]);
      expect(tunnels.moved('b2', 1), tunnels);
    });

    test('keeps an index past either end in the list', () {
      expect(tunnels.moved('b2', 9), [database, web, proxy]);
      expect(tunnels.moved('b2', -1), [proxy, database, web]);
    });

    test('leaves the list as it is for a tunnel it does not have', () {
      expect(tunnels.moved('zz', 0), tunnels);
    });
  });

  group('sshCommand', () {
    test('forwards the local port through the SSH host', () {
      expect(
        database.sshCommand,
        'ssh -N -L 127.0.0.1:15432:db.internal:5432 deploy@bastion.example.com',
      );
    });

    test('serves a SOCKS proxy through the SSH host', () {
      expect(proxy.sshCommand, 'ssh -N -D 127.0.0.1:1080 bastion');
    });

    test('forwards the local port to a socket on the SSH host', () {
      expect(
        docker.sshCommand,
        'ssh -N -L 127.0.0.1:2375:/var/run/docker.sock bastion',
      );
      for (final path in ['docker.sock', '/run/%h.sock', r'/run/$UID.sock']) {
        expect(docker.copyWith(remoteSocket: path).sshCommand, isNull);
      }
    });

    test('has the SSH host listen and forward back here', () {
      expect(
        preview.sshCommand,
        'ssh -N -R 127.0.0.1:8080:localhost:3000 bastion',
      );
      expect(
        preview.copyWith(localHost: '192.168.1.1').sshCommand,
        'ssh -N -R 127.0.0.1:8080:192.168.1.1:3000 bastion',
      );
    });

    test('is null for a tunnel ssh cannot open', () {
      expect(preview.copyWith(remotePort: null).sshCommand, isNull);
      expect(proxy.copyWith(localPort: 0).sshCommand, isNull);
      expect(database.copyWith(localPort: 65536).sshCommand, isNull);
      expect(proxy.copyWith(sshHost: '-oProxyCommand=x').sshCommand, isNull);
    });
  });
}
