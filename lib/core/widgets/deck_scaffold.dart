import 'package:flutter/material.dart';
import 'package:flutter_intro_talk/core/theme/kaigi_theme.dart';
import 'package:flutter_intro_talk/core/widgets/pixel_field.dart';
import 'package:flutter_intro_talk/core/widgets/wwdc_background.dart';

/// Standard content slide: gradient canvas, eyebrow label, big title, body.
class DeckSlide extends StatelessWidget {
  const DeckSlide({
    required this.title,
    required this.child,
    super.key,
    this.eyebrow,
    this.footnote,
    this.mood = GradientMood.cool,
    this.intensity = 0.55,
    this.titleGradient,
  });

  final String title;
  final String? eyebrow;
  final String? footnote;
  final Widget child;
  final GradientMood mood;
  final double intensity;
  final Gradient? titleGradient;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        WwdcBackground(mood: mood, intensity: intensity),
        Padding(
          padding: const EdgeInsets.fromLTRB(88, 64, 88, 56),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow != null) ...[
                Text(eyebrow!.toUpperCase(), style: DeckText.eyebrow),
                const SizedBox(height: 14),
              ],
              GradientText(
                title,
                style: DeckText.title,
                gradient: titleGradient,
              ),
              const SizedBox(height: 40),
              Expanded(child: child),
              if (footnote != null) ...[
                const SizedBox(height: 28),
                Footnote(footnote!),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Full-bleed statement slide — one sentence, nothing else.
class StatementSlide extends StatelessWidget {
  const StatementSlide({
    required this.statement,
    super.key,
    this.subtitle,
    this.eyebrow,
    this.mood = GradientMood.hero,
    this.intensity = 0.9,
    this.gradient,
  });

  final String statement;
  final String? subtitle;
  final String? eyebrow;
  final GradientMood mood;
  final double intensity;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        WwdcBackground(mood: mood, intensity: intensity),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 110, vertical: 80),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow != null) ...[
                Text(eyebrow!.toUpperCase(), style: DeckText.eyebrow),
                const SizedBox(height: 22),
              ],
              GradientText(
                statement,
                style: DeckText.display,
                gradient: gradient,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 34),
                Text(subtitle!, style: DeckText.bodySecondary),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Part divider — oversized numeral, part title, one-line framing, and a
/// shimmering pixel field: every dot is "one fragment".
class PartDivider extends StatelessWidget {
  const PartDivider({
    required this.number,
    required this.label,
    required this.title,
    super.key,
    this.subtitle,
    this.mood = GradientMood.violet,
    this.accent = DeckColors.cyan,
  });

  final String number;
  final String label;
  final String title;
  final String? subtitle;
  final GradientMood mood;

  /// Drives the pixel field colour.
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        WwdcBackground(mood: mood, intensity: 1),
        Positioned(
          right: 60,
          top: 60,
          bottom: 60,
          width: 760,
          child: PixelField(color: accent),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 110, vertical: 80),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GradientText(
                number,
                style: const TextStyle(
                  fontSize: 200,
                  fontWeight: FontWeight.w800,
                  height: 0.9,
                  letterSpacing: -10,
                  color: DeckColors.text,
                ),
                gradient: DeckGradients.hero,
              ),
              const SizedBox(height: 18),
              Text(label.toUpperCase(), style: DeckText.eyebrow),
              const SizedBox(height: 26),
              Text(title, style: DeckText.title),
              if (subtitle != null) ...[
                const SizedBox(height: 22),
                Text(subtitle!, style: DeckText.bodySecondary),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Text painted with a gradient shader. Falls back to solid when null.
class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    required this.style,
    super.key,
    this.gradient,
    this.textAlign,
  });

  final String text;
  final TextStyle style;
  final Gradient? gradient;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final label = Text(text, style: style, textAlign: textAlign);
    if (gradient == null) return label;

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient!.createShader(bounds),
      child: label,
    );
  }
}

/// Accented takeaway line pinned to the bottom of a slide.
class Footnote extends StatelessWidget {
  const Footnote(this.text, {super.key, this.color = DeckColors.cyan});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // IntrinsicHeight gives the accent bar a height to stretch to — inside a
    // Column the Row's height is unbounded, and stretch alone cannot size it.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 4,
            constraints: const BoxConstraints(minHeight: 34),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              text,
              style: DeckText.caption.copyWith(
                color: DeckColors.text,
                fontSize: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
