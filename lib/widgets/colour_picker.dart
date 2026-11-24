import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:taka/theme/app_theme.dart';
import 'package:taka/widgets/colour_dot.dart';

class const ColourPicker({
  super.key,
  required final TunnelColour? selected,
  required final void Function(TunnelColour? colour) onPick,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        for (final colour in [...TunnelColour.values, null])
          _Swatch(
            colour: colour,
            label: colour?.label ?? 'No colour',
            isSelected: selected == colour,
            onTap: () => onPick(colour),
          ),
      ],
    );
  }
}

class const _Swatch({
  required final TunnelColour? colour,
  required final String label,
  required final bool isSelected,
  required final void Function() onTap,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.theme;

    // The tooltip names it to screen readers too.
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        selected: isSelected,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            foregroundDecoration: isSelected
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.textBrilliant, width: 2),
                  )
                : null,
            child: ColourDot(colour, size: 20),
          ),
        ),
      ),
    );
  }
}
