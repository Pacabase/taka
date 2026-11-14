@Tags(['unit'])
library;

import 'package:core/core.dart';
import 'package:system_ssh/system_ssh.dart';
import 'package:test/test.dart';

void main() {
  const database = Tunnel(
    id: '',
    sshHost: 'deploy@bastion',
    localPort: 15432,
    remoteHost: 'db',
    remotePort: 5432,
  );
  const proxy = Tunnel(
    id: '',
    kind: TunnelKind.socks,
    sshHost: 'bastion',
    localPort: 1080,
  );

  group('reads back what Taka copies', () {
    test('a local forward', () {
      final pasted = parseSshCommand(
        tunnelCommand(
          const SshTarget('bastion', user: 'deploy'),
          remoteHost: 'db',
          remotePort: 5432,
          localPort: 15432,
        ),
      );

      expect(pasted?.tunnel, database);
      expect(pasted?.leftOut, isEmpty);
    });

    test('a SOCKS proxy', () {
      final pasted = parseSshCommand(
        socksProxyCommand(const SshTarget('bastion'), localPort: 1080),
      );

      expect(pasted?.tunnel, proxy);
      expect(pasted?.leftOut, isEmpty);
    });

    test('a forward to a socket', () {
      final pasted = parseSshCommand(
        socketTunnelCommand(
          const SshTarget('bastion'),
          remoteSocket: '/var/run/docker.sock',
          localPort: 2375,
        ),
      );

      expect(
        pasted?.tunnel,
        const Tunnel(
          id: '',
          sshHost: 'bastion',
          localPort: 2375,
          remoteSocket: '/var/run/docker.sock',
        ),
      );
      expect(pasted?.leftOut, isEmpty);
    });

    test('a remote forward', () {
      final pasted = parseSshCommand(
        remoteTunnelCommand(
          const SshTarget('bastion'),
          localPort: 3000,
          remotePort: 8080,
        ),
      );

      expect(
        pasted?.tunnel,
        const Tunnel(
          id: '',
          kind: TunnelKind.remote,
          sshHost: 'bastion',
          localHost: 'localhost',
          localPort: 3000,
          remotePort: 8080,
        ),
      );
      expect(pasted?.leftOut, isEmpty);
    });

    test('a remote forward typed without a bind address', () {
      final pasted = parseSshCommand('ssh -R 8080:192.168.1.1:80 bastion');

      expect(pasted?.tunnel.kind, TunnelKind.remote);
      expect(pasted?.tunnel.remotePort, 8080);
      expect(pasted?.tunnel.localHost, '192.168.1.1');
      expect(pasted?.tunnel.localPort, 80);
    });

    test('an IPv6 destination', () {
      final pasted = parseSshCommand(
        tunnelCommand(
          const SshTarget('bastion'),
          remoteHost: '::1',
          remotePort: 5432,
          localPort: 15432,
        ),
      );

      expect(pasted?.tunnel.remoteHost, '::1');
    });

    test('a server port, which a tunnel cannot keep', () {
      final pasted = parseSshCommand(
        tunnelCommand(
          const SshTarget('bastion', port: 2222),
          remoteHost: 'db',
          remotePort: 5432,
          localPort: 15432,
        ),
      );

      expect(pasted?.tunnel.sshHost, 'bastion');
      expect(pasted?.leftOut, ['-p 2222']);
    });
  });

  group('reads a command written by hand', () {
    for (final (reason, command, tunnel) in [
      (
        'without a bind address',
        'ssh -L 15432:db:5432 deploy@bastion',
        database,
      ),
      (
        'with the value against its flag',
        'ssh -L15432:db:5432 deploy@bastion',
        database,
      ),
      (
        'with flags grouped',
        'ssh -fNT -L 15432:db:5432 deploy@bastion',
        database,
      ),
      (
        'with the forward in a group',
        'ssh -NfL 15432:db:5432 deploy@bastion',
        database,
      ),
      (
        'with options after the host',
        'ssh deploy@bastion -N -L 15432:db:5432',
        database,
      ),
      (
        'with a group after the host',
        'ssh deploy@bastion -NfL 15432:db:5432',
        database,
      ),
      (
        'with the user from -l',
        'ssh -l deploy -L 15432:db:5432 bastion',
        database,
      ),
      (
        'with the user in the host before -l',
        'ssh deploy@bastion -l root -L 15432:db:5432',
        database,
      ),
      (
        'with -l before the user in the host',
        'ssh -l deploy -L 15432:db:5432 root@bastion',
        database,
      ),
      (
        'before a redirection',
        'ssh -fN -L 15432:db:5432 deploy@bastion > /dev/null 2>&1',
        database,
      ),
      ('with port 22', 'ssh -p 22 -L 15432:db:5432 deploy@bastion', database),
      ('after a prompt', r'$ ssh -L 15432:db:5432 deploy@bastion', database),
      ('from a path', '/usr/bin/ssh -L 15432:db:5432 deploy@bastion', database),
      (
        'across lines',
        'ssh -N \\\n  -L 15432:db:5432 \\\r\n  deploy@bastion\n',
        database,
      ),
      ('in quotes', "ssh -L '15432:db:5432' \"deploy@bastion\"", database),
      (
        'in the background',
        'ssh -fN -L 15432:db:5432 deploy@bastion &',
        database,
      ),
      (
        'before another command',
        'ssh -fN -L 15432:db:5432 deploy@bastion && psql',
        database,
      ),
      (
        'before an operator with no space',
        'ssh -L 15432:db:5432 deploy@bastion;ls',
        database,
      ),
      (
        'on another address',
        'ssh -L 172.17.0.1:15432:db:5432 deploy@bastion',
        database.copyWith(bindAddress: '172.17.0.1'),
      ),
      (
        "on every address, as ssh's *",
        'ssh -L *:15432:db:5432 deploy@bastion',
        database.copyWith(bindAddress: '0.0.0.0'),
      ),
      (
        'on every address, as an empty one',
        'ssh -L :15432:db:5432 deploy@bastion',
        database.copyWith(bindAddress: '0.0.0.0'),
      ),
      (
        'on 127.0.0.1, the default',
        'ssh -L 127.0.0.1:15432:db:5432 deploy@bastion',
        database,
      ),
      (
        'on a name, left at the default',
        'ssh -L localhost:15432:db:5432 deploy@bastion',
        database,
      ),
      ('a SOCKS proxy', 'ssh -D 1080 bastion', proxy),
      (
        'a SOCKS proxy with a bind address',
        'ssh -D localhost:1080 bastion',
        proxy,
      ),
      (
        'a SOCKS proxy on another address',
        'ssh -D 0.0.0.0:1080 bastion',
        proxy.copyWith(bindAddress: '0.0.0.0'),
      ),
    ]) {
      test(reason, () {
        final pasted = parseSshCommand(command);

        expect(pasted?.tunnel, tunnel);
        expect(pasted?.leftOut, isEmpty);
      });
    }

    test('IPv6 addresses in brackets', () {
      expect(
        parseSshCommand('ssh -L [::1]:15432:[fd00::5]:5432 deploy@bastion')
            ?.tunnel
            .remoteHost,
        'fd00::5',
      );
      expect(
        parseSshCommand('ssh -L [::]:15432:db:5432 deploy@bastion')
            ?.tunnel
            .bindAddress,
        '::',
      );
    });

    test('-g opens a forward with no address to other computers', () {
      expect(
        parseSshCommand('ssh -g -L 15432:db:5432 bastion')?.tunnel.bindAddress,
        '0.0.0.0',
      );
      expect(
        parseSshCommand('ssh -g -L 172.17.0.1:15432:db:5432 bastion')
            ?.tunnel
            .bindAddress,
        '172.17.0.1',
      );
    });

    test('a socket forward on another address', () {
      expect(
        parseSshCommand('ssh -L 0.0.0.0:2375:/var/run/docker.sock bastion')
            ?.tunnel
            .bindAddress,
        '0.0.0.0',
      );
    });

    test('an exposed port leaves the address to the SSH host', () {
      expect(
        parseSshCommand('ssh -R 0.0.0.0:8080:localhost:3000 bastion')
            ?.tunnel
            .bindAddress,
        isNull,
      );
    });

    test('an escape in double quotes', () {
      expect(
        parseSshCommand(r'ssh -L 15432:db:5432 "dep\"loy@bastion"')
            ?.tunnel
            .sshHost,
        'dep"loy@bastion',
      );
    });
  });

  group('says what it leaves out', () {
    for (final (reason, command, leftOut) in [
      (
        'options a tunnel cannot keep',
        'ssh -i ~/.ssh/key.pem -J jump -o ServerAliveInterval=30 -A -g '
            '-L 15432:db:5432 deploy@bastion',
        ['-i ~/.ssh/key.pem', '-J jump', '-o ServerAliveInterval=30', '-A'],
      ),
      (
        '-g, which an exposed port cannot keep',
        'ssh -g -R 8080:localhost:3000 bastion',
        ['-g'],
      ),
      (
        'a server port against its flag',
        'ssh -p2222 -L 15432:db:5432 deploy@bastion',
        ['-p 2222'],
      ),
      (
        'a flag it does not know',
        'ssh -Z -L 15432:db:5432 deploy@bastion',
        ['-Z'],
      ),
      (
        'a second forward',
        'ssh -L 15432:db:5432 -L 16379:cache:6379 deploy@bastion',
        ['-L 16379:cache:6379'],
      ),
      ('a second SOCKS proxy', 'ssh -D 1080 -D 1081 bastion', ['-D 1081']),
      (
        'a forward of another kind',
        'ssh -R 8080:localhost:3000 -L 15432:db:5432 deploy@bastion',
        ['-L 15432:db:5432'],
      ),
      (
        'a command to run on the server',
        'ssh -L 15432:db:5432 deploy@bastion sleep 60',
        ['sleep 60'],
      ),
      (
        'a command after --',
        'ssh -L 15432:db:5432 -- deploy@bastion ls -l',
        ['ls -l'],
      ),
      (
        'a quoted operator, which is no operator',
        "ssh -L 15432:db:5432 deploy@bastion '&' ls",
        ['& ls'],
      ),
    ]) {
      test(reason, () => expect(parseSshCommand(command)?.leftOut, leftOut));
    }

    test('the first forward, keeping it', () {
      expect(
        parseSshCommand('ssh -D 1080 -L 15432:db:5432 bastion')?.tunnel,
        proxy,
      );
    });
  });

  group('is not a tunnel', () {
    for (final (reason, command) in [
      ('plain text', 'bastion'),
      ('a port', '15432'),
      ('an empty string', ''),
      ('another program', 'mosh -L 15432:db:5432 deploy@bastion'),
      ('ssh with no forward', 'ssh deploy@bastion'),
      ('a remote SOCKS proxy', 'ssh -R 1080 bastion'),
      ('a relative socket path', 'ssh -L 2375:docker.sock bastion'),
      ('no host', 'ssh -L 15432:db:5432'),
      ('a flag with no value', 'ssh bastion -L'),
      ('an unclosed quote', "ssh -L '15432:db:5432 bastion"),
      ('a forward from a socket', 'ssh -L /tmp/db.sock:db:5432 bastion'),
      ('a remote forward to a socket', 'ssh -R 8080:/run/app.sock bastion'),
      ('a forward with no host', 'ssh -L 15432::5432 bastion'),
      ('a port out of range', 'ssh -L 70000:db:5432 bastion'),
      ('port 0', 'ssh -D 0 bastion'),
      ('a port that is not a number', 'ssh -D socks bastion'),
      ('an unclosed bracket', 'ssh -L 15432:[::1:5432 bastion'),
      ('an ssh:// destination', 'ssh -L 15432:db:5432 ssh://deploy@bastion'),
    ]) {
      test(reason, () => expect(parseSshCommand(command), isNull));
    }
  });
}
