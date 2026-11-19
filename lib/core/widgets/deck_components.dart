import 'package:flutter/material.dart';
import 'package:flutter_intro_talk/core/theme/kaigi_theme.dart';

/// A frosted card used for role/step/concept boxes.
class DeckCard extends StatelessWidget {
  const DeckCard({
    required this.child,
    super.key,
    this.accent,
    this.padding = const EdgeInsets.all(30),
    this.dimmed = false,
  });

  final Widget child;
  final Color? accent;
  final EdgeInsetsGeometry padding;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final a = accent ?? DeckColors.textSecondary;
    return AnimatedOpacity(
      opacity: dimmed ? 0.32 : 1,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: a.withValues(alpha: 0.35), width: 1.5),
        ),
        child: child,
      ),
    );
  }
}

/// Card with a coloured title and body copy — the deck's workhorse.
class TitledCard extends StatelessWidget {
  const TitledCard({
    required this.title,
    required this.lines,
    super.key,
    this.accent = DeckColors.cyan,
    this.badge,
  });

  final String title;
  final List<String> lines;
  final Color accent;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return DeckCard(
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null) ...[
            Pill(badge!, color: accent),
            const SizedBox(height: 16),
          ],
          Text(
            title,
            style: DeckText.heading.copyWith(fontSize: 32, color: accent),
          ),
          const SizedBox(height: 16),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                line,
                style: DeckText.bodySecondary.copyWith(fontSize: 22),
              ),
            ),
        ],
      ),
    );
  }
}

/// Small rounded label — status badges, HTTP methods, tags.
class Pill extends StatelessWidget {
  const Pill(
    this.text, {
    super.key,
    this.color = DeckColors.cyan,
    this.filled = true,
    this.fontSize = 20,
    this.mono = false,
  });

  final String text;
  final Color color;
  final bool filled;
  final double fontSize;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: fontSize * 0.8,
        vertical: fontSize * 0.34,
      ),
      decoration: BoxDecoration(
        color: filled ? color.withValues(alpha: 0.18) : Colors.transparent,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.7), width: 1.5),
      ),
      child: Text(
        text,
        style: (mono ? DeckText.mono : DeckText.body).copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: color,
          height: 1,
        ),
      ),
    );
  }
}

/// A horizontal row of boxes joined by arrows — the deck's flow diagram.
class FlowRow extends StatelessWidget {
  const FlowRow({required this.steps, super.key, this.currentStep});

  final List<FlowStep> steps;

  /// When set, boxes beyond this 1-based index are dimmed.
  final int? currentStep;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < steps.length; i++) {
      final s = steps[i];
      final visible = currentStep == null || i < currentStep!;
      children.add(
        Expanded(
          child: DeckCard(
            accent: s.accent,
            dimmed: !visible,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (s.index != null) ...[
                  _StepNumber(s.index!, s.accent),
                  const SizedBox(height: 14),
                ],
                Text(
                  s.title,
                  textAlign: TextAlign.center,
                  style: DeckText.heading.copyWith(
                    fontSize: 26,
                    color: s.accent,
                  ),
                ),
                if (s.subtitle != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    s.subtitle!,
                    textAlign: TextAlign.center,
                    style: DeckText.caption.copyWith(fontSize: 19),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
      if (i != steps.length - 1) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Icon(
              Icons.arrow_forward_rounded,
              color: DeckColors.textTertiary,
              size: 34,
            ),
          ),
        );
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}

class FlowStep {
  const FlowStep({
    required this.title,
    this.subtitle,
    this.index,
    this.accent = DeckColors.cyan,
  });

  final String title;
  final String? subtitle;
  final int? index;
  final Color accent;
}

class _StepNumber extends StatelessWidget {
  const _StepNumber(this.number, this.color);

  final int number;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Text(
        '$number',
        style: DeckText.body.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: color,
          height: 1,
        ),
      ),
    );
  }
}

/// Bulleted list with a coloured dot per line.
class BulletList extends StatelessWidget {
  const BulletList({
    required this.items,
    super.key,
    this.accent = DeckColors.cyan,
    this.fontSize = 30,
    this.visibleCount,
  });

  final List<String> items;
  final Color accent;
  final double fontSize;

  /// When set, only the first N bullets are shown (step reveal).
  final int? visibleCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++)
          AnimatedOpacity(
            opacity: visibleCount == null || i < visibleCount! ? 1 : 0,
            duration: const Duration(milliseconds: 350),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: fontSize * 0.42),
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 22),
                  Expanded(
                    child: Text(
                      items[i],
                      style: DeckText.body.copyWith(fontSize: fontSize),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Problem / Solution callout box (red for problems, green for solutions).
class CalloutBox extends StatelessWidget {
  const CalloutBox({
    required this.label,
    required this.lines,
    super.key,
    this.isProblem = true,
  });

  final String label;
  final List<String> lines;
  final bool isProblem;

  @override
  Widget build(BuildContext context) {
    final color = isProblem ? DeckColors.red : DeckColors.green;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(34),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Pill(label, color: color, fontSize: 18),
          const SizedBox(height: 20),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                line,
                style: DeckText.body.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A documentation or Xcode screenshot, framed to sit inside the dark deck.
/// Both sources are already dark, so the frame is a thin accent border rather
/// than a light card.
class DocShot extends StatelessWidget {
  const DocShot({
    required this.image,
    required this.caption,
    required this.aspectRatio,
    required this.width,
    super.key,
    this.accent = DeckColors.orange,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.radius = 14,
  });

  final ImageProvider image;
  final String caption;

  /// Frame ratio. Pass the source image's own ratio with the default
  /// [BoxFit.contain] to show all of it; pass a narrower one with
  /// [BoxFit.cover] to crop dead space and win back legible text.
  final double aspectRatio;
  final double width;
  final Color accent;
  final BoxFit fit;
  final Alignment alignment;

  /// Bigger for a phone screenshot, so it reads as a device.
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: width,
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  color: accent.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              child: Image(image: image, fit: fit, alignment: alignment),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          caption,
          style: DeckText.caption.copyWith(
            fontSize: 17,
            color: DeckColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

/// Two-column layout: explanation on the left, code/diagram on the right.
class SplitContent extends StatelessWidget {
  const SplitContent({
    required this.left,
    required this.right,
    super.key,
    this.leftFlex = 4,
    this.rightFlex = 6,
  });

  final Widget left;
  final Widget right;
  final int leftFlex;
  final int rightFlex;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: leftFlex, child: left),
        const SizedBox(width: 52),
        Expanded(flex: rightFlex, child: right),
      ],
    );
  }
}
