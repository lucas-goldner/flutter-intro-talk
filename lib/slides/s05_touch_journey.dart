import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_deck/flutter_deck.dart';
import 'package:flutter_intro_talk/core/theme/kaigi_theme.dart';
import 'package:flutter_intro_talk/core/widgets/deck_components.dart';
import 'package:flutter_intro_talk/core/widgets/deck_scaffold.dart';
import 'package:flutter_intro_talk/core/widgets/phone_frame.dart';
import 'package:flutter_intro_talk/core/widgets/templates.dart';
import 'package:flutter_intro_talk/core/widgets/wwdc_background.dart';
import 'package:flutter_intro_talk/slides/s03_shared.dart';

// ─────────────────────────────────────────────────────────────────────────────
// タップの旅 — one tap on the FAB, followed through the RenderObject tree
// (hit test), the gesture arena, setState on the Element, a rebuild of the
// Widget subtree, the RenderParagraph update, and finally the frame.
// ─────────────────────────────────────────────────────────────────────────────

final List<FlutterDeckSlideWidget> touchJourneySlides = [
  StatementSlideWidget(
    route: '/j-question',
    eyebrow: 'The journey of a tap',
    statement: 'タップした瞬間、\n何が起きている？',
    subtitle: '指が触れてから「1」が表示されるまでを、3つのツリーで追いかけます。',
    mood: GradientMood.violet,
  ),
  const _TubeSlide(),
  CodeSlideWidget(
    route: '/j-hittest',
    eyebrow: '② Hit test',
    title: 'ヒットテスト ── 「どこを触った？」',
    fileName: 'gestures/binding.dart ・ rendering/box.dart（簡略化）',
    fontSize: 19,
    points: const [
      'PointerDownEvent が来たら、RenderView から順に問い合わせる',
      '子 → 自分の順に調べ、当たったら HitTestResult に追加',
      '結果は「深い順」のリスト。その全員に handleEvent が届く',
    ],
    code: '''
// GestureBinding
void _handlePointerEventImmediately(PointerEvent event) {
  HitTestResult? result;
  if (event is PointerDownEvent) {
    result = HitTestResult();
    hitTestInView(result, event.position, event.viewId);
    _hitTests[event.pointer] = result;
  }
  // ...
  dispatchEvent(event, result); // → entry.target.handleEvent(...)
}

// RenderBox
bool hitTest(BoxHitTestResult result, {required Offset position}) {
  if (_size!.contains(position)) {
    if (hitTestChildren(result, position: position) ||
        hitTestSelf(position)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
  }
  return false;
}''',
  ),
  CodeSlideWidget(
    route: '/j-setstate',
    eyebrow: '④⑤ setState',
    title: 'setState の中身は、たった数行',
    fileName: 'widgets/framework.dart（簡略化）',
    fontSize: 21,
    points: const [
      'fn() を実行して値を変える（同期で！）',
      'Element に「汚れた（dirty）」印をつける',
      'BuildOwner が次のフレームでまとめて build する',
    ],
    footnote: 'setState を10回呼んでも、build は次のフレームで1回だけ。',
    code: '''
// State
void setState(VoidCallback fn) {
  final Object? result = fn() as dynamic; // ① 値を変える
  assert(result is! Future);              //    async は NG
  _element!.markNeedsBuild();             // ② 印をつける
}

// Element
void markNeedsBuild() {
  if (dirty) return;                      // もう印があれば何もしない
  _dirty = true;
  owner!.scheduleBuildFor(this);          // ③ dirty リストへ
}

// BuildOwner.scheduleBuildFor
//   → onBuildScheduled() → SchedulerBinding.ensureVisualUpdate()
//   → 次の vsync で WidgetsBinding.drawFrame()''',
  ),
  InteractiveSlideWidget(
    route: '/j-frame',
    eyebrow: '⑥〜⑨ One frame',
    title: '1フレームのパイプライン',
    footnote: '60fps なら 16.7ms、120fps なら 8.3ms。この中に全部収める。',
    builder: (context, step) => const _FramePipeline(),
    steps: 1,
    intensity: 0.4,
  ),
];

/// Halfway point (~45 min): the basics — including how Flutter renders — are
/// done; open the floor. main.dart places this after the rendering chapter.
final List<FlutterDeckSlideWidget> questionTimeSlides = [
  StatementSlideWidget(
    route: '/j-questions',
    eyebrow: 'Q&A · 質問タイム',
    statement: 'ここまでで、\n質問ありますか？',
    subtitle: 'Widget・3つのツリー・1フレーム・描画の仕組み。どんな小さなことでも OK 🙋',
    mood: GradientMood.warm,
  ),
];

// ── The tube ────────────────────────────────────────────────────────────────

class _TubeSlide extends FlutterDeckSlideWidget {
  const _TubeSlide()
    : super(
        configuration: const FlutterDeckSlideConfiguration(
          route: '/j-tube',
          title: '信号のチューブ',
          header: FlutterDeckHeaderConfiguration(showHeader: false),
          steps: 10,
        ),
      );

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.custom(
      builder: (context) => FlutterDeckSlideStepsBuilder(
        builder: (context, step) => _TubeStage(step: step),
      ),
    );
  }
}

/// One beat of the journey.
class _Beat {
  const _Beat(this.badge, this.title, this.code, this.path);

  final String badge;
  final String title;
  final String code;

  /// Anchor ids the signal travels through (`P:` phone, `W:`/`E:`/`R:`).
  final List<String> path;
}

const _beats = <_Beat>[
  _Beat(
    '▶',
    '＋ をタップすると、信号が3つのツリーを旅します',
    'Phone → RenderObject → Element → Widget → Element → RenderObject → Phone',
    [],
  ),
  _Beat(
    '①',
    '指が触れる',
    'Engine → PlatformDispatcher.onPointerDataPacket → GestureBinding.handlePointerEvent(PointerDownEvent)',
    ['P:fab'],
  ),
  _Beat(
    '②',
    'ヒットテスト ── 「どこを触った？」',
    'GestureBinding.hitTestInView → RenderView.hitTest → RenderBox.hitTest … → HitTestResult',
    ['P:fab', 'R:root', 'R:dots', 'R:fab'],
  ),
  _Beat(
    '③',
    'ジェスチャーアリーナ ── 誰のタップ？',
    'dispatchEvent → RenderPointerListener.handleEvent → TapGestureRecognizer が GestureArenaManager で勝利（指を離した時）',
    ['R:fab'],
  ),
  _Beat(
    '④',
    'onPressed → setState',
    'onPressed: _incrementCounter → setState(() { _counter++; })',
    ['R:fab', 'E:fab', 'E:home'],
  ),
  _Beat(
    '⑤',
    'Element に「dirty」の印',
    'State.setState → Element.markNeedsBuild → BuildOwner.scheduleBuildFor → 次のフレームを要求',
    ['E:home'],
  ),
  _Beat(
    '⑥',
    '次の vsync で build() ── 新しい Widget',
    'SchedulerBinding（vsync）→ WidgetsBinding.drawFrame → BuildOwner.buildScope → State.build()',
    ['E:home', 'W:home', 'W:scaffold', 'W:center', 'W:column', 'W:text2'],
  ),
  _Beat(
    '⑦',
    '差分だけ更新 ── RenderParagraph の文字が「1」に',
    'Element.updateChild → Widget.canUpdate ✓ → RenderParagraph.text = "1" → markNeedsLayout',
    ['W:text2', 'E:text2', 'R:text2'],
  ),
  _Beat(
    '⑧',
    'レイアウト → ペイント → 合成',
    'PipelineOwner.flushLayout → flushCompositingBits → flushPaint → RenderView.compositeFrame',
    ['R:text2', 'R:column', 'R:center', 'R:root', 'P:text'],
  ),
  _Beat('⑨', 'エンジンがラスタライズ ── 画面に「1」', 'Scene → Engine（Impeller）→ GPU → ピクセル', [
    'P:text',
  ]),
];

// Fixed layout on the 1920×1080 slide.
const _paneTop = 196.0;
const _paneH = 640.0;
const _paneW = 410.0;
const _paneXs = [64.0, 514.0, 964.0]; // Widget, Element, RenderObject
const _rowTop = 72.0;
const _rowH = 52.0;
const _chipH = 36.0;
const _indent = 16.0;
const _phoneX = 1484.0;
const _phoneY = 168.0;
const _phoneW = 340.0;

List<TreeRow> _rowsFor(String pane) => switch (pane) {
  'W' => kWidgetTree,
  'E' => kElementTree,
  _ => kRenderTree,
};

double _paneXFor(String pane) => switch (pane) {
  'W' => _paneXs[0],
  'E' => _paneXs[1],
  _ => _paneXs[2],
};

Offset _anchor(String id) {
  final pane = id.substring(0, 1);
  final link = id.substring(2);
  if (pane == 'P') {
    const bezel = _phoneW * 0.035;
    const screenR = _phoneX + _phoneW - bezel;
    const screenB = _phoneY + _phoneW / PhoneFrame.aspect - bezel;
    return link == 'fab'
        ? const Offset(screenR - 16 - 28, screenB - 16 - 28)
        : const Offset(_phoneX + _phoneW / 2, _phoneY + 418);
  }
  final rows = _rowsFor(pane);
  final i = rows.indexWhere((r) => r.link == link);
  final r = rows[i];
  return Offset(
    _paneXFor(pane) + 18 + r.depth * _indent + 14,
    _paneTop + _rowTop + i * _rowH + _chipH / 2,
  );
}

Path _pathThrough(List<String> ids) {
  final path = Path();
  if (ids.isEmpty) return path;
  final pts = ids.map(_anchor).toList();
  path.moveTo(pts.first.dx, pts.first.dy);
  for (var i = 1; i < pts.length; i++) {
    final a = pts[i - 1];
    final b = pts[i];
    final dx = b.dx - a.dx;
    if (dx.abs() < 60) {
      path.lineTo(b.dx, b.dy);
    } else {
      path.cubicTo(a.dx + dx * 0.5, a.dy, b.dx - dx * 0.5, b.dy, b.dx, b.dy);
    }
  }
  return path;
}

class _TubeStage extends StatefulWidget {
  const _TubeStage({required this.step});

  final int step;

  @override
  State<_TubeStage> createState() => _TubeStageState();
}

class _TubeStageState extends State<_TubeStage> with TickerProviderStateMixin {
  late final AnimationController _travel = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..forward();
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  int _taps = 0;
  int? _auto;
  Timer? _timer;

  int get _beat => (_auto ?? widget.step).clamp(1, _beats.length);

  @override
  void didUpdateWidget(_TubeStage old) {
    super.didUpdateWidget(old);
    if (old.step != widget.step) {
      _stopAuto();
      if (old.step < _beats.length && widget.step >= _beats.length) _taps++;
      _travel.forward(from: 0);
    }
  }

  void _stopAuto() {
    _timer?.cancel();
    _timer = null;
    _auto = null;
  }

  void _play() {
    if (_timer != null) return;
    setState(() => _auto = 2);
    _travel.forward(from: 0);
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (t) {
      if (!mounted) return;
      setState(() {
        _auto = _auto! + 1;
        if (_auto! >= _beats.length) {
          _taps++;
          t.cancel();
          _timer = null;
        }
      });
      _travel.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _travel.dispose();
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final beat = _beats[_beat - 1];
    final lit = beat.path.toSet();
    final full = [
      for (final b in _beats)
        if (b.path.length > 1) _pathThrough(b.path),
    ];
    final active = _pathThrough(beat.path);

    return Stack(
      fit: StackFit.expand,
      children: [
        const WwdcBackground(mood: GradientMood.violet, intensity: 0.35),
        // Title.
        Positioned(
          left: 72,
          top: 52,
          right: 520,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('THE JOURNEY OF A TAP', style: DeckText.eyebrow),
              const SizedBox(height: 10),
              const GradientText(
                '信号のチューブ',
                style: DeckText.title,
                gradient: LinearGradient(
                  colors: [
                    TreeColors.signal,
                    DeckColors.purple,
                    DeckColors.dart,
                  ],
                ),
              ),
            ],
          ),
        ),
        // Panes.
        for (final (pane, title, color) in const [
          ('W', 'Widget', TreeColors.widget),
          ('E', 'Element', TreeColors.element),
          ('R', 'RenderObject', TreeColors.render),
        ])
          Positioned(
            left: _paneXFor(pane),
            top: _paneTop,
            width: _paneW,
            height: _paneH,
            child: _PaneBox(title: title, color: color),
          ),
        // The tube, under the chips.
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _travel,
            builder: (context, _) => CustomPaint(
              painter: _TubePainter(
                full: full,
                active: active,
                progress: Curves.easeInOut.transform(_travel.value),
              ),
            ),
          ),
        ),
        // Chips.
        for (final pane in const ['W', 'E', 'R'])
          for (final (i, row) in _rowsFor(pane).indexed)
            Positioned(
              left: _paneXFor(pane) + 18 + row.depth * _indent,
              top: _paneTop + _rowTop + i * _rowH,
              width: _paneW - 36 - row.depth * _indent,
              height: _chipH,
              child: Row(
                children: [
                  Flexible(
                    child: TreeChip(
                      label: row.label,
                      fontSize: 14,
                      color: switch (pane) {
                        'W' => TreeColors.widget,
                        'E' => TreeColors.element,
                        _ => TreeColors.render,
                      },
                      highlighted: lit.contains('$pane:${row.link}'),
                      dimmed: _beat > 1 && !lit.contains('$pane:${row.link}'),
                    ),
                  ),
                  if (_badge(pane, row.link) case final badge?) ...[
                    const SizedBox(width: 6),
                    Pill(badge.$1, color: badge.$2, fontSize: 13),
                  ],
                ],
              ),
            ),
        // Extra explainer cards inside the RenderObject pane.
        Positioned(
          left: _paneXs[2] + 18,
          top: _paneTop + _rowTop + kRenderTree.length * _rowH + 14,
          width: _paneW - 36,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _renderPaneNote(_beat),
          ),
        ),
        // Phone.
        Positioned(
          left: _phoneX,
          top: _phoneY,
          child: PhoneFrame(
            width: _phoneW,
            accent: TreeColors.signal,
            child: CounterAppMock(
              value: _taps,
              onPressed: _play,
              counterFlash: _beat == _beats.length,
            ),
          ),
        ),
        // Particles + ripples, above everything.
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: Listenable.merge([_travel, _loop]),
              builder: (context, _) => CustomPaint(
                painter: _SignalPainter(
                  active: active,
                  progress: Curves.easeInOut.transform(_travel.value),
                  loop: _loop.value,
                  pulses: [
                    if (beat.path.length == 1) _anchor(beat.path.single),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Caption.
        Positioned(
          left: 64,
          top: 864,
          width: 1310,
          height: 168,
          child: _Caption(beat: beat, index: _beat, auto: _auto != null),
        ),
        if (_beat == 1)
          Positioned(
            left: _phoneX,
            top: _phoneY + _phoneW / PhoneFrame.aspect + 14,
            width: _phoneW,
            child: Text(
              '↑ ＋ をタップすると自動再生',
              textAlign: TextAlign.center,
              style: DeckText.caption.copyWith(color: TreeColors.signal),
            ),
          ),
      ],
    );
  }

  (String, Color)? _badge(String pane, String link) {
    final b = _beat;
    if (pane == 'E' && link == 'home' && (b == 6)) {
      return ('dirty', DeckColors.orange);
    }
    if (pane == 'E' && link == 'home' && b == 7) {
      return ('build()', DeckColors.green);
    }
    if (pane == 'W' && link == 'home' && b == 7) {
      return ('同じ', DeckColors.textSecondary);
    }
    if (pane == 'W' && link == 'text2' && b == 7) {
      return ('new', DeckColors.green);
    }
    if (pane == 'R' && link == 'text2' && (b == 8 || b == 9)) {
      return ('needsLayout', DeckColors.orange);
    }
    if (pane == 'R' && link == 'fab' && (b == 3 || b == 4)) {
      return ('hit!', TreeColors.signal);
    }
    return null;
  }

  Widget _renderPaneNote(int b) {
    if (b == 3) {
      return const _MiniCard(
        key: ValueKey('hit'),
        title: 'HitTestResult（深い順）',
        lines: [
          'RenderPointerListener ← FAB',
          '… RenderSemanticsAnnotations …',
          'RenderView',
        ],
        color: TreeColors.signal,
      );
    }
    if (b == 4) {
      return const _MiniCard(
        key: ValueKey('arena'),
        title: 'GestureArenaManager',
        lines: ['TapGestureRecognizer ✓ 勝者', '（他の候補がいれば、ここで競う）'],
        color: DeckColors.cyan,
      );
    }
    if (b == 9) {
      return const _MiniCard(
        key: ValueKey('frame'),
        title: 'PipelineOwner',
        lines: ['flushLayout()', 'flushPaint()', 'compositeFrame() → Scene'],
        color: TreeColors.render,
      );
    }
    return const SizedBox(key: ValueKey('none'));
  }
}

class _PaneBox extends StatelessWidget {
  const _PaneBox({required this.title, required this.color});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      alignment: Alignment.topLeft,
      child: Pill(title, color: color, fontSize: 20),
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({
    required this.title,
    required this.lines,
    required this.color,
    super.key,
  });

  final String title;
  final List<String> lines;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: DeckText.caption.copyWith(color: color, fontSize: 17),
          ),
          const SizedBox(height: 6),
          for (final l in lines)
            Text(l, style: DeckText.monoSmall.copyWith(fontSize: 14.5)),
        ],
      ),
    );
  }
}

class _Caption extends StatelessWidget {
  const _Caption({required this.beat, required this.index, required this.auto});

  final _Beat beat;
  final int index;
  final bool auto;

  @override
  Widget build(BuildContext context) {
    return DeckCard(
      accent: TreeColors.signal,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
      child: Row(
        children: [
          Container(
            width: 84,
            height: 84,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: TreeColors.signal.withValues(alpha: 0.18),
              border: Border.all(color: TreeColors.signal, width: 2.5),
            ),
            child: Text(
              beat.badge,
              style: DeckText.title.copyWith(
                fontSize: 44,
                color: TreeColors.signal,
                height: 1,
              ),
            ),
          ),
          const SizedBox(width: 28),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              layoutBuilder: (current, previous) => Stack(
                alignment: Alignment.centerLeft,
                children: [...previous, ?current],
              ),
              child: ScaleDownToFit(
                key: ValueKey(index),
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      beat.title,
                      style: DeckText.heading.copyWith(fontSize: 34),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      beat.code,
                      maxLines: 2,
                      style: DeckText.monoSmall.copyWith(
                        fontSize: 18,
                        color: DeckColors.cyan,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (auto)
                const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Pill('AUTO', color: TreeColors.signal, fontSize: 14),
                ),
              Row(
                children: [
                  for (var i = 2; i <= _beats.length; i++)
                    Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.only(left: 6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i <= index
                            ? TreeColors.signal
                            : Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The faint full route, and the active segment lit up to [progress].
class _TubePainter extends CustomPainter {
  _TubePainter({
    required this.full,
    required this.active,
    required this.progress,
  });

  final List<Path> full;
  final Path active;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final tube = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 18
      ..color = TreeColors.signal.withValues(alpha: 0.06);
    final wall = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.2
      ..color = TreeColors.signal.withValues(alpha: 0.22);
    for (final p in full) {
      canvas
        ..drawPath(p, tube)
        ..drawPath(p, wall);
    }

    for (final metric in active.computeMetrics()) {
      final lit = metric.extractPath(0, metric.length * progress);
      canvas
        ..drawPath(
          lit,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = 22
            ..color = TreeColors.signal.withValues(alpha: 0.35)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
        )
        ..drawPath(
          lit,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = 5
            ..shader = ui.Gradient.linear(
              metric.getTangentForOffset(0)?.position ?? Offset.zero,
              metric.getTangentForOffset(metric.length)?.position ??
                  Offset.zero,
              const [DeckColors.orange, TreeColors.signal, DeckColors.purple],
              const [0, 0.5, 1],
            ),
        );
    }
  }

  @override
  bool shouldRepaint(_TubePainter old) =>
      old.progress != progress || old.active != active;
}

/// Particles flowing through the lit tube, the travelling head, and
/// ripples for beats that happen "in place".
class _SignalPainter extends CustomPainter {
  _SignalPainter({
    required this.active,
    required this.progress,
    required this.loop,
    required this.pulses,
  });

  final Path active;
  final double progress;
  final double loop;
  final List<Offset> pulses;

  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()
      ..color = TreeColors.signal.withValues(alpha: 0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    final core = Paint()..color = Colors.white;

    for (final metric in active.computeMetrics()) {
      final reach = metric.length * progress;
      // Particles every ~70px, drifting forward, only in the lit part.
      const spacing = 70.0;
      for (var d = (loop * spacing) % spacing; d < reach; d += spacing) {
        final t = metric.getTangentForOffset(d);
        if (t == null) continue;
        final r = 3.0 + 1.5 * math.sin((d / spacing + loop) * math.pi * 2);
        canvas
          ..drawCircle(t.position, r * 2.4, glow)
          ..drawCircle(
            t.position,
            r,
            Paint()..color = TreeColors.signal.withValues(alpha: 0.9),
          );
      }
      // The head.
      if (progress < 1) {
        final head = metric.getTangentForOffset(reach);
        if (head != null) {
          canvas
            ..drawCircle(head.position, 26, glow)
            ..drawCircle(head.position, 9, core);
        }
      }
    }

    for (final p in pulses) {
      for (var k = 0; k < 3; k++) {
        final t = (loop + k / 3) % 1;
        canvas.drawCircle(
          p,
          12 + 60 * t,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = TreeColors.signal.withValues(alpha: (1 - t) * 0.8),
        );
      }
      canvas.drawCircle(
        p,
        30,
        Paint()
          ..color = TreeColors.signal.withValues(alpha: 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
      );
    }
  }

  @override
  bool shouldRepaint(_SignalPainter old) => true;
}

// ── /j-frame — the frame pipeline and a real frame budget ───────────────────

class _FramePipeline extends StatelessWidget {
  const _FramePipeline();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FlowRow(
          steps: [
            FlowStep(
              title: 'vsync',
              subtitle: 'Engine の合図',
              accent: DeckColors.textSecondary,
            ),
            FlowStep(
              title: 'Animate',
              subtitle: 'Ticker',
              accent: DeckColors.cyan,
            ),
            FlowStep(
              title: 'Build',
              subtitle: 'build()',
              accent: TreeColors.widget,
            ),
            FlowStep(
              title: 'Layout',
              subtitle: 'performLayout',
              accent: TreeColors.render,
            ),
            FlowStep(
              title: 'Paint',
              subtitle: 'paint()',
              accent: TreeColors.render,
            ),
            FlowStep(
              title: 'Composite',
              subtitle: 'Layer → Scene',
              accent: DeckColors.purple,
            ),
            FlowStep(
              title: 'Raster',
              subtitle: 'Impeller / GPU',
              accent: TreeColors.signal,
            ),
          ],
        ),
        SizedBox(height: 30),
        Expanded(child: _FrameBudgetDemo()),
      ],
    );
  }
}

class _FrameBudgetDemo extends StatefulWidget {
  const _FrameBudgetDemo();

  @override
  State<_FrameBudgetDemo> createState() => _FrameBudgetDemoState();
}

class _FrameBudgetDemoState extends State<_FrameBudgetDemo>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_tick);
  final _frames = <double>[];
  Duration _last = Duration.zero;
  Duration _now = Duration.zero;
  double _workMs = 0;

  @override
  void initState() {
    super.initState();
    // Start explicitly: a `late` field is only created on first access.
    _ticker.start();
  }

  void _tick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1000;
    _last = elapsed;
    // Really burn CPU on the UI thread — this is what jank is.
    if (_workMs > 0) {
      final sw = Stopwatch()..start();
      while (sw.elapsedMicroseconds < _workMs * 1000) {}
    }
    setState(() {
      _now = elapsed;
      if (dt > 0 && dt < 500) {
        _frames.add(dt);
        if (_frames.length > 90) _frames.removeAt(0);
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final janky = _frames.where((f) => f > 17.5).length;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 520,
          child: DeckCard(
            accent: _workMs > 16 ? DeckColors.red : DeckColors.green,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('毎フレームの重い処理', style: DeckText.caption),
                const SizedBox(height: 6),
                Text(
                  '${_workMs.round()} ms',
                  style: DeckText.title.copyWith(
                    color: _workMs > 16 ? DeckColors.red : DeckColors.green,
                  ),
                ),
                Slider(
                  value: _workMs,
                  max: 40,
                  activeColor: _workMs > 16 ? DeckColors.red : DeckColors.green,
                  onChanged: (v) => setState(() => _workMs = v),
                ),
                const Spacer(),
                Text(
                  janky == 0 ? 'なめらか ✓' : 'ジャンク：$janky フレーム',
                  style: DeckText.heading.copyWith(
                    fontSize: 30,
                    color: janky == 0 ? DeckColors.green : DeckColors.red,
                  ),
                ),
                Text(
                  'スライダーを右へ。UI スレッドを本当に止めます',
                  style: DeckText.caption.copyWith(fontSize: 18),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 30),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white12),
            ),
            child: CustomPaint(
              painter: _BudgetPainter(
                frames: List.of(_frames),
                t: _now.inMicroseconds / 1e6,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BudgetPainter extends CustomPainter {
  _BudgetPainter({required this.frames, required this.t});

  final List<double> frames;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    // Ball sweeping left↔right — stutters visibly when frames are late.
    final ballY = 54.0;
    final x = 40 + (size.width - 80) * (0.5 + 0.5 * math.sin(t * 2.4));
    canvas.drawCircle(Offset(x, ballY), 22, Paint()..color = DeckColors.cyan);

    // Frame-time bars, 16.7ms line.
    const maxMs = 50.0;
    final chartTop = 110.0;
    final chartH = size.height - chartTop - 26;
    double y(double ms) => chartTop + chartH * (1 - (ms / maxMs).clamp(0, 1));
    final barW = (size.width - 60) / 90;
    for (var i = 0; i < frames.length; i++) {
      final f = frames[i];
      final left = 30 + i * barW;
      canvas.drawRect(
        Rect.fromLTRB(left, y(f), left + barW - 2, chartTop + chartH),
        Paint()
          ..color = f > 17.5
              ? DeckColors.red.withValues(alpha: 0.85)
              : DeckColors.green.withValues(alpha: 0.75),
      );
    }
    final budget = Paint()
      ..color = DeckColors.orange
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(24, y(16.7)),
      Offset(size.width - 24, y(16.7)),
      budget,
    );
    final tp = TextPainter(
      text: TextSpan(
        text: '16.7ms（60fps の予算）',
        style: DeckText.caption.copyWith(
          color: DeckColors.orange,
          fontSize: 17,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(size.width - tp.width - 30, y(16.7) - tp.height - 4),
    );
  }

  @override
  bool shouldRepaint(_BudgetPainter old) => true;
}
