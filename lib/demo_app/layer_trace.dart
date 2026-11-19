import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The layers of the sample app, top to bottom.
enum Layer { screen, viewModel, repository, apiClient, server }

/// Which way a signal travels: a request going down, data coming back up,
/// or an error bubbling up.
enum TraceFlow { down, up, error }

class TraceEvent {
  const TraceEvent(this.layer, this.flow, this.label);

  final Layer layer;
  final TraceFlow flow;
  final String label;
}

/// Demo-only instrumentation: every layer reports what it is doing here so
/// the slide can animate the request travelling through the architecture.
/// The visualiser drains [pending] at its own pace, so the real app never
/// waits for the animation.
class LayerTrace extends ChangeNotifier {
  final pending = <TraceEvent>[];

  void add(Layer layer, TraceFlow flow, String label) {
    pending.add(TraceEvent(layer, flow, label));
    notifyListeners();
  }

  TraceEvent? take() => pending.isEmpty ? null : pending.removeAt(0);
}

/// Overridden by the slide with the instance it visualises.
final layerTraceProvider = Provider<LayerTrace>((ref) => LayerTrace());
