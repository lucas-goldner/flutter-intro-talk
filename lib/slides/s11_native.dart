import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';
import 'package:flutter_intro_talk/core/theme/kaigi_theme.dart';
import 'package:flutter_intro_talk/core/widgets/code_panel.dart';
import 'package:flutter_intro_talk/core/widgets/deck_components.dart';
import 'package:flutter_intro_talk/core/widgets/phone_frame.dart';
import 'package:flutter_intro_talk/core/widgets/templates.dart';
import 'package:flutter_intro_talk/core/widgets/wwdc_background.dart';

/// Section: 弱点と、ネイティブとの連携.
final List<FlutterDeckSlideWidget> nativeSlides = [
  StatementSlideWidget(
    route: '/n-weakness',
    eyebrow: 'Trade-offs',
    statement: 'でも…\n弱点もある。',
    mood: GradientMood.warm,
  ),
  CardGridSlideWidget(
    route: '/n-downsides',
    eyebrow: 'Downsides',
    title: '全部自分で描く、ということの裏返し',
    mood: GradientMood.warm,
    childAspectRatio: 2.7,
    cards: const [
      CardSpec(
        badge: 'LOOK',
        title: 'OS の見た目は「再現」',
        accent: DeckColors.pink,
        lines: [
          'Cupertino は iOS に似せて描いたもの',
          'iOS 26 の Liquid Glass など新デザインは追従待ち',
        ],
      ),
      CardSpec(
        badge: 'SIZE',
        title: 'アプリサイズ',
        accent: DeckColors.orange,
        lines: ['エンジンを同梱するぶん、', 'Hello World でも数 MB 大きくなる'],
      ),
      CardSpec(
        badge: 'OS FEATURES',
        title: 'OS 新機能の対応待ち',
        accent: DeckColors.purple,
        lines: ['新 API はプラグイン待ち、または自分でつなぐ', 'ホーム画面ウィジェットなどはネイティブで書く'],
      ),
      CardSpec(
        badge: 'WEB',
        title: 'Web の SEO・初回ロード',
        accent: DeckColors.cyan,
        lines: ['Canvas に描くので検索エンジンが苦手', 'ランディングページには不向き'],
      ),
    ],
  ),
  BulletSlideWidget(
    route: '/n-native-bar',
    eyebrow: 'Example',
    title: '「ネイティブのタブバーを使いたい！」',
    accent: DeckColors.green,
    mood: GradientMood.calm,
    bullets: const [
      'OS の最新デザインを、そのまま使いたい',
      '地図・動画・WebView も OS のものを使いたい',
      '→ Platform Views で、ネイティブの View を Flutter の中に置ける',
    ],
    side: const Center(child: _NativeBarPhone()),
  ),
  InteractiveSlideWidget(
    route: '/n-platform-view-code',
    eyebrow: 'Platform Views',
    title: 'ネイティブ View を Widget として置く',
    footnote:
        'Android は AndroidView、macOS は AppKitView。Flutter からは普通の Widget に見える。',
    mood: GradientMood.calm,
    intensity: 0.4,
    builder: _platformViewCodeBody,
  ),
  InteractiveSlideWidget(
    route: '/n-layers',
    eyebrow: 'Composition',
    title: '画面は、レイヤーの重ね合わせ',
    footnote: 'ネイティブ View の上に Flutter を描くと、Flutter は追加のオーバーレイ層を作って合成する。',
    mood: GradientMood.violet,
    intensity: 0.4,
    builder: _layersBody,
  ),
  CardGridSlideWidget(
    route: '/n-add-to-app',
    eyebrow: 'The other direction',
    title: '逆向きもできる：Flutter を埋め込む',
    columns: 3,
    childAspectRatio: 1.15,
    mood: GradientMood.cool,
    cards: const [
      CardSpec(
        badge: 'PLATFORM VIEWS',
        title: 'Flutter の中に\nネイティブ',
        accent: DeckColors.green,
        lines: ['UiKitView / AndroidView', '地図・動画・広告・タブバー'],
      ),
      CardSpec(
        badge: 'ADD-TO-APP',
        title: 'ネイティブアプリの中に\nFlutter',
        accent: DeckColors.dart,
        lines: [
          'FlutterViewController',
          'FlutterActivity / FlutterFragment',
          '1 画面ずつ段階的に移行できる',
        ],
      ),
      CardSpec(
        badge: 'ELEMENT EMBEDDING',
        title: 'Web ページの中に\nFlutter',
        accent: DeckColors.orange,
        lines: ['既存サイトの <div> に Flutter Web', 'JS とやりとりもできる'],
      ),
    ],
  ),
  StatementSlideWidget(
    route: '/n-is-it-hard',
    eyebrow: 'Native APIs',
    statement: '「ネイティブ機能を使うのは\n難しい」？',
    subtitle: '答え：思ったより簡単。しかも、どんどん簡単になっている。',
    mood: GradientMood.cool,
  ),
  InteractiveSlideWidget(
    route: '/n-method-channel',
    eyebrow: 'MethodChannel',
    title: 'MethodChannel：名前で呼んで、結果を待つ',
    footnote: '同じチャンネル名で Dart と各 OS をつなぐ。呼び出しは非同期（Future）。',
    mood: GradientMood.calm,
    intensity: 0.4,
    builder: _methodChannelCodeBody,
  ),
  InteractiveSlideWidget(
    route: '/n-channel-sim',
    eyebrow: 'Demo · Under the hood',
    title: 'メッセージがチャンネルを通る旅',
    footnote: 'メッセージはバイト列にシリアライズされて OS 側へ。返事を待つ間も UI は止まらない。',
    mood: GradientMood.violet,
    intensity: 0.4,
    builder: _channelSimBody,
  ),
  CodeSlideWidget(
    route: '/n-pigeon',
    eyebrow: 'Pigeon',
    title: 'Pigeon：型安全なチャンネルを自動生成',
    fileName: 'pigeons/battery.dart',
    fontSize: 20,
    points: const [
      '定義を 1 回書くだけ',
      'Dart / Swift / Kotlin のコードを生成',
      'チャンネル名や型のミスがコンパイル時にわかる',
      'プラグイン開発の推奨デフォルト',
    ],
    code: _pigeonCode,
  ),
  InteractiveSlideWidget(
    route: '/n-ffigen',
    eyebrow: 'New · Direct native interop',
    title: 'FFIgen：Dart から OS の API を直接呼ぶ',
    footnote:
        '生成されるメソッド名は ffigen のバージョンで変わることがあります。Swift は @objc 経由（swiftgen は実験的）。',
    mood: GradientMood.hero,
    intensity: 0.4,
    builder: _ffigenBody,
  ),
  InteractiveSlideWidget(
    route: '/n-compare',
    eyebrow: 'Which one?',
    title: 'どれを使う？',
    footnote: '迷ったら Pigeon。OS の API をたくさん直接触るなら FFIgen / jnigen。',
    mood: GradientMood.calm,
    intensity: 0.4,
    builder: _compareBody,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Phone with a Flutter feed under a native-looking glass tab bar.
// ─────────────────────────────────────────────────────────────────────────────
class _NativeBarPhone extends StatelessWidget {
  const _NativeBarPhone();

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      width: 330,
      screenColor: const Color(0xFFF2F2F7),
      child: Stack(
        children: [
          const _FlutterFeed(),
          Positioned(
            left: 14,
            right: 14,
            bottom: 18,
            child: const _GlassTabBar(),
          ),
        ],
      ),
    );
  }
}

class _FlutterFeed extends StatelessWidget {
  const _FlutterFeed();

  static const _colors = [
    DeckColors.pink,
    DeckColors.blue,
    DeckColors.orange,
    DeckColors.purple,
    DeckColors.green,
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      physics: const ClampingScrollPhysics(),
      children: [
        Row(
          children: [
            const Text(
              'Feed',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: DeckColors.dart.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Text(
                'Flutter',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: DeckColors.flutterNavy,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final c in _colors)
          Container(
            height: 110,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [c, c.withValues(alpha: 0.55)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
      ],
    );
  }
}

class _GlassTabBar extends StatelessWidget {
  const _GlassTabBar();

  @override
  Widget build(BuildContext context) {
    const icons = [
      Icons.home_rounded,
      Icons.search_rounded,
      Icons.favorite_rounded,
      Icons.person_rounded,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 6, right: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: DeckColors.green,
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Text(
            'UITabBar（ネイティブ）',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              fontFamilyFallback: kFontFallback,
            ),
          ),
        ),
        Container(
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var i = 0; i < icons.length; i++)
                Icon(
                  icons[i],
                  size: 28,
                  color: i == 0 ? DeckColors.blue : Colors.black45,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Platform view code — Dart and Swift side by side.
// ─────────────────────────────────────────────────────────────────────────────
Widget _platformViewCodeBody(BuildContext context, int step) => const Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Expanded(
      child: CodePanel(
        _platformViewDart,
        language: 'dart',
        fileName: 'home_screen.dart',
        accent: DeckColors.dart,
        fontSize: 20,
      ),
    ),
    SizedBox(width: 32),
    Expanded(
      child: CodePanel(
        _platformViewSwift,
        language: 'swift',
        fileName: 'TabBarFactory.swift',
        accent: DeckColors.orange,
        fontSize: 20,
      ),
    ),
  ],
);

const _platformViewDart = '''
@override
Widget build(BuildContext context) {
  return Stack(
    children: [
      const FeedList(), // ← Flutter で描く
      Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          height: 84,
          // ← ここだけ OS のネイティブ View
          child: Platform.isIOS
              ? const UiKitView(viewType: 'native-tab-bar')
              : const AndroidView(viewType: 'native-tab-bar'),
        ),
      ),
    ],
  );
}
''';

const _platformViewSwift = '''
class TabBarFactory: NSObject, FlutterPlatformViewFactory {
  func create(withFrame frame: CGRect,
              viewIdentifier viewId: Int64,
              arguments args: Any?) -> FlutterPlatformView {
    TabBarView(frame: frame)
  }
}

class TabBarView: NSObject, FlutterPlatformView {
  private let tabBar = UITabBar()
  init(frame: CGRect) {
    tabBar.frame = frame
    super.init()
  }
  func view() -> UIView { tabBar }
}

// AppDelegate.swift
let registrar = registrar(forPlugin: "NativeTabBar")!
registrar.register(TabBarFactory(), withId: "native-tab-bar")
''';

// ─────────────────────────────────────────────────────────────────────────────
// Layer explode — tilt the screen and pull the layers apart.
// ─────────────────────────────────────────────────────────────────────────────
Widget _layersBody(BuildContext context, int step) => const _LayerExplode();

class _LayerExplode extends StatefulWidget {
  const _LayerExplode();

  @override
  State<_LayerExplode> createState() => _LayerExplodeState();
}

class _LayerExplodeState extends State<_LayerExplode> {
  double _t = 0.75;

  static const _layers = [
    ('① Flutter（下）', 'リスト・画像など', DeckColors.dart),
    ('② ネイティブ View', 'UITabBar / android.view.View', DeckColors.green),
    ('③ Flutter オーバーレイ', 'ネイティブの上に重ねた FAB など', DeckColors.pink),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: LayoutBuilder(
            builder: (context, c) => Stack(
              // Pushed down a little: the tilt lifts the far edge upward.
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                for (var i = 0; i < _layers.length; i++) _layer(i, c.biggest),
              ],
            ),
          ),
        ),
        const SizedBox(width: 30),
        SizedBox(
          width: 560,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('分解する', style: DeckText.caption),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: DeckColors.purple,
                  inactiveTrackColor: DeckColors.purple.withValues(alpha: 0.2),
                  thumbColor: Colors.white,
                  trackHeight: 6,
                ),
                child: Slider(
                  value: _t,
                  onChanged: (v) => setState(() => _t = v),
                ),
              ),
              const SizedBox(height: 18),
              for (final l in _layers.reversed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: l.$3,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.$1,
                              style: DeckText.heading.copyWith(fontSize: 28),
                            ),
                            Text(l.$2, style: DeckText.caption),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              const TitledCard(
                badge: 'ANDROID',
                title: '合成の方式を選べる',
                accent: DeckColors.green,
                lines: [
                  'Hybrid Composition：忠実だが重め',
                  'Texture Layer：速いが一部制約',
                  'HC++：新しい方式（Vulkan 端末）',
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _layer(int i, Size area) {
    final t = Curves.easeInOut.transform(_t);
    const w = 300.0;
    const h = 560.0;
    final spread = lerpDouble(0, 150, t)!;
    final m = Matrix4.identity()
      ..setEntry(3, 2, 0.0011)
      ..rotateX(t * 0.85)
      ..rotateZ(-t * 0.5)
      ..translateByDouble(0, 0, -(i - 1) * spread, 1);
    final (_, _, color) = _layers[i];

    final Widget content = switch (i) {
      0 => const ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(36)),
        child: _FlutterFeed(),
      ),
      1 => const Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.fromLTRB(12, 0, 12, 18),
          child: _GlassTabBar(),
        ),
      ),
      _ => Align(
        alignment: const Alignment(0.85, 0.55),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: DeckColors.pink,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: DeckColors.pink.withValues(alpha: 0.5),
                blurRadius: 20,
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 36),
        ),
      ),
    };

    return Transform.translate(
      offset: Offset(0, 50 * t),
      child: Transform(
        alignment: Alignment.center,
        transform: m,
        child: SizedBox(
          width: w,
          height: h,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: i == 0
                        ? const Color(0xFFF2F2F7)
                        : color.withValues(alpha: 0.06 * t),
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                      color: color.withValues(alpha: math.max(0.15, t)),
                      width: 2.5,
                    ),
                  ),
                  child: content,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MethodChannel code — Dart on top, Swift and Kotlin below.
// ─────────────────────────────────────────────────────────────────────────────
Widget _methodChannelCodeBody(BuildContext context, int step) => const Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    CodePanel(
      _channelDart,
      language: 'dart',
      fileName: 'battery.dart',
      accent: DeckColors.dart,
      fontSize: 18,
    ),
    SizedBox(height: 22),
    Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CodePanel(
              _channelSwift,
              language: 'swift',
              fileName: 'AppDelegate.swift',
              accent: DeckColors.orange,
              fontSize: 16,
            ),
          ),
          SizedBox(width: 24),
          Expanded(
            child: CodePanel(
              _channelKotlin,
              language: 'kotlin',
              fileName: 'MainActivity.kt',
              accent: DeckColors.purple,
              fontSize: 16,
            ),
          ),
        ],
      ),
    ),
  ],
);

const _channelDart = '''
const channel = MethodChannel('samples.flutter.dev/battery');

Future<int> getBatteryLevel() async {
  final level = await channel.invokeMethod<int>('getBatteryLevel');
  return level ?? -1;
}
''';

const _channelSwift = '''
let channel = FlutterMethodChannel(
  name: "samples.flutter.dev/battery",
  binaryMessenger: controller.binaryMessenger)

channel.setMethodCallHandler { call, result in
  guard call.method == "getBatteryLevel" else {
    return result(FlutterMethodNotImplemented)
  }
  UIDevice.current.isBatteryMonitoringEnabled = true
  result(Int(UIDevice.current.batteryLevel * 100))
}
''';

const _channelKotlin = '''
MethodChannel(flutterEngine.dartExecutor.binaryMessenger,
    "samples.flutter.dev/battery")
  .setMethodCallHandler { call, result ->
    if (call.method == "getBatteryLevel") {
      val bm = getSystemService(BATTERY_SERVICE)
          as BatteryManager
      result.success(bm.getIntProperty(
          BatteryManager.BATTERY_PROPERTY_CAPACITY))
    } else {
      result.notImplemented()
    }
  }
''';

// ─────────────────────────────────────────────────────────────────────────────
// MethodChannel simulator — an envelope travels Dart → codec → platform
// → handler and back, with the real StandardMethodCodec bytes.
// ─────────────────────────────────────────────────────────────────────────────
Widget _channelSimBody(BuildContext context, int step) => const _ChannelSim();

class _ChannelSim extends StatefulWidget {
  const _ChannelSim();

  @override
  State<_ChannelSim> createState() => _ChannelSimState();
}

class _ChannelSimState extends State<_ChannelSim>
    with TickerProviderStateMixin {
  late final AnimationController _trip = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  )..addListener(() => setState(() {}));

  // Keeps spinning to show the UI thread is not blocked while awaiting.
  late final AnimationController _spinner = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  final _rng = math.Random();
  int? _result;
  int _pending = 0;
  final List<String> _log = [];

  static const _nodes = [
    ('Dart', 'UI スレッド', DeckColors.dart),
    ('Codec', 'StandardMethodCodec', DeckColors.purple),
    ('Platform', 'プラットフォームスレッド', DeckColors.orange),
    ('Swift', 'setMethodCallHandler', DeckColors.green),
  ];

  // "getBatteryLevel" encoded by StandardMethodCodec: string (7), length 15,
  // UTF-8 bytes, then null arguments (0).
  static const _callBytes =
      '07 0F 67 65 74 42 61 74 74 65 72 79 4C 65 76 65 6C 00';

  Future<void> _call() async {
    if (_trip.isAnimating) return;
    final level = 60 + _rng.nextInt(40);
    setState(() {
      _pending = level;
      _result = null;
      _log
        ..clear()
        ..add("await channel.invokeMethod('getBatteryLevel')");
    });
    await _trip.forward(from: 0);
    if (!mounted) return;
    setState(() {
      _result = _pending;
      _log.add('← Future が完了：$_pending');
    });
  }

  @override
  void dispose() {
    _trip.dispose();
    _spinner.dispose();
    super.dispose();
  }

  /// Envelope position along the lane, 0..3 (node index), and direction.
  (double, bool) get _position {
    final v = _trip.value;
    if (v < 0.5) return (Curves.easeInOut.transform(v / 0.5) * 3, true);
    if (v < 0.6) return (3, true);
    return (3 - Curves.easeInOut.transform((v - 0.6) / 0.4) * 3, false);
  }

  String get _phase {
    final v = _trip.value;
    if (!_trip.isAnimating) return _result == null ? '待機中' : '完了';
    if (v < 0.17) return 'Dart：メソッド名と引数を渡す';
    if (v < 0.34) return 'Codec：バイト列にシリアライズ';
    if (v < 0.5) return 'Platform スレッドへ届く';
    if (v < 0.6) return 'Swift：バッテリー残量を取得';
    if (v < 0.8) return 'Codec：結果をバイト列に';
    return 'Dart：Future が完了';
  }

  String get _replyBytes {
    final b = _pending.toRadixString(16).padLeft(2, '0').toUpperCase();
    // Success envelope (0), int32 (3), little-endian.
    return '00 03 $b 00 00 00';
  }

  @override
  Widget build(BuildContext context) {
    final (pos, outbound) = _position;
    final animating = _trip.isAnimating;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: _call,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 34,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    gradient: DeckGradients.flutter,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    'getBatteryLevel() を呼ぶ',
                    style: DeckText.mono.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 34),
            RotationTransition(
              turns: _spinner,
              child: const Icon(
                Icons.autorenew_rounded,
                color: DeckColors.cyan,
                size: 40,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'UI は動き続ける',
              style: DeckText.caption.copyWith(color: DeckColors.cyan),
            ),
            const Spacer(),
            Text(_phase, style: DeckText.heading.copyWith(fontSize: 30)),
          ],
        ),
        const SizedBox(height: 40),
        SizedBox(
          height: 220,
          child: LayoutBuilder(
            builder: (context, c) {
              final step = (c.maxWidth - 260) / 3;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // The tube.
                  Positioned(
                    left: 130,
                    right: 130,
                    top: 96,
                    height: 28,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          colors: [
                            for (final n in _nodes) n.$3.withValues(alpha: 0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                  for (var i = 0; i < _nodes.length; i++)
                    Positioned(
                      left: i * step,
                      top: 0,
                      width: 260,
                      child: _ChannelNode(
                        title: _nodes[i].$1,
                        subtitle: _nodes[i].$2,
                        color: _nodes[i].$3,
                        active: animating && (pos - i).abs() < 0.35,
                      ),
                    ),
                  if (animating)
                    Positioned(
                      left: 130 + pos * step - 36,
                      top: 82,
                      child: _Envelope(outbound: outbound),
                    ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 30),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _BytesCard(
                  title: '呼び出し（Dart → OS）',
                  bytes: _callBytes,
                  legend:
                      '07 = String · 0F = 15 文字 · 67 65 74… = "getBatteryLevel" · 00 = 引数なし',
                  color: DeckColors.dart,
                  visible: _trip.value > 0.17 || _result != null,
                ),
              ),
              const SizedBox(width: 30),
              Expanded(
                child: _BytesCard(
                  title: '返事（OS → Dart）',
                  bytes: _pending == 0 ? '' : _replyBytes,
                  legend:
                      '00 = 成功 · 03 = int32 · 残り 4 バイト = $_pending（リトルエンディアン）',
                  color: DeckColors.green,
                  visible: _trip.value > 0.62 || _result != null,
                ),
              ),
              const SizedBox(width: 30),
              SizedBox(
                width: 320,
                child: DeckCard(
                  accent: DeckColors.green,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.battery_charging_full_rounded,
                        size: 60,
                        color: DeckColors.green,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _result == null ? '--' : '$_result%',
                        style: DeckText.display.copyWith(
                          fontSize: 80,
                          color: DeckColors.green,
                        ),
                      ),
                      Text(
                        _log.isEmpty ? '' : _log.last,
                        textAlign: TextAlign.center,
                        style: DeckText.monoSmall.copyWith(
                          fontSize: 15,
                          color: DeckColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChannelNode extends StatelessWidget {
  const _ChannelNode({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.active,
  });

  final String title;
  final String subtitle;
  final Color color;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: DeckText.heading.copyWith(fontSize: 32, color: color),
        ),
        Text(subtitle, style: DeckText.caption.copyWith(fontSize: 17)),
        const SizedBox(height: 12),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: active ? 0.4 : 0.12),
            border: Border.all(color: color, width: active ? 4 : 2),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.6),
                      blurRadius: 40,
                    ),
                  ]
                : null,
          ),
        ),
      ],
    );
  }
}

class _Envelope extends StatelessWidget {
  const _Envelope({required this.outbound});

  final bool outbound;

  @override
  Widget build(BuildContext context) {
    final c = outbound ? DeckColors.dart : DeckColors.green;
    return Container(
      width: 72,
      height: 56,
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: c.withValues(alpha: 0.8), blurRadius: 30)],
      ),
      child: Icon(
        outbound ? Icons.mail_rounded : Icons.mark_email_read_rounded,
        color: DeckColors.canvas,
        size: 34,
      ),
    );
  }
}

class _BytesCard extends StatelessWidget {
  const _BytesCard({
    required this.title,
    required this.bytes,
    required this.legend,
    required this.color,
    required this.visible,
  });

  final String title;
  final String bytes;
  final String legend;
  final Color color;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return DeckCard(
      accent: color,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0.15,
        duration: const Duration(milliseconds: 300),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: DeckText.heading.copyWith(fontSize: 26, color: color),
            ),
            const SizedBox(height: 14),
            Text(
              bytes,
              style: DeckText.mono.copyWith(
                fontSize: 22,
                color: DeckColors.text,
              ),
            ),
            const Spacer(),
            Text(legend, style: DeckText.caption.copyWith(fontSize: 17)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pigeon.
// ─────────────────────────────────────────────────────────────────────────────
const _pigeonCode = '''
// ① 定義（pigeons/battery.dart）
@HostApi()
abstract class BatteryApi {
  int getBatteryLevel();
}

// ② 生成
// \$ dart run pigeon --input pigeons/battery.dart

// ③ Swift：生成されたプロトコルを実装するだけ
class BatteryApiImpl: BatteryApi {
  func getBatteryLevel() throws -> Int64 { ... }
}

// ④ Dart：普通のメソッドとして呼ぶ
final level = await BatteryApi().getBatteryLevel();
''';

// ─────────────────────────────────────────────────────────────────────────────
// FFIgen — config + synchronous call, plus jnigen / build hooks cards.
// ─────────────────────────────────────────────────────────────────────────────
Widget _ffigenBody(BuildContext context, int step) => const Row(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    Expanded(
      flex: 11,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 6,
            child: CodePanel(
              _ffigenYaml,
              language: 'yaml',
              fileName: 'ffigen.yaml',
              accent: DeckColors.green,
              fontSize: 17,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            flex: 5,
            child: CodePanel(
              _ffigenDart,
              language: 'dart',
              fileName: 'battery.dart',
              accent: DeckColors.dart,
              fontSize: 20,
            ),
          ),
        ],
      ),
    ),
    SizedBox(width: 40),
    Expanded(
      flex: 7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _MiniCard(
              badge: 'iOS / macOS',
              title: 'FFIgen',
              line: 'Objective-C / C のヘッダーから\nDart のバインディングを生成',
              accent: DeckColors.pink,
            ),
          ),
          SizedBox(height: 18),
          Expanded(
            child: _MiniCard(
              badge: 'ANDROID',
              title: 'jnigen',
              line: 'Java / Kotlin の API を\nDart から直接呼べる',
              accent: DeckColors.green,
            ),
          ),
          SizedBox(height: 18),
          Expanded(
            child: _MiniCard(
              badge: 'BUILD HOOKS',
              title: 'ネイティブコードも同梱',
              line: 'C / C++ をビルドして\nパッケージに含められる',
              accent: DeckColors.orange,
            ),
          ),
        ],
      ),
    ),
  ],
);

class _MiniCard extends StatelessWidget {
  const _MiniCard({
    required this.badge,
    required this.title,
    required this.line,
    required this.accent,
  });

  final String badge;
  final String title;
  final String line;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return DeckCard(
      accent: accent,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  title,
                  style: DeckText.heading.copyWith(fontSize: 32, color: accent),
                ),
              ),
              const SizedBox(width: 16),
              Pill(badge, color: accent, fontSize: 16),
            ],
          ),
          const SizedBox(height: 10),
          Text(line, style: DeckText.bodySecondary.copyWith(fontSize: 22)),
        ],
      ),
    );
  }
}

const _ffigenYaml = r'''
name: DeviceBindings
language: objc
output: lib/device_bindings.dart
exclude-all-by-default: true
objc-interfaces:
  include:
    - UIDevice
headers:
  entry-points:
    - '…/iPhoneOS.sdk/System/Library/Frameworks/UIKit.framework/Headers/UIDevice.h'
''';

const _ffigenDart = '''
import 'device_bindings.dart';

double batteryLevel() {
  final device = UIDevice.getCurrentDevice();
  device.batteryMonitoringEnabled = true;
  return device.batteryLevel; // 同期！ await もチャンネルもなし
}
''';

// ─────────────────────────────────────────────────────────────────────────────
// Comparison table.
// ─────────────────────────────────────────────────────────────────────────────
Widget _compareBody(BuildContext context, int step) => const _InteropTable();

class _InteropTable extends StatelessWidget {
  const _InteropTable();

  static const _cols = [
    ('MethodChannel', DeckColors.cyan),
    ('Pigeon', DeckColors.purple),
    ('FFIgen / jnigen', DeckColors.pink),
  ];

  static const _rows = [
    ('型安全', ['✕  文字列 + dynamic', '◯  コード生成', '◯  コード生成']),
    ('呼び出し', ['非同期（Future）', '非同期（Future）', '同期・直接']),
    ('オーバーヘッド', ['メッセージを変換', 'メッセージを変換', 'ほぼなし']),
    ('書くコード', ['Dart + 各 OS を手書き', '定義 1 つ + OS 側の実装', 'ほぼ Dart だけ']),
    ('向いている用途', ['ちょっとした呼び出し', 'プラグイン開発の標準', 'OS の API を直接・大量に']),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 300),
            for (final c in _cols)
              Expanded(
                child: Center(child: Pill(c.$1, color: c.$2, fontSize: 26)),
              ),
          ],
        ),
        const SizedBox(height: 18),
        for (final r in _rows)
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white12)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 300,
                    child: Text(
                      r.$1,
                      style: DeckText.heading.copyWith(
                        fontSize: 28,
                        color: DeckColors.textSecondary,
                      ),
                    ),
                  ),
                  for (var i = 0; i < r.$2.length; i++)
                    Expanded(
                      child: Center(
                        child: Text(
                          r.$2[i],
                          textAlign: TextAlign.center,
                          style: DeckText.body.copyWith(
                            fontSize: 27,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
