import 'package:flutter/material.dart';
import 'package:flutter_intro_talk/core/theme/kaigi_theme.dart';
import 'package:flutter_intro_talk/demo_app/api_client.dart';
import 'package:flutter_intro_talk/demo_app/events_screen.dart';
import 'package:flutter_intro_talk/demo_app/layer_trace.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The whole sample app, wired up with its own [ProviderScope]. The slide
/// owns [settings] and [trace] so it can flip the network switches and
/// animate the layers.
class EventsDemoApp extends StatefulWidget {
  const EventsDemoApp({required this.settings, required this.trace, super.key});

  final NetworkSettings settings;
  final LayerTrace trace;

  @override
  State<EventsDemoApp> createState() => _EventsDemoAppState();
}

final _theme = () {
  final base = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: const Color(0xFF02569B),
    brightness: Brightness.light,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(fontFamilyFallback: kFontFallback),
  );
}();

class _EventsDemoAppState extends State<EventsDemoApp> {
  late final _api = FakeApiClient(widget.settings, widget.trace);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      // Show errors right away instead of Riverpod's automatic retry.
      retry: (retryCount, error) => null,
      overrides: [
        layerTraceProvider.overrideWithValue(widget.trace),
        apiClientProvider.overrideWithValue(_api),
      ],
      child: Theme(data: _theme, child: const EventsScreen()),
    );
  }
}
