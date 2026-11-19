import 'package:flutter/material.dart';

/// Design tokens for the FlutterKaigi 2026 shader deck.
///
/// Dark WWDC-style keynote: near-black canvas, vivid multicolour gradients,
/// San Francisco (system) type with a Japanese fallback.
abstract final class DeckColors {
  static const canvas = Color(0xFF08080C);
  static const surface = Color(0xFF14141B);
  static const surfaceRaised = Color(0xFF1D1D26);

  static const text = Color(0xFFF5F5F7);
  static const textSecondary = Color(0xFF98989D);
  static const textTertiary = Color(0xFF6E6E76);

  /// Apple system accents, WWDC keynote flavour.
  static const pink = Color(0xFFFF375F);
  static const purple = Color(0xFFBF5AF2);
  static const blue = Color(0xFF0A84FF);
  static const cyan = Color(0xFF64D2FF);
  static const orange = Color(0xFFFF9F0A);
  static const green = Color(0xFF30D158);
  static const red = Color(0xFFFF453A);

  /// Language accents: GLSL code is purple, Dart / Flutter code is Flutter blue.
  static const glsl = purple;
  static const dart = Color(0xFF54C5F8);
  static const flutterNavy = Color(0xFF02569B);

  /// GPU pipeline colours — the vertex stage and the fragment stage keep the
  /// same colour on every slide, so the pipeline diagram reads as a recap.
  static const vertex = orange;
  static const fragment = pink;
  static const cpu = textSecondary;
}

abstract final class DeckGradients {
  static const hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [DeckColors.pink, DeckColors.purple, DeckColors.blue],
  );

  static const warm = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [DeckColors.orange, DeckColors.pink],
  );

  static const cool = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [DeckColors.cyan, DeckColors.blue, DeckColors.purple],
  );

  static const flutter = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [DeckColors.dart, DeckColors.blue],
  );

  static const glass = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), DeckColors.cyan, DeckColors.purple],
  );
}

/// Japanese glyphs fall back to Hiragino; Latin stays on San Francisco.
const kFontFallback = <String>[
  'Hiragino Sans',
  'Hiragino Kaku Gothic ProN',
  'Noto Sans JP',
];

const kMonoFamily = 'SF Mono';
const kMonoFallback = <String>['Menlo', 'monospace'];

abstract final class DeckText {
  static const display = TextStyle(
    fontSize: 96,
    fontWeight: FontWeight.w700,
    height: 1.08,
    letterSpacing: -2.5,
    color: DeckColors.text,
    fontFamilyFallback: kFontFallback,
  );

  static const title = TextStyle(
    fontSize: 60,
    fontWeight: FontWeight.w700,
    height: 1.14,
    letterSpacing: -1.4,
    color: DeckColors.text,
    fontFamilyFallback: kFontFallback,
  );

  static const heading = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.8,
    color: DeckColors.text,
    fontFamilyFallback: kFontFallback,
  );

  static const body = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: DeckColors.text,
    fontFamilyFallback: kFontFallback,
  );

  static const bodySecondary = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: DeckColors.textSecondary,
    fontFamilyFallback: kFontFallback,
  );

  static const caption = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: DeckColors.textSecondary,
    fontFamilyFallback: kFontFallback,
  );

  /// All-caps eyebrow label above a slide title.
  static const eyebrow = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 3.2,
    color: DeckColors.textSecondary,
    fontFamilyFallback: kFontFallback,
  );

  static const mono = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: DeckColors.text,
    fontFamily: kMonoFamily,
    fontFamilyFallback: kMonoFallback,
  );

  static const monoSmall = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: DeckColors.text,
    fontFamily: kMonoFamily,
    fontFamilyFallback: kMonoFallback,
  );
}
