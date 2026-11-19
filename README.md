# はじめての Flutter ― 1つのコードで、すべての画面を描く

**Flutter 入門（90分）** — Lucas Goldner (YOUTRUST Inc.)

「iOS と Android、2チーム・2コードベース」という課題から始めて、Flutter の基本、Everything is a Widget、
カウンターアプリ、3つのツリー、タップから画素までの旅、状態管理（setState / InheritedWidget / Riverpod / BLoC）、
Riverpod による実際のアーキテクチャ、描画の仕組み、3D とシェーダー、Platform Views とネイティブ連携（MethodChannel・Pigeon・FFIgen）、
AI、テスト、GenUI / A2UI、そして Made with Flutter ギャラリーまでを **すべて動くデモ付きで** 紹介する入門トーク。

スライドは [`flutter_deck`](https://pub.dev/packages/flutter_deck) で作られた Flutter アプリです。
デザインは FlutterKaigi 2026 のシェーダートーク（`flutterkaigi2026-shader-talk`）と共通です。

## 実行

```bash
flutter pub get
flutter run -d macos --release
```

| 操作 | キー |
| --- | --- |
| 次 / 前のスライド | `→` / `←` |
| ナビゲーションドロワー | `⌘ + ⌃ + .` |
| マーカー | `⌘ + ⌃ + M` |

### Web / Vercel

```bash
flutter build web --release      # → build/web
```

`vercel.json` + `scripts/vercel_*.sh`（Flutter 3.50.0 を clone してビルド。`FLUTTER_VERSION` で変更可）。

### テスト

```bash
flutter test                                              # 全スライド × 全ステップのスモークテスト
flutter test test/render_slides_test.dart --plain-name s05 # build/shots/ に PNG を書き出す
```

## 構成

| 章 | ファイル | 主なインタラクティブデモ |
| --- | --- | --- |
| Opening | `s01_problem.dart` | 「同じ機能を2回作る」シミュレーター、iOS/Android 間違い探し、Hot Reload |
| 自己紹介 | `speaker_slide.dart` | Rive（シェーダートークと同じ） |
| 01 なぜ Flutter？ | `s02_benefits.dart` | 6プラットフォーム切り替え、Widget X-ray、レイアウトプレイグラウンド |
| 02 カウンターアプリ | `s03_counter.dart` | 本物のカウンター + テンプレートコード、setState on/off |
| 03 3つのツリー | `s04_trees.dart` | 3ツリーエクスプローラー、リビルド可視化、Key の入れ替え |
| タップの旅 | `s05_touch_journey.dart` | **信号のチューブ**（hitTest → setState → build → layout → paint → 画素）、フレーム予算 |
| 04 Widget の種類 | `s06_widget_types.dart` | ライフサイクルロガー、Material ⇄ Cupertino（.adaptive） |
| 05 状態管理 | `s07_state.dart` | Prop drilling vs InheritedWidget、Riverpod のリビルド数、BLoC ストリーム |
| 06 アプリの設計 | `s08_architecture.dart` + `lib/demo_app/` | Screen → ViewModel → Repository → ApiClient が実際に動くアプリ |
| 07 描画の仕組み | `s09_rendering.dart` | フレームワーク比較、Skia vs Impeller、ブランドデザインの一貫性 |
| 何でも描ける | `s10_beyond.dart` | レイマーチングの 3D シーン、ワープポータル、シェーダー UI、アニメーション |
| 弱点とネイティブ連携 | `s11_native.dart` | Platform Views のレイヤー分解、MethodChannel シミュレーター、FFIgen |
| 08 AI | `s12_ai.dart` | エージェントループ、アプリ内チャット |
| 09 テスト | `s13_testing.dart` | テストランナー可視化、ゴールデン差分ビューア |
| 10 GenUI / A2UI | `s14_genui.dart` | A2UI JSON から Widget が生まれる GenUI シミュレーター |
| 11 Made with Flutter | `s15_gallery.dart` | 国内・海外アプリギャラリー |

話す原稿は [`SPEAKER_NOTES.md`](SPEAKER_NOTES.md)。
