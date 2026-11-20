# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A `flutter_deck` presentation app for a **90-minute introduction to Flutter**
「はじめての Flutter ― 1つのコードで、すべての画面を描く」 by Lucas Goldner (YOUTRUST Inc.).

The deck is a Flutter app **and** the talk is about Flutter: the counter app, the three trees, the
Riverpod architecture, the shaders, the GenUI simulator — every demo is real Flutter running inside
the slide. The visual style is shared with the FlutterKaigi 2026 shader deck (dark WWDC-style keynote).

**Target platforms**: macOS (presentation mode, Impeller) and web (deployed on Vercel)
**Slide language**: Japanese, with English technical terms left as-is (Widget, setState, RenderObject …)

## Build & Run Commands

```bash
flutter pub get
flutter run -d macos --release   # run the presentation
flutter analyze                  # must stay clean
flutter test                     # smoke-tests every slide and every step at 1920×1080
flutter build web --release      # what Vercel runs (see vercel.json, scripts/vercel_*.sh)
```

`test/render_slides_test.dart` renders the last beat of each slide to `build/shots/*.png` with real
Latin + Japanese fonts (`test/fonts/`) — use it to review layouts without a device
(`flutter test test/render_slides_test.dart --plain-name s07`). Shaders and Rive do not paint in tests.

## Architecture

### Slides — `lib/slides/`

One file per chapter, each exporting a `List<FlutterDeckSlideWidget>`; `lib/main.dart` concatenates
them in talk order (`deckSlides()`, listed below in that order) and inserts the Rive speaker slide (`speaker_slide.dart`, unchanged from the
shader deck) and the Rive thanks slide (`outro_slide.dart`).

| File | Chapter |
| --- | --- |
| `s01_problem.dart` | タイトル・2チーム2コードベース問題・Flutter とは・Dart・Hot Reload |
| `s02_benefits.dart` | アジェンダ・メリット・Everything is a Widget・レイアウト |
| `s03_counter.dart` | カウンターアプリのコードを読む |
| `s04_trees.dart` | Widget / Element / RenderObject |
| `s05_touch_journey.dart` | タップから画素までの旅（3つのツリーを貫く信号）・質問タイム ①②（`questionTimeSlides` / `secondQuestionTimeSlides`） |
| `s09_rendering.dart` | 他フレームワークとの描画比較・Impeller（04、タップの旅のすぐ後） |
| `s06_widget_types.dart` | Widget の種類・ライフサイクル・家系図 |
| `s07_state.dart` | setState / InheritedWidget / Riverpod / BLoC |
| `s08_architecture.dart` | Screen → ViewModel → Repository → ApiClient（`lib/demo_app/` が実際に動く） |
| `s10_beyond.dart` | 3D シーン・フラグメントシェーダー・アニメーション |
| `s11_native.dart` | 弱点・Platform Views・MethodChannel・Pigeon・FFIgen |
| `s12_ai.dart` – `s15_gallery.dart` | AI・テスト・GenUI/A2UI・ギャラリー・まとめ |

### Templates — `lib/core/widgets/templates.dart`

Most talking slides are data-driven: `StatementSlideWidget`, `DividerSlideWidget`,
`BulletSlideWidget`, `CardGridSlideWidget`, `CodeSlideWidget`, `QuizSlideWidget` (click to vote,
→ to reveal), `InteractiveSlideWidget`. Their constructors are not `const` (the configuration is built
from arguments), so slide lists are `final`. Bespoke interactive slides subclass
`FlutterDeckSlideWidget` directly.

### Design system — `lib/core/`

Shared with the shader deck — do not hand-roll colours or text styles in a slide.

- `theme/kaigi_theme.dart` — `DeckColors`, `DeckGradients`, `DeckText`.
- `widgets/deck_scaffold.dart` — `DeckSlide`, `StatementSlide`, `PartDivider`, `GradientText`, `Footnote`.
- `widgets/deck_components.dart` — `DeckCard`, `TitledCard`, `Pill`, `FlowRow`, `BulletList`, `CalloutBox`, `SplitContent`.
- `widgets/demo_frame.dart` — `DemoFrame` (LIVE viewport) and `CodeDemoLayout`.
- `widgets/phone_frame.dart` — `PhoneFrame`, the device mockup for in-slide apps.
- `widgets/code_panel.dart` — `CodePanel`.
- `shaders/shader_view.dart` — `ShaderView`, `ShaderLibrary`.

### Shaders — `shaders/`

Every `.frag` must be listed in `pubspec.yaml` under `flutter: shaders:` **and** in
`lib/core/shaders/shader_assets.dart`. `#version 460 core`, `#include <flutter/runtime_effect.glsl>`,
first uniform `vec2 uSize`, no `dFdx`/`dFdy`, constant loop bounds (so they compile to SkSL for web).

## Conventions

- Japanese body copy, few words per slide, one message per slide.
- Interactive demos are real Flutter and show their code beside them where it makes sense.
- Speaker notes (`SPEAKER_NOTES.md`) are numbered by deck position — update them when slides move.
- Keep `flutter analyze` and `flutter test` clean.
