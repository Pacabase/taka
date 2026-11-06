@Tags(['unit'])
library;

import 'dart:io';

import 'package:agent/src/process_name.dart';
import 'package:test/test.dart';

void main() {
  test('LaunchServices shows the name it is given', () async {
    restoreProcessName('Taka name test');

    final info = await Process.run('lsappinfo', ['info', '#$pid']);

    expect('${info.stdout}', startsWith('"Taka name test" '));
  }, testOn: 'mac-os');

  test('ps shows the name it is given', () async {
    restoreProcessName('Taka name test');

    final ps = await Process.run('ps', ['-o', 'comm=', '-p', '$pid']);

    expect('${ps.stdout}'.trim(), 'Taka name test');
  }, testOn: 'linux');
}
