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

  Tunnel? tunnelOf(String command) => parseSshCommand(command)?.tunnel;

  List<String>? leftOutOf(String command) => parseSshCommand(command)?.leftOut;

  void expectClean(String command, Tunnel tunnel) {
    expect(tunnelOf(command), tunnel);
    expect(leftOutOf(command), isEmpty);
  }

  group('reads back what Taka copies', () {
    test('a local forward', () {
      final command = tunnelCommand(
        const SshTarget('bastion', user: 'deploy'),
        remoteHost: 'db',
        remotePort: 5432,
        localPort: 15432,
      );

      expectClean(command, database);
    });

    test('a SOCKS proxy', () {
      final command = socksProxyCommand(
        const SshTarget('bastion'),
        localPort: 1080,
      );

      expectClean(command, proxy);
    });

    test('an IPv6 destination', () {
      final command = tunnelCommand(
        const SshTarget('bastion'),
        remoteHost: '::1',
        remotePort: 5432,
        localPort: 15432,
      );

      expect(tunnelOf(command)?.remoteHost, '::1');
    });

    test('a server port, which a tunnel cannot keep', () {
      final command = tunnelCommand(
        const SshTarget('bastion', port: 2222),
        remoteHost: 'db',
        remotePort: 5432,
        localPort: 15432,
      );

      expect(tunnelOf(command)?.sshHost, 'bastion');
      expect(leftOutOf(command), ['-p 2222']);
    });
  });

  group('reads a command written by hand', () {
    test('without a bind address', () {
      expect(tunnelOf('ssh -L 15432:db:5432 deploy@bastion'), database);
    });

    test('with the value against its flag', () {
      expect(tunnelOf('ssh -L15432:db:5432 deploy@bastion'), database);
    });

    test('with flags grouped before the forward', () {
      expectClean('ssh -fNT -L 15432:db:5432 deploy@bastion', database);
      expect(tunnelOf('ssh -NfL 15432:db:5432 deploy@bastion'), database);
    });

    test('with options after the host', () {
      expect(tunnelOf('ssh deploy@bastion -N -L 15432:db:5432'), database);
    });

    test('with the user from -l', () {
      expect(tunnelOf('ssh -l deploy -L 15432:db:5432 bastion'), database);
    });

    test('preferring the user in the host over -l', () {
      expect(
        tunnelOf('ssh -l root -L 15432:db:5432 deploy@bastion')?.sshHost,
        'deploy@bastion',
      );
    });

    test('with an ssh:// destination', () {
      final pasted = parseSshCommand(
        'ssh -L 15432:db:5432 ssh://deploy@bastion:2222',
      );

      expect(pasted?.tunnel, database);
      expect(pasted?.leftOut, ['-p 2222']);
    });

    test('with port 22, which needs nothing kept', () {
      expect(leftOutOf('ssh -p 22 -L 15432:db:5432 deploy@bastion'), isEmpty);
    });

    test('from a prompt, a path or across lines', () {
      expect(tunnelOf(r'$ ssh -L 15432:db:5432 deploy@bastion'), database);
      expect(
        tunnelOf('/usr/bin/ssh -L 15432:db:5432 deploy@bastion'),
        database,
      );
      expect(
        tunnelOf('ssh -N \\\n  -L 15432:db:5432 \\\r\n  deploy@bastion\n'),
        database,
      );
    });

    test('in quotes', () {
      expect(tunnelOf("ssh -L '15432:db:5432' \"deploy@bastion\""), database);
    });

    test('ending in a shell operator', () {
      expect(tunnelOf('ssh -fN -L 15432:db:5432 deploy@bastion &'), database);
      expect(
        tunnelOf('ssh -fN -L 15432:db:5432 deploy@bastion && psql'),
        database,
      );
    });

    test('a SOCKS proxy with a bind address', () {
      expect(tunnelOf('ssh -D localhost:1080 bastion'), proxy);
    });

    test('a forward on another address, which Taka keeps local', () {
      expect(tunnelOf('ssh -L 0.0.0.0:15432:db:5432 deploy@bastion'), database);
      expect(tunnelOf('ssh -L *:15432:db:5432 deploy@bastion'), database);
      expect(
        tunnelOf('ssh -L [::1]:15432:[fd00::5]:5432 deploy@bastion')
            ?.remoteHost,
        'fd00::5',
      );
    });
  });

  group('says what it leaves out', () {
    test('options a tunnel cannot keep', () {
      expect(
        leftOutOf(
          'ssh -i ~/.ssh/key.pem -J jump -o ServerAliveInterval=30 -A -g '
          '-L 15432:db:5432 deploy@bastion',
        ),
        [
          '-i ~/.ssh/key.pem',
          '-J jump',
          '-o ServerAliveInterval=30',
          '-A',
          '-g',
        ],
      );
    });

    test('a second forward', () {
      final pasted = parseSshCommand(
        'ssh -L 15432:db:5432 -L 16379:cache:6379 deploy@bastion',
      );

      expect(pasted?.tunnel, database);
      expect(pasted?.leftOut, ['-L 16379:cache:6379']);
    });

    test('a remote forward next to a local one', () {
      expect(
        leftOutOf('ssh -R 8080:localhost:3000 -L 15432:db:5432 deploy@bastion'),
        ['-R 8080:localhost:3000'],
      );
    });

    test('a command to run on the server', () {
      expect(leftOutOf('ssh -L 15432:db:5432 deploy@bastion sleep 60'), [
        'sleep 60',
      ]);
    });
  });

  group('is not a tunnel', () {
    for (final (reason, command) in [
      ('plain text', 'bastion'),
      ('a port', '15432'),
      ('an empty string', ''),
      ('another program', 'mosh -L 15432:db:5432 deploy@bastion'),
      ('ssh with no forward', 'ssh deploy@bastion'),
      ('only a remote forward', 'ssh -R 8080:localhost:3000 bastion'),
      ('no host', 'ssh -L 15432:db:5432'),
      ('a flag with no value', 'ssh bastion -L'),
      ('an unknown flag', 'ssh -Z -L 15432:db:5432 bastion'),
      ('an unclosed quote', "ssh -L '15432:db:5432 bastion"),
      ('a forward to a socket', 'ssh -L 15432:/run/db.sock bastion'),
      ('a forward with no host', 'ssh -L 15432::5432 bastion'),
      ('a port out of range', 'ssh -L 70000:db:5432 bastion'),
      ('a port that is not a number', 'ssh -D socks bastion'),
      ('an unclosed bracket', 'ssh -L 15432:[::1:5432 bastion'),
      ('an ssh:// with no host', 'ssh -L 15432:db:5432 ssh://'),
    ]) {
      test(reason, () => expect(parseSshCommand(command), isNull));
    }
  });
}
