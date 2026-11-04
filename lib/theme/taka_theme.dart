import 'package:flutter/material.dart';
import 'package:taka/theme/taka_colors.dart';

const monoFont = 'JetBrainsMono';

ThemeData takaTheme(Brightness brightness) {
  final colors = brightness == Brightness.dark
      ? TakaColors.dark
      : TakaColors.light;
  final body = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w300,
    color: colors.text,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
  const square = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(2)),
  );

  return ThemeData(
    visualDensity: VisualDensity.standard,
    fontFamily: 'Inter',
    colorScheme: ColorScheme.fromSeed(
      seedColor: colors.accent,
      brightness: brightness,
      primary: colors.accent,
      onPrimary: colors.onAccent,
      surface: colors.surface,
      onSurface: colors.text,
    ),
    scaffoldBackgroundColor: colors.surface,
    textTheme: TextTheme(bodyMedium: body, bodyLarge: body),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colors.accent,
        foregroundColor: colors.onAccent,
        disabledBackgroundColor: colors.accent.withValues(alpha: 0.6),
        disabledForegroundColor: colors.onAccent.withValues(alpha: 0.8),
        minimumSize: const Size(0, 28),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: square,
        textStyle: body.copyWith(fontWeight: FontWeight.w500),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.text,
        minimumSize: const Size(0, 28),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: square,
        textStyle: body,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: colors.textSecondary,
        minimumSize: const Size.square(24),
        maximumSize: const Size.square(24),
        padding: EdgeInsets.zero,
        shape: square,
      ),
    ),
    tooltipTheme: const TooltipThemeData(
      waitDuration: Duration(milliseconds: 600),
    ),
  );
}
