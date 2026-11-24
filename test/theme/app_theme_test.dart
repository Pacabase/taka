@Tags(['unit'])
library;

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taka/theme/app_theme.dart';
import 'package:taka/theme/app_themes.dart';
import 'package:taka/theme/taka_theme.dart';
import 'package:taka/theme/tunnel_colours.dart';

void main() {
  for (final (brightness, palette) in [
    (Brightness.dark, AppThemes.dark),
    (Brightness.light, AppThemes.light),
  ]) {
    group(brightness.name, () {
      test('the header is the darker of base00 and base01', () {
        expect(
          {palette.background, palette.surface},
          {palette.base00, palette.base01},
        );
        expect(
          palette.background.computeLuminance(),
          lessThan(palette.surface.computeLuminance()),
        );
      });

      test('is read as ${brightness.name}', () {
        expect(palette.isDark, brightness == Brightness.dark);
      });

      test('onFill picks the more readable end of the ramp', () {
        for (final fill in [palette.accent, palette.red, palette.selection]) {
          final onFill = palette.onFill(fill);

          expect(onFill, anyOf(palette.base00, palette.base07));
          expect(
            contrast(onFill, fill),
            greaterThanOrEqualTo(
              contrast(
                onFill == palette.base00 ? palette.base07 : palette.base00,
                fill,
              ),
            ),
          );
        }
      });

      test('every tunnel colour is its own', () {
        final colours = TunnelColour.values.map(palette.tunnel).toSet();

        expect(colours, hasLength(TunnelColour.values.length));
        expect(palette.guideOf(null), palette.guide);
        expect(palette.guideOf(TunnelColour.blue), palette.blue);
      });

      test('the app theme carries the palette and puts pages on surface', () {
        final theme = takaTheme(brightness);

        expect(theme.extension<Base16Palette>(), palette);
        expect(theme.scaffoldBackgroundColor, palette.surface);
        expect(theme.colorScheme.brightness, brightness);
      });
    });
  }
}
