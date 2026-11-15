import 'dart:math' as math;

import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// A base16 scheme. Every other colour is a rule over these 16, so any scheme
/// pastes in unchanged.
class const Base16Palette({
  required final Color base00,
  required final Color base01,
  required final Color base02,
  required final Color base03,
  required final Color base04,
  required final Color base05,
  required final Color base06,
  required final Color base07,
  required final Color base08,
  required final Color base09,
  required final Color base0A,
  required final Color base0B,
  required final Color base0C,
  required final Color base0D,
  required final Color base0E,
  required final Color base0F,
}) extends ThemeExtension<Base16Palette> {
  @override
  Base16Palette copyWith({
    Color? base00,
    Color? base01,
    Color? base02,
    Color? base03,
    Color? base04,
    Color? base05,
    Color? base06,
    Color? base07,
    Color? base08,
    Color? base09,
    Color? base0A,
    Color? base0B,
    Color? base0C,
    Color? base0D,
    Color? base0E,
    Color? base0F,
  }) => Base16Palette(
    base00: base00 ?? this.base00,
    base01: base01 ?? this.base01,
    base02: base02 ?? this.base02,
    base03: base03 ?? this.base03,
    base04: base04 ?? this.base04,
    base05: base05 ?? this.base05,
    base06: base06 ?? this.base06,
    base07: base07 ?? this.base07,
    base08: base08 ?? this.base08,
    base09: base09 ?? this.base09,
    base0A: base0A ?? this.base0A,
    base0B: base0B ?? this.base0B,
    base0C: base0C ?? this.base0C,
    base0D: base0D ?? this.base0D,
    base0E: base0E ?? this.base0E,
    base0F: base0F ?? this.base0F,
  );

  @override
  Base16Palette lerp(Base16Palette? other, double t) {
    if (other == null) return this;

    return Base16Palette(
      base00: Color.lerp(base00, other.base00, t)!,
      base01: Color.lerp(base01, other.base01, t)!,
      base02: Color.lerp(base02, other.base02, t)!,
      base03: Color.lerp(base03, other.base03, t)!,
      base04: Color.lerp(base04, other.base04, t)!,
      base05: Color.lerp(base05, other.base05, t)!,
      base06: Color.lerp(base06, other.base06, t)!,
      base07: Color.lerp(base07, other.base07, t)!,
      base08: Color.lerp(base08, other.base08, t)!,
      base09: Color.lerp(base09, other.base09, t)!,
      base0A: Color.lerp(base0A, other.base0A, t)!,
      base0B: Color.lerp(base0B, other.base0B, t)!,
      base0C: Color.lerp(base0C, other.base0C, t)!,
      base0D: Color.lerp(base0D, other.base0D, t)!,
      base0E: Color.lerp(base0E, other.base0E, t)!,
      base0F: Color.lerp(base0F, other.base0F, t)!,
    );
  }

  Color get background => base00;
  Color get surface => base01;
  Color get selection => base02;
  Color get subtle => base03;
  Color get muted => base04;
  Color get text => base05;
  Color get textStrong => base06;
  Color get textBrilliant => base07;

  Color get red => base08;
  Color get orange => base09;
  Color get yellow => base0A;
  Color get green => base0B;
  Color get cyan => base0C;
  Color get blue => base0D;
  Color get accent => base0E;
  Color get purple => base0E;
  Color get brown => base0F;

  bool get isDark =>
      background.computeLuminance() < textBrilliant.computeLuminance();

  Color get textSecondary => text.withValues(alpha: 0.75);

  Color onFill(Color fill) {
    double contrast(Color color) {
      final lighter = math.max(
        color.computeLuminance(),
        fill.computeLuminance(),
      );
      final darker = math.min(
        color.computeLuminance(),
        fill.computeLuminance(),
      );
      return (lighter + 0.05) / (darker + 0.05);
    }

    return contrast(background) >= contrast(textBrilliant)
        ? background
        : textBrilliant;
  }
}

extension TunnelColours on Base16Palette {
  /// The line down the side of a group's tunnels.
  Color get guide => text.withValues(alpha: 0.25);

  Color guideOf(TunnelColour? colour) =>
      colour == null ? guide : tunnel(colour);

  Color tunnel(TunnelColour colour) => switch (colour) {
    TunnelColour.red => red,
    TunnelColour.orange => orange,
    TunnelColour.yellow => yellow,
    TunnelColour.green => green,
    TunnelColour.blue => blue,
    TunnelColour.purple => purple,
  };
}

extension AppThemeContext on BuildContext {
  Base16Palette get theme => Theme.of(this).extension<Base16Palette>()!;
}
