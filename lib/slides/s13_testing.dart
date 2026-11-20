import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_deck/flutter_deck.dart';
import 'package:flutter_intro_talk/core/theme/kaigi_theme.dart';
import 'package:flutter_intro_talk/core/widgets/deck_components.dart';
import 'package:flutter_intro_talk/core/widgets/demo_frame.dart';
import 'package:flutter_intro_talk/core/widgets/phone_frame.dart';
import 'package:flutter_intro_talk/core/widgets/templates.dart';
import 'package:flutter_intro_talk/core/widgets/wwdc_background.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 09 · テスト
// ─────────────────────────────────────────────────────────────────────────────
final List<FlutterDeckSlideWidget> testingSlides = [
  DividerSlideWidget(
    route: '/q-divider',
    number: '09',
    label: 'Testing',
    title: 'テスト',
    subtitle: 'Flutter はテストが「標準装備」。',
    mood: GradientMood.cool,
    accent: DeckColors.green,
  ),
  InteractiveSlideWidget(
    route: '/q-pyramid',
    eyebrow: 'Test pyramid',
    title: '4種類のテスト',
    footnote: 'ぜんぶ flutter_test の同じ API で書ける。',
    mood: GradientMood.cool,
    builder: _pyramid,
  ),
  CodeSlideWidget(
    route: '/q-unit',
    eyebrow: 'Unit test',
    title: 'Unit テスト：ロジックだけを確かめる',
    fileName: 'test/event_list_test.dart',
    fontSize: 19,
    points: const ['Widget もエミュレータも不要', 'Repository を Fake に差し替える', 'ミリ秒で終わる'],
    code: '''
class FakeEventRepository implements EventRepository {
  @override
  Future<List<Event>> fetchEvents() async =>
      [Event(id: '1', title: 'Flutter Tokyo #1')];
}

void main() {
  test('イベントを読み込める', () async {
    final container = ProviderContainer(overrides: [
      eventRepositoryProvider
          .overrideWithValue(FakeEventRepository()),
    ]);
    addTearDown(container.dispose);

    final events =
        await container.read(eventListProvider.future);

    expect(events, hasLength(1));
    expect(events.first.title, 'Flutter Tokyo #1');
  });
}
''',
  ),
  CodeSlideWidget(
    route: '/q-widget',
    eyebrow: 'Widget test',
    title: 'Widget テスト：画面を「操作」して確かめる',
    fileName: 'test/widget_test.dart',
    fontSize: 21,
    points: const [
      'flutter create に最初から入っている',
      '端末なしで、画面を本当に描画',
      'find → tap → pump → expect',
    ],
    code: '''
testWidgets('Counter increments smoke test',
    (WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());

  expect(find.text('0'), findsOneWidget);
  expect(find.text('1'), findsNothing);

  await tester.tap(find.byIcon(Icons.add));
  await tester.pump();

  expect(find.text('0'), findsNothing);
  expect(find.text('1'), findsOneWidget);
});
''',
  ),
  InteractiveSlideWidget(
    route: '/q-runner',
    eyebrow: 'Widget test · demo',
    title: 'テストの1行ずつを、目で見る',
    footnote: 'tester が「指」になる。pump() で1フレーム進める。',
    mood: GradientMood.calm,
    builder: _runner,
  ),
  CodeSlideWidget(
    route: '/q-golden',
    eyebrow: 'Golden test',
    title: 'Golden テスト：見た目をまるごと比較',
    fileName: 'test/profile_card_golden_test.dart',
    fontSize: 21,
    points: const ['画像を「正解」として保存', '1ピクセルでも違えば失敗', '更新は --update-goldens'],
    footnote: 'フォントの描画は OS で微妙に違う → CI では同じ OS で回すのが鉄則。',
    code: '''
testWidgets('ProfileCard のゴールデン', (tester) async {
  await tester.pumpWidget(
    const MaterialApp(home: ProfileCard(name: 'Dash')),
  );

  await expectLater(
    find.byType(ProfileCard),
    matchesGoldenFile('goldens/profile_card.png'),
  );
});

// 正解画像を作る・更新する
// \$ flutter test --update-goldens
''',
  ),
  InteractiveSlideWidget(
    route: '/q-golden-diff',
    eyebrow: 'Golden test · demo',
    title: '「どこが変わった？」を一瞬で',
    footnote: 'デザインの意図しない変化を、レビューより先にテストが見つける。',
    mood: GradientMood.violet,
    builder: _goldenDiff,
  ),
  CodeSlideWidget(
    route: '/q-e2e',
    eyebrow: 'Integration test',
    title: 'Integration テスト：本物の端末で通しで',
    fileName: 'integration_test/app_test.dart',
    fontSize: 19,
    points: const [
      '実機・シミュレータで実行',
      'Widget テストと同じ API',
      'OS のダイアログや権限は Patrol',
      'CI ・ Firebase Test Lab でも',
    ],
    code: '''
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ログインしてイベントを見る', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('email')), 'dash@flutter.dev');
    await tester.tap(find.text('ログイン'));
    await tester.pumpAndSettle();

    expect(find.text('イベント一覧'), findsOneWidget);
  });
}

// \$ flutter test integration_test/ -d <device>
''',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Test pyramid — hover a layer for details.
// ─────────────────────────────────────────────────────────────────────────────
Widget _pyramid(BuildContext context, int step) => const _Pyramid();

class _Layer {
  const _Layer(
    this.name,
    this.color,
    this.speed,
    this.what,
    this.api,
    this.cmd,
  );

  final String name;
  final Color color;
  final String speed;
  final String what;
  final String api;
  final String cmd;
}

const _layers = [
  _Layer(
    'Integration (E2E)',
    DeckColors.pink,
    '分',
    '実機でアプリ全体を通しで',
    'integration_test / Patrol',
    'flutter test integration_test',
  ),
  _Layer(
    'Golden',
    DeckColors.purple,
    '秒',
    '見た目を画像で比較',
    'matchesGoldenFile',
    'flutter test --update-goldens',
  ),
  _Layer(
    'Widget',
    DeckColors.blue,
    '秒',
    '1画面を描いて操作',
    'testWidgets / WidgetTester',
    'flutter test',
  ),
  _Layer(
    'Unit',
    DeckColors.cyan,
    'ミリ秒',
    '関数・クラスのロジック',
    'test / expect',
    'flutter test',
  ),
];

class _Pyramid extends StatefulWidget {
  const _Pyramid();

  @override
  State<_Pyramid> createState() => _PyramidState();
}

class _PyramidState extends State<_Pyramid> {
  int _hovered = 2;

  @override
  Widget build(BuildContext context) {
    final l = _layers[_hovered];
    return Row(
      children: [
        // Axis: confidence vs speed.
        SizedBox(
          width: 60,
          child: Column(
            children: [
              Text(
                '本物\nに近い',
                textAlign: TextAlign.center,
                style: DeckText.caption.copyWith(fontSize: 18),
              ),
              const Expanded(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Icon(
                    Icons.arrow_right_alt_rounded,
                    size: 60,
                    color: DeckColors.textTertiary,
                  ),
                ),
              ),
              Text(
                '速い\n安い',
                textAlign: TextAlign.center,
                style: DeckText.caption.copyWith(fontSize: 18),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 6,
          child: Column(
            children: [
              for (var i = 0; i < _layers.length; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      onEnter: (_) => setState(() => _hovered = i),
                      child: GestureDetector(
                        onTap: () => setState(() => _hovered = i),
                        child: ClipPath(
                          clipper: _TrapezoidClipper(
                            top: 0.25 + 0.75 * i / _layers.length,
                            bottom: 0.25 + 0.75 * (i + 1) / _layers.length,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            color: _layers[i].color.withValues(
                              alpha: _hovered == i ? 0.75 : 0.22,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _layers[i].name,
                              style: DeckText.heading.copyWith(fontSize: 32),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 56),
        Expanded(
          flex: 5,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: DeckCard(
              key: ValueKey(_hovered),
              accent: l.color,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Pill('1回あたり：${l.speed}', color: l.color),
                  const SizedBox(height: 20),
                  Text(
                    l.name,
                    style: DeckText.heading.copyWith(
                      color: l.color,
                      fontSize: 40,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(l.what, style: DeckText.body),
                  const SizedBox(height: 26),
                  Text('API', style: DeckText.eyebrow),
                  const SizedBox(height: 6),
                  Text(
                    l.api,
                    style: DeckText.mono.copyWith(color: DeckColors.dart),
                  ),
                  const SizedBox(height: 20),
                  Text('COMMAND', style: DeckText.eyebrow),
                  const SizedBox(height: 6),
                  Text(
                    '\$ ${l.cmd}',
                    style: DeckText.mono.copyWith(
                      color: DeckColors.textSecondary,
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
}

class _TrapezoidClipper extends CustomClipper<Path> {
  const _TrapezoidClipper({required this.top, required this.bottom});

  /// Width fractions of the top and bottom edges.
  final double top;
  final double bottom;

  @override
  Path getClip(Size size) {
    final w = size.width;
    final t = (1 - top) / 2 * w;
    final b = (1 - bottom) / 2 * w;
    return Path()
      ..moveTo(t, 0)
      ..lineTo(w - t, 0)
      ..lineTo(w - b, size.height)
      ..lineTo(b, size.height)
      ..close();
  }

  @override
  bool shouldReclip(_TrapezoidClipper old) =>
      old.top != top || old.bottom != bottom;
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget test runner visualisation.
// ─────────────────────────────────────────────────────────────────────────────
Widget _runner(BuildContext context, int step) => const _TestRunner();

enum _LineState { idle, running, pass, fail }

class _TestRunner extends StatefulWidget {
  const _TestRunner();

  @override
  State<_TestRunner> createState() => _TestRunnerState();
}

class _TestRunnerState extends State<_TestRunner> {
  static const _lines = [
    "await tester.pumpWidget(const MyApp());",
    "expect(find.text('0'), findsOneWidget);",
    "expect(find.text('1'), findsNothing);",
    "await tester.tap(find.byIcon(Icons.add));",
    "await tester.pump();",
    "expect(find.text('0'), findsNothing);",
    "expect(find.text('1'), findsOneWidget);",
  ];

  Timer? _timer;
  bool _bug = false;
  int _current = -1;
  final _states = List<_LineState>.filled(_lines.length, _LineState.idle);
  bool _mounted = false; // pumpWidget happened
  int _counter = 0;
  bool _tapping = false;
  String? _failure;
  bool _finished = false;

  void _run() {
    _timer?.cancel();
    setState(() {
      _states.fillRange(0, _lines.length, _LineState.idle);
      _current = -1;
      _mounted = false;
      _counter = 0;
      _tapping = false;
      _failure = null;
      _finished = false;
    });
    _timer = Timer.periodic(
      const Duration(milliseconds: 850),
      (_) => _advance(),
    );
    _advance();
  }

  void _advance() {
    if (!mounted) return;
    setState(() {
      if (_current >= 0 && _states[_current] == _LineState.running) {
        // Resolve the line that was running.
        _states[_current] = _resolve(_current);
        if (_states[_current] == _LineState.fail) {
          _failure =
              'Expected: exactly one matching candidate\n'
              '  Actual: _TextWidgetFinder:<Found 0 widgets with text "1">';
          _finished = true;
          _timer?.cancel();
          return;
        }
      }
      _current++;
      if (_current >= _lines.length) {
        _finished = true;
        _timer?.cancel();
        return;
      }
      _states[_current] = _LineState.running;
      // Side effects happen when a line starts.
      switch (_current) {
        case 0:
          _mounted = true;
        case 3:
          _tapping = true;
        case 4:
          _tapping = false;
          _counter += _bug ? 2 : 1;
      }
    });
  }

  _LineState _resolve(int i) {
    final ok = switch (i) {
      5 => _counter != 0,
      6 => _counter == 1,
      _ => true,
    };
    return ok ? _LineState.pass : _LineState.fail;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final passed = _finished && _failure == null;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 11,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: _run,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 26,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: DeckColors.green.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: DeckColors.green, width: 2),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.play_arrow_rounded,
                              color: DeckColors.green,
                              size: 30,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'テスト実行',
                              style: DeckText.heading.copyWith(
                                fontSize: 26,
                                color: DeckColors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 30),
                  Switch(
                    value: _bug,
                    activeTrackColor: DeckColors.red,
                    onChanged: (v) => setState(() => _bug = v),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'バグを入れる（+2 する）',
                    style: DeckText.body.copyWith(
                      fontSize: 24,
                      color: _bug ? DeckColors.red : DeckColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 22, 22, 22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10101A),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: DeckColors.dart.withValues(alpha: 0.28),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < _lines.length; i++) ...[
                        if (i == 1 || i == 3 || i == 5)
                          const SizedBox(height: 14),
                        _CodeLine(text: _lines[i], state: _states[i]),
                      ],
                      const Spacer(),
                      AnimatedOpacity(
                        opacity: _finished ? 1 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Text(
                            passed
                                ? '00:01 +1: All tests passed!'
                                : (_failure ?? ''),
                            style: DeckText.monoSmall.copyWith(
                              color: passed ? DeckColors.green : DeckColors.red,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 56),
        Expanded(
          flex: 6,
          child: Center(
            child: PhoneFrame(
              width: 320,
              accent: passed
                  ? DeckColors.green
                  : (_failure != null ? DeckColors.red : DeckColors.dart),
              child: _mounted
                  ? _CounterMock(
                      counter: _counter,
                      tapping: _tapping,
                      highlight:
                          _current >= 0 &&
                              _current < _lines.length &&
                              _current != 3 &&
                              _current != 4
                          ? (_current == 1 || _current == 5 ? '0' : '1')
                          : null,
                    )
                  : const Center(
                      child: Text(
                        'pumpWidget 前',
                        style: TextStyle(color: Colors.black38, fontSize: 16),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CodeLine extends StatelessWidget {
  const _CodeLine({required this.text, required this.state});

  final String text;
  final _LineState state;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (state) {
      _LineState.idle => (Colors.transparent, null),
      _LineState.running => (DeckColors.orange, Icons.play_arrow_rounded),
      _LineState.pass => (DeckColors.green, Icons.check_rounded),
      _LineState.fail => (DeckColors.red, Icons.close_rounded),
    };
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: state == _LineState.idle ? 0 : 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: icon == null ? null : Icon(icon, color: color, size: 24),
          ),
          Expanded(
            child: Text(
              text,
              style: DeckText.mono.copyWith(
                fontSize: 21,
                color: state == _LineState.idle
                    ? DeckColors.textSecondary
                    : DeckColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The template counter app, drawn as the test "sees" it.
class _CounterMock extends StatelessWidget {
  const _CounterMock({
    required this.counter,
    required this.tapping,
    this.highlight,
  });

  final int counter;
  final bool tapping;

  /// Text the current `find.text(...)` is looking for.
  final String? highlight;

  @override
  Widget build(BuildContext context) {
    final found = highlight == '$counter';
    return Stack(
      children: [
        Column(
          children: [
            Container(
              height: 56,
              width: double.infinity,
              color: const Color(0xFFEADDFF),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.centerLeft,
              child: const Text(
                'Flutter Demo Home Page',
                style: TextStyle(color: Colors.black87, fontSize: 18),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'You have pushed the button\nthis many times:',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black87, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: highlight == null
                            ? Colors.transparent
                            : (found
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFE53935)),
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$counter',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 44,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 24,
                    child: highlight == null
                        ? null
                        : Text(
                            "find.text('$highlight') → ${found ? '1件' : '0件'}",
                            style: TextStyle(
                              fontSize: 13,
                              fontFamily: kMonoFamily,
                              color: found
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFE53935),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          right: 18,
          bottom: 22,
          child: AnimatedScale(
            scale: tapping ? 0.86 : 1,
            duration: const Duration(milliseconds: 150),
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFEADDFF),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Color(0xFF21005D)),
            ),
          ),
        ),
        // The tester's "finger".
        Positioned(
          right: 22,
          bottom: 26,
          child: IgnorePointer(
            child: AnimatedOpacity(
              opacity: tapping ? 1 : 0,
              duration: const Duration(milliseconds: 150),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DeckColors.orange.withValues(alpha: 0.35),
                  border: Border.all(color: DeckColors.orange, width: 3),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Golden diff viewer — a real pixel diff of two rendered widgets.
// ─────────────────────────────────────────────────────────────────────────────
Widget _goldenDiff(BuildContext context, int step) => const _GoldenDiff();

class _GoldenDiff extends StatefulWidget {
  const _GoldenDiff();

  @override
  State<_GoldenDiff> createState() => _GoldenDiffState();
}

class _GoldenDiffState extends State<_GoldenDiff> {
  final _goldenKey = GlobalKey();
  final _changedKey = GlobalKey();

  double _split = 0.5;
  bool _diffMode = false;
  ui.Image? _diff;
  double? _diffPercent;

  Future<void> _computeDiff() async {
    final a =
        _goldenKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    final b =
        _changedKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (a == null || b == null) return;
    final ia = await a.toImage();
    final ib = await b.toImage();
    final da = await ia.toByteData();
    final db = await ib.toByteData();
    if (da == null ||
        db == null ||
        ia.width != ib.width ||
        ia.height != ib.height) {
      return;
    }
    final pa = da.buffer.asUint8List();
    final pb = db.buffer.asUint8List();
    final out = Uint8List(pa.length);
    var changed = 0;
    for (var i = 0; i < pa.length; i += 4) {
      final d =
          (pa[i] - pb[i]).abs() +
          (pa[i + 1] - pb[i + 1]).abs() +
          (pa[i + 2] - pb[i + 2]).abs();
      if (d > 24) {
        changed++;
        out[i] = 255;
        out[i + 1] = 0;
        out[i + 2] = 200;
        out[i + 3] = 255;
      } else {
        // Ghost of the golden, dimmed.
        out[i] = pa[i] ~/ 4;
        out[i + 1] = pa[i + 1] ~/ 4;
        out[i + 2] = pa[i + 2] ~/ 4;
        out[i + 3] = 255;
      }
    }
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      out,
      ia.width,
      ia.height,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    final image = await completer.future;
    if (!mounted) return;
    setState(() {
      _diff?.dispose();
      _diff = image;
      _diffPercent = changed / (pa.length / 4) * 100;
    });
  }

  @override
  void dispose() {
    _diff?.dispose();
    super.dispose();
  }

  Widget _modeChip(String label, bool diff) {
    final selected = _diffMode == diff;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          setState(() => _diffMode = diff);
          if (diff) unawaited(_computeDiff());
        },
        child: Pill(
          label,
          color: selected ? DeckColors.pink : DeckColors.textTertiary,
          filled: selected,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const cardSize = Size(660, 400);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 14,
                children: [
                  _modeChip('Before / After', false),
                  _modeChip('差分', true),
                ],
              ),
              const SizedBox(height: 34),
              const TitledCard(
                badge: 'GOLDEN',
                title: '保存済みの正解',
                accent: DeckColors.green,
                lines: ['goldens/profile_card.png'],
              ),
              const SizedBox(height: 20),
              const TitledCard(
                badge: 'CHANGED',
                title: '今回の描画',
                accent: DeckColors.orange,
                lines: ['padding 16 → 18', 'ボタンの色をちょっと変更'],
              ),
              const SizedBox(height: 20),
              AnimatedOpacity(
                opacity: _diffMode && _diffPercent != null ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  'Golden "profile_card.png": Pixel test failed, '
                  '${_diffPercent?.toStringAsFixed(2) ?? '–'}% diff detected.',
                  style: DeckText.monoSmall.copyWith(color: DeckColors.red),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 56),
        Expanded(
          flex: 6,
          child: DemoFrame(
            accent: DeckColors.pink,
            hint: _diffMode ? 'マゼンタ = 違うピクセル' : '左右にドラッグしてみて',
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: cardSize.width,
                    child: const Row(
                      children: [
                        Pill('← golden', color: DeckColors.green, fontSize: 16),
                        Spacer(),
                        Pill(
                          'changed →',
                          color: DeckColors.orange,
                          fontSize: 16,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox.fromSize(
                    size: cardSize,
                    child: LayoutBuilder(
                      builder: (context, c) => GestureDetector(
                        onHorizontalDragUpdate: (d) => setState(
                          () => _split = (d.localPosition.dx / c.maxWidth)
                              .clamp(0.0, 1.0),
                        ),
                        onTapDown: (d) => setState(
                          () => _split = (d.localPosition.dx / c.maxWidth)
                              .clamp(0.0, 1.0),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            RepaintBoundary(
                              key: _changedKey,
                              child: const _ProfileCard(changed: true),
                            ),
                            ClipRect(
                              clipper: _LeftClipper(_split),
                              child: RepaintBoundary(
                                key: _goldenKey,
                                child: const _ProfileCard(changed: false),
                              ),
                            ),
                            if (!_diffMode) ...[
                              Positioned(
                                left: c.maxWidth * _split - 2,
                                top: 0,
                                bottom: 0,
                                child: Container(
                                  width: 4,
                                  color: DeckColors.pink,
                                ),
                              ),
                              Positioned(
                                left: c.maxWidth * _split - 22,
                                top: c.maxHeight / 2 - 22,
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: const BoxDecoration(
                                    color: DeckColors.pink,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.compare_arrows_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                            if (_diffMode && _diff != null)
                              RawImage(image: _diff, fit: BoxFit.fill),
                          ],
                        ),
                      ),
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
}

class _LeftClipper extends CustomClipper<Rect> {
  const _LeftClipper(this.fraction);

  final double fraction;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * fraction, size.height);

  @override
  bool shouldReclip(_LeftClipper old) => old.fraction != fraction;
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.changed});

  final bool changed;

  @override
  Widget build(BuildContext context) {
    final pad = changed ? 18.0 : 16.0;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(pad + 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF54C5F8), Color(0xFF01579B)],
                  ),
                ),
                child: const Icon(
                  Icons.flutter_dash,
                  color: Colors.white,
                  size: 52,
                ),
              ),
              SizedBox(width: pad + 6),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dash',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Flutter のマスコット',
                    style: TextStyle(color: Colors.black54, fontSize: 18),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          const Text(
            '好きなもの：Hot Reload・Widget・羽ばたき',
            style: TextStyle(color: Colors.black87, fontSize: 18),
          ),
          const SizedBox(height: 18),
          Container(
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: changed
                  ? const Color(0xFF1E6FD9)
                  : const Color(0xFF0B57D0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'フォローする',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
