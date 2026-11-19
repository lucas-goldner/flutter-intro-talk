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

/// Agenda → why Flutter → "everything is a widget" → layout basics.
final List<FlutterDeckSlideWidget> agendaAndBenefitsSlides = [
  const _AgendaSlide(),
  DividerSlideWidget(
    route: '/b-part-1',
    number: '01',
    label: 'Why Flutter',
    title: 'なぜ Flutter？',
    subtitle: '1つのコードベースで、何が嬉しいのか。',
    accent: DeckColors.dart,
  ),
  CardGridSlideWidget(
    route: '/b-benefits',
    eyebrow: 'Benefits',
    title: 'Flutter の6つのメリット',
    columns: 3,
    childAspectRatio: 1.75,
    cards: const [
      CardSpec(
        badge: 'ONE CODEBASE',
        title: '1つのコードベース',
        lines: ['iOS も Android も同じコード', '仕様のズレが起きにくい'],
        accent: DeckColors.dart,
      ),
      CardSpec(
        badge: 'HOT RELOAD',
        title: 'Hot Reload',
        lines: ['保存した瞬間に画面へ反映', '状態を保ったまま試せる'],
        accent: DeckColors.orange,
      ),
      CardSpec(
        badge: 'PIXEL PERFECT',
        title: 'ピクセルパーフェクト',
        lines: ['全ピクセルを自分で描く', 'デザイン通りに、どの OS でも'],
        accent: DeckColors.pink,
      ),
      CardSpec(
        badge: 'PERFORMANCE',
        title: 'ネイティブ性能',
        lines: ['AOT で機械語にコンパイル', 'JS ブリッジなし'],
        accent: DeckColors.green,
      ),
      CardSpec(
        badge: 'ECOSYSTEM',
        title: '豊富なパッケージ',
        lines: ['pub.dev に大量のパッケージ', 'Firebase など公式サポートも'],
        accent: DeckColors.purple,
      ),
      CardSpec(
        badge: 'MULTI-PLATFORM',
        title: '6 プラットフォーム',
        lines: ['Mobile・Web・Desktop', 'さらに組み込み機器まで'],
        accent: DeckColors.cyan,
      ),
    ],
  ),
  InteractiveSlideWidget(
    route: '/b-platforms',
    eyebrow: 'Write once, run anywhere',
    title: '同じコードが、6つの画面に',
    intensity: 0.4,
    builder: (context, step) => const _PlatformPicker(),
  ),
  CardGridSlideWidget(
    route: '/b-devex',
    eyebrow: 'Developer experience',
    title: '開発体験も、最初から揃っている',
    columns: 2,
    childAspectRatio: 2.5,
    mood: GradientMood.calm,
    footnote: 'エディタは VS Code でも Android Studio でも。公式プラグインがあります。',
    cards: const [
      CardSpec(
        badge: 'flutter doctor',
        title: '環境チェック',
        lines: ['足りないものを教えてくれる', 'セットアップで迷わない'],
        accent: DeckColors.green,
      ),
      CardSpec(
        badge: 'DevTools',
        title: 'Flutter DevTools',
        lines: ['Widget ツリー・パフォーマンス', 'メモリ・ネットワークを可視化'],
        accent: DeckColors.dart,
      ),
      CardSpec(
        badge: 'analyzer',
        title: '静的解析 + dart fix',
        lines: ['書いた瞬間にエラーと警告', '自動修正もワンコマンド'],
        accent: DeckColors.orange,
      ),
      CardSpec(
        badge: 'pub.dev',
        title: 'パッケージマネージャー',
        lines: ['flutter pub add で追加', 'スコアと人気度で選べる'],
        accent: DeckColors.purple,
      ),
    ],
  ),
  QuizSlideWidget(
    route: '/b-quiz-language',
    question: 'Flutter の UI は、何という言語で書く？',
    options: const ['Kotlin', 'Dart', 'JavaScript', 'Swift'],
    answer: 1,
    explanation: 'Dart。UI もロジックも、iOS も Android も、ぜんぶ同じ Dart で書きます。',
  ),
  StatementSlideWidget(
    route: '/b-everything-widget',
    eyebrow: 'Everything is a Widget',
    statement: 'Flutter では、\nすべてが Widget。',
    subtitle: 'ボタンも、文字も、余白も、レイアウトも、アプリ自体も。',
    gradient: DeckGradients.flutter,
    mood: GradientMood.cool,
  ),
  InteractiveSlideWidget(
    route: '/b-xray',
    eyebrow: 'Widget X-ray',
    title: '画面を透視すると、Widget の入れ子',
    intensity: 0.4,
    builder: (context, step) => const _WidgetXRay(),
  ),
  CodeSlideWidget(
    route: '/b-blueprint',
    eyebrow: 'Widget = blueprint',
    title: 'Widget は「設計図」',
    fileName: 'greeting.dart',
    fontSize: 22,
    points: const [
      'Widget は immutable（変更不可）な設定値',
      '画面を変えたい → 新しい Widget を作り直す',
      'だから軽い。毎フレーム作り直しても平気',
    ],
    code: '''
class Greeting extends StatelessWidget {
  const Greeting({super.key, required this.name});

  final String name; // final：あとから変わらない

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.waving_hand),
          const SizedBox(width: 8),
          Text('こんにちは、\$name さん'),
        ],
      ),
    );
  }
}''',
  ),
  InteractiveSlideWidget(
    route: '/b-composition',
    eyebrow: 'Composition over inheritance',
    title: '継承ではなく、組み合わせ',
    footnote: '大きな Widget も、中を開けると小さな Widget の組み合わせ。',
    steps: 2,
    builder: _composition,
  ),
  InteractiveSlideWidget(
    route: '/b-layout-playground',
    eyebrow: 'Layout playground',
    title: 'Row と Column でレイアウト',
    intensity: 0.4,
    builder: (context, step) => const _LayoutPlayground(),
  ),
  InteractiveSlideWidget(
    route: '/b-constraints',
    eyebrow: 'The layout rule',
    title: 'レイアウトのたった1つのルール',
    footnote: 'Constraints go down. Sizes go up. Parent sets position.',
    steps: 3,
    builder: _constraints,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Agenda
// ─────────────────────────────────────────────────────────────────────────────
class _AgendaSlide extends FlutterDeckSlideWidget {
  const _AgendaSlide()
    : super(
        configuration: const FlutterDeckSlideConfiguration(
          route: '/b-agenda',
          title: 'アジェンダ',
          header: FlutterDeckHeaderConfiguration(showHeader: false),
          steps: 7,
        ),
      );

  static const _rows = [
    ('Flutter の基本', 'メリット・Everything is a Widget・カウンターアプリ', DeckColors.dart),
    (
      'Widget と 3つのツリー',
      'Widget / Element / RenderObject とタップの旅',
      DeckColors.cyan,
    ),
    ('状態管理とアーキテクチャ', 'setState・InheritedWidget・Riverpod・BLoC', DeckColors.blue),
    ('レンダリングと表現力', '全ピクセルを描く仕組み・3D・シェーダー', DeckColors.purple),
    ('ネイティブ連携', 'Platform Views・MethodChannel・FFIgen', DeckColors.pink),
    ('AI・テスト・GenUI', 'AI との開発・4種類のテスト・A2UI', DeckColors.orange),
    ('ギャラリー', 'Flutter で作られたアプリたち', DeckColors.green),
  ];

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.custom(
      builder: (context) => FlutterDeckSlideStepsBuilder(
        builder: (context, step) => Stack(
          fit: StackFit.expand,
          children: [
            const WwdcBackground(intensity: 0.5),
            Padding(
              padding: const EdgeInsets.fromLTRB(88, 64, 88, 56),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AGENDA · 90 MIN', style: DeckText.eyebrow),
                  const SizedBox(height: 14),
                  const GradientText('今日の流れ', style: DeckText.title),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (var i = 0; i < _rows.length; i++)
                          _AgendaRow(
                            number: '0${i + 1}',
                            title: _rows[i].$1,
                            detail: _rows[i].$2,
                            accent: _rows[i].$3,
                            visible: step >= i + 1,
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
}

class _AgendaRow extends StatelessWidget {
  const _AgendaRow({
    required this.number,
    required this.title,
    required this.detail,
    required this.accent,
    required this.visible,
  });

  final String number;
  final String title;
  final String detail;
  final Color accent;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1 : 0.15,
      duration: const Duration(milliseconds: 350),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: GradientText(
              number,
              style: const TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.w800,
                height: 1,
                letterSpacing: -3,
                color: DeckColors.text,
              ),
              gradient: LinearGradient(
                colors: [accent, accent.withValues(alpha: 0.45)],
              ),
            ),
          ),
          const SizedBox(width: 20),
          SizedBox(
            width: 620,
            child: Text(title, style: DeckText.heading.copyWith(fontSize: 34)),
          ),
          Expanded(
            child: Text(detail, style: DeckText.caption.copyWith(fontSize: 22)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 🎮 Platform picker — same main.dart, six frames
// ─────────────────────────────────────────────────────────────────────────────
enum _Platform {
  ios('iOS', Icons.phone_iphone_rounded),
  android('Android', Icons.android_rounded),
  web('Web', Icons.public_rounded),
  macos('macOS', Icons.laptop_mac_rounded),
  windows('Windows', Icons.window_rounded),
  linux('Linux', Icons.terminal_rounded);

  const _Platform(this.label, this.icon);
  final String label;
  final IconData icon;
}

class _PlatformPicker extends StatefulWidget {
  const _PlatformPicker();

  @override
  State<_PlatformPicker> createState() => _PlatformPickerState();
}

class _PlatformPickerState extends State<_PlatformPicker> {
  _Platform _platform = _Platform.ios;
  int _likes = 3;
  final _visited = <_Platform>{_Platform.ios};

  static const _code = '''
void main() => runApp(const MeetupApp());

class MeetupApp extends StatelessWidget {
  const MeetupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Flutter Tokyo')),
        body: EventList(),
      ),
    );
  }
}''';

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Expanded(
                child: CodePanel(
                  _code,
                  language: 'dart',
                  fileName: 'main.dart',
                  accent: DeckColors.dart,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  const Pill(
                    'コード変更：0 行',
                    color: DeckColors.green,
                    fontSize: 22,
                  ),
                  const SizedBox(width: 18),
                  Pill(
                    '確認した OS：${_visited.length} / 6',
                    color: DeckColors.dart,
                    fontSize: 22,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 44),
        Expanded(
          flex: 11,
          child: Column(
            children: [
              Wrap(
                spacing: 12,
                children: [
                  for (final p in _Platform.values)
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _platform = p;
                          _visited.add(p);
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: p == _platform
                                ? DeckColors.dart.withValues(alpha: 0.22)
                                : Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: p == _platform
                                  ? DeckColors.dart
                                  : Colors.white24,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                p.icon,
                                size: 22,
                                color: p == _platform
                                    ? DeckColors.dart
                                    : DeckColors.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                p.label,
                                style: DeckText.body.copyWith(
                                  fontSize: 21,
                                  height: 1,
                                  fontWeight: FontWeight.w600,
                                  color: p == _platform
                                      ? DeckColors.text
                                      : DeckColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 26),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 380),
                  switchInCurve: Curves.easeOutCubic,
                  transitionBuilder: (child, a) => FadeTransition(
                    opacity: a,
                    child: ScaleTransition(
                      scale: Tween(begin: 0.92, end: 1.0).animate(a),
                      child: child,
                    ),
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(_platform),
                    child: Center(child: _frameFor(_platform)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _frameFor(_Platform p) {
    final app = _MeetupApp(
      likes: _likes,
      onLike: () => setState(() => _likes++),
      wide: p != _Platform.ios && p != _Platform.android,
    );
    return switch (p) {
      _Platform.ios => PhoneFrame(width: 300, child: app),
      _Platform.android => PhoneFrame(
        width: 300,
        style: PhoneStyle.android,
        accent: DeckColors.green,
        child: app,
      ),
      _ => _DesktopWindow(platform: p, child: app),
    };
  }
}

/// The one shared "app" shown in every frame.
class _MeetupApp extends StatelessWidget {
  const _MeetupApp({
    required this.likes,
    required this.onLike,
    required this.wide,
  });

  final int likes;
  final VoidCallback onLike;
  final bool wide;

  static const _events = [
    ('Flutter Tokyo #12', '12/5 ・ オンライン'),
    ('FlutterKaigi 2026', '11/19 ・ 東京'),
    ('Dart もくもく会', '12/14 ・ 渋谷'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF02569B),
        foregroundColor: Colors.white,
        title: const Text('Flutter Tokyo'),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(14),
        crossAxisCount: wide ? 3 : 1,
        childAspectRatio: wide ? 1.0 : 1.9,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: [
          for (final e in _events)
            Card(
              color: Colors.white,
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.$1,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      e.$2,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: onLike,
                          child: const Icon(
                            Icons.favorite,
                            color: Color(0xFFE91E63),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$likes',
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
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

class _DesktopWindow extends StatelessWidget {
  const _DesktopWindow({required this.platform, required this.child});

  final _Platform platform;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isWeb = platform == _Platform.web;
    final bar = switch (platform) {
      _Platform.web => Row(
        children: [
          ..._trafficLights(),
          const SizedBox(width: 18),
          Expanded(
            child: Container(
              height: 26,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock, size: 13, color: Colors.black45),
                  SizedBox(width: 6),
                  Text(
                    'https://meetup.example.dev',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      _Platform.windows => const Row(
        children: [
          Icon(Icons.flutter_dash, size: 16, color: Colors.black54),
          SizedBox(width: 8),
          Text(
            'Flutter Tokyo',
            style: TextStyle(fontSize: 13, color: Colors.black87),
          ),
          Spacer(),
          Icon(Icons.minimize, size: 16, color: Colors.black54),
          SizedBox(width: 18),
          Icon(Icons.crop_square, size: 15, color: Colors.black54),
          SizedBox(width: 18),
          Icon(Icons.close, size: 16, color: Colors.black54),
        ],
      ),
      _Platform.linux => Row(
        children: [
          const Spacer(),
          const Text(
            'Flutter Tokyo',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          for (final i in const [
            Icons.minimize,
            Icons.crop_square,
            Icons.close,
          ])
            Container(
              margin: const EdgeInsets.only(left: 8),
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Color(0xFFDDDDDD),
                shape: BoxShape.circle,
              ),
              child: Icon(i, size: 13, color: Colors.black87),
            ),
        ],
      ),
      _ => Row(
        children: [
          ..._trafficLights(),
          const Spacer(),
          const Text(
            'Flutter Tokyo',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const Spacer(),
          const SizedBox(width: 60),
        ],
      ),
    };

    return AspectRatio(
      aspectRatio: 16 / 10.5,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFFE9E9EE),
          borderRadius: BorderRadius.circular(
            platform == _Platform.windows ? 8 : 14,
          ),
          border: Border.all(
            color: DeckColors.dart.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: DeckColors.dart.withValues(alpha: 0.2),
              blurRadius: 60,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: isWeb ? 46 : 38,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              color: platform == _Platform.windows
                  ? Colors.white
                  : const Color(0xFFE9E9EE),
              child: bar,
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  List<Widget> _trafficLights() => [
    for (final c in const [
      Color(0xFFFF5F57),
      Color(0xFFFEBC2E),
      Color(0xFF28C840),
    ])
      Padding(
        padding: const EdgeInsets.only(right: 7),
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: c, shape: BoxShape.circle),
        ),
      ),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// 🎮 Widget X-ray
// ─────────────────────────────────────────────────────────────────────────────
class _WidgetXRay extends StatefulWidget {
  const _WidgetXRay();

  @override
  State<_WidgetXRay> createState() => _WidgetXRayState();
}

class _WidgetXRayState extends State<_WidgetXRay> {
  bool _xray = false;
  bool _following = false;

  /// Widgets under the pointer, outermost first. The innermost is highlighted.
  final _hovered = <String>[];

  String? get _active => _hovered.isEmpty ? null : _hovered.last;

  /// The widget tree as (depth, name) — mirrored on the left.
  static const _tree = [
    (0, 'Card'),
    (1, 'Padding'),
    (2, 'Column'),
    (3, 'Row'),
    (4, 'CircleAvatar'),
    (4, 'Column '),
    (5, 'Text'),
    (5, 'Text '),
    (3, 'Text  '),
    (3, 'ElevatedButton'),
    (4, 'Icon'),
  ];

  Widget _x(String name, Color color, Widget child) => _XRayBox(
    name: name.trim(),
    enabled: _xray,
    active: _active == name,
    color: color,
    onEnter: () => setState(() => _hovered.add(name)),
    onExit: () => setState(() => _hovered.remove(name)),
    child: child,
  );

  @override
  Widget build(BuildContext context) {
    const black = TextStyle(color: Colors.black87);
    final card = _x(
      'Card',
      DeckColors.pink,
      Card(
        color: Colors.white,
        elevation: 4,
        margin: EdgeInsets.zero,
        child: _x(
          'Padding',
          DeckColors.orange,
          Padding(
            padding: const EdgeInsets.all(28),
            child: _x(
              'Column',
              DeckColors.purple,
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _x(
                    'Row',
                    DeckColors.blue,
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _x(
                          'CircleAvatar',
                          DeckColors.green,
                          const CircleAvatar(
                            radius: 38,
                            backgroundColor: Color(0xFF02569B),
                            child: Icon(
                              Icons.flutter_dash,
                              color: Colors.white,
                              size: 44,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        _x(
                          'Column ',
                          DeckColors.purple,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _x(
                                'Text',
                                DeckColors.cyan,
                                Text(
                                  'Dash',
                                  style: black.copyWith(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              _x(
                                'Text ',
                                DeckColors.cyan,
                                Text(
                                  'Flutter のマスコット',
                                  style: black.copyWith(
                                    fontSize: 18,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _x(
                    'Text  ',
                    DeckColors.cyan,
                    Text(
                      'ハチドリ。好きなものは Widget と Hot Reload。',
                      style: black.copyWith(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 22),
                  _x(
                    'ElevatedButton',
                    DeckColors.red,
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF02569B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 16,
                        ),
                      ),
                      onPressed: () => setState(() => _following = !_following),
                      icon: _x(
                        'Icon',
                        DeckColors.green,
                        Icon(_following ? Icons.check : Icons.person_add),
                      ),
                      label: Text(
                        _following ? 'フォロー中' : 'フォローする',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 520,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => setState(() => _xray = !_xray),
                  child: Row(
                    children: [
                      Switch(
                        value: _xray,
                        activeThumbColor: DeckColors.pink,
                        onChanged: (v) => setState(() => _xray = v),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'X-ray モード',
                        style: DeckText.heading.copyWith(fontSize: 32),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Widget ツリー', style: DeckText.eyebrow),
              const SizedBox(height: 14),
              for (final (depth, name) in _tree)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: EdgeInsets.only(left: depth * 34.0, bottom: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _active == name
                        ? DeckColors.pink.withValues(alpha: 0.22)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    name.trim(),
                    style: DeckText.mono.copyWith(
                      fontSize: 22,
                      color: _active == name
                          ? DeckColors.pink
                          : DeckColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 40),
        Expanded(
          child: DemoFrame(
            accent: DeckColors.pink,
            hint: 'X-ray を ON にして、カードの上をなぞってみて',
            child: ColoredBox(
              color: const Color(0xFFEEF1F6),
              child: Center(
                child: Transform.scale(
                  scale: 1.45,
                  child: SizedBox(width: 560, child: card),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _XRayBox extends StatelessWidget {
  const _XRayBox({
    required this.name,
    required this.enabled,
    required this.active,
    required this.color,
    required this.onEnter,
    required this.onExit,
    required this.child,
  });

  final String name;
  final bool enabled;
  final bool active;
  final Color color;
  final VoidCallback onEnter;
  final VoidCallback onExit;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onEnter(),
      onExit: (_) => onExit(),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          child,
          if (enabled)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    color: active ? color.withValues(alpha: 0.18) : null,
                    border: Border.all(
                      color: color.withValues(alpha: active ? 1 : 0.55),
                      width: active ? 3 : 1.2,
                    ),
                  ),
                ),
              ),
            ),
          if (enabled && active)
            Positioned(
              left: 0,
              top: -26,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  color: color,
                  child: Text(
                    name,
                    style: DeckText.monoSmall.copyWith(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Composition: Container is just a bundle of smaller widgets
// ─────────────────────────────────────────────────────────────────────────────
Widget _composition(BuildContext context, int step) {
  const parts = [
    ('Padding', '内側の余白', DeckColors.orange),
    ('DecoratedBox', '背景色・角丸・影', DeckColors.pink),
    ('ConstrainedBox', '幅・高さの制約', DeckColors.purple),
    ('Align', '子の配置', DeckColors.blue),
    ('Transform', '回転・拡大', DeckColors.cyan),
  ];
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      const Expanded(
        flex: 5,
        child: CodePanel(
          '''
Container(
  padding: EdgeInsets.all(16),
  alignment: Alignment.center,
  width: 200,
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(12),
  ),
  transform: Matrix4.rotationZ(0.1),
  child: Text('Hello'),
)''',
          language: 'dart',
          fileName: 'container.dart',
          accent: DeckColors.dart,
          fontSize: 22,
        ),
      ),
      const SizedBox(width: 40),
      AnimatedOpacity(
        opacity: step >= 2 ? 1 : 0.2,
        duration: const Duration(milliseconds: 300),
        child: const Icon(
          Icons.arrow_forward_rounded,
          color: DeckColors.textTertiary,
          size: 56,
        ),
      ),
      const SizedBox(width: 40),
      Expanded(
        flex: 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Container の中身', style: DeckText.eyebrow),
            const SizedBox(height: 18),
            for (var i = 0; i < parts.length; i++)
              StaggerIn(
                visible: step >= 2,
                delayMs: i * 90,
                child: Padding(
                  padding: EdgeInsets.only(left: i * 30.0, bottom: 14),
                  child: DeckCard(
                    accent: parts[i].$3,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Text(
                          parts[i].$1,
                          style: DeckText.mono.copyWith(
                            fontSize: 26,
                            color: parts[i].$3,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          parts[i].$2,
                          style: DeckText.caption.copyWith(fontSize: 21),
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
// 🎮 Layout playground
// ─────────────────────────────────────────────────────────────────────────────
class _LayoutPlayground extends StatefulWidget {
  const _LayoutPlayground();

  @override
  State<_LayoutPlayground> createState() => _LayoutPlaygroundState();
}

class _LayoutPlaygroundState extends State<_LayoutPlayground> {
  bool _row = true;
  MainAxisAlignment _main = MainAxisAlignment.start;
  CrossAxisAlignment _cross = CrossAxisAlignment.center;
  int _count = 3;

  static const _boxColors = [
    DeckColors.pink,
    DeckColors.orange,
    DeckColors.cyan,
    DeckColors.purple,
    DeckColors.green,
  ];
  // Different sizes so cross-axis alignment is visible.
  static const _sizes = [120.0, 190.0, 95.0, 160.0, 110.0];

  String get _code {
    final children = List.generate(
      _count,
      (i) => '    Box(${i + 1}),',
    ).join('\n');
    return '''
${_row ? 'Row' : 'Column'}(
  mainAxisAlignment:
    MainAxisAlignment.${_main.name},
  crossAxisAlignment:
    CrossAxisAlignment.${_cross.name},
  children: [
$children
  ],
)''';
  }

  @override
  Widget build(BuildContext context) {
    final boxes = [
      for (var i = 0; i < _count; i++)
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          width: _row ? 150 : _sizes[i] * 1.8,
          height: _row ? _sizes[i] : 90,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _boxColors[i],
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            '${i + 1}',
            style: DeckText.heading.copyWith(color: Colors.white, height: 1),
          ),
        ),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 640,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Choices(
                label: '方向',
                options: const ['Row', 'Column'],
                selected: _row ? 0 : 1,
                onSelect: (i) => setState(() => _row = i == 0),
              ),
              _Choices(
                label: 'main',
                options: const [
                  'start',
                  'center',
                  'end',
                  'spaceBetween',
                  'spaceEvenly',
                ],
                selected: [
                  MainAxisAlignment.start,
                  MainAxisAlignment.center,
                  MainAxisAlignment.end,
                  MainAxisAlignment.spaceBetween,
                  MainAxisAlignment.spaceEvenly,
                ].indexOf(_main),
                onSelect: (i) => setState(
                  () => _main = [
                    MainAxisAlignment.start,
                    MainAxisAlignment.center,
                    MainAxisAlignment.end,
                    MainAxisAlignment.spaceBetween,
                    MainAxisAlignment.spaceEvenly,
                  ][i],
                ),
              ),
              _Choices(
                label: 'cross',
                options: const ['start', 'center', 'end', 'stretch'],
                selected: [
                  CrossAxisAlignment.start,
                  CrossAxisAlignment.center,
                  CrossAxisAlignment.end,
                  CrossAxisAlignment.stretch,
                ].indexOf(_cross),
                onSelect: (i) => setState(
                  () => _cross = [
                    CrossAxisAlignment.start,
                    CrossAxisAlignment.center,
                    CrossAxisAlignment.end,
                    CrossAxisAlignment.stretch,
                  ][i],
                ),
              ),
              _Choices(
                label: '子の数',
                options: const ['1', '2', '3', '4', '5'],
                selected: _count - 1,
                onSelect: (i) => setState(() => _count = i + 1),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: CodePanel(
                  _code,
                  language: 'dart',
                  fileName: 'layout.dart',
                  accent: DeckColors.dart,
                  fontSize: 21,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),
        Expanded(
          child: DemoFrame(
            accent: DeckColors.dart,
            hint: '左のチップを切り替えてみて',
            child: ColoredBox(
              color: DeckColors.surface,
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white24, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Flex(
                      direction: _row ? Axis.horizontal : Axis.vertical,
                      mainAxisAlignment: _main,
                      crossAxisAlignment: _cross,
                      children: [
                        // Stretch ignores the box's own cross size, so drop it.
                        for (final b in boxes) b,
                      ],
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

class _Choices extends StatelessWidget {
  const _Choices({
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(label, style: DeckText.caption.copyWith(fontSize: 21)),
          ),
          Expanded(
            child: Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                for (var i = 0; i < options.length; i++)
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => onSelect(i),
                      child: Pill(
                        options[i],
                        color: i == selected
                            ? DeckColors.dart
                            : DeckColors.textTertiary,
                        filled: i == selected,
                        fontSize: 17,
                        mono: true,
                      ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Constraints go down, sizes go up, parent sets position
// ─────────────────────────────────────────────────────────────────────────────
Widget _constraints(BuildContext context, int step) {
  Widget box(String name, String sub, Color c, {double width = 520}) =>
      DeckCard(
        accent: c,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 22),
        child: SizedBox(
          width: width,
          child: Row(
            children: [
              Text(name, style: DeckText.mono.copyWith(fontSize: 30, color: c)),
              const Spacer(),
              Text(sub, style: DeckText.caption.copyWith(fontSize: 21)),
            ],
          ),
        ),
      );

  Widget rule(int n, String jp, String en, String detail, Color c) => StaggerIn(
    visible: step >= n,
    child: DeckCard(
      accent: c,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      child: Row(
        children: [
          Text(
            '$n',
            style: DeckText.title.copyWith(color: c, fontSize: 52, height: 1),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jp,
                  style: DeckText.heading.copyWith(fontSize: 32, color: c),
                ),
                Text(en, style: DeckText.caption.copyWith(fontSize: 19)),
                const SizedBox(height: 6),
                Text(
                  detail,
                  style: DeckText.bodySecondary.copyWith(fontSize: 22),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  return Row(
    children: [
      Expanded(
        flex: 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            box('Parent', '例：Center', DeckColors.dart),
            SizedBox(
              height: 170,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedOpacity(
                    opacity: step >= 1 ? 1 : 0.1,
                    duration: const Duration(milliseconds: 300),
                    child: _arrowLabel(
                      Icons.south_rounded,
                      '制約\n0 ≤ w ≤ 390',
                      DeckColors.orange,
                    ),
                  ),
                  const SizedBox(width: 60),
                  AnimatedOpacity(
                    opacity: step >= 2 ? 1 : 0.1,
                    duration: const Duration(milliseconds: 300),
                    child: _arrowLabel(
                      Icons.north_rounded,
                      'サイズ\n200 × 48',
                      DeckColors.green,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedPadding(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.only(left: step >= 3 ? 160 : 0),
              child: box('Child', '例：Text', DeckColors.purple, width: 300),
            ),
          ],
        ),
      ),
      const SizedBox(width: 50),
      Expanded(
        flex: 6,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            rule(
              1,
              '制約は、下へ',
              'Constraints go down',
              '親が「この範囲で」と最小・最大を渡す',
              DeckColors.orange,
            ),
            const SizedBox(height: 18),
            rule(
              2,
              'サイズは、上へ',
              'Sizes go up',
              '子は範囲内で自分のサイズを決めて返す',
              DeckColors.green,
            ),
            const SizedBox(height: 18),
            rule(
              3,
              '位置は、親が決める',
              'Parent sets position',
              '子は自分がどこに置かれるか知らない',
              DeckColors.purple,
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _arrowLabel(IconData icon, String text, Color c) => Row(
  children: [
    Icon(icon, color: c, size: 64),
    const SizedBox(width: 8),
    Text(text, style: DeckText.mono.copyWith(fontSize: 22, color: c)),
  ],
);
