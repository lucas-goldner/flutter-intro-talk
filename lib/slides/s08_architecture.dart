import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';
import 'package:flutter_intro_talk/core/theme/kaigi_theme.dart';
import 'package:flutter_intro_talk/core/widgets/deck_components.dart';
import 'package:flutter_intro_talk/core/widgets/motion.dart';
import 'package:flutter_intro_talk/core/widgets/phone_frame.dart';
import 'package:flutter_intro_talk/core/widgets/templates.dart';
import 'package:flutter_intro_talk/core/widgets/wwdc_background.dart';
import 'package:flutter_intro_talk/demo_app/api_client.dart';
import 'package:flutter_intro_talk/demo_app/demo_app.dart';
import 'package:flutter_intro_talk/demo_app/layer_trace.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 06 · アプリの設計 — Screen → ViewModel → Repository → ApiClient
// ─────────────────────────────────────────────────────────────────────────────

final List<FlutterDeckSlideWidget> architectureSlides = [
  DividerSlideWidget(
    route: '/a-divider',
    number: '07',
    label: 'Architecture',
    title: 'アプリの設計',
    subtitle: '実際のアプリは、どう分ける？',
    mood: GradientMood.calm,
    accent: DeckColors.blue,
  ),
  InteractiveSlideWidget(
    route: '/a-layers',
    eyebrow: 'UI layer / Data layer',
    title: '4つの層に分ける',
    intensity: 0.4,
    steps: 4,
    footnote: '上の層は下の層だけを知っている。下の層は上を知らない。',
    builder: _layersDiagram,
  ),
  CodeSlideWidget(
    route: '/a-directories',
    eyebrow: 'Project structure',
    title: 'ディレクトリ構成',
    fileName: 'lib/',
    language: 'plaintext',
    fontSize: 22,
    points: const [
      'ui/ は画面ごと',
      'data/ は画面をまたいで共有',
      'domain/ はただのモデル',
      '1ファイル1責務',
    ],
    code: _directoryTree,
  ),
  CodeSlideWidget(
    route: '/a-model',
    eyebrow: '① Model',
    title: 'Model：ただのイミュータブルなクラス',
    fileName: 'domain/models/event.dart',
    fontSize: 17,
    points: const [
      'final だけ、変更は copyWith',
      'fromJson で「外の形」を閉じ込める',
      'パターンマッチで安全にパース',
      '実務では freezed + json_serializable も',
    ],
    code: _modelCode,
  ),
  CodeSlideWidget(
    route: '/a-api-client',
    eyebrow: '② ApiClient',
    title: 'ApiClient：HTTP と JSON だけ',
    fileName: 'data/api/api_client.dart',
    fontSize: 18,
    points: const ['Model もビジネスロジックも知らない', '失敗は型付きの例外に', 'Provider で注入する'],
    code: _apiClientCode,
  ),
  CodeSlideWidget(
    route: '/a-repository',
    eyebrow: '③ Repository',
    title: 'Repository：データの唯一の窓口',
    fileName: 'data/repositories/event_repository.dart',
    fontSize: 18,
    points: const [
      'interface で抽象化',
      'JSON → Model の変換はここ',
      'キャッシュやオフライン対応もここ',
      'テストでは Fake に差し替え',
    ],
    code: _repositoryCode,
  ),
  CodeSlideWidget(
    route: '/a-view-model',
    eyebrow: '④ ViewModel',
    title: 'ViewModel：画面の状態と操作',
    fileName: 'ui/events/events_view_model.dart',
    fontSize: 17,
    points: const [
      'build() が初回の読み込み',
      '状態は AsyncValue<List<Event>>',
      '楽観的更新：先に UI を変える',
      '失敗したら元に戻す',
    ],
    code: _viewModelCode,
  ),
  CodeSlideWidget(
    route: '/a-screen',
    eyebrow: '⑤ Screen',
    title: 'Screen：描くだけ、伝えるだけ',
    fileName: 'ui/events/events_screen.dart',
    fontSize: 16.5,
    points: const [
      'ref.watch で状態を購読',
      'switch で 3 状態を描き分け',
      '操作は ViewModel に渡すだけ',
      'ロジックを持たない',
    ],
    code: _screenCode,
  ),
  InteractiveSlideWidget(
    route: '/a-live',
    eyebrow: 'LIVE · Screen → ViewModel → Repository → ApiClient',
    title: '動かしてみる',
    intensity: 0.35,
    builder: _liveArchitecture,
  ),
  CodeSlideWidget(
    route: '/a-overrides',
    eyebrow: 'Testability',
    title: 'overrides で、層ごと差し替える',
    fileName: 'test/events_screen_test.dart',
    fontSize: 18,
    points: const ['Repository を Fake に', 'ネットワークなしで UI をテスト', '層を分けたご褒美'],
    code: _overridesCode,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Code listings
// ─────────────────────────────────────────────────────────────────────────────

const _directoryTree = '''
lib/
├── main.dart
├── domain/
│   └── models/
│       └── event.dart
├── data/
│   ├── api/
│   │   └── api_client.dart
│   └── repositories/
│       └── event_repository.dart
└── ui/
    └── events/
        ├── events_screen.dart
        ├── events_view_model.dart
        └── widgets/
            └── event_tile.dart
''';

const _modelCode = '''
@immutable
class Event {
  const Event({
    required this.id,
    required this.title,
    required this.startsAt,
    required this.venue,
    this.isFavorite = false,
  });

  final String id;
  final String title;
  final DateTime startsAt;
  final String venue;
  final bool isFavorite;

  factory Event.fromJson(Map<String, Object?> json) => switch (json) {
        {'id': String id, 'title': String title,
         'starts_at': String startsAt, 'venue': String venue} =>
          Event(id: id, title: title, venue: venue,
              startsAt: DateTime.parse(startsAt),
              isFavorite: json['is_favorite'] == true),
        _ => throw FormatException('Invalid event: \$json'),
      };

  Event copyWith({bool? isFavorite}) => Event(id: id, title: title,
      startsAt: startsAt, venue: venue, isFavorite: isFavorite ?? this.isFavorite);
}
''';

const _apiClientCode = '''
class ApiClient {
  ApiClient(this._baseUrl, [http.Client? client])
      : _client = client ?? http.Client();

  final Uri _baseUrl;
  final http.Client _client;

  Future<Object?> get(String path) async {
    final res = await _client.get(_baseUrl.resolve(path));
    return _decode(res);
  }

  Future<Object?> put(String path, Map<String, Object?> body) async {
    final res = await _client.put(_baseUrl.resolve(path), body: jsonEncode(body));
    return _decode(res);
  }

  Object? _decode(http.Response res) {
    if (res.statusCode >= 400) throw ApiException(res.statusCode, res.body);
    return res.body.isEmpty ? null : jsonDecode(res.body);
  }
}

final apiClientProvider = Provider(
  (ref) => ApiClient(Uri.parse('https://api.example.com/')),
);
''';

const _repositoryCode = '''
abstract interface class EventRepository {
  Future<List<Event>> fetchEvents();
  Future<void> setFavorite(String id, {required bool value});
}

class RemoteEventRepository implements EventRepository {
  RemoteEventRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<Event>> fetchEvents() async {
    final json = await _api.get('events') as List<Object?>;
    return [for (final e in json) Event.fromJson(e! as Map<String, Object?>)];
  }

  @override
  Future<void> setFavorite(String id, {required bool value}) =>
      _api.put('events/\$id/favorite', {'value': value});
}

final eventRepositoryProvider = Provider<EventRepository>(
  (ref) => RemoteEventRepository(ref.watch(apiClientProvider)),
);
''';

const _viewModelCode = '''
class EventsViewModel extends AsyncNotifier<List<Event>> {
  @override
  Future<List<Event>> build() =>
      ref.watch(eventRepositoryProvider).fetchEvents();

  Future<void> toggleFavorite(String id) async {
    final previous = state.value;
    if (previous == null) return;
    final target = previous.firstWhere((e) => e.id == id);

    // 楽観的更新：サーバーの返事を待たずに UI を変える
    state = AsyncData([
      for (final e in previous)
        e.id == id ? e.copyWith(isFavorite: !e.isFavorite) : e,
    ]);
    try {
      final repository = ref.read(eventRepositoryProvider);
      await repository.setFavorite(id, value: !target.isFavorite);
    } catch (_) {
      if (ref.mounted) state = AsyncData(previous); // 失敗したら戻す
    }
  }
}

final eventsViewModelProvider =
    AsyncNotifierProvider<EventsViewModel, List<Event>>(EventsViewModel.new);
''';

const _screenCode = '''
class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(eventsViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('イベント')),
      body: switch (events) {
        AsyncValue(:final value?) => RefreshIndicator(
            onRefresh: () => ref.refresh(eventsViewModelProvider.future),
            child: ListView(children: [
              for (final event in value)
                EventTile(
                  event: event,
                  onFavorite: () => ref.read(eventsViewModelProvider.notifier)
                      .toggleFavorite(event.id),
                ),
            ]),
          ),
        AsyncValue(:final error?) => ErrorView(error: error,
            onRetry: () => ref.invalidate(eventsViewModelProvider)),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
''';

const _overridesCode = '''
class FakeEventRepository implements EventRepository {
  @override
  Future<List<Event>> fetchEvents() async => [
        Event(id: '1', title: 'Flutter Tokyo #42',
            startsAt: DateTime(2026, 12, 3), venue: '渋谷'),
      ];

  @override
  Future<void> setFavorite(String id, {required bool value}) async {}
}

testWidgets('イベント一覧が表示される', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        eventRepositoryProvider.overrideWithValue(FakeEventRepository()),
      ],
      child: const MaterialApp(home: EventsScreen()),
    ),
  );
  await tester.pumpAndSettle();

  expect(find.text('Flutter Tokyo #42'), findsOneWidget);
});
''';

// ─────────────────────────────────────────────────────────────────────────────
// Layer diagram
// ─────────────────────────────────────────────────────────────────────────────

class _LayerInfo {
  const _LayerInfo(this.name, this.className, this.role, this.color);

  final String name;
  final String className;
  final String role;
  final Color color;
}

const _layerInfos = [
  _LayerInfo(
    'Screen',
    'EventsScreen',
    '状態を描く。操作を ViewModel に伝える',
    DeckColors.cyan,
  ),
  _LayerInfo(
    'ViewModel',
    'EventsViewModel',
    '画面の状態を持ち、操作をロジックにする',
    DeckColors.blue,
  ),
  _LayerInfo(
    'Repository',
    'EventRepository',
    'データの唯一の窓口。JSON → Model',
    DeckColors.purple,
  ),
  _LayerInfo('ApiClient', 'ApiClient', 'HTTP と JSON だけを知る', DeckColors.pink),
];

Widget _layersDiagram(BuildContext context, int step) => _LayersDiagram(step);

class _LayersDiagram extends StatelessWidget {
  const _LayersDiagram(this.step);

  final int step;

  @override
  Widget build(BuildContext context) {
    Widget group(String label, Color color) => Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Pill(label, color: color, fontSize: 17),
    );

    Widget layer(int i) => StaggerIn(
      visible: step > i,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: DeckCard(
          accent: _layerInfos[i].color,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Row(
            children: [
              SizedBox(
                width: 260,
                child: Text(
                  _layerInfos[i].name,
                  style: DeckText.heading.copyWith(color: _layerInfos[i].color),
                ),
              ),
              SizedBox(
                width: 300,
                child: Text(
                  _layerInfos[i].className,
                  style: DeckText.mono.copyWith(
                    fontSize: 22,
                    color: DeckColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  _layerInfos[i].role,
                  style: DeckText.body.copyWith(fontSize: 26),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              group('UI LAYER', DeckColors.cyan),
              layer(0),
              layer(1),
              group('DATA LAYER', DeckColors.purple),
              layer(2),
              layer(3),
              StaggerIn(
                visible: step >= 4,
                child: Row(
                  children: [
                    const Icon(
                      Icons.cloud_outlined,
                      color: DeckColors.textSecondary,
                      size: 34,
                    ),
                    const SizedBox(width: 14),
                    Text('API サーバー / DB', style: DeckText.bodySecondary),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),
        SizedBox(
          width: 250,
          child: Row(
            children: [
              Expanded(
                child: _FlowArrow(
                  label: '呼び出し',
                  color: DeckColors.cyan,
                  down: true,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _FlowArrow(
                  label: 'データ',
                  color: DeckColors.green,
                  down: false,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FlowArrow extends StatelessWidget {
  const _FlowArrow({
    required this.label,
    required this.color,
    required this.down,
  });

  final String label;
  final Color color;
  final bool down;

  @override
  Widget build(BuildContext context) {
    final arrow = Icon(
      down ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
      color: color,
      size: 48,
    );
    return Column(
      children: [
        if (!down) arrow,
        Expanded(
          child: Container(
            width: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: down
                    ? [color.withValues(alpha: 0.15), color]
                    : [color, color.withValues(alpha: 0.15)],
              ),
            ),
          ),
        ),
        if (down) arrow,
        const SizedBox(height: 10),
        Text(
          label,
          textAlign: TextAlign.center,
          style: DeckText.caption.copyWith(color: color),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 🎮 LIVE architecture
// ─────────────────────────────────────────────────────────────────────────────

Widget _liveArchitecture(BuildContext context, int step) =>
    const _LiveArchitecture();

class _LiveArchitecture extends StatefulWidget {
  const _LiveArchitecture();

  @override
  State<_LiveArchitecture> createState() => _LiveArchitectureState();
}

class _LiveArchitectureState extends State<_LiveArchitecture> {
  final _settings = NetworkSettings();
  final _trace = LayerTrace();

  @override
  void dispose() {
    _settings.dispose();
    _trace.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: PhoneFrame(
            width: 340,
            child: ScrollConfiguration(
              // Let the mouse drag the list too, so pull-to-refresh works
              // on stage.
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(dragDevices: PointerDeviceKind.values.toSet()),
              child: EventsDemoApp(settings: _settings, trace: _trace),
            ),
          ),
        ),
        const SizedBox(width: 48),
        Expanded(
          child: _LayerTraceView(trace: _trace, settings: _settings),
        ),
      ],
    );
  }
}

const _traceLayers = [
  (Layer.screen, 'Screen', 'UI'),
  (Layer.viewModel, 'ViewModel', 'UI'),
  (Layer.repository, 'Repository', 'Data'),
  (Layer.apiClient, 'ApiClient', 'Data'),
  (Layer.server, 'API サーバー', '外部'),
];

Color _flowColor(TraceFlow flow) => switch (flow) {
  TraceFlow.down => DeckColors.cyan,
  TraceFlow.up => DeckColors.green,
  TraceFlow.error => DeckColors.red,
};

/// Plays back what the layers reported, one hop at a time, so the audience
/// can follow a request down and the data back up.
class _LayerTraceView extends StatefulWidget {
  const _LayerTraceView({required this.trace, required this.settings});

  final LayerTrace trace;
  final NetworkSettings settings;

  @override
  State<_LayerTraceView> createState() => _LayerTraceViewState();
}

class _LayerTraceViewState extends State<_LayerTraceView> {
  late final Timer _timer;
  TraceEvent? _current;
  final _lastLabel = <Layer, TraceEvent>{};
  final _log = <TraceEvent>[];
  int _hop = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 380), (_) {
      final next = widget.trace.take();
      if (next == null) {
        if (_current != null) setState(() => _current = null);
        return;
      }
      setState(() {
        _current = next;
        _hop++;
        _lastLabel[next.layer] = next;
        _log.insert(0, next);
        if (_log.length > 9) _log.removeLast();
      });
    });
    widget.settings.addListener(_onSettings);
  }

  void _onSettings() => setState(() {});

  @override
  void dispose() {
    _timer.cancel();
    widget.settings.removeListener(_onSettings);
    super.dispose();
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
              for (final (i, (layer, name, group)) in _traceLayers.indexed) ...[
                if (i > 0)
                  _HopConnector(
                    active:
                        _current != null &&
                        {
                          layer,
                          _traceLayers[i - 1].$1,
                        }.contains(_current!.layer),
                    flow: _current?.flow,
                  ),
                Expanded(
                  child: _TraceRow(
                    name: name,
                    group: group,
                    active: _current?.layer == layer,
                    hop: _hop,
                    event: _lastLabel[layer],
                  ),
                ),
              ],
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _Toggle(
                      label: '遅いネットワーク',
                      icon: Icons.network_check_rounded,
                      value: widget.settings.slow,
                      color: DeckColors.orange,
                      onChanged: (v) => widget.settings.slow = v,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: _Toggle(
                      label: 'エラーを起こす',
                      icon: Icons.bolt_rounded,
                      value: widget.settings.fail,
                      color: DeckColors.red,
                      onChanged: (v) => widget.settings.fail = v,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          flex: 7,
          child: DeckCard(
            accent: DeckColors.textTertiary,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ログ', style: DeckText.caption),
                const SizedBox(height: 12),
                for (final (i, e) in _log.indexed)
                  Opacity(
                    opacity: (1 - i * 0.1).clamp(0.2, 1.0),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            switch (e.flow) {
                              TraceFlow.down => Icons.south_rounded,
                              TraceFlow.up => Icons.north_rounded,
                              TraceFlow.error => Icons.close_rounded,
                            },
                            size: 22,
                            color: _flowColor(e.flow),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${_traceLayers.firstWhere((l) => l.$1 == e.layer).$2}'
                              '  ${e.label}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: DeckText.monoSmall.copyWith(
                                fontSize: 17,
                                color: i == 0
                                    ? DeckColors.text
                                    : DeckColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const Spacer(),
                Text(
                  'ハートやリロードを押してみて',
                  style: DeckText.caption.copyWith(color: Colors.white38),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TraceRow extends StatelessWidget {
  const _TraceRow({
    required this.name,
    required this.group,
    required this.active,
    required this.hop,
    required this.event,
  });

  final String name;
  final String group;
  final bool active;
  final int hop;
  final TraceEvent? event;

  @override
  Widget build(BuildContext context) {
    final color = event == null
        ? DeckColors.textTertiary
        : _flowColor(event!.flow);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: active
            ? color.withValues(alpha: 0.22)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: active ? color : Colors.white.withValues(alpha: 0.12),
          width: active ? 2.5 : 1.5,
        ),
        boxShadow: [
          if (active)
            BoxShadow(color: color.withValues(alpha: 0.45), blurRadius: 30),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(group, style: DeckText.caption.copyWith(fontSize: 16)),
          ),
          SizedBox(
            width: 230,
            child: Text(
              name,
              style: DeckText.heading.copyWith(
                fontSize: 30,
                color: active ? DeckColors.text : DeckColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: AnimatedOpacity(
              opacity: event == null ? 0 : (active ? 1 : 0.45),
              duration: const Duration(milliseconds: 220),
              child: Text(
                event?.label ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: DeckText.monoSmall.copyWith(color: color, fontSize: 19),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HopConnector extends StatelessWidget {
  const _HopConnector({required this.active, required this.flow});

  final bool active;
  final TraceFlow? flow;

  @override
  Widget build(BuildContext context) {
    final color = active && flow != null
        ? _flowColor(flow!)
        : Colors.white.withValues(alpha: 0.18);
    return SizedBox(
      height: 22,
      child: Row(
        children: [
          const SizedBox(width: 120),
          Icon(
            Icons.south_rounded,
            size: 20,
            color: active && flow == TraceFlow.down ? color : Colors.white24,
          ),
          const SizedBox(width: 6),
          Icon(
            Icons.north_rounded,
            size: 20,
            color: active && flow != TraceFlow.down ? color : Colors.white24,
          ),
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.label,
    required this.icon,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final bool value;
  final Color color;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: value ? 0.2 : 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: value ? 0.9 : 0.3),
              width: value ? 2.5 : 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: DeckText.body.copyWith(fontSize: 24),
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
