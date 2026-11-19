import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_intro_talk/core/theme/kaigi_theme.dart';
import 'package:flutter_intro_talk/core/widgets/code_panel.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers shared by s03–s06: the counter template, a "focus some lines" code
// panel, and the tree-node chip used by the three-tree diagrams.
// ─────────────────────────────────────────────────────────────────────────────

/// The `flutter create` counter template, as shipped.
const kCounterTemplate = '''
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '\$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
''';

/// The counter app UI, live. If [value] is given the widget is controlled
/// from outside and [onPressed] decides what a tap does.
class CounterAppMock extends StatefulWidget {
  const CounterAppMock({
    super.key,
    this.value,
    this.onPressed,
    this.fabKey,
    this.counterFlash = false,
  });

  final int? value;
  final VoidCallback? onPressed;
  final Key? fabKey;

  /// Briefly tints the counter text — used to show "this got repainted".
  final bool counterFlash;

  @override
  State<CounterAppMock> createState() => _CounterAppMockState();
}

class _CounterAppMockState extends State<CounterAppMock> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    final value = widget.value ?? _counter;
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    );
    return Theme(
      data: theme,
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text('Flutter Demo Home Page'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'You have pushed the button this many times:',
                    textAlign: TextAlign.center,
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: widget.counterFlash
                        ? Colors.amber.withValues(alpha: 0.6)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$value',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            key: widget.fabKey,
            onPressed: widget.onPressed ?? () => setState(() => _counter++),
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

/// Editor-style code panel that dims every line outside [focus] (1-based,
/// inclusive ranges). Used for the code walk-throughs.
class FocusCodePanel extends StatelessWidget {
  const FocusCodePanel({
    required this.code,
    required this.focus,
    super.key,
    this.fileName = 'lib/main.dart',
    this.fontSize = 17,
    this.accent = DeckColors.dart,
    this.firstLine = 1,
  });

  final String code;

  /// Line ranges (inclusive, numbered like [firstLine]) that stay bright.
  final List<(int, int)> focus;
  final String fileName;
  final double fontSize;
  final Color accent;
  final int firstLine;

  bool _focused(int line) =>
      focus.isEmpty || focus.any((r) => line >= r.$1 && line <= r.$2);

  @override
  Widget build(BuildContext context) {
    final lines = code.trimRight().split('\n');
    final style = TextStyle(
      fontFamily: kMonoFamily,
      fontFamilyFallback: kMonoFallback,
      fontSize: fontSize,
      height: 1.5,
    );
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF10101A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.28), width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            color: Colors.white.withValues(alpha: 0.04),
            child: Row(
              children: [
                for (final c in const [
                  Color(0xFFFF5F57),
                  Color(0xFFFEBC2E),
                  Color(0xFF28C840),
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 9),
                    child: CircleAvatar(radius: 6.5, backgroundColor: c),
                  ),
                const SizedBox(width: 14),
                Text(
                  fileName,
                  style: DeckText.monoSmall.copyWith(
                    fontSize: 16,
                    color: DeckColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 16, 20, 12),
              child: ScaleDownToFit(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < lines.length; i++)
                      _CodeLine(
                        number: firstLine + i,
                        text: lines[i],
                        style: style,
                        focused: _focused(firstLine + i),
                        accent: accent,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CodeLine extends StatelessWidget {
  const _CodeLine({
    required this.number,
    required this.text,
    required this.style,
    required this.focused,
    required this.accent,
  });

  final int number;
  final String text;
  final TextStyle style;
  final bool focused;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 350),
      opacity: focused ? 1 : 0.22,
      child: Container(
        decoration: BoxDecoration(
          color: focused ? accent.withValues(alpha: 0.07) : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: focused ? accent : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 44,
              child: Text(
                '$number',
                textAlign: TextAlign.right,
                style: style.copyWith(color: DeckColors.textTertiary),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: text.trim().isEmpty
                  ? Text(' ', style: style)
                  // Never wrap a code line — shrink it instead.
                  : FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: HighlightView(
                        text,
                        language: 'dart',
                        theme: xcodeDarkTheme,
                        padding: EdgeInsets.zero,
                        textStyle: style,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A rounded node in a tree diagram.
class TreeChip extends StatelessWidget {
  const TreeChip({
    required this.label,
    required this.color,
    super.key,
    this.highlighted = false,
    this.dimmed = false,
    this.fontSize = 17,
    this.flash = 0,
  });

  final String label;
  final Color color;
  final bool highlighted;
  final bool dimmed;
  final double fontSize;

  /// 0..1 — a brief pulse (rebuild / repaint flash).
  final double flash;

  @override
  Widget build(BuildContext context) {
    final glow = highlighted ? 1.0 : flash;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: dimmed ? 0.3 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Color.lerp(
            color.withValues(alpha: 0.10),
            color.withValues(alpha: 0.45),
            glow,
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withValues(alpha: 0.35 + 0.65 * glow),
            width: highlighted ? 2.5 : 1.5,
          ),
          boxShadow: [
            if (glow > 0)
              BoxShadow(
                color: color.withValues(alpha: 0.5 * glow),
                blurRadius: 22,
              ),
          ],
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: DeckText.monoSmall.copyWith(
            fontSize: fontSize,
            color: highlighted ? Colors.white : DeckColors.text,
          ),
        ),
      ),
    );
  }
}

/// A node in one of the three counter-app trees.
class TreeRow {
  const TreeRow(this.depth, this.label, this.link);

  final int depth;
  final String label;

  /// Shared id across the three trees — same id = same "thing".
  final String link;
}

/// The counter app, as three trees (simplified — real trees have more
/// internal nodes, marked with "…").
const kWidgetTree = <TreeRow>[
  TreeRow(0, 'MyApp', 'myapp'),
  TreeRow(1, 'MaterialApp', 'material'),
  TreeRow(2, '…', 'dots'),
  TreeRow(3, 'MyHomePage', 'home'),
  TreeRow(4, 'Scaffold', 'scaffold'),
  TreeRow(5, 'Center', 'center'),
  TreeRow(6, 'Column', 'column'),
  TreeRow(7, 'Text', 'text1'),
  TreeRow(7, "Text('\$_counter')", 'text2'),
  TreeRow(5, 'FloatingActionButton', 'fab'),
];

const kElementTree = <TreeRow>[
  TreeRow(0, 'StatelessElement', 'myapp'),
  TreeRow(1, 'StatefulElement', 'material'),
  TreeRow(2, '…', 'dots'),
  TreeRow(3, 'StatefulElement ◆State', 'home'),
  TreeRow(4, 'StatefulElement', 'scaffold'),
  TreeRow(5, 'SingleChildRenderObjectElement', 'center'),
  TreeRow(6, 'MultiChildRenderObjectElement', 'column'),
  TreeRow(7, 'StatelessElement', 'text1'),
  TreeRow(7, 'StatelessElement', 'text2'),
  TreeRow(5, 'StatelessElement', 'fab'),
];

const kRenderTree = <TreeRow>[
  TreeRow(0, 'RenderView', 'root'),
  TreeRow(1, '…', 'dots'),
  TreeRow(2, 'RenderPositionedBox', 'center'),
  TreeRow(3, 'RenderFlex', 'column'),
  TreeRow(4, 'RenderParagraph', 'text1'),
  TreeRow(4, 'RenderParagraph', 'text2'),
  TreeRow(2, '… RenderPointerListener', 'fab'),
];

/// Lines [from]..[to] (1-based, inclusive) of [kCounterTemplate].
String templateLines(int from, int to) =>
    kCounterTemplate.trimRight().split('\n').sublist(from - 1, to).join('\n');

/// Colours of the three trees — the same on every slide.
abstract final class TreeColors {
  static const widget = DeckColors.dart;
  static const element = DeckColors.purple;
  static const render = DeckColors.orange;
  static const signal = DeckColors.pink;
}

/// Lays [child] out at the available width and scales it down (never up)
/// if it would be taller than the space — keeps dense text slides safe
/// across fonts.
class ScaleDownToFit extends StatelessWidget {
  const ScaleDownToFit({
    required this.child,
    super.key,
    this.alignment = Alignment.topLeft,
  });

  final Widget child;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) => FittedBox(
        fit: BoxFit.scaleDown,
        alignment: alignment,
        child: SizedBox(width: c.maxWidth, child: child),
      ),
    );
  }
}
