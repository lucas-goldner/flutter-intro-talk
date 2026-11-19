import 'package:flutter_intro_talk/demo_app/api_client.dart';
import 'package:flutter_intro_talk/demo_app/event.dart';
import 'package:flutter_intro_talk/demo_app/layer_trace.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Repository — the single source of truth for events. Turns JSON into
/// [Event] models; the UI never sees JSON.
abstract interface class EventRepository {
  Future<List<Event>> fetchEvents();
  Future<void> setFavorite(String id, {required bool value});
}

class RemoteEventRepository implements EventRepository {
  RemoteEventRepository(this._api, this._trace);

  final ApiClient _api;
  final LayerTrace _trace;

  @override
  Future<List<Event>> fetchEvents() async {
    _trace.add(Layer.repository, TraceFlow.down, 'fetchEvents()');
    try {
      final json = await _api.get('events') as List<Object?>;
      final events = [
        for (final item in json) Event.fromJson(item! as Map<String, Object?>),
      ];
      _trace.add(Layer.repository, TraceFlow.up, 'JSON → List<Event>');
      return events;
    } on ApiException {
      _trace.add(Layer.repository, TraceFlow.error, 'rethrow');
      rethrow;
    }
  }

  @override
  Future<void> setFavorite(String id, {required bool value}) async {
    _trace.add(Layer.repository, TraceFlow.down, 'setFavorite($id)');
    try {
      await _api.put('events/$id/favorite', {'value': value});
      _trace.add(Layer.repository, TraceFlow.up, '保存しました');
    } on ApiException {
      _trace.add(Layer.repository, TraceFlow.error, 'rethrow');
      rethrow;
    }
  }
}

final eventRepositoryProvider = Provider<EventRepository>(
  (ref) => RemoteEventRepository(
    ref.watch(apiClientProvider),
    ref.watch(layerTraceProvider),
  ),
);
