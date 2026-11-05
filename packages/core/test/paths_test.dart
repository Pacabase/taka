@Tags(['unit'])
library;

import 'dart:io';

import 'package:core/core.dart';
import 'package:test/test.dart';

void main() {
  test('the folder lives in the home directory', () {
    final directory = takaDirectory(environment: {'HOME': '/home/someone'});

    expect(
      directory.path,
      Platform.isMacOS
          ? '/home/someone/Library/Application Support/com.pacabase.taka'
          : '/home/someone/.local/share/com.pacabase.taka',
    );
  });

  test('an empty XDG_DATA_HOME counts as unset', () {
    expect(
      takaDirectory(environment: {'HOME': '/home/someone', 'XDG_DATA_HOME': ''})
          .path,
      '/home/someone/.local/share/com.pacabase.taka',
    );
  }, testOn: 'linux');

  test('XDG_DATA_HOME moves the folder', () {
    expect(
      takaDirectory(
        environment: {'HOME': '/home/someone', 'XDG_DATA_HOME': '/data'},
      ).path,
      '/data/com.pacabase.taka',
    );
  }, testOn: 'linux');

  test('the agent socket is in the folder', () {
    expect(
      agentSocketPath(environment: {'HOME': '/home/someone'}),
      endsWith('com.pacabase.taka/agent.sock'),
    );
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

  group('windowLayout', () {
    test('finds the agent among the macOS bundle\'s login items', () {
      expect(
        windowLayout(
          '/Applications/Taka.app/Contents/MacOS/Taka',
          environment: {},
          operatingSystem: 'macos',
        ),
        (
          agent: '/Applications/Taka.app/Contents/Library/LoginItems/TakaAgent.app/Contents/MacOS/Taka',
          app: '/Applications/Taka.app',
          agentBundle: '/Applications/Taka.app/Contents/Library/LoginItems/TakaAgent.app',
        ),
      );
    });

    test('finds the agent beside taka on Linux', () {
      expect(
        windowLayout(
          '/opt/taka/taka',
          environment: {},
          operatingSystem: 'linux',
        ),
        (
          agent: '/opt/taka/agent/bin/taka_agent',
          app: '/opt/taka/taka',
          agentBundle: null,
        ),
      );
    });

    test('TAKA_AGENT points at a development build', () {
      expect(
        windowLayout(
          '/src/taka/build/macos/Build/Products/Debug/Taka.app/Contents/MacOS/Taka',
          environment: {
            'TAKA_AGENT': '/src/taka/packages/agent/build/cli/macos_arm64/bundle/bin/taka_agent',
          },
          operatingSystem: 'macos',
        ),
        (
          agent: '/src/taka/packages/agent/build/cli/macos_arm64/bundle/bin/taka_agent',
          app: '/src/taka/build/macos/Build/Products/Debug/Taka.app',
          agentBundle: null,
        ),
      );
    });
  });

  group('agentLayout', () {
    test('finds the app and its resources in the macOS bundle', () {
      expect(
        agentLayout(
          '/Applications/Taka.app/Contents/Library/LoginItems/TakaAgent.app/Contents/MacOS/Taka',
          environment: {},
        ),
        (
          app: '/Applications/Taka.app',
          bundle: '/Applications/Taka.app/Contents/Library/LoginItems/TakaAgent.app',
          assets: '/Applications/Taka.app/Contents/Library/LoginItems/TakaAgent.app/Contents/Resources',
        ),
      );
    });

    test('finds taka beside the agent on Linux', () {
      expect(agentLayout('/opt/taka/agent/bin/taka_agent', environment: {}), (
        app: '/opt/taka/taka',
        bundle: null,
        assets: '/opt/taka/agent',
      ));
    });

    test('TAKA_APP points a development build at its window', () {
      expect(
        agentLayout(
          '/src/taka/packages/agent/build/cli/macos_arm64/bundle/bin/taka_agent',
          environment: {
            'TAKA_APP': '/src/taka/build/macos/Build/Products/Debug/Taka.app',
          },
        ),
        (
          app: '/src/taka/build/macos/Build/Products/Debug/Taka.app',
          bundle: null,
          assets: '/src/taka/packages/agent/build/cli/macos_arm64/bundle',
        ),
      );
    });
  });
}
