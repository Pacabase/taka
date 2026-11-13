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

    test('a bind address round-trips, and is left out when there is none', () {
      final docker = database.copyWith(bindAddress: '172.17.0.1');

      expect(docker.toJson(), containsPair('bindAddress', '172.17.0.1'));
      expect(Tunnel.fromJson(docker.toJson()), docker);
      expect(database.toJson(), isNot(contains('bindAddress')));
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
        '127.0.0.1:15432 → db.internal:5432 via deploy@bastion.example.com',
      );
    });

    test('summary describes a SOCKS proxy', () {
      expect(proxy.summary, 'SOCKS on 127.0.0.1:1080 via bastion');
    });

    test('summary describes a tunnel to a socket', () {
      expect(
        docker.summary,
        '127.0.0.1:2375 → /var/run/docker.sock via bastion',
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
      expect(database.address, '127.0.0.1:15432');
      expect(proxy.address, 'socks5h://127.0.0.1:1080');
      expect(preview.address, 'localhost:8080');
    });

    test('address and summary name another address to listen on', () {
      final docker = database.copyWith(bindAddress: '172.17.0.1');

      expect(docker.address, '172.17.0.1:15432');
      expect(docker.summary, startsWith('172.17.0.1:15432 → '));
      expect(
        proxy.copyWith(bindAddress: 'fd00::1').address,
        'socks5h://[fd00::1]:1080',
      );
    });

    test('a tunnel on every address says so, and is reached on loopback', () {
      expect(
        database.copyWith(bindAddress: '0.0.0.0').summary,
        startsWith('0.0.0.0:15432 → '),
      );
      expect(
        database.copyWith(bindAddress: '0.0.0.0').address,
        '127.0.0.1:15432',
      );
      expect(
        proxy.copyWith(bindAddress: '::').summary,
        'SOCKS on [::]:1080 via bastion',
      );
      expect(
        database.copyWith(bindAddress: '0.0.0.0').reachableAt,
        '127.0.0.1',
      );
      expect(proxy.copyWith(bindAddress: '::').address, 'socks5h://[::1]:1080');
      expect(database.reachableAt, '127.0.0.1');
    });

    test('reaches every address on loopback however it is written', () {
      for (final (address, reached) in [
        ('::0', '::1'),
        ('0:0:0:0:0:0:0:0', '::1'),
        ('172.17.0.1', '172.17.0.1'),
      ]) {
        expect(
          database.copyWith(bindAddress: address).reachableAt,
          reached,
          reason: address,
        );
      }
    });

    test('toString names the id and title', () {
      expect('$database', 'Tunnel(a1, Production database)');
    });
  });

  group('groups', () {
    const a = Tunnel(id: 'a', localPort: 1, group: 'Prod');
    const b = Tunnel(id: 'b', localPort: 2);
    const c = Tunnel(id: 'c', localPort: 3, group: 'Prod');
    const d = Tunnel(id: 'd', localPort: 4);
    const e = Tunnel(id: 'e', localPort: 5, group: 'dev');
    const tunnels = [a, b, c, d, e];

    test('a group round-trips, and is left out when there is none', () {
      expect(a.toJson()['group'], 'Prod');
      expect(Tunnel.fromJson(a.toJson()), a);
      expect(b.toJson().containsKey('group'), isFalse);
    });

    test('lists each group once, by name whatever its case', () {
      expect(tunnels.groups, ['dev', 'Prod']);
      expect(const [b, d].groups, isEmpty);
    });

    String layout(List<Tunnel> tunnels) => tunnels.rows
        .map(
          (row) => switch (row) {
            GroupHeaderRow(:final group, :final size) => '[$group $size]',
            TunnelRow(:final tunnel) => tunnel.id,
            GroupEndRow() => '/',
          },
        )
        .join(' ');

    // Rows: 0 [Prod 2], 1 a, 2 c, 3 /, 4 b, 5 d, 6 [dev 1], 7 e, 8 /.
    test(
      'shows each group where its first tunnel is, between a header and a gap',
      () {
        expect(tunnels.shown, [a, c, b, d, e]);
        expect(layout(tunnels), '[Prod 2] a c / b d [dev 1] e /');
      },
    );

    group('a dropped tunnel', () {
      test('dropped above a header is in no group', () {
        expect(
          layout(tunnels.droppedAt(4, 0)),
          'b [Prod 2] a c / d [dev 1] e /',
        );
      });

      test("dropped among a group's tunnels joins it", () {
        expect(
          layout(tunnels.droppedAt(5, 2)),
          '[Prod 3] a d c / b [dev 1] e /',
        );
      });

      test('dropped right under a header joins that group', () {
        expect(
          layout(tunnels.droppedAt(4, 1)),
          '[Prod 3] b a c / d [dev 1] e /',
        );
      });

      test("dropped above a group's gap joins it as its last tunnel", () {
        expect(
          layout(tunnels.droppedAt(4, 3)),
          '[Prod 3] a c b / d [dev 1] e /',
        );
      });

      test("dropped below a group's gap lands after the group", () {
        final dropped = tunnels.droppedAt(1, 3);

        expect(layout(dropped), '[Prod 1] c / a b d [dev 1] e /');
        expect(dropped.firstWhere((tunnel) => tunnel.id == 'a').group, isNull);
      });

      test(
        "taken out of its group, a group's only tunnel leaves no header",
        () {
          expect(layout(tunnels.droppedAt(7, 0)), 'e [Prod 2] a c / b d');
        },
      );

      test("dropped above the last group's gap joins it", () {
        expect(
          layout(tunnels.droppedAt(4, 7)),
          '[Prod 2] a c / d [dev 2] e b /',
        );
        expect(tunnels.groupOnDrop(4, 7), 'dev');
        expect(tunnels.groupOnDrop(4, 0), isNull);
      });

      test('dropped past the end lands at the end, in no group', () {
        expect(tunnels.droppedAt(4, 99).last, b);
      });
    });

    group('a dropped group', () {
      test('moves with all its tunnels', () {
        expect(
          layout(tunnels.droppedAt(0, 5)),
          'b d [dev 1] e / [Prod 2] a c /',
        );
        expect(
          layout(tunnels.droppedAt(6, 0)),
          '[dev 1] e / [Prod 2] a c / b d',
        );
      });

      test('can sit between tunnels in no group', () {
        expect(
          layout(tunnels.droppedAt(6, 5)),
          '[Prod 2] a c / b [dev 1] e / d',
        );
      });

      test(
        'dropped inside another group lands next to it, the nearer side',
        () {
          expect(
            layout(tunnels.droppedAt(6, 3)),
            '[Prod 2] a c / [dev 1] e / b d',
          );
          expect(
            layout(tunnels.droppedAt(6, 1)),
            '[dev 1] e / [Prod 2] a c / b d',
          );
          // Halfway, it goes before.
          expect(
            layout(tunnels.droppedAt(6, 2)),
            '[dev 1] e / [Prod 2] a c / b d',
          );
        },
      );

      test('dropped past the end lands at the end', () {
        expect(tunnels.droppedAt(0, 99), tunnels.droppedAt(0, 5));
      });
    });

    test('groupLike names the group in use, whatever the case', () {
      expect(groupLike(['Prod', 'dev'], 'prod'), 'Prod');
      expect(groupLike(['Prod'], 'Staging'), 'Staging');
      expect(groupLike(['prod'], 'Prod', except: 'prod'), 'Prod');
    });

    test('a blank group is no group', () {
      expect(
        Tunnel.fromJson({'id': 'x', 'localPort': 1, 'group': '  '}).group,
        isNull,
      );
      expect(
        Tunnel.fromJson({'id': 'x', 'localPort': 1, 'group': ' Prod '}).group,
        'Prod',
      );
    });

    test(
      'arranges by an order of ids and groups, keeping any it leaves out',
      () {
        expect(
          tunnels.arranged([(id: 'e', group: null), (id: 'a', group: 'dev')]),
          [e.copyWith(group: null), a.copyWith(group: 'dev'), b, c, d],
        );
        expect(
          tunnels.arranged([
            (id: 'zz', group: 'x'),
            (id: 'b', group: 'Prod'),
            (id: 'b', group: 'dev'),
          ]),
          [b.copyWith(group: 'Prod'), a, c, d, e],
        );
      },
    );
  });

  group('addresses', () {
    for (final (typed, kept) in [
      (null, null),
      ('', null),
      (' 127.0.0.1 ', null),
      ('localhost', null),
      ('*', '0.0.0.0'),
      ('[::1]', '::1'),
      ('172.17.0.1', '172.17.0.1'),
    ]) {
      test('keeps ${typed == null ? 'none' : "'$typed'"} as $kept', () {
        expect(bindAddressNamed(typed), kept);
      });
    }

    test('a saved default address reads as none', () {
      expect(
        Tunnel.fromJson({...database.toJson(), 'bindAddress': '127.0.0.1'}),
        database,
      );
    });

    for (final (address, isIp, isLoopback, isEvery) in [
      ('127.0.0.1', true, true, false),
      ('127.0.0.2', true, true, false),
      ('::1', true, true, false),
      ('0:0:0:0:0:0:0:1', true, true, false),
      ('0.0.0.0', true, false, true),
      ('::', true, false, true),
      ('::0', true, false, true),
      ('172.17.0.1', true, false, false),
      ('localhost', false, false, false),
      ('1.2.3', false, false, false),
      ('fe80::1%en0', false, false, false),
    ]) {
      test(address, () {
        expect(isIpAddress(address), isIp, reason: 'isIpAddress');
        expect(isLoopbackAddress(address), isLoopback, reason: 'isLoopback');
        expect(isEveryAddress(address), isEvery, reason: 'isEveryAddress');
      });
    }
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

    test('listens on the bind address', () {
      expect(
        database.copyWith(bindAddress: '172.17.0.1').sshCommand,
        contains('-L 172.17.0.1:15432:db.internal:5432'),
      );
      expect(
        docker.copyWith(bindAddress: '0.0.0.0').sshCommand,
        contains('-L 0.0.0.0:2375:/var/run/docker.sock'),
      );
      expect(
        proxy.copyWith(bindAddress: '::').sshCommand,
        contains('-D [::]:1080'),
      );
      expect(database.copyWith(bindAddress: 'localhost').sshCommand, isNull);
    });

    test('is null for a tunnel ssh cannot open', () {
      expect(preview.copyWith(remotePort: null).sshCommand, isNull);
      expect(proxy.copyWith(localPort: 0).sshCommand, isNull);
      expect(database.copyWith(localPort: 65536).sshCommand, isNull);
      expect(proxy.copyWith(sshHost: '-oProxyCommand=x').sshCommand, isNull);
    });
  });
}
