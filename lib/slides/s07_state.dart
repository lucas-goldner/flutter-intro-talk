import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_deck/flutter_deck.dart';
import 'package:flutter_intro_talk/core/theme/kaigi_theme.dart';
import 'package:flutter_intro_talk/core/widgets/deck_components.dart';
import 'package:flutter_intro_talk/core/widgets/templates.dart';
import 'package:flutter_intro_talk/core/widgets/wwdc_background.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 05 · 状態管理 — setState → InheritedWidget → Riverpod / BLoC
// ─────────────────────────────────────────────────────────────────────────────

final List<FlutterDeckSlideWidget> stateSlides = [
  DividerSlideWidget(
    route: '/s-divider',
    number: '05',
    label: 'State management',
    title: '状態管理',
    subtitle: '「その値、誰が持って、誰に届ける？」',
    mood: GradientMood.cool,
    accent: DeckColors.green,
  ),
  CardGridSlideWidget(
    route: '/s-kinds',
    eyebrow: 'Two kinds of state',
    title: '状態には、2種類ある',
    columns: 2,
    childAspectRatio: 2.1,
    footnote: 'Ephemeral は setState で十分。悩むのは App state の方。',
    cards: const [
      CardSpec(
        badge: 'EPHEMERAL STATE',
        title: '1つの Widget の中だけ',
        accent: DeckColors.cyan,
        lines: [
          '・TextField に入力中の文字',
          '・選択中のタブ',
          '・アニメーションの進み具合',
          '→ setState で OK',
        ],
      ),
      CardSpec(
        badge: 'APP STATE',
        title: 'アプリ全体で共有',
        accent: DeckColors.pink,
        lines: ['・ログイン中のユーザー', '・カートの中身・お気に入り', '・設定（テーマ・言語）', '→ 状態管理の出番'],
      ),
    ],
  ),
  CodeSlideWidget(
    route: '/s-prop-drilling-code',
    eyebrow: 'setState の限界',
    title: '深い Widget に値を届けるには…',
    fileName: 'prop_drilling.dart',
    fontSize: 19,
    points: const [
      '状態は一番上の State に',
      '途中の Widget は受け取って渡すだけ',
      'これが Prop drilling',
    ],
    code: _propDrillingCode,
  ),
  InteractiveSlideWidget(
    route: '/s-prop-drilling-demo',
    eyebrow: 'Prop drilling vs InheritedWidget',
    title: '値はどこを通って届く？',
    intensity: 0.4,
    builder: _propDrillingDemo,
  ),
  CodeSlideWidget(
    route: '/s-inherited-widget',
    eyebrow: 'InheritedWidget',
    title: 'ツリーの上から、直接届ける',
    fileName: 'app_theme.dart',
    fontSize: 20,
    points: const [
      'ツリーに「置いておく」だけ',
      'of(context) でどこからでも取得',
      '使った Widget だけが rebuild',
      'Theme.of / MediaQuery.of も実はこれ',
    ],
    code: _inheritedCode,
  ),
  CardGridSlideWidget(
    route: '/s-why-riverpod',
    eyebrow: 'Provider → Riverpod',
    title: 'そこで Riverpod',
    columns: 3,
    childAspectRatio: 1.95,
    footnote: 'Provider は InheritedWidget を使いやすくしたもの。Riverpod は同じ作者による、その次の世代。',
    cards: const [
      CardSpec(
        badge: 'SAFE',
        title: 'コンパイル時に安全',
        accent: DeckColors.green,
        lines: ['ProviderNotFoundException が', '起きない'],
      ),
      CardSpec(
        badge: 'NO CONTEXT',
        title: 'BuildContext 不要',
        accent: DeckColors.cyan,
        lines: ['Widget の外からでも', '状態を読める'],
      ),
      CardSpec(
        badge: 'TESTABLE',
        title: '差し替えが簡単',
        accent: DeckColors.blue,
        lines: ['overrides で', 'Fake に置き換え'],
      ),
      CardSpec(
        badge: 'AUTO DISPOSE',
        title: '自動で破棄',
        accent: DeckColors.purple,
        lines: ['誰も見ていない状態は', 'メモリから消える'],
      ),
      CardSpec(
        badge: 'ASYNC',
        title: '非同期が標準',
        accent: DeckColors.pink,
        lines: ['loading / error / data を', 'AsyncValue で表現'],
      ),
      CardSpec(
        badge: 'SELECT',
        title: '必要な分だけ rebuild',
        accent: DeckColors.orange,
        lines: ['select で', '一部の変化だけ購読'],
      ),
    ],
  ),
  CodeSlideWidget(
    route: '/s-riverpod-basics',
    eyebrow: 'Riverpod の基本',
    title: 'Notifier ＋ Provider ＋ ref',
    fileName: 'counter.dart',
    fontSize: 19,
    points: const [
      'Notifier が状態とロジックを持つ',
      'Provider はグローバルに宣言',
      'build の中は ref.watch',
      'イベントの中は ref.read',
    ],
    code: _riverpodBasicsCode,
  ),
  InteractiveSlideWidget(
    route: '/s-riverpod-live',
    eyebrow: 'LIVE · flutter_riverpod',
    title: 'rebuild されるのは、見ている Widget だけ',
    intensity: 0.4,
    footnote: 'select を使うと「レベルが変わった時」だけ rebuild される。',
    builder: _riverpodLiveDemo,
  ),
  QuizSlideWidget(
    route: '/s-quiz-watch-read',
    question: 'ボタンの onPressed の中で使うのは？',
    options: const [
      'ref.watch(counterProvider)',
      'ref.read(counterProvider.notifier)',
      'どちらでも同じ',
    ],
    answer: 1,
    explanation: 'watch は build の中で「購読」する。read はイベントの中で「今の値を一度だけ」読む。',
  ),
  CodeSlideWidget(
    route: '/s-async-value',
    eyebrow: 'AsyncNotifier / AsyncValue',
    title: '非同期の3状態を、型で網羅',
    fileName: 'user_view_model.dart',
    fontSize: 20,
    points: const [
      'build() が Future を返すだけ',
      'loading / error / data は Riverpod が管理',
      'sealed class なので switch で漏れなく',
    ],
    code: _asyncValueCode,
  ),
  CodeSlideWidget(
    route: '/s-bloc-code',
    eyebrow: 'BLoC',
    title: 'イベントを入れて、状態を受け取る',
    fileName: 'counter_bloc.dart',
    fontSize: 19,
    points: const [
      'UI は Event を add するだけ',
      'Bloc が Event を State に変換',
      'BlocBuilder が State を描画',
      '大規模チームで人気',
    ],
    code: _blocCode,
  ),
  InteractiveSlideWidget(
    route: '/s-bloc-stream',
    eyebrow: 'BLoC = Business Logic Component',
    title: 'Event の流れと State の流れ',
    intensity: 0.4,
    footnote: 'UI → Event → Bloc → State → UI。流れが一方向なので追いやすい。',
    builder: _blocStreamDemo,
  ),
  InteractiveSlideWidget(
    route: '/s-comparison',
    eyebrow: 'どれを選ぶ？',
    title: '状態管理の比較',
    intensity: 0.4,
    footnote: '迷ったら：小さく setState、共有するなら Riverpod。チームの慣れも大事。',
    builder: _comparisonTable,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Code listings
// ─────────────────────────────────────────────────────────────────────────────

const _propDrillingCode = '''
class _AppState extends State<App> {
  Color _color = Colors.pink;

  @override
  Widget build(BuildContext context) => HomePage(
        color: _color,
        onChanged: (c) => setState(() => _color = c),
      );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.color, required this.onChanged});

  final Color color;                  // 自分では使わない…
  final ValueChanged<Color> onChanged; // …でも子に渡すために必要

  @override
  Widget build(BuildContext context) =>
      Body(color: color, onChanged: onChanged);
}

// Body → Section → Card → ThemedButton … まだまだ続く
''';

const _inheritedCode = '''
class AppTheme extends InheritedWidget {
  const AppTheme({super.key, required this.color, required super.child});

  final Color color;

  static AppTheme of(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<AppTheme>();
    assert(theme != null, 'AppTheme が見つかりません');
    return theme!;
  }

  // true のとき、of(context) を呼んだ Widget が rebuild される
  @override
  bool updateShouldNotify(AppTheme old) => color != old.color;
}

// どれだけ深くても、1行で届く
final color = AppTheme.of(context).color;
''';

const _riverpodBasicsCode = '''
class Counter extends Notifier<int> {
  @override
  int build() => 0; // 初期値

  void increment() => state++;
}

final counterProvider = NotifierProvider<Counter, int>(Counter.new);

class CounterText extends ConsumerWidget {
  const CounterText({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider); // 変わったら rebuild
    return Text('\$count');
  }
}

// ボタンの中では read
onPressed: () => ref.read(counterProvider.notifier).increment(),

// アプリ全体を ProviderScope で包む
void main() => runApp(const ProviderScope(child: MyApp()));
''';

const _asyncValueCode = '''
class UserViewModel extends AsyncNotifier<User> {
  @override
  Future<User> build() => ref.watch(userRepositoryProvider).fetchMe();
}

final userProvider =
    AsyncNotifierProvider<UserViewModel, User>(UserViewModel.new);

// UI 側
@override
Widget build(BuildContext context, WidgetRef ref) {
  final user = ref.watch(userProvider);
  return switch (user) {
    AsyncData(:final value) => Text('こんにちは、\${value.name}さん'),
    AsyncError(:final error) => Text('エラー: \$error'),
    AsyncLoading() => const CircularProgressIndicator(),
  };
}
''';

const _blocCode = '''
sealed class CounterEvent {}
final class Incremented extends CounterEvent {}
final class Decremented extends CounterEvent {}
final class Reset extends CounterEvent {}

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<Incremented>((event, emit) => emit(state + 1));
    on<Decremented>((event, emit) => emit(state - 1));
    on<Reset>((event, emit) => emit(0));
  }
}

// UI：Event を投げる
context.read<CounterBloc>().add(Incremented());

// UI：State を受け取って描く
BlocBuilder<CounterBloc, int>(
  builder: (context, count) => Text('\$count'),
)
''';

// ─────────────────────────────────────────────────────────────────────────────
// 🎮 Prop drilling vs InheritedWidget
// ─────────────────────────────────────────────────────────────────────────────

Widget _propDrillingDemo(BuildContext context, int step) =>
    const _PropDrillingDemo();

class _TreeNode {
  const _TreeNode(
    this.id,
    this.label,
    this.x,
    this.depth, {
    this.parent,
    this.dependent = false,
  });

  final String id;
  final String label;
  final double x;
  final int depth;
  final String? parent;

  /// Actually reads the theme colour.
  final bool dependent;
}

const _nodes = [
  _TreeNode('app', 'App', 0.5, 0),
  _TreeNode('home', 'HomePage', 0.5, 1, parent: 'app'),
  _TreeNode('appbar', 'AppBar', 0.2, 2, parent: 'home'),
  _TreeNode('body', 'Body', 0.68, 2, parent: 'home'),
  _TreeNode('title', 'Title', 0.2, 3, parent: 'appbar', dependent: true),
  _TreeNode('sidebar', 'Sidebar', 0.5, 3, parent: 'body'),
  _TreeNode('section', 'Section', 0.84, 3, parent: 'body'),
  _TreeNode('menu', 'Menu', 0.5, 4, parent: 'sidebar'),
  _TreeNode('card', 'Card', 0.84, 4, parent: 'section'),
  _TreeNode('button', 'ThemedButton', 0.84, 5, parent: 'card', dependent: true),
];

const _maxDepth = 5;

class _PropDrillingDemo extends StatefulWidget {
  const _PropDrillingDemo();

  @override
  State<_PropDrillingDemo> createState() => _PropDrillingDemoState();
}

class _PropDrillingDemoState extends State<_PropDrillingDemo>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..value = 1;

  bool _inherited = false;
  bool _pink = true;
  int? _lastRebuilds;

  Color get _themeColor => _pink ? DeckColors.pink : DeckColors.cyan;
  Color get _previousColor => _pink ? DeckColors.cyan : DeckColors.pink;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _fire() {
    setState(() {
      _pink = !_pink;
      _lastRebuilds = _inherited
          ? _nodes.where((n) => n.dependent).length
          : _nodes.length - 1; // every widget below App
    });
    _controller.forward(from: 0);
  }

  /// When (0..1 of the animation) the new value reaches [node].
  double _arrival(_TreeNode node) {
    if (_inherited) return node.dependent ? 0.55 : double.infinity;
    if (node.depth == 0) return 0;
    return 0.08 + (node.depth - 1) / (_maxDepth - 1) * 0.6;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: DeckCard(
            accent: DeckColors.textTertiary,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => LayoutBuilder(
                builder: (context, constraints) =>
                    _buildTree(constraints.biggest, _controller.value),
              ),
            ),
          ),
        ),
        const SizedBox(width: 40),
        SizedBox(width: 440, child: _buildPanel()),
      ],
    );
  }

  Widget _buildTree(Size size, double t) {
    const nodeW = 200.0;
    const nodeH = 58.0;
    Offset center(_TreeNode n) => Offset(
      n.x * size.width,
      nodeH / 2 + n.depth / _maxDepth * (size.height - nodeH),
    );
    final byId = {for (final n in _nodes) n.id: n};
    final animating = _controller.isAnimating || t < 1;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _TreePainter(
              edges: [
                for (final n in _nodes)
                  if (n.parent != null)
                    (
                      center(byId[n.parent]!),
                      center(n),
                      // Edge lights up as the value travels through it.
                      !_inherited && animating && t >= _arrival(n)
                          ? (1 - ((t - _arrival(n)) / 0.5)).clamp(0.0, 1.0)
                          : 0.0,
                    ),
              ],
              jumps: _inherited && animating
                  ? [
                      for (final n in _nodes.where((n) => n.dependent))
                        (center(byId['app']!), center(n)),
                    ]
                  : const [],
              progress: (t / 0.55).clamp(0.0, 1.0),
              color: _themeColor,
            ),
          ),
        ),
        for (final n in _nodes)
          Positioned(
            left: center(n).dx - nodeW / 2,
            top: center(n).dy - nodeH / 2,
            width: nodeW,
            height: nodeH,
            child: _NodeChip(
              node: n,
              isRoot: n.depth == 0,
              inherited: _inherited,
              glow: animating && t >= _arrival(n)
                  ? (1 - ((t - _arrival(n)) / 0.4)).clamp(0.0, 1.0)
                  : 0.0,
              color: n.dependent || n.depth == 0
                  ? (t >= _arrival(n) ? _themeColor : _previousColor)
                  : null,
            ),
          ),
      ],
    );
  }

  Widget _buildPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('渡し方', style: DeckText.caption),
        const SizedBox(height: 12),
        _ModeButton(
          label: 'setState ＋ 引数',
          selected: !_inherited,
          color: DeckColors.orange,
          onTap: () => setState(() => _inherited = false),
        ),
        const SizedBox(height: 12),
        _ModeButton(
          label: 'InheritedWidget',
          selected: _inherited,
          color: DeckColors.green,
          onTap: () => setState(() => _inherited = true),
        ),
        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: _fire,
          style: FilledButton.styleFrom(
            backgroundColor: _themeColor,
            padding: const EdgeInsets.symmetric(vertical: 22),
            textStyle: DeckText.heading.copyWith(fontSize: 28),
          ),
          icon: const Icon(Icons.palette_rounded, size: 30),
          label: const Text('テーマを変える'),
        ),
        const Spacer(),
        DeckCard(
          accent: _inherited ? DeckColors.green : DeckColors.orange,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('rebuild された Widget', style: DeckText.caption),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _lastRebuilds == null ? '–' : '$_lastRebuilds',
                    style: DeckText.display.copyWith(
                      color: _inherited ? DeckColors.green : DeckColors.orange,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('個', style: DeckText.heading),
                ],
              ),
              Text(
                '実際に色を使うのは 2 個だけ',
                style: DeckText.caption.copyWith(fontSize: 19),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'ボタンを押してみて',
          style: DeckText.caption.copyWith(color: Colors.white38),
        ),
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: selected ? 0.2 : 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: selected ? 0.9 : 0.25),
              width: selected ? 2.5 : 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: color,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    style: DeckText.mono.copyWith(
                      fontSize: 24,
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

class _NodeChip extends StatelessWidget {
  const _NodeChip({
    required this.node,
    required this.isRoot,
    required this.inherited,
    required this.glow,
    required this.color,
  });

  final _TreeNode node;
  final bool isRoot;
  final bool inherited;
  final double glow;

  /// The theme colour this node currently shows, for the root and the two
  /// widgets that actually use it.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final base = color ?? DeckColors.textTertiary;
    final flash = Color.lerp(base, Colors.white, glow * 0.6)!;
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Color.lerp(
          DeckColors.surface,
          (color ?? DeckColors.orange).withValues(alpha: 0.55),
          glow,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: flash.withValues(alpha: color != null ? 0.95 : 0.5),
          width: color != null ? 2.5 : 1.5,
        ),
        boxShadow: [
          if (glow > 0)
            BoxShadow(
              color: (color ?? DeckColors.orange).withValues(alpha: glow * 0.7),
              blurRadius: 30 * glow,
            ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isRoot && inherited ? 'AppTheme' : node.label,
              style: DeckText.mono.copyWith(
                fontSize: 20,
                color: color != null
                    ? DeckColors.text
                    : DeckColors.textSecondary,
                height: 1.1,
              ),
            ),
            if (isRoot || node.dependent)
              Text(
                isRoot ? '状態を持つ' : 'color を使う',
                style: DeckText.caption.copyWith(fontSize: 13, height: 1.2),
              ),
          ],
        ),
      ),
    );
  }
}

class _TreePainter extends CustomPainter {
  _TreePainter({
    required this.edges,
    required this.jumps,
    required this.progress,
    required this.color,
  });

  /// (from, to, highlight 0..1)
  final List<(Offset, Offset, double)> edges;

  /// Direct InheritedWidget deliveries, drawn as arcs with a travelling dot.
  final List<(Offset, Offset)> jumps;
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    for (final (a, b, h) in edges) {
      canvas.drawLine(
        a,
        b,
        Paint()
          ..color = Color.lerp(Colors.white.withValues(alpha: 0.18), color, h)!
          ..strokeWidth = 2 + 4 * h,
      );
    }
    for (final (a, b) in jumps) {
      final control = Offset(
        (a.dx + b.dx) / 2 + (b.dx < a.dx ? -160 : 160),
        (a.dy + b.dy) / 2 - 40,
      );
      final path = Path()
        ..moveTo(a.dx, a.dy)
        ..quadraticBezierTo(control.dx, control.dy, b.dx, b.dy);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = color.withValues(alpha: 0.6),
      );
      final p = progress;
      final dot = Offset(
        math.pow(1 - p, 2) * a.dx + 2 * (1 - p) * p * control.dx + p * p * b.dx,
        math.pow(1 - p, 2) * a.dy + 2 * (1 - p) * p * control.dy + p * p * b.dy,
      );
      canvas
        ..drawCircle(dot, 18, Paint()..color = color.withValues(alpha: 0.3))
        ..drawCircle(dot, 10, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_TreePainter old) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// 🎮 Riverpod — only the widgets that watch rebuild
// ─────────────────────────────────────────────────────────────────────────────

class _Counter extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
}

final _counterProvider = NotifierProvider<_Counter, int>(_Counter.new);

Widget _riverpodLiveDemo(BuildContext context, int step) =>
    const ProviderScope(child: _RiverpodPlayground());

class _RiverpodPlayground extends StatelessWidget {
  const _RiverpodPlayground();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _WatchCountCard()),
        SizedBox(width: 28),
        Expanded(child: _SelectLevelCard()),
        SizedBox(width: 28),
        Expanded(child: _ReadButtonCard()),
      ],
    );
  }
}

/// Shared look of the three cards: what the widget does in code, its live
/// output, and how many times its build() has run.
class _ProbeCard extends StatelessWidget {
  const _ProbeCard({
    required this.badge,
    required this.code,
    required this.builds,
    required this.accent,
    required this.child,
  });

  final String badge;
  final String code;
  final int builds;
  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DeckCard(
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Pill(badge, color: accent, fontSize: 18),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF10101A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              code,
              style: DeckText.monoSmall.copyWith(
                color: DeckColors.dart,
                fontSize: 18,
              ),
            ),
          ),
          Expanded(child: Center(child: child)),
          // Flashes every time build() runs.
          TweenAnimationBuilder<double>(
            key: ValueKey(builds),
            tween: Tween(begin: 1, end: 0),
            duration: const Duration(milliseconds: 900),
            builder: (context, glow, _) => Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              decoration: BoxDecoration(
                color: Color.lerp(
                  Colors.white.withValues(alpha: 0.04),
                  accent.withValues(alpha: 0.45),
                  builds > 1 ? glow : 0,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Text('build()', style: DeckText.mono.copyWith(fontSize: 22)),
                  const Spacer(),
                  Text(
                    '× $builds',
                    style: DeckText.heading.copyWith(color: accent),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WatchCountCard extends ConsumerStatefulWidget {
  const _WatchCountCard();

  @override
  ConsumerState<_WatchCountCard> createState() => _WatchCountCardState();
}

class _WatchCountCardState extends ConsumerState<_WatchCountCard> {
  int _builds = 0;

  @override
  Widget build(BuildContext context) {
    _builds++; // demo only: count how often build runs
    final count = ref.watch(_counterProvider);
    return _ProbeCard(
      badge: 'WATCH',
      code: 'ref.watch(counterProvider)',
      builds: _builds,
      accent: DeckColors.cyan,
      child: Text('$count', style: DeckText.display.copyWith(fontSize: 140)),
    );
  }
}

class _SelectLevelCard extends ConsumerStatefulWidget {
  const _SelectLevelCard();

  @override
  ConsumerState<_SelectLevelCard> createState() => _SelectLevelCardState();
}

class _SelectLevelCardState extends ConsumerState<_SelectLevelCard> {
  int _builds = 0;

  @override
  Widget build(BuildContext context) {
    _builds++;
    final level = ref.watch(_counterProvider.select((c) => c ~/ 5));
    return _ProbeCard(
      badge: 'SELECT',
      code: 'ref.watch(counterProvider\n  .select((c) => c ~/ 5))',
      builds: _builds,
      accent: DeckColors.purple,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('レベル', style: DeckText.bodySecondary),
          Text('$level', style: DeckText.display.copyWith(fontSize: 120)),
          Text('5 回ごとに上がる', style: DeckText.caption),
        ],
      ),
    );
  }
}

class _ReadButtonCard extends ConsumerStatefulWidget {
  const _ReadButtonCard();

  @override
  ConsumerState<_ReadButtonCard> createState() => _ReadButtonCardState();
}

class _ReadButtonCardState extends ConsumerState<_ReadButtonCard> {
  int _builds = 0;

  @override
  Widget build(BuildContext context) {
    _builds++;
    return _ProbeCard(
      badge: 'READ',
      code: 'ref.read(counterProvider\n  .notifier).increment()',
      builds: _builds,
      accent: DeckColors.orange,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 220,
            height: 220,
            child: FilledButton(
              onPressed: () => ref.read(_counterProvider.notifier).increment(),
              style: FilledButton.styleFrom(
                backgroundColor: DeckColors.orange,
                shape: const CircleBorder(),
              ),
              child: Text(
                '+1',
                style: DeckText.display.copyWith(color: Colors.black),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '押してみて',
            style: DeckText.caption.copyWith(color: Colors.white38),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 🎮 BLoC — events in, states out
// ─────────────────────────────────────────────────────────────────────────────

Widget _blocStreamDemo(BuildContext context, int step) => const _BlocStream();

enum _EventKind {
  increment('Incremented()', '+1', DeckColors.cyan),
  decrement('Decremented()', '−1', DeckColors.purple),
  reset('Reset()', '0', DeckColors.orange);

  const _EventKind(this.code, this.short, this.color);

  final String code;
  final String short;
  final Color color;
}

class _Token {
  _Token.event(this.kind, this.start) : value = null;
  _Token.state(this.value, this.start) : kind = null;

  final _EventKind? kind;
  final int? value;
  final Duration start;

  bool get isEvent => kind != null;
}

class _BlocStream extends StatefulWidget {
  const _BlocStream();

  @override
  State<_BlocStream> createState() => _BlocStreamState();
}

class _BlocStreamState extends State<_BlocStream>
    with SingleTickerProviderStateMixin {
  static const _travel = Duration(milliseconds: 900);

  late final Ticker _ticker = createTicker(_onTick)..start();
  Duration _now = Duration.zero;
  final _tokens = <_Token>[];

  int _blocState = 0; // the Bloc's current state
  int _uiState = 0; // what the UI has received
  Duration _blocPulse = const Duration(seconds: -10);
  Duration _uiPulse = const Duration(seconds: -10);
  final _history = <int>[0];

  void _onTick(Duration elapsed) {
    _now = elapsed;
    final arrived = _tokens.where((t) => elapsed - t.start >= _travel).toList();
    for (final t in arrived) {
      _tokens.remove(t);
      if (t.isEvent) {
        _blocState = switch (t.kind!) {
          _EventKind.increment => _blocState + 1,
          _EventKind.decrement => _blocState - 1,
          _EventKind.reset => 0,
        };
        _blocPulse = elapsed;
        _tokens.add(_Token.state(_blocState, elapsed));
      } else {
        _uiState = t.value!;
        _uiPulse = elapsed;
        _history.add(_uiState);
        if (_history.length > 8) _history.removeAt(0);
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  double _pulse(Duration at) =>
      (1 - (_now - at).inMilliseconds / 500).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        const eventsW = 330.0;
        const blocW = 440.0;
        const uiW = 360.0;
        final blocLeft = (w - blocW) / 2;
        final uiLeft = w - uiW;
        final midY = h * 0.45;

        Widget token(_Token t) {
          final p = ((_now - t.start).inMicroseconds / _travel.inMicroseconds)
              .clamp(0.0, 1.0);
          final eased = Curves.easeInOut.transform(p);
          final from = t.isEvent ? eventsW + 10 : blocLeft + blocW + 10;
          final to = t.isEvent ? blocLeft - 170 : uiLeft - 150;
          final color = t.isEvent ? t.kind!.color : DeckColors.green;
          return Positioned(
            left: from + (to - from) * eased,
            top: midY - 26,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: color, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: Text(
                t.isEvent ? t.kind!.code : 'state: ${t.value}',
                style: DeckText.monoSmall.copyWith(color: color, fontSize: 19),
              ),
            ),
          );
        }

        return Stack(
          children: [
            // Pipes
            Positioned(
              left: eventsW,
              width: blocLeft - eventsW,
              top: midY - 3,
              height: 6,
              child: _Pipe(color: DeckColors.cyan),
            ),
            Positioned(
              left: blocLeft + blocW,
              width: uiLeft - blocLeft - blocW,
              top: midY - 3,
              height: 6,
              child: _Pipe(color: DeckColors.green),
            ),
            Positioned(
              left: eventsW + 20,
              top: midY - 70,
              child: Text(
                'Stream<CounterEvent>',
                style: DeckText.monoSmall.copyWith(color: DeckColors.cyan),
              ),
            ),
            Positioned(
              left: blocLeft + blocW + 20,
              top: midY - 70,
              child: Text(
                'Stream<int>',
                style: DeckText.monoSmall.copyWith(color: DeckColors.green),
              ),
            ),
            // Event buttons
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: eventsW,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('UI：Event を add', style: DeckText.caption),
                  const SizedBox(height: 14),
                  for (final kind in _EventKind.values)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: OutlinedButton(
                        onPressed: () => _tokens.add(_Token.event(kind, _now)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kind.color,
                          side: BorderSide(color: kind.color, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'add(${kind.code})',
                          style: DeckText.mono.copyWith(
                            fontSize: 21,
                            color: kind.color,
                          ),
                        ),
                      ),
                    ),
                  Text(
                    '連打してみて',
                    style: DeckText.caption.copyWith(color: Colors.white38),
                  ),
                ],
              ),
            ),
            // The Bloc
            Positioned(
              left: blocLeft,
              width: blocW,
              top: midY - 150,
              height: 300,
              child: _BlocBox(pulse: _pulse(_blocPulse), state: _blocState),
            ),
            // UI
            Positioned(
              left: uiLeft,
              width: uiW,
              top: 0,
              bottom: 0,
              child: _UiBox(
                value: _uiState,
                pulse: _pulse(_uiPulse),
                history: _history,
              ),
            ),
            for (final t in _tokens) token(t),
          ],
        );
      },
    );
  }
}

class _Pipe extends StatelessWidget {
  const _Pipe({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.5),
            color.withValues(alpha: 0.1),
          ],
        ),
      ),
    );
  }
}

class _BlocBox extends StatelessWidget {
  const _BlocBox({required this.pulse, required this.state});

  final double pulse;
  final int state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Color.lerp(
          DeckColors.surface,
          DeckColors.purple.withValues(alpha: 0.4),
          pulse,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: DeckColors.purple, width: 2 + pulse * 3),
        boxShadow: [
          BoxShadow(
            color: DeckColors.purple.withValues(alpha: 0.2 + pulse * 0.5),
            blurRadius: 40 + pulse * 40,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CounterBloc',
            style: DeckText.heading.copyWith(color: DeckColors.purple),
          ),
          const SizedBox(height: 14),
          for (final line in const [
            'on<Incremented> → state + 1',
            'on<Decremented> → state − 1',
            'on<Reset>       → 0',
          ])
            Text(
              line,
              softWrap: false,
              style: DeckText.monoSmall.copyWith(fontSize: 19),
            ),
          const Spacer(),
          Text(
            'state = $state',
            style: DeckText.mono.copyWith(color: DeckColors.green),
          ),
        ],
      ),
    );
  }
}

class _UiBox extends StatelessWidget {
  const _UiBox({
    required this.value,
    required this.pulse,
    required this.history,
  });

  final int value;
  final double pulse;
  final List<int> history;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('UI：BlocBuilder', style: DeckText.caption),
        const SizedBox(height: 14),
        Container(
          height: 230,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Color.lerp(
              Colors.white.withValues(alpha: 0.05),
              DeckColors.green.withValues(alpha: 0.3),
              pulse,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: DeckColors.green.withValues(alpha: 0.4 + pulse * 0.6),
              width: 2,
            ),
          ),
          child: Text(
            '$value',
            style: DeckText.display.copyWith(fontSize: 130),
          ),
        ),
        const SizedBox(height: 20),
        Text('受け取った State', style: DeckText.caption),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final v in history)
              Pill('$v', color: DeckColors.green, fontSize: 18, mono: true),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 比較表
// ─────────────────────────────────────────────────────────────────────────────

Widget _comparisonTable(BuildContext context, int step) =>
    const _ComparisonTable();

class _ComparisonTable extends StatelessWidget {
  const _ComparisonTable();

  static const _columns = ['学習コスト', '向いている規模', 'テストしやすさ', 'ボイラープレート'];

  static const _rows = [
    ('setState', DeckColors.textSecondary, ['低', 'Widget の中', '△', '最小']),
    ('InheritedWidget', DeckColors.cyan, ['中', '小〜中', '△', '多い']),
    ('Provider', DeckColors.blue, ['低', '小〜中', '○', '少ない']),
    ('Riverpod', DeckColors.purple, ['中', '小〜大', '◎', '少ない']),
    ('BLoC', DeckColors.pink, ['高', '中〜大', '◎', '多い']),
  ];

  @override
  Widget build(BuildContext context) {
    Widget cell(String text, {TextStyle? style, Color? color}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
      child: Text(
        text,
        style: style ?? DeckText.body.copyWith(fontSize: 30, color: color),
      ),
    );

    Color rating(String v) => switch (v) {
      '◎' || '低' || '最小' || '少ない' => DeckColors.green,
      '△' || '高' || '多い' => DeckColors.orange,
      _ => DeckColors.text,
    };

    return DeckCard(
      accent: DeckColors.textTertiary,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Table(
        columnWidths: const {0: FlexColumnWidth(1.4)},
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: TableBorder(
          horizontalInside: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        children: [
          TableRow(
            children: [
              cell(''),
              for (final c in _columns)
                cell(c, style: DeckText.caption.copyWith(fontSize: 22)),
            ],
          ),
          for (final (name, color, values) in _rows)
            TableRow(
              children: [
                cell(
                  name,
                  style: DeckText.mono.copyWith(fontSize: 28, color: color),
                ),
                for (final v in values) cell(v, color: rating(v)),
              ],
            ),
        ],
      ),
    );
  }
}
