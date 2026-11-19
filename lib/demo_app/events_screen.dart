import 'package:flutter/material.dart';
import 'package:flutter_intro_talk/demo_app/event.dart';
import 'package:flutter_intro_talk/demo_app/events_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Screen — only draws the state and forwards user actions.
class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(eventsViewModelProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('イベント'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(eventsViewModelProvider),
          ),
        ],
      ),
      body: switch (events) {
        AsyncValue(:final value?) => RefreshIndicator(
          onRefresh: () => ref.refresh(eventsViewModelProvider.future),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              if (events.isLoading) const LinearProgressIndicator(),
              for (final event in value)
                EventTile(
                  event: event,
                  onFavorite: () => ref
                      .read(eventsViewModelProvider.notifier)
                      .toggleFavorite(event.id),
                ),
            ],
          ),
        ),
        AsyncValue(:final error?) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(eventsViewModelProvider),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class EventTile extends StatelessWidget {
  const EventTile({required this.event, required this.onFavorite, super.key});

  final Event event;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final d = event.startsAt;
    final date =
        '${d.month}/${d.day} '
        '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFE3F2FD),
        child: Text(
          '${d.day}',
          style: const TextStyle(
            color: Color(0xFF02569B),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      title: Text(event.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('$date ・ ${event.venue}'),
      trailing: IconButton(
        icon: Icon(
          event.isFavorite ? Icons.favorite : Icons.favorite_border,
          color: event.isFavorite ? const Color(0xFFFF375F) : null,
        ),
        onPressed: onFavorite,
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({required this.error, required this.onRetry, super.key});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Color(0xFFFF453A)),
            const SizedBox(height: 12),
            const Text('読み込みに失敗しました'),
            const SizedBox(height: 4),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('再試行')),
          ],
        ),
      ),
    );
  }
}
