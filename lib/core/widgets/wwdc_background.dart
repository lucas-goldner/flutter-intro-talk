import 'package:flutter/material.dart';
import 'package:flutter_intro_talk/core/theme/kaigi_theme.dart';
import 'package:mesh/mesh.dart';

/// Which corner of the canvas the vivid colour pools in.
enum GradientMood { hero, cool, warm, violet, calm }

/// The deck's signature background: a near-black canvas with a slowly
/// drifting WWDC-style mesh gradient bleeding in from one side.
class WwdcBackground extends StatefulWidget {
  const WwdcBackground({
    super.key,
    this.mood = GradientMood.cool,
    this.intensity = 1,
  });

  final GradientMood mood;

  /// 0 = plain black, 1 = full colour. Content-heavy slides use ~0.5.
  final double intensity;

  @override
  State<WwdcBackground> createState() => _WwdcBackgroundState();
}

class _WwdcBackgroundState extends State<WwdcBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Color> get _palette => switch (widget.mood) {
        GradientMood.hero => const [
            DeckColors.pink,
            DeckColors.purple,
            DeckColors.blue,
          ],
        GradientMood.cool => const [
            DeckColors.blue,
            DeckColors.cyan,
            DeckColors.purple,
          ],
        GradientMood.warm => const [
            DeckColors.orange,
            DeckColors.pink,
            DeckColors.orange,
          ],
        GradientMood.violet => const [
            DeckColors.purple,
            DeckColors.pink,
            DeckColors.blue,
          ],
        GradientMood.calm => const [
            DeckColors.blue,
            DeckColors.purple,
            DeckColors.cyan,
          ],
      };

  @override
  Widget build(BuildContext context) {
    final palette = _palette;
    final k = widget.intensity.clamp(0.0, 1.0);

    // Colour is mixed toward the canvas so even at full intensity the deck
    // stays a dark keynote rather than a poster.
    Color pool(Color c, double amount) =>
        Color.lerp(DeckColors.canvas, c, amount * k)!;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_controller.value);
        final drift = (t - 0.5) * 0.12;

        return OMeshGradient(
          tessellation: 12,
          mesh: OMeshRect(
            width: 3,
            height: 3,
            colorSpace: OMeshColorSpace.lab,
            vertices: [
              // Row 1
              (-0.1, -0.1).v,
              (0.5 + drift, -0.08).v,
              (1.1, -0.1).v,
              // Row 2 — the drifting middle band carries the colour
              (-0.08, 0.42 + drift).v,
              (0.46 - drift, 0.55).v,
              (1.08, 0.38 - drift).v,
              // Row 3
              (-0.1, 1.1).v,
              (0.5 - drift, 1.08).v,
              (1.1, 1.1).v,
            ],
            colors: [
              // Row 1 — colour enters from the top corners
              pool(palette[0], 0.55),
              pool(palette[1], 0.28),
              pool(palette[2], 0.62),
              // Row 2
              pool(palette[1], 0.30),
              DeckColors.canvas,
              pool(palette[2], 0.34),
              // Row 3 — fades to near-black at the bottom
              pool(palette[2], 0.20),
              DeckColors.canvas,
              pool(palette[0], 0.16),
            ],
          ),
        );
      },
    );
  }
}
