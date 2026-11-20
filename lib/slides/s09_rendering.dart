import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';
import 'package:flutter_intro_talk/core/theme/kaigi_theme.dart';
import 'package:flutter_intro_talk/core/widgets/deck_components.dart';
import 'package:flutter_intro_talk/core/widgets/deck_scaffold.dart';
import 'package:flutter_intro_talk/core/widgets/motion.dart';
import 'package:flutter_intro_talk/core/widgets/phone_frame.dart';
import 'package:flutter_intro_talk/core/widgets/templates.dart';
import 'package:flutter_intro_talk/core/widgets/wwdc_background.dart';

/// Section: Flutter はどう描画するのか.
final List<FlutterDeckSlideWidget> renderingSlides = [
  DividerSlideWidget(
    route: '/r-divider',
    number: '04',
    label: 'Rendering',
    title: 'Flutter はどう描画するのか',
    subtitle: 'OS の部品を借りるか、全部自分で描くか。',
    mood: GradientMood.cool,
    accent: DeckColors.dart,
  ),
  InteractiveSlideWidget(
    route: '/r-compare',
    eyebrow: 'Who draws the button?',
    title: 'そのボタン、誰が描いている？',
    footnote: 'Flutter は OS の UI 部品を使わない。Canvas に全ピクセルを自分で描く。',
    builder: _compareBody,
  ),
  const _ArchitectureSlide(),
  InteractiveSlideWidget(
    route: '/r-impeller',
    eyebrow: 'Rendering engine',
    title: 'Impeller ── カクつかない描画エンジン',
    footnote: 'iOS は 3.10、Android（Vulkan 対応端末）は 3.27 から Impeller がデフォルト。',
    mood: GradientMood.violet,
    builder: _impellerBody,
  ),
  StatementSlideWidget(
    route: '/r-own-design',
    eyebrow: 'Design',
    statement: 'ほとんどのアプリは、\n独自のデザインを持っている。',
    subtitle: 'プラットフォームごとに見た目が変わってほしくない ── そこで Flutter。',
    mood: GradientMood.warm,
  ),
  InteractiveSlideWidget(
    route: '/r-brand',
    eyebrow: 'Pixel perfect',
    title: '同じコード、同じピクセル',
    footnote: 'デザイナーが作った 1 枚のデザインが、そのまま全プラットフォームに出る。',
    mood: GradientMood.warm,
    intensity: 0.4,
    builder: _brandBody,
  ),
  InteractiveSlideWidget(
    route: '/r-when',
    eyebrow: 'When to choose Flutter',
    title: 'Flutter が光る場面・向かない場面',
    steps: 2,
    builder: _whenBody,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// そのボタン、誰が描いている？ — click a framework, see its stack.
// ─────────────────────────────────────────────────────────────────────────────
Widget _compareBody(BuildContext context, int step) =>
    const _FrameworkCompare();

class _Layer {
  const _Layer(this.title, this.detail, {this.draws = false});
  final String title;
  final String detail;
  final bool draws;
}

class _Framework {
  const _Framework(this.name, this.summary, this.accent, this.layers);
  final String name;
  final String summary;
  final Color accent;
  final List<_Layer> layers;
}

const _frameworks = [
  _Framework('ネイティブ', 'OS が用意した UI 部品で描く', DeckColors.green, [
    _Layer('あなたのコード', 'Swift / Kotlin'),
    _Layer('UI フレームワーク', 'SwiftUI · UIKit / Compose · View'),
    _Layer('OS の UI 部品', 'UIButton / android.widget.Button', draws: true),
    _Layer('GPU', 'Metal / Vulkan'),
  ]),
  _Framework('WebView', 'アプリの中のブラウザが HTML を描く', DeckColors.orange, [
    _Layer('あなたのコード', 'HTML / CSS / JavaScript'),
    _Layer('WebView', 'WKWebView / Android WebView', draws: true),
    _Layer('GPU', 'ブラウザエンジン経由'),
  ]),
  _Framework('React Native', 'JS から OS の UI 部品を操作する', DeckColors.cyan, [
    _Layer('あなたのコード', 'JavaScript / TypeScript'),
    _Layer('JS ランタイム', 'Hermes + JSI（New Architecture）'),
    _Layer('OS の UI 部品', 'UIView / android.view.View', draws: true),
    _Layer('GPU', 'Metal / Vulkan'),
  ]),
  _Framework(
    'Compose Multiplatform',
    'Android は Compose、iOS は Skia で自前描画',
    DeckColors.purple,
    [
      _Layer('あなたのコード', 'Kotlin'),
      _Layer('Compose', 'Kotlin Multiplatform'),
      _Layer('Skia（Skiko）', 'iOS ではキャンバスに自前で描く', draws: true),
      _Layer('GPU', 'Metal / Vulkan'),
    ],
  ),
  _Framework('Flutter', '全ピクセルを自分のエンジンで描く', DeckColors.dart, [
    _Layer('あなたのコード', 'Dart'),
    _Layer('Flutter Framework', 'Widget → Element → RenderObject'),
    _Layer('Flutter Engine', 'Impeller が全ピクセルを描く', draws: true),
    _Layer('GPU', 'Metal / Vulkan / OpenGL ES'),
  ]),
];

class _FrameworkCompare extends StatefulWidget {
  const _FrameworkCompare();

  @override
  State<_FrameworkCompare> createState() => _FrameworkCompareState();
}

class _FrameworkCompareState extends State<_FrameworkCompare> {
  int _selected = 4;

  @override
  Widget build(BuildContext context) {
    final fw = _frameworks[_selected];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 520,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('クリックして切り替え', style: DeckText.caption),
              const SizedBox(height: 16),
              for (var i = 0; i < _frameworks.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _SelectableRow(
                    label: _frameworks[i].name,
                    accent: _frameworks[i].accent,
                    selected: i == _selected,
                    onTap: () => setState(() => _selected = i),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 60),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 420),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0.04, 0),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: _Stack(key: ValueKey(_selected), framework: fw),
          ),
        ),
      ],
    );
  }
}

class _SelectableRow extends StatelessWidget {
  const _SelectableRow({
    required this.label,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
          decoration: BoxDecoration(
            color: selected
                ? accent.withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: accent.withValues(alpha: selected ? 0.9 : 0.25),
              width: selected ? 2.5 : 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 18),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    style: DeckText.heading.copyWith(
                      fontSize: 30,
                      color: selected
                          ? DeckColors.text
                          : DeckColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stack extends StatelessWidget {
  const _Stack({required this.framework, super.key});

  final _Framework framework;

  @override
  Widget build(BuildContext context) {
    final a = framework.accent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          framework.summary,
          style: DeckText.heading.copyWith(color: a, fontSize: 36),
        ),
        const SizedBox(height: 26),
        for (var i = 0; i < framework.layers.length; i++) ...[
          if (i > 0)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Icon(
                Icons.arrow_downward_rounded,
                color: DeckColors.textTertiary,
                size: 28,
              ),
            ),
          _LayerBox(layer: framework.layers[i], accent: a),
        ],
      ],
    );
  }
}

class _LayerBox extends StatelessWidget {
  const _LayerBox({required this.layer, required this.accent});

  final _Layer layer;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final draws = layer.draws;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      decoration: BoxDecoration(
        color: draws
            ? accent.withValues(alpha: 0.20)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accent.withValues(alpha: draws ? 1 : 0.25),
          width: draws ? 2.5 : 1.5,
        ),
        boxShadow: draws
            ? [BoxShadow(color: accent.withValues(alpha: 0.3), blurRadius: 30)]
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  layer.title,
                  style: DeckText.heading.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 4),
                Text(layer.detail, style: DeckText.caption),
              ],
            ),
          ),
          if (draws) ...[
            Text(
              'ここが描く',
              style: DeckText.body.copyWith(
                color: accent,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Button',
                style: DeckText.body.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: DeckColors.canvas,
                  height: 1,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Flutter のアーキテクチャ — Framework / Engine / Embedder.
// ─────────────────────────────────────────────────────────────────────────────
class _ArchitectureSlide extends FlutterDeckSlideWidget {
  const _ArchitectureSlide()
    : super(
        configuration: const FlutterDeckSlideConfiguration(
          route: '/r-architecture',
          title: 'Flutter のアーキテクチャ',
          header: FlutterDeckHeaderConfiguration(showHeader: false),
          steps: 3,
        ),
      );

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.custom(
      builder: (context) => FlutterDeckSlideStepsBuilder(
        builder: (context, step) => DeckSlide(
          eyebrow: 'Architecture',
          title: 'Flutter は 3 つの層でできている',
          footnote: 'プラットフォームごとに違うのは一番下の Embedder だけ。上の 2 層は全部共通。',
          child: Column(
            children: [
              Expanded(
                child: StaggerIn(
                  visible: step >= 1,
                  child: const _Tier(
                    name: 'Framework',
                    lang: 'Dart',
                    accent: DeckColors.dart,
                    chips: [
                      'Material / Cupertino',
                      'Widgets',
                      'Rendering',
                      'Animation · Painting · Gestures',
                    ],
                    note: 'あなたが書くのはここ',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: StaggerIn(
                  visible: step >= 2,
                  child: const _Tier(
                    name: 'Engine',
                    lang: 'C++',
                    accent: DeckColors.purple,
                    chips: ['Impeller', 'Dart Runtime', 'テキストレイアウト', 'dart:ui'],
                    note: 'ピクセルを描く心臓部',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: StaggerIn(
                  visible: step >= 3,
                  child: const _Tier(
                    name: 'Embedder',
                    lang: 'プラットフォーム固有',
                    accent: DeckColors.orange,
                    chips: [
                      'iOS',
                      'Android',
                      'Web',
                      'macOS',
                      'Windows',
                      'Linux',
                    ],
                    note: 'OS とつなぐ：画面・入力・スレッド',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tier extends StatelessWidget {
  const _Tier({
    required this.name,
    required this.lang,
    required this.accent,
    required this.chips,
    required this.note,
  });

  final String name;
  final String lang;
  final Color accent;
  final List<String> chips;
  final String note;

  @override
  Widget build(BuildContext context) {
    return DeckCard(
      accent: accent,
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
      child: Row(
        children: [
          SizedBox(
            width: 340,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: DeckText.title.copyWith(fontSize: 48, color: accent),
                ),
                Text(lang, style: DeckText.caption),
              ],
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: 14,
              runSpacing: 12,
              children: [
                for (final c in chips) Pill(c, color: accent, fontSize: 20),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Text(note, style: DeckText.bodySecondary.copyWith(fontSize: 22)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Impeller — interactive frame-time graph. Skia compiles shaders the first
// time an effect appears, which shows up as a spike; Impeller does not.
// ─────────────────────────────────────────────────────────────────────────────
Widget _impellerBody(BuildContext context, int step) => const _JankDemo();

class _JankDemo extends StatefulWidget {
  const _JankDemo();

  @override
  State<_JankDemo> createState() => _JankDemoState();
}

class _JankDemoState extends State<_JankDemo> {
  static const _count = 60;
  final _rng = math.Random(7);
  final List<double> _frames = List.filled(_count, 8, growable: true);
  bool _impeller = false;
  int _pendingSpikes = 0;
  int _jankCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 80), (_) => _tick());
  }

  void _tick() {
    double ms = 6 + _rng.nextDouble() * 4;
    if (_pendingSpikes > 0) {
      _pendingSpikes--;
      ms = 40 + _rng.nextDouble() * 90;
      _jankCount++;
    }
    setState(() {
      _frames
        ..removeAt(0)
        ..add(ms);
    });
  }

  void _newEffect() {
    // Skia: a new effect → compile its shaders on the raster thread now.
    if (!_impeller) _pendingSpikes = 3;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = _impeller ? DeckColors.green : DeckColors.red;
    return SplitContent(
      leftFlex: 4,
      rightFlex: 6,
      left: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ModeToggle(
            impeller: _impeller,
            onChanged: (v) => setState(() {
              _impeller = v;
              _jankCount = 0;
            }),
          ),
          const SizedBox(height: 30),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              key: ValueKey(_impeller),
              _impeller
                  ? 'シェーダーはビルド時にコンパイル済み。\n初めてのエフェクトでも滑らか。'
                  : '初めて出るエフェクトのたびに、\n実行時にシェーダーをコンパイル。\n→ 最初の 1 回だけカクつく（jank）',
              style: DeckText.body.copyWith(fontSize: 27),
            ),
          ),
          const SizedBox(height: 34),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: _newEffect,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  gradient: DeckGradients.hero,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '✨ 新しいアニメーションを初表示',
                  style: DeckText.body.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Pill('Metal', color: DeckColors.textSecondary, fontSize: 18),
              const SizedBox(width: 10),
              Pill('Vulkan', color: DeckColors.textSecondary, fontSize: 18),
              const SizedBox(width: 10),
              Pill('OpenGL ES', color: DeckColors.textSecondary, fontSize: 18),
            ],
          ),
        ],
      ),
      right: DeckCard(
        accent: accent,
        padding: const EdgeInsets.fromLTRB(30, 26, 30, 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('フレーム時間（ms）', style: DeckText.caption),
                const Spacer(),
                Text(
                  'jank: $_jankCount',
                  style: DeckText.mono.copyWith(color: accent, fontSize: 22),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: CustomPaint(
                size: Size.infinite,
                painter: _FramePainter(
                  _frames,
                  _impeller ? DeckColors.green : DeckColors.cyan,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '点線 = 16.7ms（60fps の締め切り）',
              style: DeckText.caption.copyWith(fontSize: 17),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.impeller, required this.onChanged});

  final bool impeller;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget seg(String label, bool value, Color c) {
      final on = impeller == value;
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => onChanged(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 16),
            decoration: BoxDecoration(
              color: on ? c.withValues(alpha: 0.25) : Colors.transparent,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: on ? c : Colors.transparent, width: 2),
            ),
            child: Text(
              label,
              style: DeckText.heading.copyWith(
                fontSize: 28,
                color: on ? c : DeckColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          seg('Skia', false, DeckColors.red),
          seg('Impeller', true, DeckColors.green),
        ],
      ),
    );
  }
}

class _FramePainter extends CustomPainter {
  _FramePainter(this.frames, this.color);

  final List<double> frames;
  final Color color;

  static const _maxMs = 140.0;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width / frames.length;
    for (var i = 0; i < frames.length; i++) {
      final ms = frames[i];
      final h = (ms / _maxMs).clamp(0.0, 1.0) * size.height;
      final over = ms > 16.7;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(i * w + 1.5, size.height - h, w - 3, h),
          const Radius.circular(3),
        ),
        Paint()..color = over ? DeckColors.red : color,
      );
    }
    // 16.7 ms budget line.
    final y = size.height - 16.7 / _maxMs * size.height;
    final dash = Paint()
      ..color = Colors.white54
      ..strokeWidth = 2;
    for (var x = 0.0; x < size.width; x += 18) {
      canvas.drawLine(Offset(x, y), Offset(x + 9, y), dash);
    }
  }

  @override
  bool shouldRepaint(_FramePainter old) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// Brand consistency — one custom design, three platforms, identical pixels.
// Toggle 「ネイティブで作ったら」 to see each platform drift.
// ─────────────────────────────────────────────────────────────────────────────
Widget _brandBody(BuildContext context, int step) => const _BrandDemo();

enum _Plat { ios, android, web }

class _BrandDemo extends StatefulWidget {
  const _BrandDemo();

  @override
  State<_BrandDemo> createState() => _BrandDemoState();
}

class _BrandDemoState extends State<_BrandDemo> {
  bool _native = false;
  bool _notify = true;

  @override
  Widget build(BuildContext context) {
    Widget screen(_Plat p) => _BrandScreen(
      platform: p,
      native: _native,
      notify: _notify,
      onNotify: (v) => setState(() => _notify = v),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BigSwitchRow(
                label: 'Flutter で作る',
                value: !_native,
                accent: DeckColors.dart,
                onTap: () => setState(() => _native = false),
              ),
              const SizedBox(height: 16),
              _BigSwitchRow(
                label: 'ネイティブで作ったら',
                value: _native,
                accent: DeckColors.red,
                onTap: () => setState(() => _native = true),
              ),
              const SizedBox(height: 40),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _native
                    ? const CalloutBox(
                        key: ValueKey('n'),
                        label: '少しずつズレる',
                        lines: ['フォント・スイッチ', 'ボタン・余白・角丸', '× 3 プラットフォーム'],
                      )
                    : const CalloutBox(
                        key: ValueKey('f'),
                        label: 'ピクセル単位で同じ',
                        isProblem: false,
                        lines: ['1 つのデザインシステム', '1 つのコード', '3 つの画面'],
                      ),
              ),
              const SizedBox(height: 24),
              Text(
                'スイッチは実際に動きます',
                style: DeckText.caption.copyWith(color: Colors.white38),
              ),
            ],
          ),
        ),
        const SizedBox(width: 50),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PhoneFrame(
                width: 300,
                label: 'iOS',
                accent: DeckColors.textSecondary,
                screenColor: _BrandScreen.bg,
                child: screen(_Plat.ios),
              ),
              PhoneFrame(
                width: 300,
                style: PhoneStyle.android,
                label: 'Android',
                accent: DeckColors.green,
                screenColor: _BrandScreen.bg,
                child: screen(_Plat.android),
              ),
              _BrowserFrame(child: screen(_Plat.web)),
            ],
          ),
        ),
      ],
    );
  }
}

class _BigSwitchRow extends StatelessWidget {
  const _BigSwitchRow({
    required this.label,
    required this.value,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final bool value;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _SelectableRow(
      label: label,
      accent: accent,
      selected: value,
      onTap: onTap,
    );
  }
}

class _BrowserFrame extends StatelessWidget {
  const _BrowserFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 400,
          height: 650,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A20),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: DeckColors.orange.withValues(alpha: 0.45),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: DeckColors.orange.withValues(alpha: 0.18),
                blurRadius: 60,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    for (final c in const [
                      Color(0xFFFF5F57),
                      Color(0xFFFEBC2E),
                      Color(0xFF28C840),
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 7),
                        child: Container(
                          width: 11,
                          height: 11,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 26,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'kissa.app',
                          style: DeckText.caption.copyWith(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ColoredBox(color: _BrandScreen.bg, child: child),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text('Web', style: DeckText.caption.copyWith(color: DeckColors.orange)),
      ],
    );
  }
}

/// A coffee-shop app with its own bold brand. With `native: true` every
/// platform swaps in its own stock widgets, fonts and spacing.
class _BrandScreen extends StatelessWidget {
  const _BrandScreen({
    required this.platform,
    required this.native,
    required this.notify,
    required this.onNotify,
  });

  final _Plat platform;
  final bool native;
  final bool notify;
  final ValueChanged<bool> onNotify;

  static const bg = Color(0xFFFFF4E6);
  static const ink = Color(0xFF1B1209);
  static const brand = Color(0xFFFF6B1A);

  @override
  Widget build(BuildContext context) {
    final drift = native;
    // Each platform's "stock" look.
    final font = !drift
        ? FontWeight.w900
        : switch (platform) {
            _Plat.ios => FontWeight.w700,
            _Plat.android => FontWeight.w500,
            _Plat.web => FontWeight.w400,
          };
    final pad = !drift
        ? 20.0
        : switch (platform) {
            _Plat.ios => 16.0,
            _Plat.android => 24.0,
            _Plat.web => 10.0,
          };
    final radius = !drift
        ? 24.0
        : switch (platform) {
            _Plat.ios => 12.0,
            _Plat.android => 28.0,
            _Plat.web => 4.0,
          };

    return Padding(
      padding: EdgeInsets.all(pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'KISSA',
            style: TextStyle(
              fontSize: 15,
              letterSpacing: drift ? 1 : 5,
              fontWeight: FontWeight.w800,
              color: brand,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'おはよう、\nLucas さん',
            style: TextStyle(
              fontSize: 28,
              height: 1.15,
              fontWeight: font,
              color: ink,
              fontFamilyFallback: kFontFallback,
            ),
          ),
          const SizedBox(height: 18),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 150,
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              gradient: drift && platform == _Plat.web
                  ? null
                  : const LinearGradient(
                      colors: [Color(0xFFFF6B1A), Color(0xFFFF2E63)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              color: drift && platform == _Plat.web ? brand : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '今日のおすすめ',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.85),
                    fontFamilyFallback: kFontFallback,
                  ),
                ),
                Text(
                  '黒糖ラテ',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: font,
                    color: Colors.white,
                    fontFamilyFallback: kFontFallback,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(
                '入荷のお知らせ',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: ink,
                  fontFamilyFallback: kFontFallback,
                ),
              ),
              const Spacer(),
              _toggle(),
            ],
          ),
          const Spacer(),
          SizedBox(width: double.infinity, child: _button(radius)),
        ],
      ),
    );
  }

  Widget _toggle() {
    if (!native) {
      // The brand's own toggle — same pixels everywhere.
      return GestureDetector(
        onTap: () => onNotify(!notify),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 52,
          height: 30,
          padding: const EdgeInsets.all(4),
          alignment: notify ? Alignment.centerRight : Alignment.centerLeft,
          decoration: BoxDecoration(
            color: notify ? ink : ink.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: notify ? brand : Colors.white,
              borderRadius: BorderRadius.circular(7),
            ),
          ),
        ),
      );
    }
    return switch (platform) {
      _Plat.ios => CupertinoSwitch(value: notify, onChanged: onNotify),
      _Plat.android => Theme(
        data: ThemeData.light(useMaterial3: true),
        child: Switch(value: notify, onChanged: onNotify),
      ),
      _Plat.web => Theme(
        data: ThemeData.light(useMaterial3: false),
        child: Checkbox(value: notify, onChanged: (v) => onNotify(v ?? false)),
      ),
    };
  }

  Widget _button(double radius) {
    const label = '注文する';
    if (!native) {
      return Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ink,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: const Text(
          '$label  →',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            fontFamilyFallback: kFontFallback,
          ),
        ),
      );
    }
    return switch (platform) {
      _Plat.ios => CupertinoButton.filled(
        onPressed: () {},
        child: const Text(label),
      ),
      _Plat.android => Theme(
        data: ThemeData.light(useMaterial3: true),
        child: FilledButton(onPressed: () {}, child: const Text(label)),
      ),
      _Plat.web => Container(
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFE9E9ED),
          border: Border.all(color: const Color(0xFF8F8F9D)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          label,
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontFamilyFallback: kFontFallback,
          ),
        ),
      ),
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 光る場面・向かない場面
// ─────────────────────────────────────────────────────────────────────────────
Widget _whenBody(BuildContext context, int step) => Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Expanded(
      child: StaggerIn(
        visible: step >= 1,
        child: const CalloutBox(
          label: '✓ 光る場面',
          isProblem: false,
          lines: [
            '独自のデザインシステムがある',
            'アニメーションが多い UI',
            'iOS・Android・Web を同時に',
            '少人数のチームで速く作りたい',
          ],
        ),
      ),
    ),
    const SizedBox(width: 40),
    Expanded(
      child: StaggerIn(
        visible: step >= 2,
        child: const CalloutBox(
          label: '△ 向かない場面',
          lines: [
            'OS 標準 UI そのものが欲しい',
            '数 MB を争う超軽量アプリ',
            'SEO が命の Web サイト',
            'OS の新機能を初日から使いたい',
          ],
        ),
      ),
    ),
  ],
);
