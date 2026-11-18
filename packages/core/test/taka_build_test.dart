@Tags(['unit'])
library;

import 'dart:io';

import 'package:core/core.dart';
import 'package:test/test.dart';

void main() {
  late Directory assets;

  setUp(() async {
    assets = await Directory.systemTemp.createTemp('taka_build');
    addTearDown(() => assets.delete(recursive: true));
  });

  void writeAppId(String content, {String? into}) =>
      File('${into ?? assets.path}/app_id')
        ..parent.createSync(recursive: true)
        ..writeAsStringSync(content);

  for (final content in [
    'com.pacabase.taka\n',
    'com.pacabase.taka',
    '  com.pacabase.taka\r\n',
  ]) {
    test(
      'is a release for ${content.trim()} written as ${content.length} bytes',
      () {
        writeAppId(content);

        expect(TakaBuild.inAgentAssets(assets.path), TakaBuild.release);
      },
    );
  }

  for (final content in [
    'com.pacabase.taka.dev\n',
    '',
    'com.pacabase.taka.agent\n',
    'COM.PACABASE.TAKA\n',
  ]) {
    test('is a development build for "${content.trim()}"', () {
      writeAppId(content);

      expect(TakaBuild.inAgentAssets(assets.path), TakaBuild.development);
    });
  }

  test('is a development build when nothing packaged it', () {
    expect(TakaBuild.inAgentAssets(assets.path), TakaBuild.development);
  });

  test('names the agent after the app', () {
    expect(TakaBuild.release.agentId, 'com.pacabase.taka.agent');
    expect(TakaBuild.development.agentId, 'com.pacabase.taka.dev.agent');
  });

  group('an install reads its build from its agent', () {
    test('inside a macOS app bundle', () {
      final app = '${assets.path}/Taka.app/Contents';
      writeAppId(
        'com.pacabase.taka\n',
        into: '$app/Library/LoginItems/Taka.app/Contents/Resources',
      );

      final window = TakaInstall.fromWindow(
        '$app/MacOS/Taka',
        environment: {},
        operatingSystem: 'macos',
      );
      final agent = TakaInstall.fromAgent(
        '$app/Library/LoginItems/Taka.app/Contents/MacOS/Taka',
        environment: {},
      );

      expect(window.build, TakaBuild.release);
      expect(agent.build, TakaBuild.release);
    });

    test('beside a Linux bundle', () {
      writeAppId('com.pacabase.taka\n', into: '${assets.path}/agent');

      final window = TakaInstall.fromWindow(
        '${assets.path}/taka',
        environment: {},
        operatingSystem: 'linux',
      );
      final agent = TakaInstall.fromAgent(
        '${assets.path}/agent/bin/taka_agent',
        environment: {},
      );

      expect(window.build, TakaBuild.release);
      expect(agent.build, TakaBuild.release);
    });

    test('not from anywhere else', () {
      writeAppId('com.pacabase.taka\n', into: '${assets.path}/agent/bin');

      expect(
        TakaInstall.fromAgent(
          '${assets.path}/agent/bin/taka_agent',
          environment: {},
        ).build,
        TakaBuild.development,
      );
    });
  });

  group('matches the builds', () {
    String read(String path) => File('../../$path').readAsStringSync();

    test('Xcode gives Debug and Profile the development app ID and name', () {
      final config = read('macos/Runner/Configs/AppInfo.xcconfig');

      expect(
        config,
        contains('PRODUCT_BUNDLE_IDENTIFIER = ${TakaBuild.release.appId}\n'),
      );
      for (final configuration in ['Debug', 'Profile']) {
        expect(
          config,
          contains(
            'PRODUCT_BUNDLE_IDENTIFIER[config=$configuration] = '
            '${TakaBuild.development.appId}\n',
          ),
        );
        expect(
          config,
          contains(
            'PRODUCT_NAME[config=$configuration] = '
            '${TakaBuild.development.name}\n',
          ),
        );
      }
      expect(config, contains('PRODUCT_NAME = ${TakaBuild.release.name}\n'));
      expect(
        config,
        contains('WINDOW_NAME = ${TakaBuild.release.name} Settings\n'),
      );
      for (final configuration in ['Debug', 'Profile']) {
        expect(
          config,
          contains(
            'WINDOW_NAME[config=$configuration] = '
            '${TakaBuild.release.name} Settings Dev\n',
          ),
        );
      }
      expect(
        read('macos/Runner/Info.plist'),
        contains('<string>\$(WINDOW_NAME)</string>'),
      );
    });

    test('the macOS embed script names the helper and writes the app ID', () {
      final script = read('macos/embed_agent.sh');
      const plist = r'"$helper/Contents/Info.plist"';

      expect(
        script,
        contains(
          'plutil -replace CFBundleIdentifier -string '
          '"\$PRODUCT_BUNDLE_IDENTIFIER.agent" $plist\n',
        ),
      );
      for (final key in ['CFBundleName', 'CFBundleDisplayName']) {
        expect(
          script,
          contains('plutil -replace $key -string "\$PRODUCT_NAME" $plist\n'),
        );
      }
      expect(
        script,
        contains(
          r'echo "$PRODUCT_BUNDLE_IDENTIFIER" > '
          r'"$helper/Contents/Resources/app_id"'
          '\n',
        ),
      );
    });

    test('CMake gives every build but Release the development app ID', () {
      final cmake = read('linux/CMakeLists.txt');

      expect(
        cmake,
        contains('set(APPLICATION_ID "${TakaBuild.release.appId}")'),
      );
      expect(
        cmake,
        contains(
          'if(NOT CMAKE_BUILD_TYPE STREQUAL "Release")\n'
          r'  set(APPLICATION_ID "${APPLICATION_ID}.dev")',
        ),
      );
      expect(TakaBuild.development.appId, '${TakaBuild.release.appId}.dev');
      expect(
        cmake,
        contains(r'\"${CMAKE_INSTALL_PREFIX}/agent\" \"${APPLICATION_ID}\"'),
      );
    });

    test('the Linux embed script writes the app ID it is given', () {
      final script = read('linux/embed_agent.sh');

      expect(script, contains('app_id="\$4"\n'));
      expect(
        script,
        contains(
          r'echo "$app_id" > "$destination/app_id"'
          '\n',
        ),
      );
    });
  });
}
