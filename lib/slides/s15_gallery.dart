import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';
import 'package:flutter_intro_talk/core/theme/kaigi_theme.dart';
import 'package:flutter_intro_talk/core/widgets/deck_components.dart';
import 'package:flutter_intro_talk/core/widgets/deck_scaffold.dart';
import 'package:flutter_intro_talk/core/widgets/motion.dart';
import 'package:flutter_intro_talk/core/widgets/templates.dart';
import 'package:flutter_intro_talk/core/widgets/wwdc_background.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 11 · Made with Flutter ・ まとめ
// ─────────────────────────────────────────────────────────────────────────────
final List<FlutterDeckSlideWidget> gallerySlides = [
  DividerSlideWidget(
    route: '/m-divider',
    number: '11',
    label: 'Showcase',
    title: 'Made with Flutter',
    subtitle: 'もう、身近なアプリの中で動いている。',
    mood: GradientMood.hero,
    accent: DeckColors.dart,
  ),
  InteractiveSlideWidget(
    route: '/m-japan',
    eyebrow: 'Made in Japan',
    title: '日本の Flutter アプリ',
    footnote: 'カードをクリックすると「ポイント」が見られます。',
    mood: GradientMood.warm,
    intensity: 0.45,
    builder: _japanGallery,
  ),
  InteractiveSlideWidget(
    route: '/m-world',
    eyebrow: 'Around the world',
    title: '世界の Flutter アプリ',
    footnote: '金融・車・EC・テーマパーク・デスクトップ・TV まで。',
    mood: GradientMood.cool,
    intensity: 0.45,
    builder: _worldGallery,
  ),
  InteractiveSlideWidget(
    route: '/m-sources',
    eyebrow: 'Sources',
    title: '出典',
    mood: GradientMood.calm,
    intensity: 0.35,
    builder: _sources,
  ),
  InteractiveSlideWidget(
    route: '/m-recap',
    eyebrow: 'Recap',
    title: '今日のまとめ',
    footnote: '1つのコードで、すべての画面を、自分の手で描く。',
    mood: GradientMood.hero,
    steps: 2,
    builder: _recap,
  ),
  InteractiveSlideWidget(
    route: '/m-next',
    eyebrow: 'Next steps',
    title: '次の一歩',
    footnote: 'このスライド自体も Flutter アプリです（flutter_deck）。',
    mood: GradientMood.calm,
    intensity: 0.45,
    builder: _nextSteps,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Japan gallery — flip cards with drawn mini mockups.
// ─────────────────────────────────────────────────────────────────────────────
enum _Mock { car, jobs, delivery, sushi }

class _App {
  const _App(
    this.name,
    this.category,
    this.fact,
    this.points,
    this.accent,
    this.mock, {
    this.note,
  });

  final String name;
  final String category;
  final String fact;
  final List<String> points;
  final Color accent;
  final _Mock mock;
  final String? note;
}

const _japanApps = [
  _App(
    'トヨタ',
    'モビリティ',
    '車載マルチメディアに Flutter',
    [
      '車のディスプレイの UI を Flutter で',
      '2021年の Flutter Engage で発表',
      '社内向け Flutter 研修プログラムも',
    ],
    DeckColors.red,
    _Mock.car,
  ),
  _App(
    'メルカリ ハロ',
    'スキマバイト',
    '2024年3月リリース',
    [
      '公式エンジニアリングブログで採用を公表',
      '少人数で iOS / Android 同時リリース',
      'デザインシステムも Flutter で構築',
    ],
    DeckColors.pink,
    _Mock.jobs,
  ),
  _App(
    '出前館',
    'フードデリバリー',
    'React Native → Flutter',
    ['2023年11月に全面移行', '加盟店・配達員のアプリも Flutter', 'FlutterKaigi 2025 で2年運用の知見を発表'],
    DeckColors.orange,
    _Mock.delivery,
  ),
  _App(
    'スシロー',
    '飲食',
    '公式アプリ',
    ['テイクアウト注文', '店舗情報・順番待ち'],
    DeckColors.cyan,
    _Mock.sushi,
    note: '※ 公開情報ベース',
  ),
];

Widget _japanGallery(BuildContext context, int step) => Row(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    for (var i = 0; i < _japanApps.length; i++) ...[
      if (i > 0) const SizedBox(width: 26),
      Expanded(child: _FlipCard(app: _japanApps[i])),
    ],
  ],
);

class _FlipCard extends StatefulWidget {
  const _FlipCard({required this.app});

  final _App app;

  @override
  State<_FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<_FlipCard> {
  bool _flipped = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.app;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _flipped = !_flipped),
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: _flipped ? 1 : 0),
          duration: const Duration(milliseconds: 550),
          curve: Curves.easeInOutCubic,
          builder: (context, t, _) {
            final angle = t * math.pi;
            final showBack = t > 0.5;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..rotateY(angle),
              child: showBack
                  ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(math.pi),
                      child: _back(a),
                    )
                  : _front(a),
            );
          },
        ),
      ),
    );
  }

  Widget _front(_App a) => DeckCard(
    accent: a.accent,
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: _MiniMock(kind: a.mock, accent: a.accent),
          ),
        ),
        const SizedBox(height: 20),
        Pill(a.category, color: a.accent, fontSize: 16),
        const SizedBox(height: 12),
        Text(a.name, style: DeckText.heading.copyWith(fontSize: 36)),
        const SizedBox(height: 6),
        Text(a.fact, style: DeckText.bodySecondary.copyWith(fontSize: 22)),
      ],
    ),
  );

  Widget _back(_App a) => DeckCard(
    accent: a.accent,
    padding: const EdgeInsets.all(30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ポイント', style: DeckText.eyebrow.copyWith(color: a.accent)),
        const SizedBox(height: 12),
        Text(
          a.name,
          style: DeckText.heading.copyWith(fontSize: 36, color: a.accent),
        ),
        const SizedBox(height: 26),
        for (final p in a.points)
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Icon(Icons.check_rounded, color: a.accent, size: 24),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(p, style: DeckText.body.copyWith(fontSize: 23)),
                ),
              ],
            ),
          ),
        const Spacer(),
        if (a.note != null)
          Text(a.note!, style: DeckText.caption.copyWith(fontSize: 17)),
      ],
    ),
  );
}

/// Generic, logo-free sketches of each kind of app.
class _MiniMock extends StatelessWidget {
  const _MiniMock({required this.kind, required this.accent});

  final _Mock kind;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kind == _Mock.car
          ? const Color(0xFF0E1117)
          : const Color(0xFFF6F6F8),
      padding: const EdgeInsets.all(14),
      child: switch (kind) {
        _Mock.car => _car(),
        _Mock.jobs => _jobs(),
        _Mock.delivery => _delivery(),
        _Mock.sushi => _sushi(),
      },
    );
  }

  Widget _bar(double w, {Color c = const Color(0xFFD8D8DE), double h = 9}) =>
      Container(
        width: w,
        height: h,
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(5),
        ),
      );

  Widget _car() => Column(
    children: [
      Expanded(
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2230),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomPaint(
                  painter: _MapPainter(accent),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '48',
                    style: TextStyle(
                      color: accent,
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    'km/h',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  const Icon(
                    Icons.music_note_rounded,
                    color: Colors.white54,
                    size: 22,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (final i in [
            Icons.navigation_rounded,
            Icons.phone_rounded,
            Icons.ac_unit_rounded,
            Icons.settings_rounded,
          ])
            Icon(i, color: Colors.white38, size: 22),
        ],
      ),
    ],
  );

  Widget _jobs() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          for (final d in ['月', '火', '水', '木', '金'])
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 4),
                padding: const EdgeInsets.symmetric(vertical: 4),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: d == '水' ? accent : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  d,
                  style: TextStyle(
                    fontSize: 12,
                    color: d == '水' ? Colors.white : Colors.black54,
                  ),
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 10),
      for (var i = 0; i < 3; i++)
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _bar(90),
                    _bar(56, c: accent.withValues(alpha: 0.5), h: 7),
                  ],
                ),
              ),
              Text(
                '¥${1200 + i * 100}',
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ],
          ),
        ),
    ],
  );

  Widget _delivery() => Column(
    children: [
      Container(
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFFE6EEF4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _MapPainter(accent, light: true)),
            ),
            Positioned(
              left: 70,
              top: 22,
              child: Icon(
                Icons.delivery_dining_rounded,
                color: accent,
                size: 28,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      Expanded(
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.2,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final c in [
              const Color(0xFFFFCC80),
              const Color(0xFFA5D6A7),
              const Color(0xFFEF9A9A),
              const Color(0xFF90CAF9),
            ])
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: c,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    _bar(50, h: 6),
                  ],
                ),
              ),
          ],
        ),
      ),
    ],
  );

  Widget _sushi() => Column(
    children: [
      Expanded(
        child: GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final c in [
              const Color(0xFFFF8A65),
              const Color(0xFFFFF59D),
              const Color(0xFFEF5350),
              const Color(0xFFFFCC80),
              const Color(0xFFE57373),
              const Color(0xFFA5D6A7),
            ])
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accent.withValues(alpha: 0.6),
                    width: 3,
                  ),
                ),
                alignment: Alignment.center,
                child: Container(
                  width: 30,
                  height: 16,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
          ],
        ),
      ),
      Container(
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: accent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          '注文する',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
  );
}

class _MapPainter extends CustomPainter {
  _MapPainter(this.accent, {this.light = false});

  final Color accent;
  final bool light;

  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = light ? Colors.white : const Color(0xFF2C3545)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    for (var i = 1; i < 4; i++) {
      canvas
        ..drawLine(
          Offset(0, size.height * i / 4),
          Offset(size.width, size.height * i / 4 + 8),
          road,
        )
        ..drawLine(
          Offset(size.width * i / 4, 0),
          Offset(size.width * i / 4 - 10, size.height),
          road,
        );
    }
    final route = Path()
      ..moveTo(size.width * 0.1, size.height * 0.85)
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.3,
        size.width * 0.9,
        size.height * 0.2,
      );
    canvas.drawPath(
      route,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }

  @override
  bool shouldRepaint(_MapPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// World gallery — filter chips.
// ─────────────────────────────────────────────────────────────────────────────
const _categories = ['すべて', '金融', 'モビリティ', 'EC', 'エンタメ', '教育', 'デスクトップ・TV'];

const _worldApps = [
  (
    'Google Pay',
    '金融',
    'Flutter で再構築、コード量を大幅削減',
    Icons.account_balance_wallet_rounded,
    DeckColors.blue,
  ),
  (
    'Nubank',
    '金融',
    'ブラジル発の巨大デジタル銀行',
    Icons.credit_card_rounded,
    DeckColors.purple,
  ),
  (
    'My BMW',
    'モビリティ',
    '車とつながる公式アプリ',
    Icons.directions_car_filled_rounded,
    DeckColors.cyan,
  ),
  (
    'Xianyu（Alibaba）',
    'EC',
    '中古売買アプリで初期から大規模採用',
    Icons.shopping_bag_rounded,
    DeckColors.orange,
  ),
  (
    'ByteDance',
    'エンタメ',
    '社内の多数のアプリで活用',
    Icons.music_video_rounded,
    DeckColors.pink,
  ),
  (
    'Universal',
    'エンタメ',
    'テーマパーク公式アプリ',
    Icons.attractions_rounded,
    DeckColors.orange,
  ),
  (
    'Google Classroom',
    '教育',
    'iOS / Android の開発を統一',
    Icons.school_rounded,
    DeckColors.green,
  ),
  (
    'Ubuntu（Canonical）',
    'デスクトップ・TV',
    'インストーラーとデスクトップアプリ',
    Icons.desktop_windows_rounded,
    DeckColors.red,
  ),
  (
    'LG webOS',
    'デスクトップ・TV',
    'テレビのアプリにも Flutter',
    Icons.tv_rounded,
    DeckColors.pink,
  ),
];

Widget _worldGallery(BuildContext context, int step) => const _WorldGallery();

class _WorldGallery extends StatefulWidget {
  const _WorldGallery();

  @override
  State<_WorldGallery> createState() => _WorldGalleryState();
}

class _WorldGalleryState extends State<_WorldGallery> {
  String _filter = 'すべて';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            for (final c in _categories)
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => setState(() => _filter = c),
                  child: Pill(
                    c,
                    color: _filter == c
                        ? DeckColors.dart
                        : DeckColors.textTertiary,
                    filled: _filter == c,
                    fontSize: 19,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 26),
        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            childAspectRatio: 3.0,
            mainAxisSpacing: 18,
            crossAxisSpacing: 18,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (final (name, cat, line, icon, color) in _worldApps)
                AnimatedOpacity(
                  opacity: _filter == 'すべて' || _filter == cat ? 1 : 0.12,
                  duration: const Duration(milliseconds: 300),
                  child: DeckCard(
                    accent: color,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(icon, color: color, size: 34),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      name,
                                      overflow: TextOverflow.ellipsis,
                                      style: DeckText.heading.copyWith(
                                        fontSize: 26,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Pill(cat, color: color, fontSize: 13),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                line,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: DeckText.caption.copyWith(fontSize: 19),
                              ),
                            ],
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

// ─────────────────────────────────────────────────────────────────────────────
// Sources.
// ─────────────────────────────────────────────────────────────────────────────
const _sourceList = [
  (
    'メルカリ ハロ アプリの技術スタックの紹介',
    'engineering.mercari.com/blog/entry/20240606-mercari-hallo-app-tech-stacks',
    DeckColors.pink,
  ),
  (
    'メルカリ ハロのデザインシステムと Flutter',
    'engineering.mercari.com/blog/entry/20241210-flutter-hallo-design-system',
    DeckColors.pink,
  ),
  (
    'Flutterにしてよかった？ 出前館アプリを2年運用して…',
    'fortee.jp/flutterkaigi-2025（FlutterKaigi 2025）',
    DeckColors.orange,
  ),
  (
    'TOYOTA Developers Night — Flutter training',
    'techplay.jp/video/71',
    DeckColors.red,
  ),
  ('Flutter Showcase', 'flutter.dev/showcase', DeckColors.dart),
  (
    'Flutter の「本格活用の時代」を祝う',
    'developers.googleblog.com/ja/celebrating-flutters-production-era',
    DeckColors.blue,
  ),
];

Widget _sources(BuildContext context, int step) => Column(
  children: [
    for (final (title, url, accent) in _sourceList)
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: DeckCard(
          accent: accent,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Text(
                  title,
                  style: DeckText.heading.copyWith(fontSize: 26, color: accent),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 6,
                child: Text(
                  url,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DeckText.monoSmall.copyWith(
                    color: DeckColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    const Spacer(),
    Footnote(
      'スシロー・海外事例は公開情報・まとめ記事ベース。数字や詳細は各社の一次情報で確認を。',
      color: DeckColors.orange,
    ),
  ],
);

// ─────────────────────────────────────────────────────────────────────────────
// Recap.
// ─────────────────────────────────────────────────────────────────────────────
const _chapters = [
  ('2チーム・2コードベース → 1つの Flutter', DeckColors.red),
  ('すべては Widget', DeckColors.dart),
  ('Widget ・ Element ・ RenderObject の3つのツリー', DeckColors.cyan),
  ('setState → InheritedWidget → Riverpod / BLoC', DeckColors.blue),
  ('Screen → ViewModel → Repository → ApiClient', DeckColors.purple),
  ('全ピクセルを自分で描く → 何でも描ける', DeckColors.pink),
  ('Platform View ・ MethodChannel ・ FFIgen', DeckColors.orange),
  ('AI ・ テスト ・ GenUI / A2UI', DeckColors.green),
];

Widget _recap(BuildContext context, int step) => GridView.count(
  crossAxisCount: 2,
  childAspectRatio: 6.4,
  mainAxisSpacing: 18,
  crossAxisSpacing: 26,
  physics: const NeverScrollableScrollPhysics(),
  children: [
    for (var i = 0; i < _chapters.length; i++)
      StaggerIn(
        visible: step >= 1,
        delayMs: i * 90,
        child: DeckCard(
          accent: _chapters[i].$2,
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 10),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  step >= 2
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  key: ValueKey(step >= 2),
                  color: _chapters[i].$2,
                  size: 34,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  _chapters[i].$1,
                  style: DeckText.body.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
  ],
);

// ─────────────────────────────────────────────────────────────────────────────
// Next steps.
// ─────────────────────────────────────────────────────────────────────────────
const _links = [
  ('公式ドキュメント', 'docs.flutter.dev', Icons.menu_book_rounded, DeckColors.dart),
  (
    'DartPad',
    'dartpad.dev — ブラウザだけで試せる',
    Icons.play_circle_outline_rounded,
    DeckColors.cyan,
  ),
  (
    'Codelabs',
    'docs.flutter.dev/codelabs',
    Icons.school_rounded,
    DeckColors.green,
  ),
  ('pub.dev', 'パッケージを探す', Icons.inventory_2_rounded, DeckColors.blue),
  (
    'Flutter Tokyo',
    'connpass で「Flutter Tokyo」',
    Icons.groups_rounded,
    DeckColors.pink,
  ),
  (
    'FlutterKaigi',
    'flutterkaigi.jp',
    Icons.campaign_rounded,
    DeckColors.purple,
  ),
];

Widget _nextSteps(BuildContext context, int step) => GridView.count(
  crossAxisCount: 2,
  childAspectRatio: 4.0,
  mainAxisSpacing: 22,
  crossAxisSpacing: 22,
  physics: const NeverScrollableScrollPhysics(),
  children: [
    for (final (title, url, icon, accent) in _links)
      DeckCard(
        accent: accent,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
        child: Row(
          children: [
            Icon(icon, color: accent, size: 48),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: DeckText.heading.copyWith(
                      fontSize: 32,
                      color: accent,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    url,
                    style: DeckText.monoSmall.copyWith(
                      color: DeckColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
  ],
);
