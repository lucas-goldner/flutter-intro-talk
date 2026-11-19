import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';
import 'package:flutter_intro_talk/core/shaders/shader_assets.dart';
import 'package:flutter_intro_talk/core/shaders/shader_view.dart';
import 'package:flutter_intro_talk/core/theme/kaigi_theme.dart';
import 'package:flutter_intro_talk/core/widgets/code_panel.dart';
import 'package:flutter_intro_talk/core/widgets/deck_components.dart';
import 'package:flutter_intro_talk/core/widgets/deck_scaffold.dart';
import 'package:flutter_intro_talk/core/widgets/demo_frame.dart';
import 'package:flutter_intro_talk/core/widgets/motion.dart';
import 'package:flutter_intro_talk/core/widgets/phone_frame.dart';
import 'package:flutter_intro_talk/core/widgets/templates.dart';
import 'package:flutter_intro_talk/core/widgets/wwdc_background.dart';

/// Opening: title → the "two teams, two codebases" problem → Flutter.
/// The speaker slide is inserted right after this list by main.dart.
final List<FlutterDeckSlideWidget> titleAndProblemSlides = [
  const _TitleSlide(),
  StatementSlideWidget(
    route: '/p-want-app',
    eyebrow: 'Let’s build an app',
    statement: 'アプリを作りたい。',
    subtitle: '……iOS と Android、両方で。',
    mood: GradientMood.cool,
  ),
  InteractiveSlideWidget(
    route: '/p-two-teams',
    eyebrow: 'The native reality',
    title: 'ネイティブ開発の現実：2チーム・2コードベース',
    footnote: '1つの仕様書が、2つのチーム・2つの言語・2つのコードに分かれる。',
    steps: 3,
    builder: _twoTeams,
  ),
  InteractiveSlideWidget(
    route: '/p-simulator',
    eyebrow: 'Simulator',
    title: '同じ機能を、2回作る',
    mood: GradientMood.warm,
    intensity: 0.4,
    builder: (context, step) => const _FeatureSimulator(),
  ),
  const _SpotTheDifferenceSlide(),
  CardGridSlideWidget(
    route: '/p-costs',
    eyebrow: 'What happens',
    title: '何が起きるか',
    columns: 3,
    childAspectRatio: 1.75,
    mood: GradientMood.warm,
    cards: const [
      CardSpec(
        badge: 'COST',
        title: '開発コスト ×2',
        lines: ['同じ機能を2回実装', 'レビューも2回'],
        accent: DeckColors.red,
      ),
      CardSpec(
        badge: 'SPEC',
        title: '仕様のズレ',
        lines: ['解釈の違いが', '少しずつ積み重なる'],
        accent: DeckColors.orange,
      ),
      CardSpec(
        badge: 'RELEASE',
        title: 'リリースのズレ',
        lines: ['「Android 版は来月です」', '遅い方に合わせる'],
        accent: DeckColors.pink,
      ),
      CardSpec(
        badge: 'QA',
        title: 'テストも2倍',
        lines: ['テストケースも', '2プラットフォーム分'],
        accent: DeckColors.purple,
      ),
      CardSpec(
        badge: 'PEOPLE',
        title: '人材の確保',
        lines: ['iOS と Android、', '両方の専門家が必要'],
        accent: DeckColors.blue,
      ),
      CardSpec(
        badge: 'DESIGN',
        title: 'デザインの二重管理',
        lines: ['2つの実装を', 'デザイナーが二重チェック'],
        accent: DeckColors.cyan,
      ),
    ],
  ),
  InteractiveSlideWidget(
    route: '/p-options',
    eyebrow: 'Cross-platform',
    title: 'クロスプラットフォームという選択肢',
    footnote: 'どれも「1つのコードで複数OS」を目指す。違いは「誰が画面を描くか」。',
    steps: 4,
    builder: _options,
  ),
  StatementSlideWidget(
    route: '/p-one-code',
    eyebrow: 'Enter Flutter',
    statement: '1つのコードで、\niOS も Android も\nWeb も Desktop も。',
    subtitle: 'それが Flutter です。',
    gradient: DeckGradients.flutter,
    mood: GradientMood.cool,
  ),
  InteractiveSlideWidget(
    route: '/p-what-is-flutter',
    eyebrow: 'What is Flutter',
    title: 'Flutter とは',
    footnote: 'Google が開発するオープンソースの UI ツールキット。2018年12月に 1.0。',
    steps: 4,
    builder: _whatIsFlutter,
  ),
  InteractiveSlideWidget(
    route: '/p-history',
    eyebrow: 'History',
    title: 'Flutter の歩み',
    steps: _history.length,
    builder: _historyTimeline,
  ),
  InteractiveSlideWidget(
    route: '/p-dart',
    eyebrow: 'Dart',
    title: 'Dart：開発は速く、本番も速く',
    mood: GradientMood.calm,
    steps: 2,
    builder: _dart,
  ),
  InteractiveSlideWidget(
    route: '/p-hot-reload',
    eyebrow: 'Hot Reload',
    title: 'Hot Reload：保存したら、もう動いている',
    mood: GradientMood.calm,
    intensity: 0.4,
    builder: (context, step) => const _HotReloadDemo(),
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// 01 — Title. One fragment shader: aurora + liquid glass blobs.
// ─────────────────────────────────────────────────────────────────────────────
class _TitleSlide extends FlutterDeckSlideWidget {
  const _TitleSlide()
    : super(
        configuration: const FlutterDeckSlideConfiguration(
          route: '/p-title',
          title: 'タイトル',
          header: FlutterDeckHeaderConfiguration(showHeader: false),
          footer: FlutterDeckFooterConfiguration(showFooter: false),
        ),
      );

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.custom(builder: (context) => const _TitleBody());
  }
}

class _TitleBody extends StatefulWidget {
  const _TitleBody();

  @override
  State<_TitleBody> createState() => _TitleBodyState();
}

class _TitleBodyState extends State<_TitleBody> {
  double _press = 0;
  double _lastTime = 0;

  void _setUniforms(ui.FragmentShader shader, ShaderFrame frame) {
    final dt = (frame.time - _lastTime).clamp(0.0, 0.1);
    _lastTime = frame.time;
    _press += ((frame.pressed ? 1.0 : 0.0) - _press) * math.min(1, dt * 10);
    final intro = Curves.easeOutBack.transform(
      ((frame.time - 0.4) / 1.6).clamp(0.0, 1.0),
    );
    shader
      ..getUniformVec2('uSize').set(frame.size.width, frame.size.height)
      ..getUniformFloat('uTime').set(frame.time)
      ..getUniformVec2('uMouse').set(frame.pointer.dx, frame.pointer.dy)
      ..getUniformFloat('uGlass').set(intro)
      ..getUniformFloat('uPress').set(_press);
  }

  @override
  Widget build(BuildContext context) {
    return ShaderView(
      asset: ShaderAssets.titleAurora,
      pointerSmoothing: 0.12,
      setUniforms: _setUniforms,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(110, 90, 110, 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('FLUTTER 入門 · 90 MIN', style: DeckText.eyebrow),
                const SizedBox(width: 22),
                const Pill(
                  'void main() => runApp(MyApp());',
                  color: DeckColors.dart,
                  fontSize: 16,
                  mono: true,
                ),
              ],
            ),
            const SizedBox(height: 34),
            const GradientText('はじめての Flutter', style: DeckText.display),
            const SizedBox(height: 10),
            GradientText(
              '― 1つのコードで、すべての画面を描く',
              style: DeckText.display.copyWith(
                fontSize: 68,
                letterSpacing: -1.5,
              ),
              gradient: DeckGradients.flutter,
            ),
            const SizedBox(height: 34),
            Text(
              'Widget・3つのツリー・状態管理から、レンダリング、ネイティブ連携、AI まで。',
              style: DeckText.bodySecondary.copyWith(color: Colors.white70),
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Lucas Goldner', style: DeckText.body),
                const SizedBox(width: 18),
                Container(
                  width: 1.5,
                  height: 26,
                  color: DeckColors.textTertiary,
                ),
                const SizedBox(width: 18),
                Text('YOUTRUST Inc.', style: DeckText.bodySecondary),
                const Spacer(),
                Text(
                  'この背景も Flutter で描いています  ↗',
                  style: DeckText.caption.copyWith(color: Colors.white54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 03 — Two teams, two codebases
// ─────────────────────────────────────────────────────────────────────────────
Widget _twoTeams(BuildContext context, int step) {
  Widget team({
    required String os,
    required Color accent,
    required IconData icon,
    required List<(String, String)> rows,
    required bool visible,
    required int delay,
  }) {
    return StaggerIn(
      visible: visible,
      delayMs: delay,
      child: DeckCard(
        accent: accent,
        padding: const EdgeInsets.all(34),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, color: accent, size: 44),
                const SizedBox(width: 16),
                Text(os, style: DeckText.heading.copyWith(color: accent)),
                const Spacer(),
                Pill('チーム', color: accent, fontSize: 18),
              ],
            ),
            const SizedBox(height: 26),
            for (final (k, v) in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    SizedBox(
                      width: 140,
                      child: Text(
                        k,
                        style: DeckText.caption.copyWith(fontSize: 22),
                      ),
                    ),
                    Text(v, style: DeckText.body.copyWith(fontSize: 28)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  return Column(
    children: [
      Center(
        child: DeckCard(
          accent: DeckColors.text,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 22),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.description_outlined,
                color: DeckColors.text,
                size: 36,
              ),
              const SizedBox(width: 16),
              Text(
                '仕様書：「いいね機能を追加」',
                style: DeckText.heading.copyWith(fontSize: 32),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 10),
      AnimatedOpacity(
        opacity: step >= 2 ? 1 : 0,
        duration: const Duration(milliseconds: 350),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(
              Icons.south_west_rounded,
              color: DeckColors.textTertiary,
              size: 54,
            ),
            Icon(
              Icons.south_east_rounded,
              color: DeckColors.textTertiary,
              size: 54,
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      Expanded(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: team(
                os: 'iOS',
                accent: DeckColors.cyan,
                icon: Icons.phone_iphone_rounded,
                visible: step >= 2,
                delay: 0,
                rows: const [
                  ('言語', 'Swift'),
                  ('UI', 'SwiftUI / UIKit'),
                  ('IDE', 'Xcode'),
                  ('コード', 'iOS 用リポジトリ'),
                ],
              ),
            ),
            const SizedBox(width: 40),
            Expanded(
              child: team(
                os: 'Android',
                accent: DeckColors.green,
                icon: Icons.android_rounded,
                visible: step >= 3,
                delay: 0,
                rows: const [
                  ('言語', 'Kotlin'),
                  ('UI', 'Jetpack Compose'),
                  ('IDE', 'Android Studio'),
                  ('コード', 'Android 用リポジトリ'),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// 04 — 🎮 Feature simulator: the same feature, built twice
// ─────────────────────────────────────────────────────────────────────────────
class _FeatureSimulator extends StatefulWidget {
  const _FeatureSimulator();

  @override
  State<_FeatureSimulator> createState() => _FeatureSimulatorState();
}

class _LaneEvent {
  const _LaneEvent(this.text, this.isBug);
  final String text;
  final bool isBug;
}

class _Lane {
  double progress = 0;
  int? doneDay;
  final events = <_LaneEvent>[];
}

class _FeatureSimulatorState extends State<_FeatureSimulator> {
  static const _features = [
    'いいね機能',
    'ダークモード',
    'プッシュ通知設定',
    '検索フィルター',
    'プロフィール編集',
  ];
  static const _bugs = [
    'ボタンの色が違う',
    '文言が古いまま',
    '日付の書式が違う',
    'エラー時の挙動が違う',
    '並び順が逆',
    '余白が 4px 違う',
  ];

  final _rng = math.Random(7);
  final _ios = _Lane();
  final _android = _Lane();
  Timer? _timer;
  int _day = 0;
  int _featureCount = 0;
  int _manDays = 0;
  int _drift = 0;
  int _releaseGap = 0;
  String? _current;

  bool get _running => _timer != null;

  void _request() {
    if (_running) return;
    setState(() {
      _current = _features[_featureCount % _features.length];
      _featureCount++;
      _day = 0;
      for (final lane in [_ios, _android]) {
        lane
          ..progress = 0
          ..doneDay = null
          ..events.clear();
      }
    });
    // Different teams, different speeds — and the gap is never the same.
    final iosSpeed = 0.022 + _rng.nextDouble() * 0.012;
    final androidSpeed = 0.014 + _rng.nextDouble() * 0.012;
    _timer = Timer.periodic(const Duration(milliseconds: 90), (_) {
      setState(() {
        _day++;
        _step(_ios, iosSpeed);
        _step(_android, androidSpeed);
        if (_ios.doneDay != null && _android.doneDay != null) {
          _timer?.cancel();
          _timer = null;
          _releaseGap = (_ios.doneDay! - _android.doneDay!).abs();
        }
      });
    });
  }

  void _step(_Lane lane, double speed) {
    if (lane.doneDay != null) return;
    _manDays++;
    lane.progress = math.min(1, lane.progress + speed);
    if (_rng.nextDouble() < 0.07 && lane.events.length < 4) {
      final bug = _rng.nextBool();
      lane.events.add(
        _LaneEvent(
          bug ? '🐛 ${_bugs[_rng.nextInt(_bugs.length)]}' : '⚠️ 仕様の解釈がズレた',
          bug,
        ),
      );
      _drift++;
    }
    if (lane.progress >= 1) lane.doneDay = _day;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 13,
          child: DemoFrame(
            accent: DeckColors.orange,
            hint: '「新機能をリクエスト」を押してみて',
            child: ColoredBox(
              color: DeckColors.surface,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(36, 30, 36, 56),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _ActionButton(
                          label: _running ? '開発中…' : '＋ 新機能をリクエスト',
                          color: DeckColors.orange,
                          onTap: _running ? null : _request,
                        ),
                        const SizedBox(width: 24),
                        if (_current != null)
                          Text(
                            '仕様：$_current',
                            style: DeckText.heading.copyWith(fontSize: 30),
                          ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Expanded(
                      child: _LaneView(
                        name: 'iOS チーム',
                        accent: DeckColors.cyan,
                        lane: _ios,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: _LaneView(
                        name: 'Android チーム',
                        accent: DeckColors.green,
                        lane: _android,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 40),
        Expanded(
          flex: 5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Stat(
                label: '依頼した機能',
                value: '$_featureCount',
                unit: '個',
                color: DeckColors.text,
              ),
              _Stat(
                label: '実装した回数',
                value: '${_featureCount * 2}',
                unit: '回',
                color: DeckColors.red,
              ),
              _Stat(
                label: '工数（人日）',
                value: '$_manDays',
                unit: '日',
                color: DeckColors.orange,
              ),
              _Stat(
                label: 'ズレ・バグ',
                value: '$_drift',
                unit: '件',
                color: DeckColors.pink,
              ),
              _Stat(
                label: 'リリース日のズレ',
                value: '+$_releaseGap',
                unit: '日',
                color: DeckColors.purple,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LaneView extends StatelessWidget {
  const _LaneView({
    required this.name,
    required this.accent,
    required this.lane,
  });

  final String name;
  final Color accent;
  final _Lane lane;

  @override
  Widget build(BuildContext context) {
    return DeckCard(
      accent: accent,
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                name,
                style: DeckText.heading.copyWith(fontSize: 28, color: accent),
              ),
              const Spacer(),
              Text(
                lane.doneDay != null
                    ? '✅ リリース（${lane.doneDay}日目）'
                    : '${(lane.progress * 100).round()}%',
                style: DeckText.body.copyWith(fontSize: 24),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: lane.progress,
              minHeight: 18,
              color: accent,
              backgroundColor: Colors.white10,
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Wrap(
              spacing: 12,
              runSpacing: 10,
              children: [
                for (final e in lane.events)
                  Pill(
                    e.text,
                    color: e.isBug ? DeckColors.red : DeckColors.orange,
                    fontSize: 18,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  final String label;
  final String value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DeckCard(
      accent: color,
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(label, style: DeckText.caption.copyWith(fontSize: 22)),
          ),
          Text(
            value,
            style: DeckText.title.copyWith(
              fontSize: 50,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(width: 6),
          Text(unit, style: DeckText.body.copyWith(fontSize: 22, color: color)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.color, this.onTap});

  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: enabled ? 0.9 : 0.25),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            label,
            style: DeckText.body.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: enabled ? DeckColors.canvas : DeckColors.textSecondary,
              height: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 05 — 🎮 Spot the difference: iOS 版 vs Android 版
// ─────────────────────────────────────────────────────────────────────────────
class _SpotTheDifferenceSlide extends FlutterDeckSlideWidget {
  const _SpotTheDifferenceSlide()
    : super(
        configuration: const FlutterDeckSlideConfiguration(
          route: '/p-spot-the-difference',
          title: '間違い探し',
          header: FlutterDeckHeaderConfiguration(showHeader: false),
          steps: 2,
        ),
      );

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.custom(
      builder: (context) => FlutterDeckSlideStepsBuilder(
        builder: (context, step) => DeckSlide(
          eyebrow: 'Spot the difference',
          title: '間違い探し：同じ仕様、2つの実装',
          mood: GradientMood.violet,
          intensity: 0.45,
          child: _SpotTheDifference(revealAll: step >= 2),
        ),
      ),
    );
  }
}

class _SpotTheDifference extends StatefulWidget {
  const _SpotTheDifference({required this.revealAll});

  final bool revealAll;

  @override
  State<_SpotTheDifference> createState() => _SpotTheDifferenceState();
}

class _SpotTheDifferenceState extends State<_SpotTheDifference> {
  static const _total = 5;
  static const _labels = ['タイトルの文言', '検索バーの有無', '日付の書式', 'アイコンの種類', 'ボタンの色'];

  final _found = <int>{};

  bool _shown(int id) => widget.revealAll || _found.contains(id);

  void _tap(int id) => setState(() => _found.add(id));

  @override
  Widget build(BuildContext context) {
    final count = widget.revealAll ? _total : _found.length;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _EventsScreen(isIos: true, shown: _shown, onTap: _tap),
        const SizedBox(width: 50),
        _EventsScreen(isIos: false, shown: _shown, onTap: _tap),
        const SizedBox(width: 70),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Pill('🖱 違いをクリック', color: DeckColors.pink, fontSize: 18),
              const SizedBox(height: 22),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GradientText(
                    '$count',
                    style: DeckText.display.copyWith(fontSize: 140, height: 1),
                    gradient: DeckGradients.hero,
                  ),
                  Text(
                    ' / $_total',
                    style: DeckText.title.copyWith(
                      color: DeckColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              for (var i = 0; i < _total; i++)
                AnimatedOpacity(
                  opacity: _shown(i) ? 1 : 0.18,
                  duration: const Duration(milliseconds: 300),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      '${_shown(i) ? '✔' : '・'}  ${_labels[i]}',
                      style: DeckText.body.copyWith(fontSize: 26),
                    ),
                  ),
                ),
              const SizedBox(height: 26),
              StaggerIn(
                visible: widget.revealAll || _found.length == _total,
                child: const GradientText(
                  '2つのコードベースは、\n必ずズレる。',
                  style: DeckText.heading,
                  gradient: DeckGradients.warm,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EventsScreen extends StatelessWidget {
  const _EventsScreen({
    required this.isIos,
    required this.shown,
    required this.onTap,
  });

  final bool isIos;
  final bool Function(int id) shown;
  final void Function(int id) onTap;

  Widget _target(int id, Widget child) =>
      _DiffTarget(found: shown(id), onTap: () => onTap(id), child: child);

  @override
  Widget build(BuildContext context) {
    const events = [
      ('Flutter Tokyo #12', 'オンライン', 12, 5),
      ('FlutterKaigi 2026', '東京', 11, 19),
      ('Dart もくもく会', '渋谷', 12, 14),
    ];
    final accent = isIos ? const Color(0xFF0A84FF) : const Color(0xFF3D5AFE);
    return PhoneFrame(
      width: 330,
      style: isIos ? PhoneStyle.ios : PhoneStyle.android,
      accent: isIos ? DeckColors.cyan : DeckColors.green,
      label: isIos ? 'iOS 版（Swift）' : 'Android 版（Kotlin）',
      child: Material(
        color: const Color(0xFFF6F6F8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _target(
                0,
                Text(
                  isIos ? 'イベント一覧' : 'イベント',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _target(
                1,
                isIos
                    ? Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6E6EA),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.search, size: 18, color: Colors.black45),
                            SizedBox(width: 6),
                            Text(
                              '検索',
                              style: TextStyle(
                                color: Colors.black45,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(height: 38, width: double.infinity),
              ),
              const SizedBox(height: 14),
              for (var i = 0; i < events.length; i++)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              events[i].$1,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            i == 0
                                ? _target(2, _date(events[i]))
                                : _date(events[i]),
                          ],
                        ),
                      ),
                      i == 0 ? _target(3, _icon()) : _icon(),
                    ],
                  ),
                ),
              const Spacer(),
              _target(
                4,
                Container(
                  width: double.infinity,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(isIos ? 14 : 24),
                  ),
                  child: const Text(
                    '参加する',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 26),
            ],
          ),
        ),
      ),
    );
  }

  Widget _date((String, String, int, int) e) => Text(
    isIos ? '${e.$3}月${e.$4}日 ・ ${e.$2}' : '${e.$3}/${e.$4} ・ ${e.$2}',
    style: const TextStyle(fontSize: 13, color: Colors.black54),
  );

  Widget _icon() => Icon(
    isIos ? Icons.favorite_border : Icons.star_border,
    color: Colors.black45,
    size: 22,
  );
}

class _DiffTarget extends StatelessWidget {
  const _DiffTarget({
    required this.found,
    required this.onTap,
    required this.child,
  });

  final bool found;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: found ? DeckColors.pink : Colors.transparent,
              width: 3,
            ),
            color: found
                ? DeckColors.pink.withValues(alpha: 0.12)
                : Colors.transparent,
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 07 — Cross-platform options
// ─────────────────────────────────────────────────────────────────────────────
const _optionRows = [
  (
    'WebView 系',
    'Cordova / Capacitor',
    'HTML / CSS / JS',
    'WebView（ブラウザ）が描く',
    DeckColors.orange,
  ),
  (
    'React Native',
    'Meta',
    'JavaScript / TypeScript',
    '各 OS のネイティブ UI 部品を呼ぶ',
    DeckColors.cyan,
  ),
  (
    'Kotlin Multiplatform',
    'JetBrains',
    'Kotlin',
    'ロジックを共有（UI は各 OS か Compose MP）',
    DeckColors.purple,
  ),
  ('Flutter', 'Google', 'Dart', '自前のエンジンで全ピクセルを描く', DeckColors.dart),
];

Widget _options(BuildContext context, int step) {
  Widget cell(String text, {double flex = 1, TextStyle? style}) => Expanded(
    flex: (flex * 10).round(),
    child: Text(text, style: style ?? DeckText.body.copyWith(fontSize: 26)),
  );

  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
        child: Row(
          children: [
            cell('名前', flex: 1.3, style: DeckText.eyebrow),
            cell('言語', style: DeckText.eyebrow),
            cell('誰が画面を描く？', flex: 1.8, style: DeckText.eyebrow),
          ],
        ),
      ),
      const SizedBox(height: 10),
      for (var i = 0; i < _optionRows.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: StaggerIn(
            visible: step > i,
            child: DeckCard(
              accent: _optionRows[i].$5,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 22),
              child: Row(
                children: [
                  Expanded(
                    flex: 13,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _optionRows[i].$1,
                          style: DeckText.heading.copyWith(
                            fontSize: 32,
                            color: _optionRows[i].$5,
                          ),
                        ),
                        Text(_optionRows[i].$2, style: DeckText.caption),
                      ],
                    ),
                  ),
                  cell(_optionRows[i].$3),
                  cell(
                    _optionRows[i].$4,
                    flex: 1.8,
                    style: DeckText.body.copyWith(
                      fontSize: 26,
                      fontWeight: i == 3 ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// 09 — Flutter とは
// ─────────────────────────────────────────────────────────────────────────────
Widget _whatIsFlutter(BuildContext context, int step) {
  const facts = [
    ('UI ツールキット', 'Google 製・オープンソース', Icons.widgets_rounded, DeckColors.dart),
    ('言語は Dart', 'UI もロジックも同じ言語', Icons.code_rounded, DeckColors.blue),
    (
      '6 プラットフォーム',
      'iOS / Android / Web / macOS / Windows / Linux',
      Icons.devices_rounded,
      DeckColors.purple,
    ),
    ('自前で描画', 'OS の UI 部品に頼らず全ピクセルを描く', Icons.brush_rounded, DeckColors.pink),
  ];
  return Row(
    children: [
      Expanded(
        flex: 4,
        child: Center(
          child: ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (b) => DeckGradients.flutter.createShader(b),
            child: const FlutterLogo(
              size: 340,
              style: FlutterLogoStyle.markOnly,
            ),
          ),
        ),
      ),
      const SizedBox(width: 40),
      Expanded(
        flex: 7,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < facts.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: StaggerIn(
                  visible: step > i,
                  child: DeckCard(
                    accent: facts[i].$4,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 22,
                    ),
                    child: Row(
                      children: [
                        Icon(facts[i].$3, color: facts[i].$4, size: 44),
                        const SizedBox(width: 26),
                        SizedBox(
                          width: 330,
                          child: Text(
                            facts[i].$1,
                            style: DeckText.heading.copyWith(
                              fontSize: 32,
                              color: facts[i].$4,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            facts[i].$2,
                            style: DeckText.bodySecondary.copyWith(
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// 10 — History timeline
// ─────────────────────────────────────────────────────────────────────────────
const _history = [
  ('2015', '"Sky"', 'Dart Developer Summit で\n初公開', DeckColors.textSecondary),
  ('2017', 'Alpha', '最初の公開アルファ', DeckColors.cyan),
  ('2018.12', 'Flutter 1.0', 'iOS / Android で\n正式リリース', DeckColors.dart),
  ('2021', 'Flutter 2', 'Web が stable\nNull Safety', DeckColors.blue),
  ('2022', 'Flutter 3', 'Desktop 全 OS が\nstable に', DeckColors.purple),
  ('2023–24', 'Impeller', 'iOS → Android で\n新レンダラーが標準に', DeckColors.pink),
  ('2025', 'GenUI', 'AI が UI を組み立てる\nGenUI SDK・A2UI', DeckColors.orange),
  ('2026', 'いま', 'Flutter 3.50\nそして今日', DeckColors.green),
];

Widget _historyTimeline(BuildContext context, int step) {
  return LayoutBuilder(
    builder: (context, c) {
      final n = _history.length;
      final w = c.maxWidth / n;
      return Stack(
        children: [
          // Track.
          Positioned(
            left: w / 2,
            right: w / 2,
            top: c.maxHeight * 0.48,
            child: Container(height: 4, color: Colors.white12),
          ),
          Positioned(
            left: w / 2,
            top: c.maxHeight * 0.48,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              width: math.max(0, (step - 1) * w),
              height: 4,
              decoration: const BoxDecoration(gradient: DeckGradients.hero),
            ),
          ),
          for (var i = 0; i < n; i++)
            Positioned(
              left: i * w,
              width: w,
              top: 0,
              bottom: 0,
              child: AnimatedOpacity(
                opacity: step > i ? 1 : 0.12,
                duration: const Duration(milliseconds: 350),
                child: Column(
                  children: [
                    SizedBox(
                      height: c.maxHeight * 0.48 - 70,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            _history[i].$1,
                            style: DeckText.heading.copyWith(
                              fontSize: 30,
                              color: _history[i].$4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _history[i].$2,
                            textAlign: TextAlign.center,
                            style: DeckText.heading.copyWith(fontSize: 28),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 52),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: DeckColors.canvas,
                        shape: BoxShape.circle,
                        border: Border.all(color: _history[i].$4, width: 5),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        _history[i].$3,
                        textAlign: TextAlign.center,
                        style: DeckText.caption.copyWith(
                          fontSize: 20,
                          color: DeckColors.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    },
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// 11 — Dart: JIT for development, AOT for release
// ─────────────────────────────────────────────────────────────────────────────
const _dartCode = '''
void main() {
  final speakers = ['Lucas', 'Dash'];

  for (final name in speakers) {
    print('こんにちは、\$name！');
  }
}

// null safety：String? は null かも
String greet(String? name) =>
    'Hello, \${name ?? 'Flutter'}';

// async / await も素直に書ける
Future<User> load() async {
  final json = await api.get('/me');
  return User.fromJson(json);
}''';

Widget _dart(BuildContext context, int step) {
  return SplitContent(
    leftFlex: 6,
    rightFlex: 5,
    left: CodePanel(
      _dartCode,
      language: 'dart',
      fileName: 'main.dart',
      accent: DeckColors.dart,
      fontSize: 21,
    ),
    right: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StaggerIn(
          visible: step >= 1,
          child: const TitledCard(
            badge: '開発中 · JIT',
            title: 'Just-In-Time',
            accent: DeckColors.cyan,
            lines: ['実行しながらコンパイル', '→ Hot Reload で 1 秒以内に反映'],
          ),
        ),
        const SizedBox(height: 28),
        StaggerIn(
          visible: step >= 2,
          child: const TitledCard(
            badge: '本番 · AOT',
            title: 'Ahead-Of-Time',
            accent: DeckColors.pink,
            lines: ['事前に ARM / x64 の機械語へ', '→ 起動が速く、動作もネイティブ並み'],
          ),
        ),
        const SizedBox(height: 28),
        Text(
          '型安全・Null Safety・async/await。Java や TypeScript を書ける人ならすぐ読める。',
          style: DeckText.caption.copyWith(fontSize: 21),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// 12 — 🎮 Hot Reload demo
// ─────────────────────────────────────────────────────────────────────────────
class _HotReloadDemo extends StatefulWidget {
  const _HotReloadDemo();

  @override
  State<_HotReloadDemo> createState() => _HotReloadDemoState();
}

class _HotReloadDemoState extends State<_HotReloadDemo> {
  static const _colors = [
    ('Colors.blue', Color(0xFF2196F3)),
    ('Colors.pink', Color(0xFFE91E63)),
    ('Colors.green', Color(0xFF43A047)),
    ('Colors.deepPurple', Color(0xFF673AB7)),
  ];
  static const _titles = ['カウンター', 'いいね数', 'Flutter Tokyo'];
  static const _icons = [
    ('Icons.add', Icons.add),
    ('Icons.favorite', Icons.favorite),
    ('Icons.rocket_launch', Icons.rocket_launch),
  ];

  int _color = 0;
  int _title = 0;
  int _icon = 0;
  int _counter = 0;

  // Flash banner: (text, color, key) — key restarts the animation.
  String _flash = '';
  Color _flashColor = DeckColors.orange;
  int _flashKey = 0;

  void _hotReload(VoidCallback change) {
    setState(() {
      change();
      _flash = '⚡ Hot Reload  0.3s ・ 状態はそのまま';
      _flashColor = DeckColors.orange;
      _flashKey++;
    });
  }

  void _restart() {
    setState(() {
      _counter = 0;
      _flash = '🔄 Hot Restart ・ 状態がリセット';
      _flashColor = DeckColors.purple;
      _flashKey++;
    });
  }

  String get _code =>
      '''
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ${_colors[_color].$1},
        title: Text('${_titles[_title]}'),
      ),
      body: Center(child: Text('\$count')),
      floatingActionButton: FloatingActionButton(
        onPressed: increment,
        child: Icon(${_icons[_icon].$1}),
      ),
    );
  }
}''';

  @override
  Widget build(BuildContext context) {
    final color = _colors[_color].$2;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 11,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: CodePanel(
                  _code,
                  language: 'dart',
                  fileName: 'my_home_page.dart',
                  accent: DeckColors.dart,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 22),
              _ChoiceRow(
                label: '色',
                options: [
                  for (final c in _colors) c.$1.replaceFirst('Colors.', ''),
                ],
                selected: _color,
                onSelect: (i) => _hotReload(() => _color = i),
              ),
              const SizedBox(height: 12),
              _ChoiceRow(
                label: 'タイトル',
                options: _titles,
                selected: _title,
                onSelect: (i) => _hotReload(() => _title = i),
              ),
              const SizedBox(height: 12),
              _ChoiceRow(
                label: 'アイコン',
                options: [
                  for (final c in _icons) c.$1.replaceFirst('Icons.', ''),
                ],
                selected: _icon,
                onSelect: (i) => _hotReload(() => _icon = i),
              ),
            ],
          ),
        ),
        const SizedBox(width: 50),
        SizedBox(
          width: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PhoneFrame(
                width: 300,
                accent: color,
                child: Scaffold(
                  backgroundColor: Colors.white,
                  appBar: AppBar(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    title: Text(_titles[_title]),
                  ),
                  body: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'ボタンを押した回数',
                          style: TextStyle(color: Colors.black54, fontSize: 16),
                        ),
                        Text(
                          '$_counter',
                          style: const TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  floatingActionButton: FloatingActionButton(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    onPressed: () => setState(() => _counter++),
                    child: Icon(_icons[_icon].$2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 46,
                child: _flash.isEmpty
                    ? Text(
                        '① ＋ で数を増やす → ② 左でコードを変える',
                        style: DeckText.caption.copyWith(fontSize: 19),
                      )
                    : TweenAnimationBuilder<double>(
                        key: ValueKey(_flashKey),
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 600),
                        builder: (context, t, child) => Opacity(
                          opacity: t,
                          child: Transform.scale(
                            scale: 0.9 + 0.1 * t,
                            child: child,
                          ),
                        ),
                        child: Pill(_flash, color: _flashColor, fontSize: 20),
                      ),
              ),
              const SizedBox(height: 8),
              _ActionButton(
                label: '🔄 Hot Restart',
                color: DeckColors.purple,
                onTap: _restart,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final String label;
  final List<String> options;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: DeckText.caption.copyWith(fontSize: 21)),
        ),
        for (var i = 0; i < options.length; i++)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => onSelect(i),
                child: Pill(
                  options[i],
                  color: i == selected
                      ? DeckColors.dart
                      : DeckColors.textTertiary,
                  filled: i == selected,
                  fontSize: 18,
                  mono: true,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
