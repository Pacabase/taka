@Tags(['unit'])
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart';

import '../../tool/app_icons.dart';

void main() {
  final source = decodePng(File(sourcePath).readAsBytesSync())!;
  final icon = devIcon(source);

  bool samePixels(String path, Image expected) => listEquals(
    decodePng(File(path).readAsBytesSync())!.getBytes(),
    expected.getBytes(),
  );

  test('the red Dev icon, its macOS set and both Windows icons come from '
      'the current icon; run fvm dart run tool/app_icons.dart', () {
    final files = iconSetFiles();

    expect(samePixels(devIconPath, icon), isTrue);
    expect(files, isNotEmpty);
    expect(
      File('$devIconSet/Contents.json').readAsStringSync(),
      File('$releaseIconSet/Contents.json').readAsStringSync(),
    );
    files.forEach(
      (size, name) => expect(
        samePixels('$devIconSet/$name', iconAt(icon, size)),
        isTrue,
        reason: name,
      ),
    );
    expect(File(windowsIcon).readAsBytesSync(), windowsIconFor(source));
    expect(File(windowsDevIcon).readAsBytesSync(), windowsIconFor(icon));
  });
}
