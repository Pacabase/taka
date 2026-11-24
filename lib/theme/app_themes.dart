import 'package:flutter/material.dart';
import 'package:taka/theme/app_theme.dart';

class AppThemes {
  // Light: near-neutral greys with a hint of purple. Text is 11:1 on the
  // background; base03 is 3:1 and base08 to base0F 4.5:1 on the surface.
  static const light = Base16Palette(
    base00: Color(0xfff9f6fa),
    base01: Color(0xffeae7eb),
    base02: Color(0xffd8d5d9),
    base03: Color(0xff837f84),
    base04: Color(0xff6f6c70),
    base05: Color(0xff373438),
    base06: Color(0xff232024),
    base07: Color(0xff0c0a0d),
    base08: Color(0xffb13b3f),
    base09: Color(0xff9d4f00),
    base0A: Color(0xff7e6000),
    base0B: Color(0xff01751d),
    base0C: Color(0xff006f79),
    base0D: Color(0xff1664ba),
    base0E: Color(0xff824cbc),
    base0F: Color(0xff8c5743),
  );

  // Dark: greys tinted towards the accent's violet, with the same
  // contrast rules.
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
