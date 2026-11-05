@Tags(['unit'])
library;

import 'dart:io';

import 'package:core/core.dart';
import 'package:core/src/logging/file_log_tree.dart';
import 'package:core/src/logging/log_format.dart';
import 'package:fimber/fimber.dart';
import 'package:test/test.dart';

void main() {
  late Directory directory;
  late DateTime now;

  DateTime clock() => now;

  List<String> names() =>
      directory
          .listSync()
          .whereType<File>()
          .map((file) => file.uri.pathSegments.last)
          .toList()
        ..sort();

  setUp(() {
    directory = Directory.systemTemp.createTempSync('taka_logs_');
    now = DateTime(2026, 3, 7, 9, 5, 4, 32);
  });

  tearDown(() {
    Fimber.clearAll();
    if (directory.existsSync()) directory.deleteSync(recursive: true);
  });

  group('formatLogLine', () {
    test('puts later lines, the exception and the stack trace under it', () {
      expect(
        formatLogLine(
          time: now,
          level: 'E',
          tag: 'Tunnels',
          message: 'Dev failed\nsecond line',
          exception: 'boom',
          stackTrace: StackTrace.fromString('#0 frame\n'),
        ),
        '2026-03-07 09:05:04.032 E/Tunnels: Dev failed\n'
        '    second line\n'
        '    boom\n'
        '    #0 frame\n',
      );
    });
  });

  group('FileLogTree', () {
    FileLogTree open({int keep = 10}) =>
        FileLogTree.open(directory, process: 'agent', keep: keep, clock: clock);

    test('starts a stamped file for its process and writes lines to it', () {
      final tree = open()..log('I', 'Connected', tag: 'Tunnels');
      now = DateTime(2026, 3, 7, 9, 5, 5, 100);
      tree.log('W', 'Dropped');

      expect(
        tree.file.uri.pathSegments.last,
        'agent-2026-03-07T09-05-04-032.log',
      );
      expect(tree.file.readAsLinesSync(), [
        '2026-03-07 09:05:04.032 I/Tunnels: Connected',
        '2026-03-07 09:05:05.100 W/Taka: Dropped',
      ]);
    });

    test("keeps the newest files of its process and nobody else's", () {
      for (final stamp in ['01', '02', '03']) {
        File('${directory.path}/agent-2026-03-${stamp}T00-00-00-000.log')
            .createSync();
      }
      File('${directory.path}/window-2026-03-01T00-00-00-000.log').createSync();

      open(keep: 2);

      expect(names(), [
        'agent-2026-03-03T00-00-00-000.log',
        'agent-2026-03-07T09-05-04-032.log',
        'window-2026-03-01T00-00-00-000.log',
      ]);
    });
  });

  group('DebugLogging', () {
    late File flag;

    DebugLogging logging() => DebugLogging(
      'agent',
      logs: Directory('${directory.path}/logs'),
      flag: flag,
    );

    setUp(() => flag = File('${directory.path}/debug-logging'));

    test('writes nothing until it is turned on', () {
      logging().start();
      Fimber.i('hidden');

      expect(Directory('${directory.path}/logs').existsSync(), isFalse);
    });

    test('turned on, it remembers and writes; turned off, it stops', () {
      final debugLogging = logging()..turn(on: true);
      Fimber.i('shown');
      debugLogging.turn(on: false);
      Fimber.i('hidden');

      final file = Directory('${directory.path}/logs')
          .listSync()
          .whereType<File>()
          .single;
      expect(file.readAsStringSync(), contains('shown'));
      expect(file.readAsStringSync(), isNot(contains('hidden')));
      expect(debugLogging.isOn, isFalse);
    });

    test('a process started while it is on writes from the start', () {
      logging().turn(on: true);
      Fimber.clearAll();

      final window = DebugLogging(
        'window',
        logs: Directory('${directory.path}/logs'),
        flag: flag,
      )..start();
      Fimber.i('window started');

      expect(window.isOn, isTrue);
      expect(
        Directory('${directory.path}/logs')
            .listSync()
            .whereType<File>()
            .where((file) => file.path.contains('window-'))
            .single
            .readAsStringSync(),
        contains('window started'),
      );
    });
  });

  group('logDirectory', () {
    test('is in ~/Library/Logs on macOS and the XDG state folder on Linux', () {
      final logs = logDirectory(environment: {'HOME': '/home/me'}).path;

      expect(
        logs,
        Platform.isMacOS
            ? '/home/me/Library/Logs/Taka'
            : '/home/me/.local/state/taka/logs',
      );
    });

    test('follows XDG_STATE_HOME on Linux', () {
      final logs = logDirectory(
        environment: {'HOME': '/home/me', 'XDG_STATE_HOME': '/state'},
      ).path;

      expect(
        logs,
        Platform.isMacOS ? '/home/me/Library/Logs/Taka' : '/state/taka/logs',
      );
    });
  });
}
