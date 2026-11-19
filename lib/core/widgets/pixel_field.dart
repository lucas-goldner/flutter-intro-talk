import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A grid of dots with a diagonal wave sweeping through it — every dot is
/// one "fragment" lighting up. Ambient motion for the part dividers.
class PixelField extends StatefulWidget {
  const PixelField({super.key, required this.color, this.cell = 26});

  final Color color;
  final double cell;

  @override
  State<PixelField> createState() => _PixelFieldState();
}

class _PixelFieldState extends State<PixelField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 7),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _PixelFieldPainter(
          animation: _controller,
          color: widget.color,
          cell: widget.cell,
        ),
      ),
    );
  }
}

class _PixelFieldPainter extends CustomPainter {
  _PixelFieldPainter({
    required this.animation,
    required this.color,
    required this.cell,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color color;
  final double cell;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value * 2 * math.pi;
    final cols = (size.width / cell).floor();
    final rows = (size.height / cell).floor();
    final paint = Paint();

    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < cols; x++) {
        final u = x / cols;
        final v = y / rows;
        // Radial falloff so the field fades into the canvas on the left.
        final fade = math.pow(u, 1.4) * (1 - (v - 0.5).abs() * 1.2);
        final wave = 0.5 + 0.5 * math.sin(t - (u * 7 + v * 4));
        final glint = math.pow(wave, 8).toDouble();
        final a = (0.06 + 0.55 * glint) * fade;
        if (a <= 0.01) continue;
        paint.color = Color.lerp(
          color,
          Colors.white,
          glint * 0.5,
        )!.withValues(alpha: a.clamp(0.0, 1.0));
        final s = cell * (0.16 + 0.22 * glint);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset((x + 0.5) * cell, (y + 0.5) * cell),
              width: s,
              height: s,
            ),
            Radius.circular(s * 0.25),
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_PixelFieldPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.cell != cell;
}
