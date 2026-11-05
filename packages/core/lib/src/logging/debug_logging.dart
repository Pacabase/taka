import 'dart:io';

import 'package:core/src/logging/file_log_tree.dart';
import 'package:core/src/paths.dart';
import 'package:fimber/fimber.dart';

class DebugLogging(
  final String process, {
  final Directory? logs,
  final File? flag,
}) {
  late final Directory _logs = logs ?? logDirectory();
  late final File _flag = flag ?? File('${takaDirectory().path}/debug-logging');
  FileLogTree? _tree;

  bool get isOn => _flag.existsSync();

  void start() {
    if (!isOn) return;

    try {
      _startWriting();
    } on FileSystemException catch (exception) {
      Fimber.w('Could not start the debug log', ex: exception);
    }
  }

  // The flag follows the file, so a log that can't be written stays off.
  void turn({required bool on}) {
    try {
      if (on) {
        _startWriting();
        _flag.createSync(recursive: true);
      } else {
        _stopWriting();
        if (_flag.existsSync()) _flag.deleteSync();
      }
    } on FileSystemException catch (exception) {
      Fimber.w(
        'Could not turn debug logging ${on ? 'on' : 'off'}',
        ex: exception,
      );
    }
  }

  Future<void> reveal() async {
    _logs.createSync(recursive: true);
    await Process.run(Platform.isMacOS ? 'open' : 'xdg-open', [_logs.path]);
  }

  void _startWriting() {
    if (_tree != null) return;

    Fimber.plantTree(_tree = FileLogTree.open(_logs, process: process));
  }

  void _stopWriting() {
    if (_tree case final tree?) {
      Fimber.unplantTree(tree);
      tree.close();
      _tree = null;
    }
  }
}
