import 'dart:math';

import 'package:flutter/material.dart';
import 'package:taka/theme/taka_colors.dart';

// The dashes run on through the 12px gap to the next step's dot.
class const RouteStep({
  super.key,
  required final String label,
  required final bool hasNext,
  required final Widget child,
}) extends StatelessWidget {
  static const indent = 22.0;

  @override
  Widget build(BuildContext context) {
    final color = TakaColors.of(context).textSecondary;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 2,
          top: 30,
          bottom: hasNext ? -41 : null,
          width: 9,
          child: Column(
            spacing: 2,
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hasNext ? null : color,
                  border: Border.all(color: color, width: 1.5),
                ),
              ),
              if (hasNext)
                Expanded(
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: Dashes(color),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: indent),
          child: Labelled(label: label, child: child),
        ),
      ],
    );
  }
}

class const Dashes(final Color color) extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    final x = size.width / 2;
    for (var y = 0.0; y < size.height; y += 6) {
      canvas.drawLine(Offset(x, y), Offset(x, min(y + 3, size.height)), paint);
    }
  }

  @override
  bool shouldRepaint(Dashes old) => old.color != color;
}

class const Labelled({
  super.key,
  required final String label,
  required final Widget child,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 4,
      children: [
        SizedBox(
          height: 16,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: TakaColors.of(context).textSecondary,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
