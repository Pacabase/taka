import 'package:flutter/material.dart';
import 'package:taka/theme/app_theme.dart';

class AppThemes {
  static const List<Base16Palette> all = [light, dark];

  // Light: near-neutral greys with a hint of purple. Text is 10:1 on the
  // background; comments 3:1 and every other colour 4.5:1 on the surface.
  static const light = Base16Palette(
    base00: Color(0xfff9f6fa),
    base01: Color(0xffefecf0),
    base02: Color(0xffe3e0e4),
    base03: Color(0xff868287),
    base04: Color(0xff6f6c70),
    base05: Color(0xff3d393e),
    base06: Color(0xff282529),
    base07: Color(0xff110e12),
    base08: Color(0xffb53e42),
    base09: Color(0xffa15200),
    base0A: Color(0xff816300),
    base0B: Color(0xff097820),
    base0C: Color(0xff00727c),
    base0D: Color(0xff1a67be),
    base0E: Color(0xff864fc0),
    base0F: Color(0xff8f5a46),
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
