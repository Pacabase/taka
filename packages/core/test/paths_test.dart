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
}
