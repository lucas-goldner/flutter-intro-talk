import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_deck/flutter_deck.dart';
import 'package:flutter_intro_talk/core/shaders/shader_assets.dart';
import 'package:flutter_intro_talk/core/shaders/shader_view.dart';
import 'package:flutter_intro_talk/core/theme/kaigi_theme.dart';
import 'package:flutter_intro_talk/slides/outro_slide.dart';
import 'package:flutter_intro_talk/slides/s01_problem.dart';
import 'package:flutter_intro_talk/slides/s02_benefits.dart';
import 'package:flutter_intro_talk/slides/s03_counter.dart';
import 'package:flutter_intro_talk/slides/s04_trees.dart';
import 'package:flutter_intro_talk/slides/s05_touch_journey.dart';
import 'package:flutter_intro_talk/slides/s06_widget_types.dart';
import 'package:flutter_intro_talk/slides/s07_state.dart';
import 'package:flutter_intro_talk/slides/s08_architecture.dart';
import 'package:flutter_intro_talk/slides/s09_rendering.dart';
import 'package:flutter_intro_talk/slides/s10_beyond.dart';
import 'package:flutter_intro_talk/slides/s11_native.dart';
import 'package:flutter_intro_talk/slides/s12_ai.dart';
import 'package:flutter_intro_talk/slides/s13_testing.dart';
import 'package:flutter_intro_talk/slides/s14_genui.dart';
import 'package:flutter_intro_talk/slides/s15_gallery.dart';
import 'package:flutter_intro_talk/slides/speaker_slide.dart';
import 'package:rive/rive.dart' show RiveNative;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Compile every program and load the Rive runtime before the first slide
  // is shown. On the web Rive fetches its wasm from a CDN; if that never
  // answers, only the Rive slides are affected, not the whole deck.
  await Future.wait([
    ShaderLibrary.warmUp(ShaderAssets.all),
    RiveNative.init().timeout(
      const Duration(seconds: 10),
      onTimeout: () => false,
    ),
  ]);
  runApp(FlutterIntroDeck(slides: deckSlides()));
}

class FlutterIntroDeck extends StatelessWidget {
  const FlutterIntroDeck({required this.slides, super.key});

  /// Injected so tests can exercise a subset — the Rive-backed slides
  /// cannot render in a headless test VM.
  final List<FlutterDeckSlideWidget> slides;

  @override
  Widget build(BuildContext context) {
    final base = ThemeData.dark(useMaterial3: true);

    return FlutterDeckApp(
      darkTheme: FlutterDeckThemeData.fromTheme(
        base.copyWith(
          scaffoldBackgroundColor: DeckColors.canvas,
          textTheme: base.textTheme.apply(
            bodyColor: DeckColors.text,
            displayColor: DeckColors.text,
            fontFamilyFallback: kFontFallback,
          ),
        ),
      ),
      themeMode: ThemeMode.dark,
      configuration: FlutterDeckConfiguration(
        background: const FlutterDeckBackgroundConfiguration(
          dark: FlutterDeckBackground.solid(DeckColors.canvas),
        ),
        controls: const FlutterDeckControlsConfiguration(
          shortcuts: FlutterDeckShortcutsConfiguration(
            toggleMarker: SingleActivator(
              LogicalKeyboardKey.keyM,
              control: true,
              meta: true,
            ),
            toggleNavigationDrawer: SingleActivator(
              LogicalKeyboardKey.period,
              control: true,
              meta: true,
            ),
          ),
        ),
        footer: const FlutterDeckFooterConfiguration(showSlideNumbers: true),
        marker: const FlutterDeckMarkerConfiguration(
          color: DeckColors.pink,
          strokeWidth: 8,
        ),
        progressIndicator: const FlutterDeckProgressIndicator.gradient(
          gradient: DeckGradients.hero,
          backgroundColor: Colors.white12,
        ),
        slideSize: FlutterDeckSlideSize.fromAspectRatio(
          aspectRatio: const FlutterDeckAspectRatio.ratio16x9(),
          resolution: const FlutterDeckResolution.fromWidth(1920),
        ),
        transition: const FlutterDeckTransition.fade(),
      ),
      slides: slides,
    );
  }
}

/// Routes to leave out for the 90-minute cut — see 「時間配分」 in
/// SPEAKER_NOTES.md for the suggested candidates. Empty = the full deck.
const Set<String> kSkippedRoutes = {};

/// The deck, in presentation order.
List<FlutterDeckSlideWidget> deckSlides() => [
      for (final slide in _allSlides())
        if (!kSkippedRoutes.contains(slide.configuration!.route)) slide,
    ];

List<FlutterDeckSlideWidget> _allSlides() => [
  // ── 00 · 問題提起 → Flutter の紹介 ─────────────────────────────
  ...titleAndProblemSlides,
  // ── 自己紹介 ───────────────────────────────────────────────────
  const S02Speaker(),
  // ── アジェンダ・Flutter のメリット・Everything is a Widget ───────
  ...agendaAndBenefitsSlides,
  // ── カウンターアプリ ───────────────────────────────────────────
  ...counterSlides,
  // ── 3つのツリー ────────────────────────────────────────────────
  ...treeSlides,
  // ── タップの旅（3つのツリーを貫く信号） ─────────────────────────
  ...touchJourneySlides,
  // ── Widget の種類 ──────────────────────────────────────────────
  ...widgetTypeSlides,
  // ── 状態管理 ───────────────────────────────────────────────────
  ...stateSlides,
  // ── アプリのアーキテクチャ ─────────────────────────────────────
  ...architectureSlides,
  // ── レンダリングの仕組み ───────────────────────────────────────
  ...renderingSlides,
  // ── 何でも描ける（3D・シェーダー・アニメーション） ───────────────
  ...beyondSlides,
  // ── 弱点とネイティブ連携 ───────────────────────────────────────
  ...nativeSlides,
  // ── AI と Flutter ──────────────────────────────────────────────
  ...aiSlides,
  // ── テスト ─────────────────────────────────────────────────────
  ...testingSlides,
  // ── GenUI / A2UI ───────────────────────────────────────────────
  ...genUiSlides,
  // ── ギャラリー・まとめ ─────────────────────────────────────────
  ...gallerySlides,
  const Slide43Thanks(),
];
