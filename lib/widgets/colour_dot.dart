import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:taka/theme/taka_colors.dart';

extension TunnelColourLabel on TunnelColour {
  String get label => '${name[0].toUpperCase()}${name.substring(1)}';
}

/// A dot of [colour], or an empty ring with none.
class const ColourDot(
  final TunnelColour? colour, {
  super.key,
  final double size = 8,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = TakaColors.of(context);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: switch (colour) {
          final colour? => colors.tunnel(colour),
          null => null,
        },
        border: colour == null ? Border.all(color: colors.textSecondary) : null,
      ),
    );
  }
}
