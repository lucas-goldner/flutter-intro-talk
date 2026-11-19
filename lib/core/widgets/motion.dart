import 'package:flutter/material.dart';

/// Fade + rise, driven by a step reveal. `delayMs` staggers a row of them.
class StaggerIn extends StatelessWidget {
  const StaggerIn({
    required this.visible,
    required this.child,
    super.key,
    this.delayMs = 0,
    this.offset = 26,
  });

  final bool visible;
  final Widget child;
  final int delayMs;
  final double offset;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: visible ? 1 : 0),
      duration: Duration(milliseconds: 460 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * offset),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
