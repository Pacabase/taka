import 'package:core/core.dart';
import 'package:flutter/material.dart';

// base16 One Light by Daniel Pfeifer and OneDark by Lalit Magant (tinted-theming), after Atom's One themes.
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
    background: Color(0xfffafafa),
    surface: Color(0xfff0f0f1),
    selection: Color(0xffe5e5e6),
    text: Color(0xff383a42),
    textBrilliant: Color(0xff090a0b),
    red: Color(0xffca1243),
    orange: Color(0xffd75f00),
    yellow: Color(0xffc18401),
    green: Color(0xff50a14f),
    blue: Color(0xff4078f2),
    purple: Color(0xffa626a4),
    accent: Color(0xff4078f2),
    onAccent: Color(0xfffafafa),
  );

  static const dark = TakaColors(
    background: Color(0xff282c34),
    surface: Color(0xff353b45),
    selection: Color(0xff3e4451),
    text: Color(0xffabb2bf),
    textBrilliant: Color(0xffc8ccd4),
    red: Color(0xffe06c75),
    orange: Color(0xffd19a66),
    yellow: Color(0xffe5c07b),
    green: Color(0xff98c379),
    blue: Color(0xff61afef),
    purple: Color(0xffc678dd),
    accent: Color(0xffc678dd),
    onAccent: Color(0xff282c34),
  );

  static TakaColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  Color get textSecondary => text.withValues(alpha: 0.75);

  Color tunnel(TunnelColour colour) => switch (colour) {
    TunnelColour.red => red,
    TunnelColour.orange => orange,
    TunnelColour.yellow => yellow,
    TunnelColour.green => green,
    TunnelColour.blue => blue,
    TunnelColour.purple => purple,
  };
}
