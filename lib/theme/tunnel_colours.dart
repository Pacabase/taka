import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:taka/theme/app_theme.dart';

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
