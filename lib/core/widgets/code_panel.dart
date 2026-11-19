import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_intro_talk/core/theme/kaigi_theme.dart';

/// Xcode "Default (Dark)" flavoured highlight theme.
const Map<String, TextStyle> xcodeDarkTheme = {
  // HighlightView paints theme['root'] behind the code and defaults to white
  // when it has no backgroundColor — keep it transparent so the panel shows.
  'root': TextStyle(
    color: Color(0xFFDFDFE0),
    backgroundColor: Color(0x00000000),
  ),
  'keyword': TextStyle(color: Color(0xFFFC5FA3), fontWeight: FontWeight.w600),
  'built_in': TextStyle(color: Color(0xFFD0A8FF)),
  'type': TextStyle(color: Color(0xFF5DD8FF)),
  'class': TextStyle(color: Color(0xFF5DD8FF)),
  'title': TextStyle(color: Color(0xFF67B7A4)),
  'function': TextStyle(color: Color(0xFF67B7A4)),
  'params': TextStyle(color: Color(0xFFDFDFE0)),
  'string': TextStyle(color: Color(0xFFFC6A5D)),
  'number': TextStyle(color: Color(0xFFD0BF69)),
  'literal': TextStyle(color: Color(0xFFD0BF69)),
  'comment': TextStyle(color: Color(0xFF6C7986), fontStyle: FontStyle.italic),
  'meta': TextStyle(color: Color(0xFFFFA14F)),
  'meta-keyword': TextStyle(color: Color(0xFFFFA14F)),
  'attribute': TextStyle(color: Color(0xFFFFA14F)),
  'variable': TextStyle(color: Color(0xFFDFDFE0)),
  'property': TextStyle(color: Color(0xFF9EF1DD)),
  'symbol': TextStyle(color: Color(0xFFD0BF69)),
  'operator': TextStyle(color: Color(0xFFDFDFE0)),
  'punctuation': TextStyle(color: Color(0xFFDFDFE0)),
};

/// A code panel styled like an editor window. GLSL and Dart are both
/// highlighted with the same Xcode-dark theme.
class CodePanel extends StatelessWidget {
  const CodePanel(
    this.code, {
    super.key,
    this.language = 'glsl',
    this.fileName,
    this.fontSize = 20,
    this.accent = DeckColors.glsl,
  });

  final String code;
  final String language;
  final String? fileName;
  final double fontSize;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF10101A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.28), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 40,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (fileName != null) _TitleBar(fileName!, accent),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 26),
              child: HighlightView(
                code.trim(),
                language: language,
                theme: xcodeDarkTheme,
                padding: EdgeInsets.zero,
                textStyle: TextStyle(
                  fontFamily: kMonoFamily,
                  fontFamilyFallback: kMonoFallback,
                  fontSize: fontSize,
                  height: 1.55,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TitleBar extends StatelessWidget {
  const _TitleBar(this.fileName, this.accent);

  final String fileName;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        border: Border(
          bottom: BorderSide(color: accent.withValues(alpha: 0.22)),
        ),
      ),
      child: Row(
        children: [
          for (final c in const [
            Color(0xFFFF5F57),
            Color(0xFFFEBC2E),
            Color(0xFF28C840),
          ])
            Padding(
              padding: const EdgeInsets.only(right: 9),
              child: Container(
                width: 13,
                height: 13,
                decoration: BoxDecoration(color: c, shape: BoxShape.circle),
              ),
            ),
          const SizedBox(width: 14),
          Text(
            fileName,
            style: DeckText.monoSmall.copyWith(
              fontSize: 17,
              color: DeckColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
