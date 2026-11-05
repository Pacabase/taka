import 'package:flutter/material.dart';
import 'package:taka/theme/taka_colors.dart';
import 'package:taka/widgets/app_icon.dart';

class const TunnelsHeader({
  super.key,
  required final String title,
  required final bool isFormOpen,
  required final void Function() onPressed,
  required final void Function() onSettings,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = TakaColors.of(context);

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: colors.background,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          if (!isFormOpen)
            IconButton(
              tooltip: 'Settings',
              onPressed: onSettings,
              icon: AppIcon(AppIcons.settings, color: colors.textSecondary),
            ),
          IconButton(
            tooltip: isFormOpen ? 'Cancel' : 'Add tunnel',
            onPressed: onPressed,
            icon: AnimatedRotation(
              turns: isFormOpen ? 1 / 8 : 0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: AppIcon(AppIcons.plus, color: colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
