import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';
import 'package:flutter_intro_talk/core/theme/kaigi_theme.dart';
import 'package:flutter_intro_talk/core/widgets/deck_components.dart';
import 'package:flutter_intro_talk/core/widgets/demo_frame.dart';
import 'package:flutter_intro_talk/core/widgets/motion.dart';
import 'package:flutter_intro_talk/core/widgets/phone_frame.dart';
import 'package:flutter_intro_talk/core/widgets/templates.dart';
import 'package:flutter_intro_talk/core/widgets/wwdc_background.dart';
import 'package:flutter_intro_talk/slides/s12_web_first_demo.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 08 · AI と Flutter
// ─────────────────────────────────────────────────────────────────────────────
final List<FlutterDeckSlideWidget> aiSlides = [
  DividerSlideWidget(
    route: '/ai-divider',
    number: '08',
    label: 'AI × Flutter',
    title: 'AI と Flutter',
    subtitle: 'AI に書かせる。AI をアプリに組み込む。',
    mood: GradientMood.hero,
    accent: DeckColors.purple,
  ),
  InteractiveSlideWidget(
    route: '/ai-mcp',
    eyebrow: 'Coding with agents',
    title: 'AI エージェントが「動いているアプリ」を触れる',
    footnote: 'Dart & Flutter MCP server：エージェントがアプリを実行し、見て、直す。',
    steps: 3,
    builder: _mcpDiagram,
  ),
  CardGridSlideWidget(
    route: '/ai-why',
    eyebrow: 'Why Flutter + AI',
    title: 'Flutter は AI と相性がいい',
    columns: 3,
    childAspectRatio: 1.75,
    mood: GradientMood.violet,
    cards: const [
      CardSpec(
        badge: 'DECLARATIVE',
        title: '宣言的 UI',
        lines: ['UI = コード', 'ツリー構造は LLM が得意'],
        accent: DeckColors.pink,
      ),
      CardSpec(
        badge: 'ONE CODEBASE',
        title: '1回の生成で全 OS',
        lines: ['iOS / Android / Web…', '同じコードを2回書かせない'],
        accent: DeckColors.purple,
      ),
      CardSpec(
        badge: 'TYPES',
        title: '型 + analyzer',
        lines: ['間違いを即座に検出', 'AI への速いフィードバック'],
        accent: DeckColors.blue,
      ),
      CardSpec(
        badge: 'HOT RELOAD',
        title: '1秒のループ',
        lines: ['書く → 反映 → 確認', 'エージェントも同じ速さで回せる'],
        accent: DeckColors.cyan,
      ),
      CardSpec(
        badge: 'TESTS',
        title: 'テストが書きやすい',
        lines: ['Widget テストで自己検証', 'AI の変更を安心して受け入れる'],
        accent: DeckColors.green,
      ),
    ],
  ),
  InteractiveSlideWidget(
    route: '/ai-loop',
    eyebrow: 'Agent loop · demo',
    title: 'エージェントのループを見てみる',
    footnote: '生成 → analyze → Hot Reload → スクショで確認 → 修正。人間と同じループを、秒単位で。',
    mood: GradientMood.violet,
    builder: _agentLoop,
  ),
  // The speaker's own solo-dev loop: build for web first, check on the phone.
  InteractiveSlideWidget(
    route: '/ai-web-first',
    eyebrow: 'My workflow · Web first',
    title: '私の個人開発フロー：まず Web で作る',
    footnote:
        'Web なら Claude が自分で動かしてスクショで見せてくれる。同じコードのまま TestFlight で実機へ。個人開発の最強ループ（個人の感想です）。',
    mood: GradientMood.violet,
    intensity: 0.4,
    builder: (context, step) => const WebFirstDemo(),
  ),
  InteractiveSlideWidget(
    route: '/ai-in-app',
    eyebrow: 'AI in your app',
    title: 'アプリに AI を組み込む',
    footnote:
        'firebase_ai（Firebase AI Logic）で Gemini を直接呼ぶ。チャット UI は flutter_ai_toolkit で一行。',
    mood: GradientMood.calm,
    builder: _aiInApp,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// MCP diagram: agent ⇄ MCP server ⇄ running app.
// ─────────────────────────────────────────────────────────────────────────────
Widget _mcpDiagram(BuildContext context, int step) => _McpDiagram(step: step);

class _McpDiagram extends StatelessWidget {
  const _McpDiagram({required this.step});

  final int step;

  static const _tools = [
    ('analyze', Icons.rule_rounded),
    ('Hot Reload', Icons.bolt_rounded),
    ('Widget ツリー', Icons.account_tree_rounded),
    ('実行時エラー', Icons.error_outline_rounded),
    ('pub.dev 検索', Icons.search_rounded),
    ('テスト実行', Icons.check_circle_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: StaggerIn(
                  visible: step >= 1,
                  child: _Node(
                    accent: DeckColors.purple,
                    icon: Icons.smart_toy_outlined,
                    title: 'AI エージェント',
                    child: const Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        Pill(
                          'Claude Code',
                          color: DeckColors.orange,
                          fontSize: 18,
                        ),
                        Pill(
                          'Gemini CLI',
                          color: DeckColors.blue,
                          fontSize: 18,
                        ),
                        Pill('Copilot', color: DeckColors.text, fontSize: 18),
                        Pill(
                          'Cursor …',
                          color: DeckColors.textSecondary,
                          fontSize: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _Link(visible: step >= 2),
              Expanded(
                child: StaggerIn(
                  visible: step >= 2,
                  child: _Node(
                    accent: DeckColors.dart,
                    icon: Icons.hub_outlined,
                    title: 'MCP server',
                    child: Column(
                      children: [
                        Text(
                          r'$ dart mcp-server',
                          style: DeckText.mono.copyWith(color: DeckColors.dart),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '+ AI rules ・ agent skills',
                          style: DeckText.caption.copyWith(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _Link(visible: step >= 3),
              Expanded(
                child: StaggerIn(
                  visible: step >= 3,
                  child: _Node(
                    accent: DeckColors.cyan,
                    icon: Icons.phone_iphone_rounded,
                    title: '動いているアプリ',
                    child: Text(
                      'flutter run 中の\nアプリ / DevTools',
                      textAlign: TextAlign.center,
                      style: DeckText.bodySecondary.copyWith(fontSize: 22),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 34),
        StaggerIn(
          visible: step >= 3,
          child: Wrap(
            spacing: 16,
            runSpacing: 14,
            alignment: WrapAlignment.center,
            children: [
              for (final (label, icon) in _tools)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: DeckColors.cyan.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: DeckColors.cyan.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: DeckColors.cyan, size: 24),
                      const SizedBox(width: 10),
                      Text(label, style: DeckText.body.copyWith(fontSize: 22)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Node extends StatelessWidget {
  const _Node({
    required this.accent,
    required this.icon,
    required this.title,
    required this.child,
  });

  final Color accent;
  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DeckCard(
      accent: accent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.16),
              shape: BoxShape.circle,
              border: Border.all(color: accent, width: 2),
            ),
            child: Icon(icon, color: accent, size: 44),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: DeckText.heading.copyWith(color: accent, fontSize: 34),
          ),
          const SizedBox(height: 22),
          child,
        ],
      ),
    );
  }
}

/// Bidirectional link with packets flowing both ways.
class _Link extends StatefulWidget {
  const _Link({required this.visible});

  final bool visible;

  @override
  State<_Link> createState() => _LinkState();
}

class _LinkState extends State<_Link> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: AnimatedOpacity(
        opacity: widget.visible ? 1 : 0,
        duration: const Duration(milliseconds: 400),
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => CustomPaint(painter: _LinkPainter(_c.value)),
        ),
      ),
    );
  }
}

class _LinkPainter extends CustomPainter {
  _LinkPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final y1 = size.height / 2 - 16;
    final y2 = size.height / 2 + 16;
    final line = Paint()
      ..color = DeckColors.textTertiary
      ..strokeWidth = 2;
    canvas
      ..drawLine(Offset(8, y1), Offset(size.width - 8, y1), line)
      ..drawLine(Offset(8, y2), Offset(size.width - 8, y2), line);
    final w = size.width - 16;
    canvas
      ..drawCircle(Offset(8 + w * t, y1), 7, Paint()..color = DeckColors.purple)
      ..drawCircle(
        Offset(8 + w * (1 - t), y2),
        7,
        Paint()..color = DeckColors.cyan,
      );
  }

  @override
  bool shouldRepaint(_LinkPainter old) => old.t != t;
}

// ─────────────────────────────────────────────────────────────────────────────
// Agent loop simulator.
// ─────────────────────────────────────────────────────────────────────────────
Widget _agentLoop(BuildContext context, int step) => const _AgentLoop();

class _AgentLoop extends StatefulWidget {
  const _AgentLoop();

  @override
  State<_AgentLoop> createState() => _AgentLoopState();
}

class _AgentLoopState extends State<_AgentLoop> {
  static const _phases = ['生成', 'analyze', 'Hot Reload', 'スクショ確認', '修正'];
  static const _phaseColors = [
    DeckColors.purple,
    DeckColors.blue,
    DeckColors.orange,
    DeckColors.cyan,
    DeckColors.pink,
  ];

  /// Per iteration: log line per phase.
  static const _logs = [
    [
      '✎ login_screen.dart を生成',
      '✓ No issues found',
      '⚡ Reloaded 1 of 812 libraries',
      '✗ RenderFlex overflowed by 48 pixels',
      '✎ Column を SingleChildScrollView で包む',
    ],
    [
      '✎ 余白と入力欄を整理',
      '⚠ prefer_const_constructors (3)',
      '⚡ Reloaded 1 of 812 libraries',
      '△ ボタンが目立たない・ロゴがない',
      '✎ FilledButton とロゴを追加',
    ],
    [
      '✎ テーマカラーを適用',
      '✓ No issues found',
      '⚡ Reloaded 1 of 812 libraries',
      '✓ デザインどおり',
      '✓ 完了 — Widget テストも追加',
    ],
  ];

  Timer? _timer;
  int _iteration = -1; // -1 = not started
  int _phase = 0;
  int _quality = 0; // 0 = empty, 1 = broken, 2 = ok, 3 = polished
  final _log = <(String, Color)>[];
  bool _done = false;

  void _start() {
    _timer?.cancel();
    setState(() {
      _iteration = 0;
      _phase = 0;
      _quality = 0;
      _log.clear();
      _done = false;
    });
    _tick();
    _timer = Timer.periodic(const Duration(milliseconds: 950), (_) => _tick());
  }

  void _tick() {
    if (!mounted) return;
    setState(() {
      _log.add((_logs[_iteration][_phase], _phaseColors[_phase]));
      if (_log.length > 9) _log.removeAt(0);
      if (_phase == 2) _quality = _iteration + 1; // Hot Reload shows new UI
      if (_phase == _phases.length - 1) {
        if (_iteration == _logs.length - 1) {
          _done = true;
          _timer?.cancel();
          return;
        }
        _iteration++;
        _phase = 0;
      } else {
        _phase++;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final running = _iteration >= 0 && !_done;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: running ? null : _start,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 26,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      gradient: running ? null : DeckGradients.hero,
                      color: running ? DeckColors.surfaceRaised : null,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 14),
                        Text(
                          '「ログイン画面を作って」',
                          style: DeckText.heading.copyWith(fontSize: 28),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          running ? '実行中…' : (_done ? 'もう一度 ↻' : 'タップして実行'),
                          style: DeckText.caption.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Loop phases.
              Row(
                children: [
                  for (var i = 0; i < _phases.length; i++) ...[
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _phaseColors[i].withValues(
                            alpha: running && _phase == i ? 0.30 : 0.06,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _phaseColors[i].withValues(
                              alpha: running && _phase == i ? 1 : 0.3,
                            ),
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _phases[i],
                          style: DeckText.body.copyWith(
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                            color: _phaseColors[i],
                          ),
                        ),
                      ),
                    ),
                    if (i != _phases.length - 1)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: DeckColors.textTertiary,
                          size: 22,
                        ),
                      ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _iteration < 0 ? 'ループ 0 / 3' : 'ループ ${_iteration + 1} / 3',
                style: DeckText.caption,
              ),
              const SizedBox(height: 14),
              // Console.
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10101A),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: DeckColors.purple.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final (line, color) in _log)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            line,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: DeckText.monoSmall.copyWith(
                              color: line.startsWith('✗')
                                  ? DeckColors.red
                                  : line.startsWith('✓')
                                  ? DeckColors.green
                                  : color,
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
          flex: 4,
          child: Center(
            child: PhoneFrame(
              width: 330,
              accent: DeckColors.purple,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: KeyedSubtree(
                  key: ValueKey(_quality),
                  child: _LoginMock(quality: _quality),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The "generated" login screen, at increasing levels of quality.
class _LoginMock extends StatelessWidget {
  const _LoginMock({required this.quality});

  final int quality;

  @override
  Widget build(BuildContext context) {
    if (quality == 0) {
      return const Center(
        child: Text(
          '（まだ何もない）',
          style: TextStyle(color: Colors.black38, fontSize: 16),
        ),
      );
    }
    const field = TextStyle(color: Colors.black54, fontSize: 14);
    if (quality == 1) {
      // Cramped and overflowing — debug overflow stripe at the bottom.
      return Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Login',
                style: TextStyle(color: Colors.black, fontSize: 40),
              ),
              Container(
                height: 40,
                color: const Color(0xFFEDEDED),
                child: const Text('Email', style: field),
              ),
              Container(
                height: 40,
                color: const Color(0xFFEDEDED),
                child: const Text('Password', style: field),
              ),
              const SizedBox(height: 400),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 14,
            child: CustomPaint(painter: _OverflowStripes()),
          ),
        ],
      );
    }
    final polished = quality >= 3;
    final primary = polished
        ? const Color(0xFF6C4CF1)
        : const Color(0xFF888888);
    InputDecoration deco(String label, IconData icon) => InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(polished ? 14 : 4),
      ),
      isDense: true,
    );
    return Theme(
      data: ThemeData.light(useMaterial3: true),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (polished) ...[
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C4CF1), Color(0xFF29B6F6)],
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.flutter_dash,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            Text(
              polished ? 'おかえりなさい' : 'Login',
              textAlign: polished ? TextAlign.center : TextAlign.start,
              style: TextStyle(
                color: Colors.black87,
                fontSize: polished ? 26 : 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            TextField(decoration: deco('メールアドレス', Icons.mail_outline)),
            const SizedBox(height: 14),
            TextField(
              obscureText: true,
              decoration: deco('パスワード', Icons.lock_outline),
            ),
            const SizedBox(height: 26),
            if (polished)
              FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: primary,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('ログイン', style: TextStyle(fontSize: 16)),
              )
            else
              OutlinedButton(onPressed: () {}, child: const Text('Login')),
            if (polished) ...[
              const SizedBox(height: 14),
              const Center(
                child: Text(
                  'パスワードをお忘れですか？',
                  style: TextStyle(color: Color(0xFF6C4CF1), fontSize: 13),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OverflowStripes extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFFFEB3B),
    );
    final p = Paint()
      ..color = const Color(0xFFD32F2F)
      ..strokeWidth = 6;
    for (var x = -size.height; x < size.width; x += 16) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), p);
    }
  }

  @override
  bool shouldRepaint(_OverflowStripes oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// AI in your app: firebase_ai + flutter_ai_toolkit, with a tiny chat demo.
// ─────────────────────────────────────────────────────────────────────────────
const _firebaseAiCode = '''
// package:firebase_ai（Firebase AI Logic）
final model = FirebaseAI.googleAI()
    .generativeModel(model: 'gemini-flash-latest');

final response = await model.generateContent([
  Content.text('この写真の料理名は？'),
]);
print(response.text);
''';

const _toolkitCode = '''
// package:flutter_ai_toolkit
LlmChatView(
  provider: FirebaseProvider(model: model),
)
''';

Widget _aiInApp(BuildContext context, int step) => const CodeDemoLayout(
  codeFlex: 12,
  demoFlex: 8,
  snippets: [
    CodeSnippet(
      _firebaseAiCode,
      fileName: 'gemini.dart',
      language: 'dart',
      flex: 3,
    ),
    CodeSnippet(
      _toolkitCode,
      fileName: 'chat_screen.dart',
      language: 'dart',
      flex: 2,
    ),
  ],
  demo: Center(
    child: PhoneFrame(width: 320, accent: DeckColors.dart, child: _ChatDemo()),
  ),
);

class _ChatDemo extends StatefulWidget {
  const _ChatDemo();

  @override
  State<_ChatDemo> createState() => _ChatDemoState();
}

class _ChatDemoState extends State<_ChatDemo> {
  static const _question = 'Flutter の良いところを一言で？';
  static const _answer = '1つのコードで、iOS・Android・Web・デスクトップの画面をすべて同じように描けることです。';

  Timer? _timer;
  bool _asked = false;
  int _chars = 0;

  void _ask() {
    _timer?.cancel();
    setState(() {
      _asked = true;
      _chars = 0;
    });
    _timer = Timer.periodic(const Duration(milliseconds: 45), (t) {
      if (!mounted) return;
      setState(() => _chars++);
      if (_chars >= _answer.length) t.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _bubble(String text, {required bool me}) => Align(
    alignment: me ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      constraints: const BoxConstraints(maxWidth: 220),
      decoration: BoxDecoration(
        color: me ? const Color(0xFF1A73E8) : const Color(0xFFF1F3F4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: me ? Colors.white : Colors.black87,
          fontSize: 14,
          height: 1.4,
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 48,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
          ),
          child: const Text(
            '✦ Gemini チャット',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                if (_asked) _bubble(_question, me: true),
                if (_asked && _chars > 0)
                  _bubble(_answer.substring(0, _chars), me: false),
                const Spacer(),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: _ask,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F4),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _asked ? 'メッセージを入力' : _question,
                        style: TextStyle(
                          color: _asked ? Colors.black38 : Colors.black87,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.send_rounded,
                      color: Color(0xFF1A73E8),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
