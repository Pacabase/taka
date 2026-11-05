import 'dart:io';

import 'package:collection/collection.dart';
import 'package:core/src/logging/log_format.dart';
import 'package:fimber/fimber.dart';

class FileLogTree._({
  required final File file,
  required final RandomAccessFile _output,
  required final DateTime Function() _clock,
}) extends LogTree {
  static FileLogTree open(
    Directory directory, {
    required String process,
    int keep = 10,
    DateTime Function() clock = DateTime.now,
  }) {
    final name = RegExp('^${RegExp.escape(process)}-[\\dT-]+\\.log\$');
    directory.createSync(recursive: true);
    directory
        .listSync()
        .whereType<File>()
        .where((file) => name.hasMatch(file.uri.pathSegments.last))
        .sortedBy((file) => file.uri.pathSegments.last)
        .reversed
        .skip(keep - 1)
        .forEach(_deleteQuietly);

    final stamp = logTimestamp(clock())
        .replaceAll(' ', 'T')
        .replaceAll(RegExp('[:.]'), '-');
    final file = File(
      '${directory.path}${Platform.pathSeparator}$process-$stamp.log',
    );

    return FileLogTree._(
      file: file,
      output: file.openSync(mode: FileMode.append),
      clock: clock,
    );
  }

  @override
  List<String> getLevels() => const ['V', 'D', 'I', 'W', 'E'];

  // Written straight through, so a crash still leaves every line before it.
  @override
  void log(
    String level,
    String message, {
    String? tag,
    dynamic ex,
    StackTrace? stacktrace,
  }) {
    try {
      _output.writeStringSync(
        formatLogLine(
          time: _clock(),
          level: level,
          tag: tag ?? 'Taka',
          message: message,
          exception: ex,
          stackTrace: stacktrace,
        ),
      );
    } on FileSystemException {
      return;
    }
  }

  void close() {
    try {
      _output.closeSync();
    } on FileSystemException {
      return;
    }
  }

  static void _deleteQuietly(File file) {
    try {
      file.deleteSync();
    } on FileSystemException {
      return;
    }
  }
}
