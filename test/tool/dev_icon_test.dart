@Tags(['unit'])
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart';

import '../../tool/dev_icon.dart';

void main() {
  final icon = devIcon(decodePng(File(sourcePath).readAsBytesSync())!);

  bool samePixels(String path, Image expected) => listEquals(
    decodePng(File(path).readAsBytesSync())!.getBytes(),
    expected.getBytes(),
  );

  test('the red Dev icon and every size of its set come from the current '
      'icon; run fvm dart run tool/dev_icon.dart', () {
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
  });
}
