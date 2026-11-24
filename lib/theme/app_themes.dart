import 'package:flutter/material.dart';
import 'package:taka/theme/app_theme.dart';

class AppThemes {
  // Colours 3:1 and yellow 2.5:1, so they stay bright enough to read as colours.
  static const light = Base16Palette(
    base00: Color(0xfff9f6fa),
    base01: Color(0xffefecf0),
    base02: Color(0xffe3e0e4),
    base03: Color(0xff868287),
    base04: Color(0xff6f6c70),
    base05: Color(0xff3a373b),
    base06: Color(0xff262327),
    base07: Color(0xff0f0c10),
    base08: Color(0xffe7585c),
    base09: Color(0xffd36d00),
    base0A: Color(0xffbd9a00),
    base0B: Color(0xff239d36),
    base0C: Color(0xff0097a4),
    base0D: Color(0xff3089f1),
    base0E: Color(0xff864fc0),
    base0F: Color(0xffb97961),
  );

  static const dark = Base16Palette(
    base00: Color(0xff1f1b25),
    base01: Color(0xff2a2630),
    base02: Color(0xff38343e),
    base03: Color(0xff77747d),
    base04: Color(0xff87848d),
    base05: Color(0xffc9c6cd),
    base06: Color(0xffdcdadf),
    base07: Color(0xfff2f1f4),
    base08: Color(0xffed807e),
    base09: Color(0xffe28a48),
    base0A: Color(0xffe8bf51),
    base0B: Color(0xff60b164),
    base0C: Color(0xff00b0be),
    base0D: Color(0xff62a2f1),
    base0E: Color(0xffb27fed),
    base0F: Color(0xffb68471),
  );
}
