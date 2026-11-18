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

  void writeAppId(String appId) =>
      File('${assets.path}/${TakaBuild.appIdFileName}')
          .writeAsStringSync('$appId\n');

  test('is a release when the packaged app ID is the release one', () {
    writeAppId('com.pacabase.taka');

    expect(TakaBuild.inAgentAssets(assets.path), TakaBuild.release);
  });

  test('is a development build when packaged with the dev app ID', () {
    writeAppId('com.pacabase.taka.dev');

    expect(TakaBuild.inAgentAssets(assets.path), TakaBuild.development);
  });

  test('is a development build when nothing packaged it', () {
    expect(TakaBuild.inAgentAssets(assets.path), TakaBuild.development);
  });

  test('names the agent after the app', () {
    expect(TakaBuild.release.agentId, 'com.pacabase.taka.agent');
    expect(TakaBuild.development.agentId, 'com.pacabase.taka.dev.agent');
  });

  group('matches the builds', () {
    String read(String path) => File('../../$path').readAsStringSync();

    test('Xcode gives Debug and Profile the development app ID', () {
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
            'APP_BUNDLE_NAME[config=$configuration] = '
            '${TakaBuild.development.name}\n',
          ),
        );
      }
    });

    test('CMake gives every build but Release the development app ID', () {
      final cmake = read('linux/CMakeLists.txt');

      expect(
        cmake,
        contains('set(APPLICATION_ID "${TakaBuild.release.appId}")'),
      );
      expect(TakaBuild.development.appId, '${TakaBuild.release.appId}.dev');
      expect(cmake, contains(r'set(APPLICATION_ID "${APPLICATION_ID}.dev")'));
    });

    test('both embed scripts write the app ID file the agent reads', () {
      expect(
        read('macos/embed_agent.sh'),
        contains('Resources/${TakaBuild.appIdFileName}"'),
      );
      expect(
        read('linux/embed_agent.sh'),
        contains(
          r'$destination/'
          '${TakaBuild.appIdFileName}"',
        ),
      );
    });
  });
}
