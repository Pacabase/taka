@Tags(['unit'])
library;

import 'dart:io';
import 'dart:isolate';

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
        operatingSystem: 'macos',
      );

      expect(window.build, TakaBuild.release);
      expect(agent.build, TakaBuild.release);
    });

    test("inside a debug build's Taka Dev.app", () {
      final app = '${assets.path}/Taka Dev.app/Contents';
      writeAppId(
        'com.pacabase.taka.dev\n',
        into: '$app/Library/LoginItems/Taka.app/Contents/Resources',
      );

      final window = TakaInstall.fromWindow(
        '$app/MacOS/Taka Dev',
        environment: {},
        operatingSystem: 'macos',
      );
      final agent = TakaInstall.fromAgent(
        '$app/Library/LoginItems/Taka.app/Contents/MacOS/Taka',
        environment: {},
        operatingSystem: 'macos',
      );

      expect(window.build, TakaBuild.development);
      expect(agent.build, TakaBuild.development);
      expect(agent.app, endsWith('Taka Dev.app'));
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
        operatingSystem: 'linux',
      );

      expect(window.build, TakaBuild.release);
      expect(agent.build, TakaBuild.release);
    });

    test('beside a Windows install', () {
      writeAppId('com.pacabase.taka', into: '${assets.path}/agent');

      final window = TakaInstall.fromWindow(
        '${assets.path}/taka.exe',
        environment: {},
        operatingSystem: 'windows',
      );
      final agent = TakaInstall.fromAgent(
        '${assets.path}/agent/bin/Taka.exe',
        environment: {},
        operatingSystem: 'windows',
      );

      expect(window.build, TakaBuild.release);
      expect(agent.build, TakaBuild.release);
    }, testOn: 'windows');

    test('not from anywhere else', () {
      writeAppId('com.pacabase.taka\n', into: '${assets.path}/agent/bin');

      expect(
        TakaInstall.fromAgent(
          '${assets.path}/agent/bin/taka_agent',
          environment: {},
          operatingSystem: 'linux',
        ).build,
        TakaBuild.development,
      );
    });
  });

  group('matches the builds', () {
    // The package's own path, wherever the tests run from.
    final root = Directory.fromUri(
      Isolate.resolvePackageUriSync(Uri.parse('package:core/'))!,
    ).parent.parent.parent.path;
    String read(String path) => File('$root/$path').readAsStringSync();

    // Each Xcode setting, by key and configuration, as the xcconfig sets it.
    Map<String, String> settings(String name) => {
      for (final line in RegExp(
        '^($name(?:\\[config=\\w+\\])?) = (.*)\$',
        multiLine: true,
      ).allMatches(read('macos/Runner/Configs/AppInfo.xcconfig')))
        line[1]!: line[2]!,
    };

    Map<String, String> byConfiguration(
      String name,
      String Function(TakaBuild) value,
    ) => {
      name: value(TakaBuild.release),
      '$name[config=Debug]': value(TakaBuild.development),
      '$name[config=Profile]': value(TakaBuild.development),
    };

    test("Xcode sets each build's ID and names, and nothing else", () {
      expect(
        settings('PRODUCT_BUNDLE_IDENTIFIER'),
        byConfiguration('PRODUCT_BUNDLE_IDENTIFIER', (build) => build.appId),
      );
      expect(
        settings('PRODUCT_NAME'),
        byConfiguration('PRODUCT_NAME', (build) => build.name),
      );
      expect(
        settings('WINDOW_NAME'),
        byConfiguration('WINDOW_NAME', (build) => build.windowName),
      );
      expect(settings('ASSETCATALOG_COMPILER_APPICON_NAME'), {
        'ASSETCATALOG_COMPILER_APPICON_NAME': 'AppIcon',
        'ASSETCATALOG_COMPILER_APPICON_NAME[config=Debug]': 'AppIcon-Dev',
        'ASSETCATALOG_COMPILER_APPICON_NAME[config=Profile]': 'AppIcon-Dev',
      });
    });

    test("the window's bundle name is WINDOW_NAME", () {
      expect(
        read('macos/Runner/Info.plist'),
        contains('<key>CFBundleName</key>\n\t<string>\$(WINDOW_NAME)</string>'),
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
          r'cp "$app/Contents/Resources/$ASSETCATALOG_COMPILER_APPICON_NAME.icns" '
          r'"$helper/Contents/Resources/AppIcon.icns"'
          '\n',
        ),
      );
      expect(
        script,
        contains(
          r'echo "$PRODUCT_BUNDLE_IDENTIFIER" > '
          r'"$helper/Contents/Resources/app_id"'
          '\n',
        ),
      );
    });

    test('CMake gives every build but Release the development ID and name', () {
      final cmake = read('linux/CMakeLists.txt');
      final release = cmake.indexOf(
        'set(APPLICATION_ID "${TakaBuild.release.appId}")',
      );
      final dev = cmake.indexOf(
        'if(NOT CMAKE_BUILD_TYPE STREQUAL "Release")\n'
        r'  set(APPLICATION_ID "${APPLICATION_ID}.dev")'
        '\n  set(WINDOW_NAME "${TakaBuild.development.windowName}")',
      );

      expect(release, isNot(-1));
      expect(dev, greaterThan(release));
      expect(
        cmake,
        contains('set(WINDOW_NAME "${TakaBuild.release.windowName}")'),
      );
      expect(TakaBuild.development.appId, '${TakaBuild.release.appId}.dev');
      expect(
        cmake,
        contains(r'\"${CMAKE_INSTALL_PREFIX}/agent\" \"${APPLICATION_ID}\"'),
      );
      expect(
        read('linux/runner/CMakeLists.txt'),
        contains(r'add_definitions(-DWINDOW_NAME="${WINDOW_NAME}")'),
      );
    });

    test("Linux names the window's process within its 15 characters", () {
      expect(
        read('linux/runner/main.cc'),
        contains('prctl(PR_SET_NAME, "${TakaBuild.release.windowName}");'),
      );
      expect(TakaBuild.release.windowName.length, lessThanOrEqualTo(15));
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

    test(
      'the Windows embed script writes the app ID for its configuration',
      () {
        final script = read('windows/embed_agent.ps1');

        expect(
          read('windows/CMakeLists.txt'),
          contains(
            r'\"${CMAKE_INSTALL_PREFIX}/agent\"'
            '\n'
            r'      \"\${CMAKE_INSTALL_CONFIG_NAME}\"',
          ),
        );
        expect(
          script,
          contains(
            "\$appId = if (\$Configuration -eq 'Release') "
            "{ '${TakaBuild.release.appId}' } "
            "else { '${TakaBuild.development.appId}' }\n",
          ),
        );
        expect(
          script,
          contains(
            r'Set-Content -NoNewline -Path "$Destination\app_id" -Value $appId',
          ),
        );
      },
    );

    test('a Windows window is one per build, named like its agent', () {
      final main = read('windows/runner/main.cpp');

      expect(
        read('windows/runner/CMakeLists.txt'),
        contains(r'"$<$<NOT:$<CONFIG:Release>>:TAKA_DEVELOPMENT>"'),
      );
      for (final (build, prefix) in [
        (TakaBuild.development, '#ifdef TAKA_DEVELOPMENT\n'),
        (TakaBuild.release, '#else\n'),
      ]) {
        expect(
          main,
          contains(
            '$prefix'
            'constexpr wchar_t kWindowMutex[] = '
            'L"Local\\\\${build.appId}.window";\n'
            'constexpr wchar_t kWindowTitle[] = L"${build.name}";\n',
          ),
        );
      }
    });
  });
}
