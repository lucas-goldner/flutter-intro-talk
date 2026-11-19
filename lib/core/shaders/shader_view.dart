import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Loads and caches [ui.FragmentProgram]s by asset key.
///
/// Compiling a program is the expensive part, so every slide that uses the
/// same `.frag` shares one program and only creates its own
/// [ui.FragmentShader] (a cheap uniform buffer) from it.
abstract final class ShaderLibrary {
  static final _programs = <String, Future<ui.FragmentProgram>>{};

  static Future<ui.FragmentProgram> load(String asset) =>
      _programs.putIfAbsent(asset, () => ui.FragmentProgram.fromAsset(asset));

  /// Kicks off compilation of every shader up front so no slide flashes
  /// empty the first time it is shown.
  static Future<void> warmUp(Iterable<String> assets) =>
      Future.wait(assets.map(load));
}

/// Decodes and caches asset images as [ui.Image]s — the only thing a
/// `sampler2D` uniform accepts.
abstract final class DeckImages {
  static final _images = <String, Future<ui.Image>>{};

  static Future<ui.Image> load(String asset, {int? targetWidth}) =>
      _images.putIfAbsent('$asset@$targetWidth', () async {
        final data = await rootBundle.load(asset);
        final codec = await ui.instantiateImageCodec(
          data.buffer.asUint8List(),
          targetWidth: targetWidth,
        );
        final frame = await codec.getNextFrame();
        return frame.image;
      });
}

/// What a demo shader usually wants from Flutter each frame.
class ShaderFrame {
  const ShaderFrame({
    required this.size,
    required this.time,
    required this.pointer,
    required this.hover,
    required this.pressed,
  });

  /// Size of the painted area in logical pixels.
  final Size size;

  /// Seconds since the view was mounted.
  final double time;

  /// Smoothed pointer position in local coordinates. Rests at the centre
  /// until the pointer first enters.
  final Offset pointer;

  /// 0 → 1, eased: how "hovered" the view currently is.
  final double hover;

  /// Whether a pointer is pressed on the view right now.
  final bool pressed;
}

typedef ShaderUniformSetter = void Function(
  ui.FragmentShader shader,
  ShaderFrame frame,
);

/// Paints a full-rect fragment shader, ticking every frame and tracking the
/// pointer. The deck's live demos are all built on top of this.
///
/// [setUniforms] runs right before every paint — it is the "Flutter → GPU"
/// boundary that the talk is about.
class ShaderView extends StatefulWidget {
  const ShaderView({
    required this.asset,
    required this.setUniforms,
    super.key,
    this.child,
    this.animate = true,
    this.pointerSmoothing = 0.18,
    this.cursor = MouseCursor.defer,
    this.onPointerDown,
  });

  final String asset;
  final ShaderUniformSetter setUniforms;

  /// Painted above the shader.
  final Widget? child;

  /// When false the shader paints once per pointer event instead of every
  /// frame.
  final bool animate;

  /// 1 = pointer follows instantly, smaller values lag behind smoothly.
  final double pointerSmoothing;

  final MouseCursor cursor;
  final void Function(Offset localPosition)? onPointerDown;

  @override
  State<ShaderView> createState() => _ShaderViewState();
}

class _ShaderViewState extends State<ShaderView>
    with SingleTickerProviderStateMixin {
  ui.FragmentShader? _shader;
  late final Ticker _ticker = createTicker(_onTick);
  final _repaint = ValueNotifier<int>(0);

  Duration _elapsed = Duration.zero;
  Duration _lastTick = Duration.zero;
  Size _size = Size.zero;
  Offset? _target;
  Offset? _pointer;
  bool _inside = false;
  bool _pressed = false;
  double _hover = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
    _ticker.start();
  }

  Future<void> _load() async {
    final program = await ShaderLibrary.load(widget.asset);
    if (!mounted) return;
    setState(() => _shader = program.fragmentShader());
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    _elapsed = elapsed;

    // Frame-rate independent exponential smoothing.
    final k = 1 - math.pow(1 - widget.pointerSmoothing, dt * 60).toDouble();
    if (_target case final target?) {
      _pointer = _pointer == null ? target : Offset.lerp(_pointer, target, k);
    }
    final hoverK = 1 - math.pow(1 - 0.12, dt * 60).toDouble();
    _hover += ((_inside ? 1.0 : 0.0) - _hover) * hoverK;

    if (widget.animate || _hover > 0.001 && _hover < 0.999) {
      _repaint.value++;
    }
  }

  void _setPointer(Offset local) {
    _target = local;
    if (!widget.animate) _repaint.value++;
  }

  @override
  void dispose() {
    _ticker.dispose();
    _shader?.dispose();
    _repaint.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shader = _shader;
    return MouseRegion(
      cursor: widget.cursor,
      onEnter: (e) {
        _inside = true;
        _setPointer(e.localPosition);
      },
      onExit: (_) => _inside = false,
      onHover: (e) => _setPointer(e.localPosition),
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (e) {
          _pressed = true;
          _inside = true;
          _setPointer(e.localPosition);
          widget.onPointerDown?.call(e.localPosition);
        },
        onPointerMove: (e) => _setPointer(e.localPosition),
        onPointerUp: (_) => _pressed = false,
        onPointerCancel: (_) => _pressed = false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            _size = constraints.biggest;
            return CustomPaint(
              size: _size,
              painter: shader == null
                  ? null
                  : _ShaderPainter(
                      shader: shader,
                      repaint: _repaint,
                      frame: () => ShaderFrame(
                        size: _size,
                        time: _elapsed.inMicroseconds / 1e6,
                        pointer: _pointer ?? _size.center(Offset.zero),
                        hover: _hover,
                        pressed: _pressed,
                      ),
                      setUniforms: widget.setUniforms,
                    ),
              child: widget.child,
            );
          },
        ),
      ),
    );
  }
}

class _ShaderPainter extends CustomPainter {
  _ShaderPainter({
    required this.shader,
    required this.frame,
    required this.setUniforms,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final ui.FragmentShader shader;
  final ShaderFrame Function() frame;
  final ShaderUniformSetter setUniforms;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    setUniforms(shader, frame());
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(_ShaderPainter oldDelegate) =>
      oldDelegate.shader != shader || oldDelegate.setUniforms != setUniforms;
}

/// Waits for an asset image, then builds with it.
class DeckImageBuilder extends StatelessWidget {
  const DeckImageBuilder({
    required this.asset,
    required this.builder,
    super.key,
    this.targetWidth = 1024,
  });

  final String asset;
  final int targetWidth;
  final Widget Function(BuildContext context, ui.Image image) builder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.Image>(
      future: DeckImages.load(asset, targetWidth: targetWidth),
      builder: (context, snapshot) => switch (snapshot.data) {
        final image? => builder(context, image),
        null => const SizedBox.expand(),
      },
    );
  }
}
