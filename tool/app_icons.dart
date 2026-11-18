import 'dart:io';
import 'dart:math';

import 'package:image/image.dart';

const sourcePath = 'assets/icon/icon.png';
const devIconPath = 'assets/icon/icon-dev.png';
const releaseIconSet = 'macos/Runner/Assets.xcassets/AppIcon.appiconset';
const devIconSet = 'macos/Runner/Assets.xcassets/AppIcon-Dev.appiconset';
const windowsIcon = 'windows/runner/resources/app_icon.ico';
const windowsDevIcon = 'windows/runner/resources/app_icon_dev.ico';
const windowsIconSize = 256;

final _red = ColorRgb8(0xC6, 0x28, 0x28);

/// Taka's icon with its darkest colour turned red and the white kept, so a
/// debug build's Dock and taskbar icon tells it from a release's.
Image devIcon(Image source) {
  final darkest = source
      .map((pixel) => pixel.luminanceNormalized)
      .reduce((least, luminance) => luminance < least ? luminance : least);
  final icon = source.clone();
  for (final pixel in icon) {
    final weight = ((1 - pixel.luminanceNormalized) / (1 - darkest)).clamp(
      0.0,
      1.0,
    );
    pixel.setRgb(
      255 + (_red.r - 255) * weight,
      255 + (_red.g - 255) * weight,
      255 + (_red.b - 255) * weight,
    );
  }
  return icon;
}

Map<int, String> iconSetFiles() => {
  for (final file in Directory(releaseIconSet).listSync().whereType<File>())
    if (RegExp(r'app_icon_(\d+)\.png$').firstMatch(file.path) case final match?)
      int.parse(match.group(1)!): file.uri.pathSegments.last,
};

/// [icon] without the margin macOS icons keep around their artwork, which
/// makes a Windows icon look smaller than its neighbours.
Image withoutMargin(Image icon) {
  // The image reuses one Pixel while iterating, so keep its coordinates.
  final opaque = [
    for (final pixel in icon)
      if (pixel.a > 0) (x: pixel.x, y: pixel.y),
  ];
  final left = opaque.map((point) => point.x).reduce(min);
  final top = opaque.map((point) => point.y).reduce(min);
  final right = opaque.map((point) => point.x).reduce(max);
  final bottom = opaque.map((point) => point.y).reduce(max);
  final side = max(right - left, bottom - top) + 1;
  return copyCrop(
    icon,
    x: (left + right + 1 - side) ~/ 2,
    y: (top + bottom + 1 - side) ~/ 2,
    width: side,
    height: side,
  );
}

List<int> windowsIconFor(Image icon) =>
    encodeIco(iconAt(withoutMargin(icon), windowsIconSize));

/// Resized the way `flutter_launcher_icons` resizes the release set.
Image iconAt(Image icon, int size) => copyResize(
  icon,
  width: size,
  height: size,
  interpolation: icon.width >= size
      ? Interpolation.average
      : Interpolation.linear,
);

void main() {
  final source = decodePng(File(sourcePath).readAsBytesSync())!;
  final icon = devIcon(source);
  File(devIconPath).writeAsBytesSync(encodePng(icon));

  Directory(devIconSet).createSync();
  File('$releaseIconSet/Contents.json').copySync('$devIconSet/Contents.json');
  iconSetFiles().forEach(
    (size, name) =>
        File('$devIconSet/$name')
            .writeAsBytesSync(encodePng(iconAt(icon, size))),
  );
  File(windowsIcon).writeAsBytesSync(windowsIconFor(source));
  File(windowsDevIcon).writeAsBytesSync(windowsIconFor(icon));
  stdout.writeln(
    'Wrote $devIconPath, $devIconSet, $windowsIcon and $windowsDevIcon',
  );
}
