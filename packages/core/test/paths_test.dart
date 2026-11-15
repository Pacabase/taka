@Tags(['unit'])
library;

import 'dart:io';

import 'package:core/core.dart';
import 'package:test/test.dart';

void main() {
  const home = {'HOME': '/home/someone'};
  const windows = {
    'APPDATA': r'C:\Users\someone\AppData\Roaming',
    'LOCALAPPDATA': r'C:\Users\someone\AppData\Local',
    'SystemRoot': r'C:\Windows',
  };

  group('takaDirectory', () {
    test('is in Application Support on macOS', () {
      expect(
        takaDirectory(environment: home, operatingSystem: 'macos').path,
        '/home/someone/Library/Application Support/com.pacabase.taka',
      );
    });

    test('is in the XDG data folder on Linux', () {
      expect(
        takaDirectory(environment: home, operatingSystem: 'linux').path,
        '/home/someone/.local/share/com.pacabase.taka',
      );
    });

    test('an empty XDG_DATA_HOME counts as unset', () {
      expect(
        takaDirectory(
          environment: {...home, 'XDG_DATA_HOME': ''},
          operatingSystem: 'linux',
        ).path,
        '/home/someone/.local/share/com.pacabase.taka',
      );
    });

    test('XDG_DATA_HOME moves the folder', () {
      expect(
        takaDirectory(
          environment: {...home, 'XDG_DATA_HOME': '/data'},
          operatingSystem: 'linux',
        ).path,
        '/data/com.pacabase.taka',
      );
    });

    test('is in the roaming AppData on Windows', () {
      expect(
        takaDirectory(environment: windows, operatingSystem: 'windows').path,
        r'C:\Users\someone\AppData\Roaming\Taka',
      );
    });

    test('finds AppData in the profile when APPDATA is unset', () {
      expect(
        takaDirectory(
          environment: {'USERPROFILE': r'C:\Users\someone', 'APPDATA': ''},
          operatingSystem: 'windows',
        ).path,
        r'C:\Users\someone\AppData\Roaming\Taka',
      );
    });

    test('reads Windows variables in any case', () {
      expect(
        takaDirectory(
          environment: {'AppData': r'D:\Roaming'},
          operatingSystem: 'windows',
        ).path,
        r'D:\Roaming\Taka',
      );
    });

    test('is unsupported elsewhere', () {
      expect(
        () => takaDirectory(environment: home, operatingSystem: 'fuchsia'),
        throwsUnsupportedError,
      );
    });
  });

  group('agentSocketPath', () {
    test('is in the folder on macOS and Linux', () {
      for (final system in ['macos', 'linux']) {
        expect(
          agentSocketPath(environment: home, operatingSystem: system),
          endsWith('com.pacabase.taka/agent.sock'),
        );
      }
    });

    test('is a ticket in the local AppData on Windows', () {
      expect(
        agentSocketPath(environment: windows, operatingSystem: 'windows'),
        r'C:\Users\someone\AppData\Local\Taka\agent.port',
      );
    });
  });

  group('logDirectory', () {
    test('is in ~/Library/Logs on macOS', () {
      expect(
        logDirectory(environment: home, operatingSystem: 'macos').path,
        '/home/someone/Library/Logs/Taka',
      );
    });

    test('is in the XDG state folder on Linux', () {
      expect(
        logDirectory(environment: home, operatingSystem: 'linux').path,
        '/home/someone/.local/state/taka/logs',
      );
    });

    test('follows XDG_STATE_HOME on Linux', () {
      expect(
        logDirectory(
          environment: {...home, 'XDG_STATE_HOME': '/state'},
          operatingSystem: 'linux',
        ).path,
        '/state/taka/logs',
      );
    });

    test('is in the local AppData on Windows', () {
      expect(
        logDirectory(environment: windows, operatingSystem: 'windows').path,
        r'C:\Users\someone\AppData\Local\Taka\logs',
      );
    });
  });

  group('sshExecutable', () {
    test('is the ssh on the PATH on macOS and Linux', () {
      for (final system in ['macos', 'linux']) {
        expect(
          sshExecutable(environment: home, operatingSystem: system),
          'ssh',
        );
      }
    });

    test("is Windows' own OpenSSH on Windows", () {
      expect(
        sshExecutable(
          environment: {...windows, 'SystemRoot': r'D:\Windows'},
          operatingSystem: 'windows',
        ),
        r'D:\Windows\System32\OpenSSH\ssh.exe',
      );
    });

    test('falls back to C:\\Windows without SystemRoot', () {
      expect(
        sshExecutable(environment: {}, operatingSystem: 'windows'),
        r'C:\Windows\System32\OpenSSH\ssh.exe',
      );
    });
  });

  group('agentIdentity', () {
    late Directory directory;
    late File agent;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp('taka_identity');
      agent = File('${directory.path}/taka_agent')
        ..writeAsStringSync('v1')
        ..setLastModifiedSync(DateTime(2026));
    });

    tearDown(() => directory.delete(recursive: true));

    test('stays the same for the same build', () {
      expect(agentIdentity(agent.path), agentIdentity(agent.path));
    });

    test('changes when a newer build replaces the file', () {
      final before = agentIdentity(agent.path);
      agent
        ..writeAsStringSync('v2')
        ..setLastModifiedSync(DateTime(2026, 2));

      expect(agentIdentity(agent.path), isNot(before));
    });

    test('is the same through a link to the file', () {
      final link = Link('${directory.path}/link')..createSync(agent.path);

      expect(agentIdentity(link.path), agentIdentity(agent.path));
    });

    test('throws when there is no agent at the path', () {
      expect(
        () => agentIdentity('${directory.path}/missing'),
        throwsA(isA<FileSystemException>()),
      );
    });
  });

  group('TakaInstall', () {
    const bundle = '/Applications/Taka.app';
    const agentBundle = '$bundle/Contents/Library/LoginItems/Taka.app';
    const installed = TakaInstall(
      app: bundle,
      agent: '$agentBundle/Contents/MacOS/Taka',
      agentBundle: agentBundle,
      agentAssets: '$agentBundle/Contents/Resources',
    );
    const onLinux = TakaInstall(
      app: '/opt/taka/taka',
      agent: '/opt/taka/agent/bin/taka_agent',
      agentAssets: '/opt/taka/agent',
    );
    const onWindows = TakaInstall(
      app: r'C:\Users\someone\AppData\Local\Programs\Taka\taka.exe',
      agent: r'C:\Users\someone\AppData\Local\Programs\Taka\agent\bin\taka_agent.exe',
      agentAssets: r'C:\Users\someone\AppData\Local\Programs\Taka\agent',
    );
    const development = TakaInstall(
      app: '/src/taka/build/macos/Build/Products/Debug/Taka.app',
      agent: '/src/taka/packages/agent/build/cli/macos_arm64/bundle/bin/taka_agent',
      agentAssets: '/src/taka/packages/agent/build/cli/macos_arm64/bundle',
    );

    test('is the same macOS bundle from the window and from the agent', () {
      expect(
        TakaInstall.fromWindow(
          '$bundle/Contents/MacOS/Taka',
          environment: {},
          operatingSystem: 'macos',
        ),
        installed,
      );
      expect(
        TakaInstall.fromAgent(
          installed.agent,
          environment: {},
          operatingSystem: 'macos',
        ),
        installed,
      );
    });

    test('is the same Linux install from the window and from the agent', () {
      expect(
        TakaInstall.fromWindow(
          '/opt/taka/taka',
          environment: {},
          operatingSystem: 'linux',
        ),
        onLinux,
      );
      expect(
        TakaInstall.fromAgent(
          onLinux.agent,
          environment: {},
          operatingSystem: 'linux',
        ),
        onLinux,
      );
    });

    test('is the same Windows install from the window and from the agent', () {
      expect(
        TakaInstall.fromWindow(
          onWindows.app,
          environment: {},
          operatingSystem: 'windows',
        ),
        onWindows,
      );
      expect(
        TakaInstall.fromAgent(
          onWindows.agent,
          environment: {},
          operatingSystem: 'windows',
        ),
        onWindows,
      );
    });

    test('follows TAKA_AGENT and TAKA_APP to development builds', () {
      expect(
        TakaInstall.fromWindow(
          '${development.app}/Contents/MacOS/Taka',
          environment: {'TAKA_AGENT': development.agent},
          operatingSystem: 'macos',
        ),
        development,
      );
      expect(
        TakaInstall.fromAgent(
          development.agent,
          environment: {'TAKA_APP': development.app},
        ),
        development,
      );
    });
  });
}
