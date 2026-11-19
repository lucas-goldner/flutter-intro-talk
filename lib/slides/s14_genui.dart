import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';
import 'package:flutter_intro_talk/core/theme/kaigi_theme.dart';
import 'package:flutter_intro_talk/core/widgets/deck_components.dart';
import 'package:flutter_intro_talk/core/widgets/motion.dart';
import 'package:flutter_intro_talk/core/widgets/phone_frame.dart';
import 'package:flutter_intro_talk/core/widgets/templates.dart';
import 'package:flutter_intro_talk/core/widgets/wwdc_background.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 10 · GenUI と A2UI
// ─────────────────────────────────────────────────────────────────────────────
final List<FlutterDeckSlideWidget> genUiSlides = [
  DividerSlideWidget(
    route: '/g-divider',
    number: '10',
    label: 'Generative UI',
    title: 'GenUI と A2UI',
    subtitle: 'AI がその場で UI を組み立てる時代へ。',
    mood: GradientMood.violet,
    accent: DeckColors.pink,
  ),
  StatementSlideWidget(
    route: '/g-statement',
    eyebrow: 'Generative UI',
    statement: 'AI が返すのは、\nテキストではなく UI。',
    subtitle: '「予約したい」と言ったら、文章ではなく予約フォームが返ってくる。',
    gradient: DeckGradients.hero,
  ),
  InteractiveSlideWidget(
    route: '/g-a2ui',
    eyebrow: 'A2UI · Agent to UI',
    title: 'A2UI：UI を「データ」として送るプロトコル',
    footnote: 'コードは送らない。カタログにある部品の「組み立て方」だけを送る → 安全。',
    mood: GradientMood.violet,
    steps: 3,
    builder: _a2uiDiagram,
  ),
  CodeSlideWidget(
    route: '/g-json',
    eyebrow: 'A2UI message',
    title: 'エージェントが送ってくる JSON',
    fileName: 'agent → client（イメージ）',
    language: 'json',
    fontSize: 20,
    points: const [
      'id でつなぐフラットなツリー',
      'component はカタログの名前',
      'path でデータモデルにバインド',
      'action はエージェントへ返るイベント',
    ],
    footnote: '形式は A2UI v0.9 をもとに簡略化したイメージ。',
    code: '''
{
  "updateComponents": {
    "surfaceId": "booking",
    "components": [
      { "id": "root", "component": "Column",
        "children": ["title", "date", "book"] },
      { "id": "title", "component": "Text",
        "text": "カフェ Dash を予約" },
      { "id": "date", "component": "DateTimeInput",
        "value": { "path": "/reservation/date" } },
      { "id": "book", "component": "Button",
        "child": "bookLabel",
        "action": { "name": "confirm_booking" } }
    ]
  }
}
''',
  ),
  CardGridSlideWidget(
    route: '/g-why-flutter',
    eyebrow: 'Why Flutter first',
    title: 'なぜ Flutter が最初の A2UI フレームワークなのか',
    columns: 3,
    childAspectRatio: 1.7,
    mood: GradientMood.hero,
    footnote: 'GenUI SDK は A2A チーム・Google Labs（Opal）と一緒に、A2UI を前提に作られた。',
    cards: const [
      CardSpec(
        badge: 'CATALOG',
        title: 'Widget = 部品カタログ',
        lines: ['A2UI のカタログが', 'そのまま Widget の一覧になる'],
        accent: DeckColors.pink,
      ),
      CardSpec(
        badge: 'TREE',
        title: 'ツリー ≈ JSON',
        lines: ['宣言的な Widget ツリーと', 'JSON の部品ツリーが同じ形'],
        accent: DeckColors.purple,
      ),
      CardSpec(
        badge: 'EVERYWHERE',
        title: '1レンダラーで6 OS',
        lines: ['自前で描くので', 'どの OS でも同じ見た目'],
        accent: DeckColors.blue,
      ),
      CardSpec(
        badge: 'TYPED',
        title: 'スキーマで型安全',
        lines: ['部品ごとに JSON Schema', 'LLM の出力を検証できる'],
        accent: DeckColors.cyan,
      ),
      CardSpec(
        badge: 'GOOGLE',
        title: '同じチームで設計',
        lines: ['A2A ・ Opal と並走', 'A2UI と一緒に生まれた'],
        accent: DeckColors.orange,
      ),
    ],
  ),
  CodeSlideWidget(
    route: '/g-sdk',
    eyebrow: 'GenUI SDK for Flutter',
    title: 'GenUI SDK：自分の Widget をカタログに',
    fileName: 'genui_setup.dart（イメージ）',
    fontSize: 18,
    points: const ['① Widget + スキーマを登録', '② エージェントとつなぐ', '③ Surface に描かれる'],
    footnote: 'イメージ — GenUI の API はバージョンごとに変化中。最新は docs.flutter.dev/ai/genui',
    code: '''
// ① アプリの部品をカタログとして公開
final weatherCard = CatalogItem(
  name: 'WeatherCard',
  dataSchema: S.object(properties: {
    'city': S.string(),
    'tempC': S.number(),
  }),
  widgetBuilder: (context) => WeatherCard(
    city: context.data['city'],
    tempC: context.data['tempC'],
  ),
);

// ② エージェントとの会話をつなぐ
final conversation = GenUiConversation(
  catalog: CoreCatalogItems.asCatalog()
      .copyWith([weatherCard]),
  contentGenerator: myAgent, // Gemini / A2A サーバー
);

// ③ 生成された UI を描く
GenUiSurface(host: conversation.host, surfaceId: 'main')
''',
  ),
  InteractiveSlideWidget(
    route: '/g-simulator',
    eyebrow: 'GenUI · demo',
    title: 'JSON が届くそばから、Widget になる',
    mood: GradientMood.violet,
    intensity: 0.45,
    builder: _simulator,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// A2UI flow diagram.
// ─────────────────────────────────────────────────────────────────────────────
Widget _a2uiDiagram(BuildContext context, int step) => Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    FlowRow(
      currentStep: step == 1 ? 2 : (step == 2 ? 4 : 5),
      steps: const [
        FlowStep(
          index: 1,
          title: 'ユーザー',
          subtitle: '「予約したい」',
          accent: DeckColors.text,
        ),
        FlowStep(
          index: 2,
          title: 'エージェント',
          subtitle: 'LLM が UI を考える',
          accent: DeckColors.purple,
        ),
        FlowStep(
          index: 3,
          title: 'A2UI JSON',
          subtitle: 'UI をデータで送る',
          accent: DeckColors.green,
        ),
        FlowStep(
          index: 4,
          title: 'レンダラー',
          subtitle: 'カタログで解釈',
          accent: DeckColors.dart,
        ),
        FlowStep(
          index: 5,
          title: 'Widget',
          subtitle: 'ネイティブに描画',
          accent: DeckColors.cyan,
        ),
      ],
    ),
    const SizedBox(height: 40),
    StaggerIn(
      visible: step >= 3,
      child: Row(
        children: [
          const Icon(
            Icons.subdirectory_arrow_left_rounded,
            color: DeckColors.orange,
            size: 48,
          ),
          const SizedBox(width: 18),
          Text(
            'タップ・入力 → userAction としてエージェントへ戻る → UI を更新',
            style: DeckText.heading.copyWith(
              fontSize: 30,
              color: DeckColors.orange,
            ),
          ),
        ],
      ),
    ),
    const SizedBox(height: 40),
    StaggerIn(
      visible: step >= 3,
      child: const Wrap(
        spacing: 16,
        runSpacing: 14,
        children: [
          Pill('ストリーミングで少しずつ', color: DeckColors.cyan),
          Pill('データモデルにバインド', color: DeckColors.blue),
          Pill('レンダラー：Flutter ・ Lit ・ Angular …', color: DeckColors.purple),
        ],
      ),
    ),
  ],
);

// ─────────────────────────────────────────────────────────────────────────────
// GenUI simulator: scripted A2UI messages stream in, widgets materialise.
// ─────────────────────────────────────────────────────────────────────────────
Widget _simulator(BuildContext context, int step) => const _GenUiSimulator();

enum _Comp {
  title,
  weather,
  tip,
  button,
  cafe,
  dates,
  people,
  timeline,
  budget,
  done,
}

class _Chunk {
  const _Chunk(this.lines, [this.comp]);

  final List<String> lines;
  final _Comp? comp;
}

class _Scenario {
  const _Scenario({
    required this.prompt,
    required this.chunks,
    required this.buttonLabel,
    required this.action,
    required this.doneText,
  });

  final String prompt;
  final List<_Chunk> chunks;
  final String buttonLabel;
  final String action;
  final String doneText;
}

const _header = _Chunk([
  '{ "updateComponents": {',
  '  "surfaceId": "main", "components": [',
]);
const _footer = _Chunk([']}}']);

_Chunk _buttonChunk(String label, String action) => _Chunk([
  '  { "id": "cta", "component": "Button",',
  '    "label": "$label",',
  '    "action": { "name": "$action" } }',
], _Comp.button);

final _scenarios = [
  _Scenario(
    prompt: '週末の東京の天気',
    buttonLabel: '傘リマインダーをオン',
    action: 'enable_reminder',
    doneText: '日曜 8:00 にお知らせします ☂',
    chunks: const [
      _header,
      _Chunk([
        '  { "id": "title", "component": "Text",',
        '    "text": "週末の東京", "style": "h2" },',
      ], _Comp.title),
      _Chunk([
        '  { "id": "sat", "component": "WeatherCard",',
        '    "day": "土", "icon": "sunny", "tempC": 18 },',
        '  { "id": "sun", "component": "WeatherCard",',
        '    "day": "日", "icon": "rain", "tempC": 14 },',
      ], _Comp.weather),
      _Chunk([
        '  { "id": "tip", "component": "Text",',
        '    "text": "日曜は傘があると安心です" },',
      ], _Comp.tip),
    ],
  ),
  _Scenario(
    prompt: 'カフェを予約したい',
    buttonLabel: '予約する',
    action: 'confirm_booking',
    doneText: '予約が完了しました',
    chunks: const [
      _header,
      _Chunk([
        '  { "id": "title", "component": "Text",',
        '    "text": "カフェ Dash を予約", "style": "h2" },',
      ], _Comp.title),
      _Chunk([
        '  { "id": "shop", "component": "PlaceCard",',
        '    "name": "カフェ Dash 渋谷", "rating": 4.6 },',
      ], _Comp.cafe),
      _Chunk([
        '  { "id": "date", "component": "ChoicePicker",',
        '    "options": ["今日", "明日", "土曜"],',
        '    "value": { "path": "/booking/day" } },',
      ], _Comp.dates),
      _Chunk([
        '  { "id": "people", "component": "Slider",',
        '    "min": 1, "max": 6,',
        '    "value": { "path": "/booking/people" } },',
      ], _Comp.people),
    ],
  ),
  _Scenario(
    prompt: '京都2泊の旅行プラン',
    buttonLabel: 'プランを保存',
    action: 'save_plan',
    doneText: 'プランを保存しました',
    chunks: const [
      _header,
      _Chunk([
        '  { "id": "title", "component": "Text",',
        '    "text": "京都 2泊3日", "style": "h2" },',
      ], _Comp.title),
      _Chunk([
        '  { "id": "plan", "component": "Timeline",',
        '    "items": ["伏見稲荷", "嵐山", "錦市場"] },',
      ], _Comp.timeline),
      _Chunk([
        '  { "id": "budget", "component": "Slider",',
        '    "min": 3, "max": 15, "unit": "万円",',
        '    "value": { "path": "/plan/budget" } },',
      ], _Comp.budget),
    ],
  ),
];

class _GenUiSimulator extends StatefulWidget {
  const _GenUiSimulator();

  @override
  State<_GenUiSimulator> createState() => _GenUiSimulatorState();
}

class _GenUiSimulatorState extends State<_GenUiSimulator> {
  Timer? _timer;
  _Scenario? _scenario;

  /// All JSON lines to type, and which component each line completes.
  final _queue = <(String, _Comp?, bool)>[]; // (line, completes, isEvent)
  final _shown = <(String, bool)>[]; // (line, isEvent)
  final _built = <_Comp>[];
  bool _actionSent = false;

  // Data model the generated widgets are bound to.
  int _day = 2;
  double _people = 2;
  double _budget = 8;

  void _choose(_Scenario s) {
    _timer?.cancel();
    setState(() {
      _scenario = s;
      _queue.clear();
      _shown.clear();
      _built.clear();
      _actionSent = false;
      _day = 2;
      _people = 2;
      _budget = 8;
      final chunks = [
        ...s.chunks,
        _buttonChunk(s.buttonLabel, s.action),
        _footer,
      ];
      for (final c in chunks) {
        for (var i = 0; i < c.lines.length; i++) {
          _queue.add((
            c.lines[i],
            i == c.lines.length - 1 ? c.comp : null,
            false,
          ));
        }
      }
    });
    _startTyping();
  }

  void _startTyping() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 140), (t) {
      if (!mounted) return;
      if (_queue.isEmpty) {
        t.cancel();
        return;
      }
      setState(() {
        final (line, comp, isEvent) = _queue.removeAt(0);
        _shown.add((line, isEvent));
        if (_shown.length > 22) _shown.removeAt(0);
        if (comp != null) _built.add(comp);
      });
    });
  }

  void _sendAction() {
    final s = _scenario;
    if (s == null || _actionSent) return;
    setState(() {
      _actionSent = true;
      final detail = switch (s.action) {
        'confirm_booking' =>
          '"day": "${['今日', '明日', '土曜'][_day]}", "people": ${_people.round()}',
        'save_plan' => '"budget": ${_budget.round()}',
        _ => '"enabled": true',
      };
      _queue
        ..add(('↑ { "userAction": { "name": "${s.action}",', null, true))
        ..add(('↑   "context": { $detail } } }', null, true))
        ..add(('{ "updateComponents": { "surfaceId": "main",', null, false))
        ..add(('  "components": [ { "id": "done",', null, false))
        ..add((
          '    "component": "Banner", "text": "${s.doneText}" } ]}}',
          _Comp.done,
          false,
        ));
    });
    _startTyping();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 11,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 14,
                runSpacing: 12,
                children: [
                  for (final s in _scenarios)
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => _choose(s),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            gradient: _scenario == s
                                ? DeckGradients.hero
                                : null,
                            color: _scenario == s
                                ? null
                                : Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: DeckColors.purple.withValues(alpha: 0.6),
                            ),
                          ),
                          child: Text(
                            '✦ ${s.prompt}',
                            style: DeckText.body.copyWith(fontSize: 23),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10101A),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: DeckColors.green.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'A2UI stream  agent ⇄ client',
                        style: DeckText.eyebrow.copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: 10),
                      if (_scenario == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(
                            '↑ プロンプトを選んでみて',
                            style: DeckText.body.copyWith(
                              color: DeckColors.textTertiary,
                            ),
                          ),
                        ),
                      Expanded(
                        child: ClipRect(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final (line, isEvent) in _shown)
                                _JsonLine(line, isEvent: isEvent),
                            ],
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
        const SizedBox(width: 48),
        Expanded(
          flex: 6,
          child: Center(
            child: PhoneFrame(
              width: 340,
              accent: DeckColors.purple,
              screenColor: const Color(0xFFF7F5FF),
              child: _scenario == null
                  ? const Center(
                      child: Text(
                        'GenUiSurface',
                        style: TextStyle(color: Colors.black26, fontSize: 18),
                      ),
                    )
                  : _Surface(
                      scenario: _scenario!,
                      built: _built,
                      day: _day,
                      people: _people,
                      budget: _budget,
                      actionSent: _actionSent,
                      onDay: (d) => setState(() => _day = d),
                      onPeople: (v) => setState(() => _people = v),
                      onBudget: (v) => setState(() => _budget = v),
                      onAction: _sendAction,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _JsonLine extends StatelessWidget {
  const _JsonLine(this.line, {required this.isEvent});

  final String line;
  final bool isEvent;

  @override
  Widget build(BuildContext context) {
    final base = DeckText.monoSmall.copyWith(fontSize: 18, height: 1.5);
    if (isEvent) {
      return Text(
        line,
        maxLines: 1,
        overflow: TextOverflow.clip,
        style: base.copyWith(color: DeckColors.orange),
      );
    }
    // Colour "strings" green, the rest grey.
    final parts = line.split('"');
    return Text.rich(
      TextSpan(
        children: [
          for (var i = 0; i < parts.length; i++)
            TextSpan(
              text: i == parts.length - 1 ? parts[i] : '${parts[i]}"',
              style: base.copyWith(
                color: i.isOdd
                    ? const Color(0xFF9EF1DD)
                    : DeckColors.textSecondary,
              ),
            ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.clip,
    );
  }
}

/// The client-side renderer: maps catalog names to real Flutter widgets.
class _Surface extends StatelessWidget {
  const _Surface({
    required this.scenario,
    required this.built,
    required this.day,
    required this.people,
    required this.budget,
    required this.actionSent,
    required this.onDay,
    required this.onPeople,
    required this.onBudget,
    required this.onAction,
  });

  final _Scenario scenario;
  final List<_Comp> built;
  final int day;
  final double people;
  final double budget;
  final bool actionSent;
  final ValueChanged<int> onDay;
  final ValueChanged<double> onPeople;
  final ValueChanged<double> onBudget;
  final VoidCallback onAction;

  static const _ink = Color(0xFF1C1B1F);
  static const _primary = Color(0xFF6C4CF1);

  Widget _card(Widget child) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 10,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: child,
  );

  Widget _weather(String d, IconData icon, Color c, int temp) => Expanded(
    child: _card(
      Column(
        children: [
          Text(
            '$d曜',
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Icon(icon, color: c, size: 38),
          const SizedBox(height: 6),
          Text(
            '$temp°',
            style: const TextStyle(
              color: _ink,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _build(_Comp c) {
    switch (c) {
      case _Comp.title:
        final text = switch (scenario.action) {
          'enable_reminder' => '週末の東京',
          'confirm_booking' => 'カフェ Dash を予約',
          _ => '京都 2泊3日',
        };
        return Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 4),
          child: Text(
            text,
            style: const TextStyle(
              color: _ink,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        );
      case _Comp.weather:
        return Row(
          children: [
            _weather('土', Icons.wb_sunny_rounded, const Color(0xFFFFA000), 18),
            const SizedBox(width: 10),
            _weather('日', Icons.umbrella_rounded, const Color(0xFF1E88E5), 14),
          ],
        );
      case _Comp.tip:
        return const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            '日曜は傘があると安心です',
            style: TextStyle(color: Colors.black54, fontSize: 14),
          ),
        );
      case _Comp.cafe:
        return _card(
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE0B2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_cafe_rounded,
                  color: Color(0xFF8D6E63),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'カフェ Dash 渋谷',
                      style: TextStyle(
                        color: _ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '★ 4.6 ・ 徒歩5分',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      case _Comp.dates:
        const options = ['今日', '明日', '土曜'];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              for (var i = 0; i < options.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: actionSent ? null : () => onDay(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: day == i ? _primary : Colors.white,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: _primary),
                      ),
                      child: Text(
                        options[i],
                        style: TextStyle(
                          color: day == i ? Colors.white : _primary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      case _Comp.people:
        return _labeledSlider(
          '人数',
          '${people.round()} 名',
          people,
          1,
          6,
          onPeople,
        );
      case _Comp.budget:
        return _labeledSlider(
          '予算',
          '${budget.round()} 万円',
          budget,
          3,
          15,
          onBudget,
        );
      case _Comp.timeline:
        const items = [('1日目', '伏見稲荷'), ('2日目', '嵐山'), ('3日目', '錦市場')];
        return _card(
          Column(
            children: [
              for (final (d, place) in items)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: _primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        d,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        place,
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      case _Comp.button:
        return Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 12),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onAction,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: actionSent ? const Color(0xFFBDBDBD) : _primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  actionSent ? '送信済み' : '${scenario.buttonLabel}  ← タップ',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        );
      case _Comp.done:
        final detail = switch (scenario.action) {
          'confirm_booking' =>
            '\n${['今日', '明日', '土曜'][day]} 14:00 ・ ${people.round()} 名',
          'save_plan' => '\n予算 ${budget.round()} 万円',
          _ => '',
        };
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF43A047)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF43A047)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${scenario.doneText}$detail',
                  style: const TextStyle(
                    color: Color(0xFF1B5E20),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _labeledSlider(
    String label,
    String value,
    double v,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) => _card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                color: _ink,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: const SliderThemeData(
            activeTrackColor: _primary,
            thumbColor: _primary,
            inactiveTrackColor: Color(0xFFDDD6FF),
          ),
          child: Slider(
            value: v,
            min: min,
            max: max,
            onChanged: actionSent ? null : onChanged,
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final c in built)
              TweenAnimationBuilder<double>(
                key: ValueKey(c),
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 420),
                curve: Curves.easeOutBack,
                builder: (context, t, child) => Opacity(
                  opacity: t.clamp(0.0, 1.0),
                  child: Transform.scale(scale: 0.85 + 0.15 * t, child: child),
                ),
                child: _build(c),
              ),
          ],
        ),
      ),
    );
  }
}
