import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_deck/flutter_deck.dart';
import 'package:flutter_intro_talk/core/theme/kaigi_theme.dart';
import 'package:flutter_intro_talk/core/widgets/code_panel.dart';
import 'package:flutter_intro_talk/core/widgets/deck_components.dart';
import 'package:flutter_intro_talk/core/widgets/demo_frame.dart';
import 'package:flutter_intro_talk/core/widgets/motion.dart';
import 'package:flutter_intro_talk/core/widgets/phone_frame.dart';
import 'package:flutter_intro_talk/core/widgets/templates.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 04 · Widget の種類 — Stateless / Stateful, the State lifecycle,
// InheritedWidget, the Widget family tree, and Material ⇄ Cupertino.
// ─────────────────────────────────────────────────────────────────────────────

final List<FlutterDeckSlideWidget> widgetTypeSlides = [
  DividerSlideWidget(
    route: '/w-divider',
    number: '04',
    label: 'Widget Types',
    title: 'Widget の種類',
    subtitle: '状態を持つ・持たない・描く・渡す',
    accent: DeckColors.green,
  ),
  InteractiveSlideWidget(
    route: '/w-stateless-stateful',
    eyebrow: 'Two kinds',
    title: 'StatelessWidget と StatefulWidget',
    builder: (context, step) => const _TwoKinds(),
    intensity: 0.4,
  ),
  InteractiveSlideWidget(
    route: '/w-lifecycle',
    eyebrow: 'State lifecycle',
    title: 'State の一生を、ログで見る',
    builder: (context, step) => const _LifecycleDemo(),
    intensity: 0.35,
  ),
  CodeSlideWidget(
    route: '/w-inherited',
    eyebrow: 'InheritedWidget',
    title: 'InheritedWidget ── 上から下へ届ける',
    fileName: 'app_color.dart',
    fontSize: 21,
    points: const [
      'ツリーの上に置くだけで、下のどこからでも取れる',
      '依存した Widget だけが、変更時に再ビルド',
      'Theme.of・MediaQuery.of も同じ仕組み',
    ],
    footnote: '状態管理パッケージの多くは、この仕組みの上に作られている（詳しくは後半で）。',
    code: '''
class AppColor extends InheritedWidget {
  const AppColor({super.key, required this.color, required super.child});

  final Color color;

  static Color of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<AppColor>()!
      .color;

  @override
  bool updateShouldNotify(AppColor old) => color != old.color;
}

// どこからでも
final color = AppColor.of(context);
final theme = Theme.of(context);         // 中身は InheritedWidget
final size  = MediaQuery.sizeOf(context);''',
  ),
  InteractiveSlideWidget(
    route: '/w-family',
    eyebrow: 'Widget family',
    title: 'Widget の家系図',
    footnote: '画面に何かを「描く」のは RenderObjectWidget だけ。ほかは組み立て役・橋渡し役。',
    builder: (context, step) => _FamilyTree(step: step),
    steps: 4,
    intensity: 0.4,
  ),
  InteractiveSlideWidget(
    route: '/w-adaptive',
    eyebrow: 'Material ⇄ Cupertino',
    title: '同じコードで、Android らしく・iOS らしく',
    builder: (context, step) => const _AdaptiveDemo(),
    intensity: 0.35,
  ),
];

// ── /w-stateless-stateful ───────────────────────────────────────────────────

class _TwoKinds extends StatelessWidget {
  const _TwoKinds();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _KindColumn(
            badge: 'StatelessWidget',
            caption: '外から渡された値だけで決まる',
            color: DeckColors.cyan,
            code: '''
class Greeting extends StatelessWidget {
  const Greeting({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Text('こんにちは、\$name さん');
  }
}''',
            demo: _GreetingDemo(),
          ),
        ),
        SizedBox(width: 40),
        Expanded(
          child: _KindColumn(
            badge: 'StatefulWidget',
            caption: '自分で覚えておく値（State）がある',
            color: DeckColors.purple,
            code: '''
class LikeButton extends StatefulWidget {
  const LikeButton({super.key});

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(_liked ? Icons.favorite : Icons.favorite_border),
      onPressed: () => setState(() => _liked = !_liked),
    );
  }
}''',
            demo: _LikeDemo(),
          ),
        ),
      ],
    );
  }
}

class _KindColumn extends StatelessWidget {
  const _KindColumn({
    required this.badge,
    required this.caption,
    required this.color,
    required this.code,
    required this.demo,
  });

  final String badge;
  final String caption;
  final Color color;
  final String code;
  final Widget demo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Pill(badge, color: color, fontSize: 22, mono: true),
            const SizedBox(width: 18),
            Expanded(child: Text(caption, style: DeckText.bodySecondary)),
          ],
        ),
        const SizedBox(height: 18),
        Expanded(
          child: CodePanel(
            code,
            language: 'dart',
            fileName: '${badge.toLowerCase()}.dart',
            fontSize: 18,
            accent: color,
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 110,
          child: DemoFrame(accent: color, radius: 18, child: demo),
        ),
      ],
    );
  }
}

class _GreetingDemo extends StatelessWidget {
  const _GreetingDemo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'こんにちは、FlutterKaigi さん',
        style: DeckText.body.copyWith(fontSize: 30),
      ),
    );
  }
}

class _LikeDemo extends StatefulWidget {
  const _LikeDemo();

  @override
  State<_LikeDemo> createState() => _LikeDemoState();
}

class _LikeDemoState extends State<_LikeDemo> {
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            iconSize: 52,
            color: DeckColors.pink,
            icon: Icon(_liked ? Icons.favorite : Icons.favorite_border),
            onPressed: () => setState(() => _liked = !_liked),
          ),
          const SizedBox(width: 12),
          Text(
            _liked ? 'State: _liked = true' : 'タップしてみて',
            style: DeckText.mono.copyWith(
              fontSize: 22,
              color: _liked ? DeckColors.pink : DeckColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── /w-lifecycle ────────────────────────────────────────────────────────────

class _LogEntry {
  const _LogEntry(this.ms, this.name);

  final int ms;
  final String name;
}

/// Collects lifecycle calls. Calls arrive during build, so listeners are
/// notified after the frame, never synchronously.
class _LifecycleLog extends ChangeNotifier {
  final _start = DateTime.now();
  final entries = <_LogEntry>[];
  bool _scheduled = false;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void add(String name) {
    if (_disposed) return;
    entries.add(
      _LogEntry(DateTime.now().difference(_start).inMilliseconds, name),
    );
    if (entries.length > 200) entries.removeAt(0);
    if (_scheduled) return;
    _scheduled = true;
    SchedulerBinding.instance
      ..addPostFrameCallback((_) {
        _scheduled = false;
        if (!_disposed) notifyListeners();
      })
      ..ensureVisualUpdate();
  }

  void clear() {
    entries.clear();
    notifyListeners();
  }
}

const _methodColors = <String, Color>{
  'createState()': DeckColors.purple,
  'initState()': DeckColors.green,
  'didChangeDependencies()': DeckColors.cyan,
  'build()': DeckColors.dart,
  'didUpdateWidget()': DeckColors.orange,
  'setState()': DeckColors.pink,
  'deactivate()': DeckColors.textSecondary,
  'dispose()': DeckColors.red,
};

class _Mood extends InheritedWidget {
  const _Mood({required this.value, required super.child});

  final int value;

  static int of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_Mood>()!.value;

  @override
  bool updateShouldNotify(_Mood old) => value != old.value;
}

class _LifecycleDemo extends StatefulWidget {
  const _LifecycleDemo();

  @override
  State<_LifecycleDemo> createState() => _LifecycleDemoState();
}

class _LifecycleDemoState extends State<_LifecycleDemo> {
  final _log = _LifecycleLog();
  bool _mounted = true;
  int _propColor = 0;
  int _mood = 0;

  static const _colors = [DeckColors.cyan, DeckColors.orange, DeckColors.green];
  static const _moods = ['☀️ 晴れ', '🌧 雨', '❄️ 雪'];

  @override
  void dispose() {
    _log.dispose();
    super.dispose();
  }

  Widget _button(String label, IconData icon, Color color, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 24),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.7), width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        textStyle: DeckText.body.copyWith(fontSize: 21),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 11,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  _button(
                    _mounted ? 'アンマウント' : 'マウント',
                    _mounted ? Icons.eject_rounded : Icons.add_box_rounded,
                    _mounted ? DeckColors.red : DeckColors.green,
                    () => setState(() => _mounted = !_mounted),
                  ),
                  _button(
                    'props を変える',
                    Icons.palette_rounded,
                    DeckColors.orange,
                    () => setState(
                      () => _propColor = (_propColor + 1) % _colors.length,
                    ),
                  ),
                  _button(
                    'InheritedWidget を変える',
                    Icons.cloud_rounded,
                    DeckColors.cyan,
                    () => setState(() => _mood = (_mood + 1) % _moods.length),
                  ),
                  _button(
                    'ログを消す',
                    Icons.delete_sweep_rounded,
                    DeckColors.textSecondary,
                    _log.clear,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Expanded(
                child: DemoFrame(
                  accent: DeckColors.green,
                  child: _Mood(
                    value: _mood,
                    child: Center(
                      child: _mounted
                          ? _Probe(
                              color: _colors[_propColor],
                              moods: _moods,
                              log: _log,
                            )
                          : Text(
                              '（ツリーから外れています）',
                              style: DeckText.bodySecondary,
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              ListenableBuilder(
                listenable: _log,
                builder: (context, _) => _LifecycleFlow(
                  last: _log.entries.isEmpty ? null : _log.entries.last.name,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 36),
        Expanded(
          flex: 8,
          child: Container(
            padding: const EdgeInsets.fromLTRB(26, 20, 26, 20),
            decoration: BoxDecoration(
              color: const Color(0xFF10101A),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: DeckColors.green.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: ListenableBuilder(
              listenable: _log,
              builder: (context, _) {
                final entries = _log.entries;
                final shown = entries.sublist(math.max(0, entries.length - 15));
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'debug console',
                      style: DeckText.monoSmall.copyWith(
                        color: DeckColors.textTertiary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final (i, e) in shown.indexed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Opacity(
                          opacity: 0.45 + 0.55 * ((i + 1) / shown.length),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 110,
                                child: Text(
                                  '+${e.ms}ms',
                                  style: DeckText.monoSmall.copyWith(
                                    fontSize: 17,
                                    color: DeckColors.textTertiary,
                                  ),
                                ),
                              ),
                              Text(
                                e.name,
                                style: DeckText.mono.copyWith(
                                  fontSize: 22,
                                  color:
                                      _methodColors[e.name] ?? DeckColors.text,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// The widget whose lifecycle is being logged.
class _Probe extends StatefulWidget {
  const _Probe({required this.color, required this.moods, required this.log});

  final Color color;
  final List<String> moods;
  final _LifecycleLog log;

  @override
  // ignore: no_logic_in_create_state
  State<_Probe> createState() {
    log.add('createState()');
    return _ProbeState();
  }
}

class _ProbeState extends State<_Probe> {
  int _taps = 0;
  int _mood = 0;

  @override
  void initState() {
    super.initState();
    widget.log.add('initState()');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mood = _Mood.of(context);
    widget.log.add('didChangeDependencies()');
  }

  @override
  void didUpdateWidget(_Probe oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.log.add('didUpdateWidget()');
  }

  @override
  void deactivate() {
    widget.log.add('deactivate()');
    super.deactivate();
  }

  @override
  void dispose() {
    widget.log.add('dispose()');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.log.add('build()');
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 460,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: widget.color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.color, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'props: color ・ inherited: ${widget.moods[_mood]}',
            style: DeckText.caption.copyWith(color: DeckColors.text),
          ),
          const SizedBox(height: 10),
          Text(
            'State: _taps = $_taps',
            style: DeckText.mono.copyWith(fontSize: 28, color: widget.color),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () {
              widget.log.add('setState()');
              setState(() => _taps++);
            },
            style: FilledButton.styleFrom(
              backgroundColor: widget.color,
              foregroundColor: Colors.black,
              textStyle: DeckText.body.copyWith(fontSize: 22),
            ),
            child: const Text('setState'),
          ),
        ],
      ),
    );
  }
}

class _LifecycleFlow extends StatelessWidget {
  const _LifecycleFlow({required this.last});

  final String? last;

  @override
  Widget build(BuildContext context) {
    const order = [
      'createState()',
      'initState()',
      'didChangeDependencies()',
      'build()',
      'didUpdateWidget()',
      'setState()',
      'deactivate()',
      'dispose()',
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final (i, m) in order.indexed) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: m == last
                  ? _methodColors[m]!.withValues(alpha: 0.4)
                  : _methodColors[m]!.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _methodColors[m]!.withValues(
                  alpha: m == last ? 1 : 0.35,
                ),
              ),
            ),
            child: Text(
              m.replaceAll('()', ''),
              style: DeckText.monoSmall.copyWith(fontSize: 15),
            ),
          ),
          if (i != order.length - 1)
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: DeckColors.textTertiary,
            ),
        ],
      ],
    );
  }
}

// ── /w-family ───────────────────────────────────────────────────────────────

class _FamilyTree extends StatelessWidget {
  const _FamilyTree({required this.step});

  final int step;

  static const _cards = [
    CardSpec(
      badge: 'StatelessWidget',
      title: '組み立てるだけ',
      accent: DeckColors.cyan,
      lines: [
        'build() で他の Widget を返す',
        '例：Text, Icon,',
        'FloatingActionButton',
      ],
    ),
    CardSpec(
      badge: 'StatefulWidget',
      title: '状態を持つ',
      accent: DeckColors.purple,
      lines: ['State が Element に住む', '例：Scaffold, TextField,', 'Checkbox'],
    ),
    CardSpec(
      badge: 'RenderObjectWidget',
      title: '描く・並べる',
      accent: DeckColors.orange,
      lines: [
        'Leaf：RawImage',
        'SingleChild：Padding, Align',
        'MultiChild：Row, Column, Stack',
      ],
    ),
    CardSpec(
      badge: 'ProxyWidget',
      title: '情報を渡す',
      accent: DeckColors.green,
      lines: [
        'InheritedWidget：',
        '  MediaQuery, Theme の中身',
        'ParentDataWidget：',
        '  Expanded, Positioned',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Pill('Widget', color: DeckColors.text, fontSize: 30, mono: true),
        SizedBox(
          height: 90,
          width: double.infinity,
          child: CustomPaint(painter: _FamilyLines(visible: step)),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < _cards.length; i++) ...[
                if (i > 0) const SizedBox(width: 24),
                Expanded(
                  child: StaggerIn(
                    visible: step > i,
                    child: TitledCard(
                      badge: _cards[i].badge,
                      title: _cards[i].title,
                      lines: _cards[i].lines,
                      accent: _cards[i].accent,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _FamilyLines extends CustomPainter {
  _FamilyLines({required this.visible});

  final int visible;

  static const _colors = [
    DeckColors.cyan,
    DeckColors.purple,
    DeckColors.orange,
    DeckColors.green,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const gap = 24.0;
    final w = (size.width - gap * 3) / 4;
    final top = Offset(size.width / 2, 0);
    for (var i = 0; i < 4; i++) {
      final x = i * (w + gap) + w / 2;
      final path = Path()
        ..moveTo(top.dx, top.dy)
        ..cubicTo(
          top.dx,
          size.height * 0.6,
          x,
          size.height * 0.4,
          x,
          size.height,
        );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = _colors[i].withValues(alpha: visible > i ? 0.8 : 0.12),
      );
    }
  }

  @override
  bool shouldRepaint(_FamilyLines old) => old.visible != visible;
}

// ── /w-adaptive ─────────────────────────────────────────────────────────────

class _AdaptiveDemo extends StatefulWidget {
  const _AdaptiveDemo();

  @override
  State<_AdaptiveDemo> createState() => _AdaptiveDemoState();
}

class _AdaptiveDemoState extends State<_AdaptiveDemo> {
  bool _on = true;
  bool _checked = false;
  double _value = 0.4;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _phone(TargetPlatform.android),
        const SizedBox(width: 40),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: CodePanel(
                  '''
// 同じ1行が、OS ごとの見た目に
Switch.adaptive(value: on, onChanged: …)
Slider.adaptive(value: v, onChanged: …)
Checkbox.adaptive(value: c, onChanged: …)
CircularProgressIndicator.adaptive()

showAdaptiveDialog(
  context: context,
  builder: (_) => AlertDialog.adaptive(
    title: Text('保存しますか？'),
    actions: [...],
  ),
);''',
                  language: 'dart',
                  fileName: 'adaptive.dart',
                  fontSize: 20,
                  accent: DeckColors.dart,
                ),
              ),
              SizedBox(height: 20),
              CalloutBox(
                label: 'ポイント',
                isProblem: false,
                lines: ['Theme の platform で切り替わる', '全 OS で同じデザインにするのも自由'],
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),
        _phone(TargetPlatform.iOS),
      ],
    );
  }

  ThemeData _theme(TargetPlatform platform) => ThemeData(
    useMaterial3: true,
    platform: platform,
    colorScheme: ColorScheme.fromSeed(seedColor: DeckColors.blue),
  );

  Widget _phone(TargetPlatform platform) {
    final ios = platform == TargetPlatform.iOS;
    final theme = _theme(platform);
    return Column(
      children: [
        Pill(
          ios ? 'iOS ── Cupertino' : 'Android ── Material',
          color: ios ? DeckColors.text : DeckColors.green,
          fontSize: 20,
        ),
        const SizedBox(height: 14),
        Expanded(
          child: FittedBox(
            child: PhoneFrame(
              width: 330,
              style: ios ? PhoneStyle.ios : PhoneStyle.android,
              accent: ios ? DeckColors.text : DeckColors.green,
              child: Theme(
                data: theme,
                child: Builder(builder: (context) => _screen(context, ios)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _screen(BuildContext context, bool ios) {
    final theme = Theme.of(context);
    Widget row(String label, Widget child) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
          child,
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          row(
            '通知',
            Switch.adaptive(
              value: _on,
              onChanged: (v) => setState(() => _on = v),
            ),
          ),
          row(
            '同意する',
            Checkbox.adaptive(
              value: _checked,
              onChanged: (v) => setState(() => _checked = v ?? false),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Slider.adaptive(
              value: _value,
              onChanged: (v) => setState(() => _value = v),
            ),
          ),
          const SizedBox(height: 10),
          const Center(child: CircularProgressIndicator.adaptive()),
          const SizedBox(height: 22),
          Center(
            child: ios
                ? CupertinoButton.filled(
                    onPressed: () => _dialog(context, theme),
                    child: const Text('ダイアログ'),
                  )
                : FilledButton(
                    onPressed: () => _dialog(context, theme),
                    child: const Text('ダイアログ'),
                  ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => _date(context, theme, ios),
              child: const Text('日付を選ぶ'),
            ),
          ),
        ],
      ),
    );
  }

  void _dialog(BuildContext context, ThemeData theme) {
    final ios = theme.platform == TargetPlatform.iOS;
    showAdaptiveDialog<void>(
      context: context,
      builder: (dialogContext) {
        Widget action(String label) => ios
            ? CupertinoDialogAction(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(label),
              )
            : TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(label),
              );
        return Theme(
          data: theme,
          child: AlertDialog.adaptive(
            title: const Text('保存しますか？'),
            content: const Text('同じコードから、OS らしいダイアログ。'),
            actions: [action('キャンセル'), action('保存')],
          ),
        );
      },
    );
  }

  void _date(BuildContext context, ThemeData theme, bool ios) {
    if (!ios) {
      showDatePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        initialDate: DateTime(2026, 11, 19),
        builder: (context, child) => Theme(data: theme, child: child!),
      );
      return;
    }
    showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => Container(
        height: 280,
        color: CupertinoColors.systemBackground,
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.date,
          initialDateTime: DateTime(2026, 11, 19),
          onDateTimeChanged: (_) {},
        ),
      ),
    );
  }
}
