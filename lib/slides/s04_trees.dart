import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';
import 'package:flutter_intro_talk/core/theme/kaigi_theme.dart';
import 'package:flutter_intro_talk/core/widgets/code_panel.dart';
import 'package:flutter_intro_talk/core/widgets/deck_components.dart';
import 'package:flutter_intro_talk/core/widgets/deck_scaffold.dart';
import 'package:flutter_intro_talk/core/widgets/demo_frame.dart';
import 'package:flutter_intro_talk/core/widgets/phone_frame.dart';
import 'package:flutter_intro_talk/core/widgets/templates.dart';
import 'package:flutter_intro_talk/slides/s03_shared.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 03 · 3つのツリー — Widget / Element / RenderObject.
// ─────────────────────────────────────────────────────────────────────────────

final List<FlutterDeckSlideWidget> treeSlides = [
  DividerSlideWidget(
    route: '/t-divider',
    number: '03',
    label: 'Three Trees',
    title: '3つのツリー',
    subtitle: 'Widget ・ Element ・ RenderObject',
    accent: DeckColors.purple,
  ),
  CardGridSlideWidget(
    route: '/t-three',
    eyebrow: 'Three Trees',
    title: 'Flutter の中には、ツリーが3本ある',
    columns: 3,
    childAspectRatio: 1.6,
    footnote: '私たちが書くのは Widget だけ。残りの2本は Flutter が面倒を見る。',
    cards: const [
      CardSpec(
        badge: 'WIDGET',
        title: '設計図',
        accent: TreeColors.widget,
        lines: ['「こう見えてほしい」の設定', 'immutable（不変）', '軽い ── 毎フレーム作り直してOK'],
      ),
      CardSpec(
        badge: 'ELEMENT',
        title: '実体',
        accent: TreeColors.element,
        lines: [
          'ツリー上の「位置」とライフサイクル',
          'State はここに住む',
          'Widget と RenderObject の橋渡し',
        ],
      ),
      CardSpec(
        badge: 'RENDEROBJECT',
        title: '描く人',
        accent: TreeColors.render,
        lines: ['レイアウト・ペイント・ヒットテスト', '重い ── できるだけ再利用', '画面に出るものだけが持つ'],
      ),
    ],
  ),
  InteractiveSlideWidget(
    route: '/t-explorer',
    eyebrow: 'Explore',
    title: 'カウンターアプリの3つのツリー',
    builder: (context, step) => const _TreeExplorer(),
    intensity: 0.35,
  ),
  CodeSlideWidget(
    route: '/t-why',
    eyebrow: 'Why three?',
    title: 'なぜ3本に分けるのか',
    fileName: 'widgets/framework.dart（簡略化）',
    fontSize: 22,
    points: const [
      'build() は何度でも呼ばれる。Widget は捨てて作り直す',
      'Element は「型」と「key」が同じなら使い回す',
      'だから重い RenderObject も、State も生き残る',
    ],
    footnote: '「作り直す」のは設計図だけ。実体は差分だけ更新される。',
    code: '''
// Widget
static bool canUpdate(Widget oldWidget, Widget newWidget) {
  return oldWidget.runtimeType == newWidget.runtimeType
      && oldWidget.key == newWidget.key;
}

// Element
Element? updateChild(Element? child, Widget? newWidget, Object? slot) {
  if (child != null && Widget.canUpdate(child.widget, newWidget!)) {
    child.update(newWidget);   // ✅ 再利用（State も RenderObject も）
    return child;
  }
  return inflateWidget(newWidget!, slot); // 🆕 作り直し
}''',
  ),
  InteractiveSlideWidget(
    route: '/t-rebuild',
    eyebrow: 'Rebuild',
    title: '＋ を押すと、どのツリーが動く？',
    footnote: 'Widget は毎回新品。Element と RenderObject は「更新」されるだけ。',
    builder: (context, step) => const _RebuildDemo(),
    intensity: 0.35,
  ),
  InteractiveSlideWidget(
    route: '/t-keys',
    eyebrow: 'Keys',
    title: 'Key ── Element に「名札」をつける',
    footnote: '状態を持つ Widget を並べ替えるなら Key を。型が同じだと位置で対応づけられてしまう。',
    builder: (context, step) => const _KeysDemo(),
    intensity: 0.35,
  ),
];

// ── Shared three-column tree view ──────────────────────────────────────────

class _ThreeTrees extends StatelessWidget {
  const _ThreeTrees({
    this.selected,
    this.onHover,
    this.onTap,
    this.widgetFlash = const {},
    this.elementFlash = const {},
    this.renderFlash = const {},
    this.badges = const {},
    this.rowHeight = 54,
    this.chipFontSize = 17,
  });

  final String? selected;
  final ValueChanged<String?>? onHover;
  final ValueChanged<String>? onTap;
  final Map<String, double> widgetFlash;
  final Map<String, double> elementFlash;
  final Map<String, double> renderFlash;

  /// Extra small label next to a node, keyed by `tree:link` (w/e/r).
  final Map<String, String> badges;
  final double rowHeight;
  final double chipFontSize;

  static const _gap = 96.0;
  static const _indent = 22.0;
  static const _top = 64.0;
  static const _chipH = 40.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final cw = (c.maxWidth - 2 * _gap) / 3;
        final trees = [
          (kWidgetTree, TreeColors.widget, 'Widget', widgetFlash, 'w'),
          (kElementTree, TreeColors.element, 'Element', elementFlash, 'e'),
          (kRenderTree, TreeColors.render, 'RenderObject', renderFlash, 'r'),
        ];
        final children = <Widget>[
          Positioned.fill(
            child: CustomPaint(
              painter: _TreeLinesPainter(
                columnWidth: cw,
                gap: _gap,
                indent: _indent,
                top: _top,
                rowHeight: rowHeight,
                chipHeight: _chipH,
                selected: selected,
                chipFontSize: chipFontSize,
              ),
            ),
          ),
        ];
        for (var t = 0; t < trees.length; t++) {
          final (rows, color, title, flash, id) = trees[t];
          final x0 = t * (cw + _gap);
          children.add(
            Positioned(
              left: x0,
              top: 0,
              child: Pill(title, color: color, fontSize: 22),
            ),
          );
          for (var i = 0; i < rows.length; i++) {
            final row = rows[i];
            final indent = row.depth * _indent;
            final isDots = row.link == 'dots' || row.link == 'root';
            final badge = badges['$id:${row.link}'];
            children.add(
              Positioned(
                left: x0 + indent,
                top: _top + i * rowHeight,
                width: cw - indent,
                height: _chipH,
                child: MouseRegion(
                  cursor: isDots ? MouseCursor.defer : SystemMouseCursors.click,
                  onEnter: isDots ? null : (_) => onHover?.call(row.link),
                  onExit: isDots ? null : (_) => onHover?.call(null),
                  child: GestureDetector(
                    onTap: isDots ? null : () => onTap?.call(row.link),
                    child: Row(
                      children: [
                        Flexible(
                          child: TreeChip(
                            label: row.label,
                            color: color,
                            highlighted:
                                selected != null && row.link == selected,
                            dimmed:
                                selected != null &&
                                row.link != selected &&
                                !isDots,
                            flash: flash[row.link] ?? 0,
                            fontSize: chipFontSize,
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            badge,
                            style: DeckText.caption.copyWith(
                              fontSize: 16,
                              color: color,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        }
        return Stack(clipBehavior: Clip.none, children: children);
      },
    );
  }
}

class _TreeLinesPainter extends CustomPainter {
  _TreeLinesPainter({
    required this.columnWidth,
    required this.gap,
    required this.indent,
    required this.top,
    required this.rowHeight,
    required this.chipHeight,
    required this.selected,
    required this.chipFontSize,
  });

  final double chipFontSize;
  final double columnWidth;
  final double gap;
  final double indent;
  final double top;
  final double rowHeight;
  final double chipHeight;
  final String? selected;

  double _y(int i) => top + i * rowHeight + chipHeight / 2;

  /// Width of a [TreeChip] with [label] — chips size to their text.
  double _chipWidth(String label) {
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: DeckText.monoSmall.copyWith(fontSize: chipFontSize),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return tp.width + 24 + 3;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final trees = [kWidgetTree, kElementTree, kRenderTree];
    final colors = [TreeColors.widget, TreeColors.element, TreeColors.render];

    // Parent → child guides inside each tree.
    for (var t = 0; t < 3; t++) {
      final rows = trees[t];
      final x0 = t * (columnWidth + gap);
      final paint = Paint()
        ..color = colors[t].withValues(alpha: 0.28)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      for (var i = 1; i < rows.length; i++) {
        final d = rows[i].depth;
        var p = i - 1;
        while (p >= 0 && rows[p].depth >= d) {
          p--;
        }
        if (p < 0) continue;
        final px = x0 + rows[p].depth * indent + 12;
        final path = Path()
          ..moveTo(px, _y(p) + chipHeight / 2)
          ..lineTo(px, _y(i))
          ..lineTo(x0 + d * indent, _y(i));
        canvas.drawPath(path, paint);
      }
    }

    // Selected thing across the trees.
    final sel = selected;
    if (sel == null) return;
    final idx = [
      for (final rows in trees) rows.indexWhere((r) => r.link == sel),
    ];
    for (var t = 0; t < 2; t++) {
      final a = idx[t];
      final b = idx[t + 1];
      if (a < 0 || b < 0) continue;
      final rowA = trees[t][a];
      final xa =
          t * (columnWidth + gap) +
          rowA.depth * indent +
          _chipWidth(rowA.label).clamp(0, columnWidth - rowA.depth * indent);
      final xb = (t + 1) * (columnWidth + gap) + trees[t + 1][b].depth * indent;
      final ya = _y(a);
      final yb = _y(b);
      final path = Path()
        ..moveTo(xa + 4, ya)
        ..cubicTo(
          xa + (xb - xa) * 0.5,
          ya,
          xb - (xb - xa) * 0.5,
          yb,
          xb - 4,
          yb,
        );
      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            colors: [colors[t], colors[t + 1]],
          ).createShader(Rect.fromPoints(Offset(xa, ya), Offset(xb, yb + 1)))
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke,
      );
      for (final p in [Offset(xa + 4, ya), Offset(xb - 4, yb)]) {
        canvas.drawCircle(p, 5, Paint()..color = TreeColors.signal);
      }
    }
  }

  @override
  bool shouldRepaint(_TreeLinesPainter old) =>
      old.selected != selected ||
      old.columnWidth != columnWidth ||
      old.rowHeight != rowHeight ||
      old.chipFontSize != chipFontSize;
}

// ── /t-explorer ─────────────────────────────────────────────────────────────

class _TreeExplorer extends StatefulWidget {
  const _TreeExplorer();

  @override
  State<_TreeExplorer> createState() => _TreeExplorerState();
}

class _TreeExplorerState extends State<_TreeExplorer> {
  String? _hover;
  String _pinned = 'text2';

  static const _notes = <String, String>{
    'myapp': 'StatelessWidget は build() するだけ。RenderObject は持たない',
    'material': 'MaterialApp も StatefulWidget。中で Navigator や Theme を組み立てる',
    'home': 'State（_counter）は Element が持っている。Widget ではない',
    'scaffold': 'Scaffold も組み立て役。描くのは中の RenderObject たち',
    'center': 'Center は RenderObjectWidget ── RenderPositionedBox を作る',
    'column': 'Column → RenderFlex。子を縦に並べる計算をする',
    'text1': 'Text の中の RichText が RenderParagraph を作る',
    'text2': 'カウンターの数字。押すたびに更新されるのはこの RenderParagraph',
    'fab': 'FAB の奥深くの Listener が RenderPointerListener を作り、タップを受け取る',
  };

  @override
  Widget build(BuildContext context) {
    final sel = _hover ?? _pinned;
    String find(List<TreeRow> rows) {
      for (final r in rows) {
        if (r.link == sel) return r.label;
      }
      return '—';
    }

    final render = find(kRenderTree);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _ThreeTrees(
            selected: sel,
            onHover: (l) => setState(() => _hover = l),
            onTap: (l) => setState(() => _pinned = l),
          ),
        ),
        DeckCard(
          accent: TreeColors.signal,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          child: Row(
            children: [
              const Pill('ホバー / クリック', color: TreeColors.signal, fontSize: 17),
              const SizedBox(width: 22),
              Expanded(
                child: Text(
                  render == '—'
                      ? '${find(kWidgetTree)} → RenderObject なし。${_notes[sel] ?? ''}'
                      : _notes[sel] ?? '',
                  style: DeckText.body.copyWith(fontSize: 25),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── /t-rebuild ──────────────────────────────────────────────────────────────

class _RebuildDemo extends StatefulWidget {
  const _RebuildDemo();

  @override
  State<_RebuildDemo> createState() => _RebuildDemoState();
}

class _RebuildDemoState extends State<_RebuildDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flash = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  int _taps = 0;

  /// What `_MyHomePageState.build` returns that is not `const`:
  /// Scaffold, AppBar, Text(title), Center, Column, Text('$_counter'),
  /// FloatingActionButton.
  static const _newWidgetsPerBuild = 7;

  @override
  void dispose() {
    _flash.dispose();
    super.dispose();
  }

  void _tap() {
    setState(() => _taps++);
    _flash.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 330,
          child: DemoFrame(
            accent: TreeColors.signal,
            hint: '＋ をタップ',
            child: Center(
              child: FittedBox(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: PhoneFrame(
                    width: 320,
                    child: CounterAppMock(value: _taps, onPressed: _tap),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 56),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: AnimatedBuilder(
                  animation: _flash,
                  builder: (context, _) {
                    final t = _taps == 0
                        ? 0.0
                        : Curves.easeOut.transform(1 - _flash.value);
                    return _ThreeTrees(
                      rowHeight: 50,
                      chipFontSize: 15,
                      widgetFlash: {
                        for (final l in [
                          'scaffold',
                          'center',
                          'column',
                          'text2',
                          'fab',
                        ])
                          l: t,
                      },
                      elementFlash: {
                        'home': t,
                        for (final l in [
                          'scaffold',
                          'center',
                          'column',
                          'text2',
                          'fab',
                        ])
                          l: t * 0.45,
                      },
                      renderFlash: {'text2': t},
                      badges: {
                        'w:text1': 'const → 再利用',
                        'e:home': 'build()',
                        if (_taps > 0) 'r:text2': 'markNeedsLayout',
                      },
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: _Counter(
                      label: '新しい Widget',
                      value: _taps * _newWidgetsPerBuild,
                      color: TreeColors.widget,
                      note: '1回の build で $_newWidgetsPerBuild 個',
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Expanded(
                    child: _Counter(
                      label: '新しい Element',
                      value: 0,
                      color: TreeColors.element,
                      note: 'update() で使い回し',
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Expanded(
                    child: _Counter(
                      label: '新しい RenderObject',
                      value: 0,
                      color: TreeColors.render,
                      note: 'テキストだけ書き換え',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({
    required this.label,
    required this.value,
    required this.color,
    required this.note,
  });

  final String label;
  final int value;
  final Color color;
  final String note;

  @override
  Widget build(BuildContext context) {
    return DeckCard(
      accent: color,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: DeckText.caption.copyWith(fontSize: 19)),
                Text(note, style: DeckText.caption.copyWith(fontSize: 16)),
              ],
            ),
          ),
          Text(
            '$value',
            style: DeckText.title.copyWith(
              fontSize: 52,
              color: color,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── /t-keys ─────────────────────────────────────────────────────────────────

class _KeysDemo extends StatefulWidget {
  const _KeysDemo();

  @override
  State<_KeysDemo> createState() => _KeysDemoState();
}

class _KeysDemoState extends State<_KeysDemo> {
  bool _swapped = false;

  static const _tiles = [('A', DeckColors.pink), ('B', DeckColors.cyan)];

  @override
  Widget build(BuildContext context) {
    final order = _swapped ? _tiles.reversed.toList() : _tiles;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CodePanel(
                '''
// Key なし：位置（slot）で対応づけ
Row(children: [
  ColorTile(label: 'A'),
  ColorTile(label: 'B'),
])

// Key あり：名札で対応づけ
Row(children: [
  ColorTile(key: ValueKey('A'), label: 'A'),
  ColorTile(key: ValueKey('B'), label: 'B'),
])''',
                language: 'dart',
                fileName: 'keys.dart',
                fontSize: 21,
                accent: DeckColors.dart,
              ),
              SizedBox(height: 24),
              Footnote(
                'ColorTile は StatefulWidget。色は initState で決めて State が持つ。',
                color: DeckColors.purple,
              ),
            ],
          ),
        ),
        const SizedBox(width: 56),
        Expanded(
          flex: 5,
          child: DemoFrame(
            accent: DeckColors.purple,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(40, 40, 40, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _KeyRow(
                    title: 'Key なし',
                    ok: !_swapped,
                    children: [
                      for (final (label, color) in order)
                        _ColorTile(label: label, color: color),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _KeyRow(
                    title: 'ValueKey あり',
                    ok: true,
                    children: [
                      for (final (label, color) in order)
                        _ColorTile(
                          key: ValueKey(label),
                          label: label,
                          color: color,
                        ),
                    ],
                  ),
                  const Spacer(),
                  Center(
                    child: FilledButton.icon(
                      onPressed: () => setState(() => _swapped = !_swapped),
                      icon: const Icon(Icons.swap_horiz_rounded, size: 30),
                      label: const Text('入れ替える'),
                      style: FilledButton.styleFrom(
                        backgroundColor: DeckColors.purple,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 34,
                          vertical: 20,
                        ),
                        textStyle: DeckText.body.copyWith(fontSize: 26),
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

class _KeyRow extends StatelessWidget {
  const _KeyRow({
    required this.title,
    required this.ok,
    required this.children,
  });

  final String title;
  final bool ok;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: DeckText.heading.copyWith(fontSize: 28)),
            const SizedBox(width: 16),
            Icon(
              ok ? Icons.check_circle_rounded : Icons.error_rounded,
              color: ok ? DeckColors.green : DeckColors.red,
              size: 30,
            ),
            if (!ok) ...[
              const SizedBox(width: 10),
              Text(
                'ラベルと色がズレた！',
                style: DeckText.body.copyWith(
                  fontSize: 22,
                  color: DeckColors.red,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            for (final c in children) ...[
              Expanded(child: c),
              if (c != children.last) const SizedBox(width: 20),
            ],
          ],
        ),
      ],
    );
  }
}

/// Holds its colour in State — set once, in initState.
class _ColorTile extends StatefulWidget {
  const _ColorTile({required this.label, required this.color, super.key});

  final String label;
  final Color color;

  @override
  State<_ColorTile> createState() => _ColorTileState();
}

class _ColorTileState extends State<_ColorTile> {
  late final Color _color;

  @override
  void initState() {
    super.initState();
    _color = widget.color;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.label,
            style: DeckText.display.copyWith(fontSize: 64, color: Colors.white),
          ),
          const SizedBox(width: 16),
          // The colour the *Widget* asks for, as a small dot.
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
          ),
        ],
      ),
    );
  }
}
