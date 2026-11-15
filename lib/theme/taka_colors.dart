import 'package:core/core.dart';
import 'package:flutter/material.dart';

// Taka's own light and dark schemes: greys with a faint purple tint, and every
// colour readable as text on the background.
class const TakaColors({
  required final Color background,
  required final Color surface,
  required final Color selection,
  required final Color text,
  required final Color textBrilliant,
  required final Color red,
  required final Color orange,
  required final Color yellow,
  required final Color green,
  required final Color blue,
  required final Color purple,
  required final Color accent,
  required final Color onAccent,
}) {
  static const light = TakaColors(
    background: Color(0xfff9f6fa),
    surface: Color(0xffefecf0),
    selection: Color(0xffe3e0e4),
    text: Color(0xff3d393e),
    textBrilliant: Color(0xff110e12),
    red: Color(0xffb53e42),
    orange: Color(0xffa15200),
    yellow: Color(0xff816300),
    green: Color(0xff097820),
    blue: Color(0xff1a67be),
    purple: Color(0xff864fc0),
    accent: Color(0xff864fc0),
    onAccent: Color(0xfff9f6fa),
  );

  static const dark = TakaColors(
    background: Color(0xff1f1b25),
    surface: Color(0xff2a2630),
    selection: Color(0xff38343e),
    text: Color(0xffc9c6cd),
    textBrilliant: Color(0xfff2f1f4),
    red: Color(0xffed807e),
    orange: Color(0xffe28a48),
    yellow: Color(0xffe8bf51),
    green: Color(0xff60b164),
    blue: Color(0xff62a2f1),
    purple: Color(0xffb27fed),
    accent: Color(0xffb27fed),
    onAccent: Color(0xff1f1b25),
  );

  static TakaColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  Color get textSecondary => text.withValues(alpha: 0.75);

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
