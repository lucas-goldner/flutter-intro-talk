import 'package:flutter/material.dart';
import 'package:flutter_intro_talk/core/theme/kaigi_theme.dart';

enum PhoneStyle { ios, android }

/// A device mockup that hosts a live Flutter UI. Every in-slide "app" is
/// real Flutter rendered inside this frame — tap it and it reacts.
class PhoneFrame extends StatelessWidget {
  const PhoneFrame({
    required this.child,
    super.key,
    this.width = 380,
    this.style = PhoneStyle.ios,
    this.accent = DeckColors.dart,
    this.label,
    this.screenColor = Colors.white,
  });

  final Widget child;
  final double width;
  final PhoneStyle style;
  final Color accent;
  final String? label;
  final Color screenColor;

  static const aspect = 9 / 19.5;

  @override
  Widget build(BuildContext context) {
    final radius = width * 0.13;
    final bezel = width * 0.035;
    final phone = SizedBox(
      width: width,
      height: width / aspect,
      child: Container(
        padding: EdgeInsets.all(bezel),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A20),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: accent.withValues(alpha: 0.45), width: 2),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.22),
              blurRadius: 60,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius - bezel),
          child: ColoredBox(
            color: screenColor,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: width * 0.09),
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: child,
                  ),
                ),
                // Status bar + island / punch-hole.
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: width * 0.09,
                  child: IgnorePointer(
                    child: _StatusBar(style: style, width: width),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (label == null) return phone;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        phone,
        const SizedBox(height: 14),
        Text(label!, style: DeckText.caption.copyWith(color: accent)),
      ],
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.style, required this.width});

  final PhoneStyle style;
  final double width;

  @override
  Widget build(BuildContext context) {
    final s = width / 380;
    final text = TextStyle(
      fontSize: 13 * s,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    );
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 26 * s),
      child: Row(
        children: [
          Text('9:41', style: text),
          const Spacer(),
          if (style == PhoneStyle.ios)
            Container(
              width: 96 * s,
              height: 26 * s,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20 * s),
              ),
            )
          else
            Container(
              width: 12 * s,
              height: 12 * s,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
          const Spacer(),
          Icon(Icons.signal_cellular_alt, size: 15 * s, color: Colors.black87),
          SizedBox(width: 4 * s),
          Icon(Icons.battery_full, size: 15 * s, color: Colors.black87),
        ],
      ),
    );
  }
}
