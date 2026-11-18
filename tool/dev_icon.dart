import 'dart:io';
import 'dart:math';

import 'package:image/image.dart';

const sourcePath = 'assets/icon/icon.png';
const devIconPath = 'assets/icon/icon-dev.png';
const releaseIconSet = 'macos/Runner/Assets.xcassets/AppIcon.appiconset';
const devIconSet = 'macos/Runner/Assets.xcassets/AppIcon-Dev.appiconset';
const linuxIconPath = 'assets/icon/icon-linux.png';

final _red = ColorRgb8(0xC6, 0x28, 0x28);

/// Taka's icon with its darkest colour turned red and the white kept, so a
/// debug build's Dock icon tells it from a release's.
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

/// [icon] on a rounded tile with a margin, since Linux shows an icon as it is
/// drawn, where macOS gives it its own shape.
Image linuxIcon(Image icon) {
  final size = icon.width;
  final margin = (size * 0.06).round();
  final side = size - 2 * margin;
  final radius = side * 0.2;
  double inside(double x, double y) {
    final dx = max(max(radius - x, x - (side - radius)), 0.0);
    final dy = max(max(radius - y, y - (side - radius)), 0.0);
    return (radius + 0.5 - sqrt(dx * dx + dy * dy)).clamp(0.0, 1.0);
  }

  final linux = Image(width: size, height: size, numChannels: 4);
  for (final pixel in iconAt(icon, side)) {
    final coverage = inside(pixel.x + 0.5, pixel.y + 0.5);
    if (coverage == 0) continue;
    linux.setPixelRgba(
      pixel.x + margin,
      pixel.y + margin,
      pixel.r,
      pixel.g,
      pixel.b,
      pixel.a * coverage,
    );
  }
  return linux;
}

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
  File(linuxIconPath).writeAsBytesSync(encodePng(linuxIcon(source)));
  final icon = devIcon(source);
  File(devIconPath).writeAsBytesSync(encodePng(icon));

  Directory(devIconSet).createSync();
  File('$releaseIconSet/Contents.json').copySync('$devIconSet/Contents.json');
  iconSetFiles().forEach(
    (size, name) =>
        File('$devIconSet/$name')
            .writeAsBytesSync(encodePng(iconAt(icon, size))),
  );
  stdout.writeln('Wrote $linuxIconPath, $devIconPath and $devIconSet');
}
