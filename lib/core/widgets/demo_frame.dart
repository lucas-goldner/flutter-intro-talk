import 'package:flutter/material.dart';
import 'package:flutter_intro_talk/core/theme/kaigi_theme.dart';
import 'package:flutter_intro_talk/core/widgets/code_panel.dart';
import 'package:flutter_intro_talk/core/widgets/deck_components.dart';

/// A framed, clipped viewport for a live demo with a pulsing LIVE badge.
class DemoFrame extends StatelessWidget {
  const DemoFrame({
    required this.child,
    super.key,
    this.caption,
    this.accent = DeckColors.pink,
    this.radius = 26,
    this.hint,
  });

  final Widget child;
  final String? caption;
  final Color accent;
  final double radius;

  /// Small interaction hint shown bottom-left inside the frame:
  /// 「ドラッグしてみて」 etc.
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: accent.withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.18),
                  blurRadius: 60,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                child,
                Positioned(top: 18, right: 18, child: _LiveBadge(accent)),
                if (hint != null)
                  Positioned(
                    left: 18,
                    bottom: 16,
                    child: IgnorePointer(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          hint!,
                          style: DeckText.caption.copyWith(
                            fontSize: 17,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (caption != null) ...[
          const SizedBox(height: 12),
          Text(
            caption!,
            style: DeckText.caption.copyWith(
              fontSize: 18,
              color: DeckColors.textTertiary,
            ),
          ),
        ],
      ],
    );
  }
}

class _LiveBadge extends StatefulWidget {
  const _LiveBadge(this.color);

  final Color color;

  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: widget.color.withValues(alpha: 0.6)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeTransition(
              opacity: Tween(begin: 0.35, end: 1.0).animate(_controller),
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'LIVE',
              style: DeckText.mono.copyWith(
                fontSize: 14,
                letterSpacing: 2.4,
                height: 1,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One code panel in a [CodeDemoLayout].
class CodeSnippet {
  const CodeSnippet(
    this.code, {
    required this.fileName,
    this.language = 'glsl',
    this.fontSize = 19,
    this.flex = 1,
  });

  final String code;
  final String fileName;
  final String language;
  final double fontSize;
  final int flex;

  Color get accent => language == 'dart' ? DeckColors.dart : DeckColors.glsl;
}

/// The deck's "code on the side, real demo next to it" layout: GLSL and
/// Dart stacked on the left, the live result on the right.
class CodeDemoLayout extends StatelessWidget {
  const CodeDemoLayout({
    required this.snippets,
    required this.demo,
    super.key,
    this.codeFlex = 11,
    this.demoFlex = 9,
  });

  final List<CodeSnippet> snippets;
  final Widget demo;
  final int codeFlex;
  final int demoFlex;

  @override
  Widget build(BuildContext context) {
    return SplitContent(
      leftFlex: codeFlex,
      rightFlex: demoFlex,
      left: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < snippets.length; i++) ...[
            if (i > 0) const SizedBox(height: 18),
            Flexible(
              flex: snippets[i].flex,
              child: CodePanel(
                snippets[i].code,
                language: snippets[i].language,
                fileName: snippets[i].fileName,
                fontSize: snippets[i].fontSize,
                accent: snippets[i].accent,
              ),
            ),
          ],
        ],
      ),
      right: demo,
    );
  }
}
