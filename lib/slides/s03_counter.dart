import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';
import 'package:flutter_intro_talk/core/theme/kaigi_theme.dart';
import 'package:flutter_intro_talk/core/widgets/code_panel.dart';
import 'package:flutter_intro_talk/core/widgets/deck_components.dart';
import 'package:flutter_intro_talk/core/widgets/deck_scaffold.dart';
import 'package:flutter_intro_talk/core/widgets/demo_frame.dart';
import 'package:flutter_intro_talk/core/widgets/motion.dart';
import 'package:flutter_intro_talk/core/widgets/phone_frame.dart';
import 'package:flutter_intro_talk/core/widgets/templates.dart';
import 'package:flutter_intro_talk/core/widgets/wwdc_background.dart';
import 'package:flutter_intro_talk/slides/s03_shared.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 02 · カウンターアプリで学ぶ — the `flutter create` template, live, and a
// line-by-line walk through it.
// ─────────────────────────────────────────────────────────────────────────────

final List<FlutterDeckSlideWidget> counterSlides = [
  DividerSlideWidget(
    route: '/c-divider',
    number: '02',
    label: 'Counter App',
    title: 'カウンターアプリで学ぶ',
    subtitle: 'flutter create が最初にくれる、66行のアプリ',
    accent: DeckColors.dart,
  ),
  InteractiveSlideWidget(
    route: '/c-create',
    eyebrow: 'flutter create',
    title: 'コマンド1つで、6プラットフォーム分',
    footnote: '書くのは lib/ の Dart だけ。各 OS のフォルダは「入れ物」です。',
    builder: _createBody,
    steps: 2,
  ),
  const _CounterAppSlide(),
  InteractiveSlideWidget(
    route: '/c-walk-main',
    eyebrow: 'Code walk 1/3',
    title: 'main() → runApp() → MaterialApp',
    builder: _walkMain,
    steps: 3,
    mood: GradientMood.calm,
    intensity: 0.4,
  ),
  InteractiveSlideWidget(
    route: '/c-walk-stateful',
    eyebrow: 'Code walk 2/3',
    title: 'StatefulWidget と State',
    builder: _walkStateful,
    steps: 3,
    mood: GradientMood.calm,
    intensity: 0.4,
  ),
  InteractiveSlideWidget(
    route: '/c-walk-setstate',
    eyebrow: 'Code walk 3/3',
    title: 'setState() と build()',
    builder: _walkSetState,
    steps: 3,
    mood: GradientMood.calm,
    intensity: 0.4,
  ),
  QuizSlideWidget(
    route: '/c-quiz',
    question: 'setState を呼ばずに _counter++ だけしたら？',
    options: const ['表示もちゃんと増える', '値は増えるが、表示は変わらない', 'クラッシュする'],
    answer: 1,
    explanation: 'setState は「再ビルドしてね」という合図。値を変えるだけでは画面は描き直されない。',
  ),
  InteractiveSlideWidget(
    route: '/c-setstate-demo',
    eyebrow: 'Try it',
    title: 'setState を外すと、何が起きる？',
    footnote: 'setState = 値の変更 ＋「このWidgetを次のフレームで作り直して」のお願い。',
    builder: _setStateDemo,
    mood: GradientMood.warm,
    intensity: 0.4,
  ),
];

// ── /c-create ───────────────────────────────────────────────────────────────

Widget _createBody(BuildContext context, int step) {
  return SplitContent(
    leftFlex: 5,
    rightFlex: 5,
    left: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CodePanel(
          r'''
$ flutter create my_app
Creating project my_app...
Wrote 130 files.

All done!
$ cd my_app
$ flutter run''',
          language: 'bash',
          fileName: 'Terminal',
          fontSize: 24,
          accent: DeckColors.textSecondary,
        ),
        const SizedBox(height: 28),
        StaggerIn(
          visible: step >= 2,
          child: const Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              Pill('iOS', color: DeckColors.text),
              Pill('Android', color: DeckColors.green),
              Pill('Web', color: DeckColors.cyan),
              Pill('macOS', color: DeckColors.purple),
              Pill('Windows', color: DeckColors.blue),
              Pill('Linux', color: DeckColors.orange),
            ],
          ),
        ),
      ],
    ),
    right: DeckCard(
      accent: DeckColors.dart,
      padding: const EdgeInsets.fromLTRB(34, 28, 34, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('my_app/', style: DeckText.mono.copyWith(fontSize: 26)),
          const SizedBox(height: 14),
          for (final (name, note, hot) in const [
            ('lib/main.dart', 'アプリのコード（ここだけ書く）', true),
            ('pubspec.yaml', 'パッケージ・アセットの設定', true),
            ('test/', 'テスト', false),
            ('android/  ios/', 'ネイティブのプロジェクト', false),
            ('web/  macos/  windows/  linux/', '各プラットフォームの入れ物', false),
          ])
            Padding(
              padding: const EdgeInsets.only(left: 22, bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    name.endsWith('/') || name.contains('  ')
                        ? Icons.folder_rounded
                        : Icons.description_rounded,
                    color: hot ? DeckColors.dart : DeckColors.textTertiary,
                    size: 28,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: DeckText.mono.copyWith(
                            fontSize: 22,
                            color: hot
                                ? DeckColors.text
                                : DeckColors.textSecondary,
                          ),
                        ),
                        Text(
                          note,
                          style: DeckText.caption.copyWith(fontSize: 19),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}

// ── /c-app — the full template next to the real thing ───────────────────────

class _CounterAppSlide extends FlutterDeckSlideWidget {
  const _CounterAppSlide()
    : super(
        configuration: const FlutterDeckSlideConfiguration(
          route: '/c-app',
          title: 'カウンターアプリ（全コード）',
          header: FlutterDeckHeaderConfiguration(showHeader: false),
        ),
      );

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.custom(
      builder: (context) => Stack(
        fit: StackFit.expand,
        children: [
          const WwdcBackground(mood: GradientMood.calm, intensity: 0.4),
          Padding(
            padding: const EdgeInsets.fromLTRB(72, 48, 72, 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const GradientText('これが全部です。', style: DeckText.title),
                    const SizedBox(width: 28),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        'lib/main.dart ・ 66行',
                        style: DeckText.bodySecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CodePanel(
                          templateLines(1, 32),
                          language: 'dart',
                          fileName: 'lib/main.dart  (1–32)',
                          fontSize: 14.5,
                          accent: DeckColors.dart,
                        ),
                      ),
                      const SizedBox(width: 22),
                      Expanded(
                        child: CodePanel(
                          templateLines(34, 66),
                          language: 'dart',
                          fileName: 'lib/main.dart  (34–66)',
                          fontSize: 14.5,
                          accent: DeckColors.dart,
                        ),
                      ),
                      const SizedBox(width: 40),
                      SizedBox(
                        width: 360,
                        child: Column(
                          children: [
                            Expanded(
                              child: DemoFrame(
                                accent: DeckColors.dart,
                                hint: '＋ をタップしてみて',
                                child: Center(
                                  child: FittedBox(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: PhoneFrame(
                                        width: 320,
                                        child: const CounterAppMock(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Code walks ──────────────────────────────────────────────────────────────

Widget _walk({
  required int step,
  required int from,
  required int to,
  required List<List<(int, int)>> focus,
  required List<String> points,
  Widget? extra,
  double fontSize = 19,
}) {
  return SplitContent(
    leftFlex: 4,
    rightFlex: 6,
    left: ScaleDownToFit(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BulletList(
            items: points,
            accent: DeckColors.dart,
            fontSize: 28,
            visibleCount: step,
          ),
          if (extra != null) ...[const SizedBox(height: 40), extra],
        ],
      ),
    ),
    right: FocusCodePanel(
      code: templateLines(from, to),
      firstLine: from,
      focus: focus[(step - 1).clamp(0, focus.length - 1)],
      fontSize: fontSize,
    ),
  );
}

Widget _walkMain(BuildContext context, int step) => _walk(
  step: step,
  from: 1,
  to: 20,
  focus: const [
    [(3, 5)],
    [(7, 11)],
    [(12, 18)],
  ],
  points: const [
    'main() から始まる。runApp() に「ルートの Widget」を渡すだけ',
    'MyApp は StatelessWidget ── 状態を持たない部品',
    'MaterialApp がテーマ・画面遷移・言語設定をまとめて用意',
  ],
);

Widget _walkStateful(BuildContext context, int step) => _walk(
  step: step,
  from: 22,
  to: 38,
  focus: const [
    [(22, 29)],
    [(31, 32)],
    [(34, 38)],
  ],
  points: const [
    'MyHomePage は StatefulWidget。Widget 自体は不変（final）',
    '変わる値は State クラスへ。_counter はここに住む',
    '_incrementCounter() で値を変えて、setState で知らせる',
  ],
);

Widget _walkSetState(BuildContext context, int step) => _walk(
  step: step,
  from: 34,
  to: 64,
  focus: const [
    [(34, 38)],
    [(40, 58)],
    [(52, 55), (59, 63)],
  ],
  fontSize: 15.5,
  points: const [
    'setState(() { … }) ＝ 値を変えて「作り直して」と頼む',
    'build() は「今の状態なら、画面はこう」を返すだけ',
    'ボタンを押す → setState → build() → 新しい数字',
  ],
  extra: StaggerIn(
    visible: step >= 3,
    child: const CalloutBox(
      label: 'UI = f(state)',
      isProblem: false,
      lines: ['画面は「状態の関数」。', '手で書き換えない、作り直す。'],
    ),
  ),
);

// ── /c-setstate-demo ────────────────────────────────────────────────────────

Widget _setStateDemo(BuildContext context, int step) => const _SetStateDemo();

class _SetStateDemo extends StatefulWidget {
  const _SetStateDemo();

  @override
  State<_SetStateDemo> createState() => _SetStateDemoState();
}

class _SetStateDemoState extends State<_SetStateDemo> {
  bool _useSetState = false;

  /// The "real" value inside the State, mirrored for the side panel.
  final _internal = ValueNotifier<int>(0);

  /// The value the phone's last build() actually put on screen.
  final _shown = ValueNotifier<int>(0);

  /// Bumped to force the phone to rebuild (simulates "something else
  /// triggered a frame").
  int _parentBuilds = 0;

  @override
  void dispose() {
    _internal.dispose();
    _shown.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DeckCard(
                accent: _useSetState ? DeckColors.green : DeckColors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 18,
                ),
                child: Row(
                  children: [
                    Text(
                      'setState を使う',
                      style: DeckText.heading.copyWith(fontSize: 34),
                    ),
                    const Spacer(),
                    Transform.scale(
                      scale: 1.5,
                      child: Switch(
                        value: _useSetState,
                        activeTrackColor: DeckColors.green,
                        onChanged: (v) => setState(() => _useSetState = v),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              CodePanel(
                _useSetState
                    ? '''
void _incrementCounter() {
  setState(() {
    _counter++;
  });
}'''
                    : '''
void _incrementCounter() {
  _counter++; // setState なし
}''',
                language: 'dart',
                fileName: '_MyHomePageState',
                fontSize: 24,
                accent: _useSetState ? DeckColors.green : DeckColors.red,
              ),
              const SizedBox(height: 22),
              ListenableBuilder(
                listenable: Listenable.merge([_internal, _shown]),
                builder: (context, _) {
                  final diverged = _internal.value != _shown.value;
                  return Row(
                    children: [
                      Expanded(
                        child: _ValueTile(
                          label: 'State の中の値（_counter）',
                          value: '${_internal.value}',
                          color: DeckColors.cyan,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _ValueTile(
                          label: '画面の表示（最後の build）',
                          value: '${_shown.value}',
                          color: diverged ? DeckColors.red : DeckColors.green,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => setState(() => _parentBuilds++),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('外から再ビルドを起こす'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: DeckColors.orange,
                  side: const BorderSide(color: DeckColors.orange, width: 1.5),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26,
                    vertical: 20,
                  ),
                  textStyle: DeckText.body.copyWith(fontSize: 24),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 60),
        SizedBox(
          width: 400,
          child: DemoFrame(
            accent: _useSetState ? DeckColors.green : DeckColors.red,
            hint: '＋ を何回か押してみて',
            child: Center(
              child: FittedBox(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(40, 70, 40, 70),
                  child: PhoneFrame(
                    width: 320,
                    child: _LazyCounter(
                      // A new config each parent rebuild → State.build runs.
                      generation: _parentBuilds,
                      useSetState: _useSetState,
                      internal: _internal,
                      shown: _shown,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A counter whose State really does skip setState when told to.
class _LazyCounter extends StatefulWidget {
  const _LazyCounter({
    required this.generation,
    required this.useSetState,
    required this.internal,
    required this.shown,
  });

  final int generation;
  final bool useSetState;
  final ValueNotifier<int> internal;
  final ValueNotifier<int> shown;

  @override
  State<_LazyCounter> createState() => _LazyCounterState();
}

class _LazyCounterState extends State<_LazyCounter> {
  int _counter = 0;

  void _increment() {
    if (widget.useSetState) {
      setState(() => _counter++);
    } else {
      _counter++; // ← no rebuild is scheduled
    }
    widget.internal.value = _counter;
  }

  @override
  Widget build(BuildContext context) {
    final built = _counter;
    // Report what this build put on screen — after the frame, never during.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.shown.value = built;
    });
    return CounterAppMock(value: built, onPressed: _increment);
  }
}

class _ValueTile extends StatelessWidget {
  const _ValueTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DeckCard(
      accent: color,
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: DeckText.caption),
          const SizedBox(height: 6),
          Text(
            value,
            style: DeckText.title.copyWith(
              fontSize: 56,
              color: color,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
