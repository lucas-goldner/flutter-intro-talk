import 'package:flutter_intro_talk/demo_app/event.dart';
import 'package:flutter_intro_talk/demo_app/event_repository.dart';
import 'package:flutter_intro_talk/demo_app/layer_trace.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ViewModel — holds the screen's state as an [AsyncValue] and exposes the
/// actions the screen can trigger.
class EventsViewModel extends AsyncNotifier<List<Event>> {
  LayerTrace get _trace => ref.read(layerTraceProvider);

  @override
  Future<List<Event>> build() async {
    _trace
      ..add(Layer.screen, TraceFlow.down, 'ref.watch(eventsViewModelProvider)')
      ..add(Layer.viewModel, TraceFlow.down, 'build()');
    try {
      final events = await ref.watch(eventRepositoryProvider).fetchEvents();
      _trace
        ..add(Layer.viewModel, TraceFlow.up, 'AsyncData(${events.length}件)')
        ..add(Layer.screen, TraceFlow.up, 'rebuild → リスト表示');
      return events;
    } catch (_) {
      _trace
        ..add(Layer.viewModel, TraceFlow.error, 'AsyncError')
        ..add(Layer.screen, TraceFlow.error, 'rebuild → エラー表示');
      rethrow;
    }
  }

  Future<void> toggleFavorite(String id) async {
    final previous = state.value;
    if (previous == null) return;
    final target = previous.firstWhere((e) => e.id == id);

    _trace
      ..add(Layer.screen, TraceFlow.down, 'onFavorite')
      ..add(Layer.viewModel, TraceFlow.down, 'toggleFavorite() 楽観的更新');
    // Optimistic update: the UI changes before the server answers.
    state = AsyncData([
      for (final e in previous)
        e.id == id ? e.copyWith(isFavorite: !e.isFavorite) : e,
    ]);
    try {
      await ref
          .read(eventRepositoryProvider)
          .setFavorite(id, value: !target.isFavorite);
      _trace.add(Layer.viewModel, TraceFlow.up, '確定');
    } catch (_) {
      // Roll back if the server said no.
      if (ref.mounted) state = AsyncData(previous);
      _trace
        ..add(Layer.viewModel, TraceFlow.error, 'ロールバック')
        ..add(Layer.screen, TraceFlow.error, 'rebuild → 元に戻る');
    }
  }
}

final eventsViewModelProvider =
    AsyncNotifierProvider<EventsViewModel, List<Event>>(EventsViewModel.new);
