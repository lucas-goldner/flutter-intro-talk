import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';
import 'package:flutter_intro_talk/core/shaders/shader_assets.dart';
import 'package:flutter_intro_talk/core/shaders/shader_view.dart';
import 'package:flutter_intro_talk/core/theme/kaigi_theme.dart';
import 'package:flutter_intro_talk/core/widgets/code_panel.dart';
import 'package:flutter_intro_talk/core/widgets/deck_components.dart';
import 'package:flutter_intro_talk/core/widgets/demo_frame.dart';
import 'package:flutter_intro_talk/core/widgets/templates.dart';
import 'package:flutter_intro_talk/core/widgets/wwdc_background.dart';

/// Section: 全ピクセルを描けるなら、何でも描ける.
final List<FlutterDeckSlideWidget> beyondSlides = [
  StatementSlideWidget(
    route: '/x-anything',
    eyebrow: 'Beyond widgets',
    statement: '全ピクセルを描けるなら、\n何でも描ける。',
    subtitle: '3D も、シェーダーも、アニメーションも。',
    mood: GradientMood.hero,
  ),
  InteractiveSlideWidget(
    route: '/x-scene',
    eyebrow: 'Demo · 3D',
    title: 'Flutter の中で、3D シーン',
    footnote: 'メッシュも 3D エンジンもなし。1 本のフラグメントシェーダーでレイマーチングしている。',
    mood: GradientMood.calm,
    intensity: 0.35,
    builder: _sceneBody,
  ),
  CodeSlideWidget(
    route: '/x-flutter-scene',
    eyebrow: 'Flutter GPU',
    title: '本物の 3D モデルなら flutter_scene',
    fileName: 'dash_scene.dart',
    fontSize: 16,
    points: const [
      'Flutter GPU：Dart から GPU を直接扱う低レベル API',
      'flutter_scene：その上の 3D レンダラー（glTF を読み込む）',
      'まだ実験的・Impeller が必須',
    ],
    footnote: 'コードはイメージです。API は実験段階のため変わる可能性があります。',
    code: _flutterSceneCode,
  ),
  InteractiveSlideWidget(
    route: '/x-portal',
    eyebrow: 'Demo · Fragment shader',
    title: 'ワープポータル',
    footnote: 'スライダーの値は、毎フレーム uniform としてシェーダーに渡しているだけ。',
    mood: GradientMood.violet,
    intensity: 0.35,
    builder: _portalBody,
  ),
  InteractiveSlideWidget(
    route: '/x-shader-howto',
    eyebrow: 'How to',
    title: 'フラグメントシェーダーの使い方',
    footnote: '.frag を書いて pubspec に登録 → FragmentProgram で読み込んで Paint に渡す。それだけ。',
    mood: GradientMood.calm,
    intensity: 0.4,
    builder: _howToBody,
  ),
  InteractiveSlideWidget(
    route: '/x-shader-ui',
    eyebrow: 'Demo · UI',
    title: 'シェーダーは、UI にも使える',
    footnote: 'ボタンも背景も、普通の Widget の中にシェーダーを敷いているだけ。',
    mood: GradientMood.violet,
    intensity: 0.4,
    builder: _shaderUiBody,
  ),
  InteractiveSlideWidget(
    route: '/x-animations',
    eyebrow: 'Implicit animations',
    title: 'アニメーションも、Widget を変えるだけ',
    footnote:
        '値を変えて setState するだけで、Flutter が間を補間してくれる。'
        '（ちなみに自己紹介スライドは Rive）',
    mood: GradientMood.cool,
    intensity: 0.4,
    builder: _animBody,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// 3D scene — drag to orbit, button to explode the logo.
// ─────────────────────────────────────────────────────────────────────────────
Widget _sceneBody(BuildContext context, int step) => const _SceneDemo();

class _SceneDemo extends StatefulWidget {
  const _SceneDemo();

  @override
  State<_SceneDemo> createState() => _SceneDemoState();
}

class _SceneDemoState extends State<_SceneDemo> {
  double _yaw = 0.5;
  double _pitch = 0.32;
  double _yawVel = 0.0025;
  bool _explode = false;
  double _explodeShown = 0;
  double _lastTime = 0;

  void _setUniforms(ui.FragmentShader shader, ShaderFrame frame) {
    final dt = (frame.time - _lastTime).clamp(0.0, 0.1);
    _lastTime = frame.time;
    // Gentle auto-orbit, decaying fling after a drag.
    _yaw += _yawVel;
    _yawVel += (0.0025 - _yawVel) * math.min(1, dt * 2);
    _explodeShown +=
        ((_explode ? 1.0 : 0.0) - _explodeShown) * math.min(1, dt * 4);

    shader
      ..getUniformVec2('uSize').set(frame.size.width, frame.size.height)
      ..getUniformFloat('uTime').set(frame.time)
      ..getUniformFloat('uYaw').set(_yaw)
      ..getUniformFloat('uPitch').set(_pitch)
      ..getUniformFloat('uExplode').set(_explodeShown);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: DemoFrame(
            accent: DeckColors.dart,
            hint: 'ドラッグで回転',
            child: GestureDetector(
              onPanUpdate: (d) {
                _yaw -= d.delta.dx * 0.008;
                _pitch = (_pitch + d.delta.dy * 0.006).clamp(-0.1, 1.15);
                _yawVel = 0;
              },
              onPanEnd: (d) =>
                  _yawVel = -d.velocity.pixelsPerSecond.dx * 0.00012,
              child: ShaderView(
                asset: ShaderAssets.scene3d,
                cursor: SystemMouseCursors.grab,
                setUniforms: _setUniforms,
              ),
            ),
          ),
        ),
        const SizedBox(width: 44),
        SizedBox(
          width: 420,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TitledCard(
                badge: 'RAYMARCHING',
                title: '光線を飛ばして形を探す',
                accent: DeckColors.dart,
                lines: ['1 ピクセルごとに光線を進め、', '距離関数（SDF）で物体に当たる場所を探す'],
              ),
              const SizedBox(height: 22),
              const TitledCard(
                badge: 'INSIDE',
                title: '影・反射・霧も計算',
                accent: DeckColors.purple,
                lines: ['ソフトシャドウ、床の反射、', 'フレネル……全部 GLSL'],
              ),
              const Spacer(),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => setState(() => _explode = !_explode),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 22),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: _explode ? null : DeckGradients.flutter,
                      color: _explode ? Colors.white10 : null,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: DeckColors.dart, width: 2),
                    ),
                    child: Text(
                      _explode ? '元に戻す' : 'ロゴを分解する',
                      style: DeckText.heading.copyWith(fontSize: 28, height: 1),
                    ),
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

const _flutterSceneCode = r'''
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

final scene = Scene();

Future<void> loadDash() async {
  // glTF はビルド時に .model へ変換される
  final dash = await Node.fromAsset('build/models/dash.model');
  scene.add(dash);
}

class ScenePainter extends CustomPainter {
  ScenePainter(this.angle);
  final double angle;

  @override
  void paint(Canvas canvas, Size size) {
    final camera = PerspectiveCamera(
      position: Vector3(sin(angle) * 5, 2, cos(angle) * 5),
      target: Vector3(0, 1, 0),
    );
    scene.render(camera, canvas, viewport: Offset.zero & size);
  }
  // shouldRepaint は省略
}
''';

// ─────────────────────────────────────────────────────────────────────────────
// Warp portal — sliders drive uniforms; the pointer moves the centre;
// press for a warp jump.
// ─────────────────────────────────────────────────────────────────────────────
Widget _portalBody(BuildContext context, int step) => const _PortalDemo();

class _PortalDemo extends StatefulWidget {
  const _PortalDemo();

  @override
  State<_PortalDemo> createState() => _PortalDemoState();
}

class _PortalDemoState extends State<_PortalDemo> {
  double _speed = 0.5;
  double _twist = 1.0;
  double _hue = 0.0;
  double _warp = 0;
  double _lastTime = 0;

  void _setUniforms(ui.FragmentShader shader, ShaderFrame frame) {
    final dt = (frame.time - _lastTime).clamp(0.0, 0.1);
    _lastTime = frame.time;
    _warp += ((frame.pressed ? 1.0 : 0.0) - _warp) * math.min(1, dt * 3);
    shader
      ..getUniformVec2('uSize').set(frame.size.width, frame.size.height)
      ..getUniformFloat('uTime').set(frame.time)
      ..getUniformVec2('uMouse').set(frame.pointer.dx, frame.pointer.dy)
      ..getUniformFloat('uSpeed').set(_speed)
      ..getUniformFloat('uTwist').set(_twist)
      ..getUniformFloat('uHue').set(_hue)
      ..getUniformFloat('uWarp').set(_warp);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: DemoFrame(
            accent: DeckColors.purple,
            hint: 'マウスで中心が動く・押しっぱなしでワープ',
            child: ShaderView(
              asset: ShaderAssets.warpPortal,
              pointerSmoothing: 0.08,
              cursor: SystemMouseCursors.precise,
              setUniforms: _setUniforms,
            ),
          ),
        ),
        const SizedBox(width: 44),
        SizedBox(
          width: 420,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _UniformSlider(
                name: 'uSpeed',
                label: '速度',
                value: _speed,
                max: 2,
                color: DeckColors.cyan,
                onChanged: (v) => setState(() => _speed = v),
              ),
              _UniformSlider(
                name: 'uTwist',
                label: 'ねじれ',
                value: _twist,
                min: -4,
                max: 4,
                color: DeckColors.pink,
                onChanged: (v) => setState(() => _twist = v),
              ),
              _UniformSlider(
                name: 'uHue',
                label: '色相',
                value: _hue,
                color: DeckColors.orange,
                onChanged: (v) => setState(() => _hue = v),
              ),
              const Spacer(),
              CodePanel(
                'shader\n'
                "  ..setFloat('uSpeed', ${_speed.toStringAsFixed(2)})\n"
                "  ..setFloat('uTwist', ${_twist.toStringAsFixed(2)})\n"
                "  ..setFloat('uHue', ${_hue.toStringAsFixed(2)});",
                language: 'dart',
                accent: DeckColors.dart,
                fontSize: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UniformSlider extends StatelessWidget {
  const _UniformSlider({
    required this.name,
    required this.label,
    required this.value,
    required this.color,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
  });

  final String name;
  final String label;
  final double value;
  final double min;
  final double max;
  final Color color;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: DeckText.heading.copyWith(fontSize: 26)),
              const SizedBox(width: 12),
              Text(name, style: DeckText.monoSmall.copyWith(color: color)),
              const Spacer(),
              Text(
                value.toStringAsFixed(2),
                style: DeckText.mono.copyWith(color: color, fontSize: 22),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.2),
              thumbColor: Colors.white,
              overlayColor: color.withValues(alpha: 0.15),
              trackHeight: 6,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// How to use a fragment shader — the three snippets and the live result.
// ─────────────────────────────────────────────────────────────────────────────
Widget _howToBody(BuildContext context, int step) => CodeDemoLayout(
  codeFlex: 12,
  demoFlex: 8,
  snippets: const [
    CodeSnippet(
      _glslSnippet,
      fileName: 'shaders/hello.frag',
      fontSize: 15,
      flex: 10,
    ),
    CodeSnippet(
      _dartSnippet,
      fileName: 'hello_painter.dart',
      language: 'dart',
      fontSize: 15,
      flex: 12,
    ),
  ],
  demo: DemoFrame(
    accent: DeckColors.glsl,
    hint: 'マウスを動かしてみて',
    child: ShaderView(
      asset: ShaderAssets.helloGradient,
      setUniforms: (shader, frame) => shader
        ..getUniformVec2('uSize').set(frame.size.width, frame.size.height)
        ..getUniformFloat('uTime').set(frame.time)
        ..getUniformVec2('uMouse').set(frame.pointer.dx, frame.pointer.dy),
    ),
  ),
);

const _glslSnippet = '''
uniform vec2 uSize;   // Flutter から: 描画サイズ
uniform float uTime;  // Flutter から: 経過秒
uniform vec2 uMouse;  // Flutter から: ポインター位置
out vec4 fragColor;

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  vec3 color = 0.5 + 0.5 * cos(uTime + uv.xyx * 3.0 + vec3(0, 2, 4));
  float d = distance(FlutterFragCoord().xy, uMouse);
  color += smoothstep(120.0, 0.0, d) * 0.6;
  fragColor = vec4(color, 1.0);
}
''';

const _dartSnippet = '''
// pubspec.yaml → flutter: shaders: [shaders/hello.frag]
final program = await FragmentProgram.fromAsset('shaders/hello.frag');
final shader = program.fragmentShader();

// CustomPainter.paint() の中で、毎フレーム
shader
  ..setFloat(0, size.width)   // uSize
  ..setFloat(1, size.height)
  ..setFloat(2, time)         // uTime
  ..setFloat(3, mouse.dx)     // uMouse
  ..setFloat(4, mouse.dy);
canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
''';

// ─────────────────────────────────────────────────────────────────────────────
// Shader UI gallery — chaos button, galaxy button, music player background.
// ─────────────────────────────────────────────────────────────────────────────
Widget _shaderUiBody(BuildContext context, int step) => Row(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    Expanded(
      flex: 6,
      child: Column(
        children: [
          Expanded(
            child: DemoFrame(
              accent: DeckColors.blue,
              hint: 'ホバーしてみて',
              caption: 'chaos button',
              child: _ShaderButton(
                asset: ShaderAssets.chaosButton,
                label: 'chaos button',
                size: Size(420, 112),
                mono: true,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: DemoFrame(
              accent: DeckColors.purple,
              hint: 'ホバーしてみて',
              caption: 'Galaxy button ── カーソルの周りで銀河が回る',
              child: _ShaderButton(
                asset: ShaderAssets.galaxyButton,
                label: 'Galaxy button!',
                size: Size(440, 124),
              ),
            ),
          ),
        ],
      ),
    ),
    const SizedBox(width: 40),
    const Expanded(flex: 4, child: _MusicPlayer()),
  ],
);

class _ShaderButton extends StatelessWidget {
  const _ShaderButton({
    required this.asset,
    required this.label,
    required this.size,
    this.mono = false,
  });

  final String asset;
  final String label;
  final Size size;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.fromSize(
        size: size,
        child: ShaderView(
          asset: asset,
          cursor: SystemMouseCursors.click,
          pointerSmoothing: 0.25,
          setUniforms: (shader, frame) => shader
            ..getUniformVec2('uSize').set(frame.size.width, frame.size.height)
            ..getUniformFloat('uTime').set(frame.time)
            ..getUniformFloat('uHover').set(frame.hover)
            ..getUniformVec2('uMouse').set(frame.pointer.dx, frame.pointer.dy),
          child: Center(
            child: IgnorePointer(
              child: Text(
                label,
                style: (mono ? DeckText.mono : DeckText.heading).copyWith(
                  fontSize: mono ? 28 : 34,
                  color: Colors.white,
                  letterSpacing: mono ? 1.5 : 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Album {
  const _Album(this.title, this.artist, this.colors);
  final String title;
  final String artist;
  final List<Color> colors;
}

class _MusicPlayer extends StatefulWidget {
  const _MusicPlayer();

  @override
  State<_MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<_MusicPlayer> {
  static const _albums = [
    _Album('NEON', 'Shibuya Nights', [
      Color(0xFFFF375F),
      Color(0xFFBF5AF2),
      Color(0xFF14002B),
      Color(0xFFFF9F0A),
    ]),
    _Album('OCEAN', 'Blue Hour', [
      Color(0xFF0A84FF),
      Color(0xFF64D2FF),
      Color(0xFF031B3A),
      Color(0xFF5E5CE6),
    ]),
    _Album('DESERT', 'Dune Orchestra', [
      Color(0xFFFF8A00),
      Color(0xFFD9480F),
      Color(0xFF2B0F05),
      Color(0xFFFFC46B),
    ]),
    _Album('FOREST', 'Moss & Rain', [
      Color(0xFF30D158),
      Color(0xFF0B3D2E),
      Color(0xFFA8E063),
      Color(0xFF1E6F5C),
    ]),
  ];

  int _selected = 0;
  late final List<Color> _shown = [..._albums[0].colors];

  void _setUniforms(ui.FragmentShader shader, ShaderFrame frame) {
    final target = _albums[_selected].colors;
    for (var i = 0; i < 4; i++) {
      _shown[i] = Color.lerp(_shown[i], target[i], 0.05)!;
    }
    final beatPhase = (frame.time * 96 / 60) % 1.0;
    final beat = math.exp(-beatPhase * 7);
    final colors = shader.getUniformVec3Array('uColors');
    for (var i = 0; i < 4; i++) {
      colors[i].set(_shown[i].r, _shown[i].g, _shown[i].b);
    }
    shader
      ..getUniformVec2('uSize').set(frame.size.width, frame.size.height)
      ..getUniformFloat('uTime').set(frame.time)
      ..getUniformFloat('uBeat').set(beat);
  }

  @override
  Widget build(BuildContext context) {
    final album = _albums[_selected];
    return DemoFrame(
      accent: album.colors.first,
      radius: 40,
      hint: 'タップで次のアルバム',
      caption: '音楽アプリ ── ジャケットの色が背景に溶ける',
      child: GestureDetector(
        onTap: () =>
            setState(() => _selected = (_selected + 1) % _albums.length),
        child: ShaderView(
          asset: ShaderAssets.musicBackground,
          cursor: SystemMouseCursors.click,
          setUniforms: _setUniforms,
          child: IgnorePointer(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(36, 70, 36, 70),
              child: Column(
                children: [
                  const Spacer(),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [album.colors[0], album.colors[1]],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 40,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      album.title,
                      style: DeckText.heading.copyWith(
                        fontSize: 34,
                        letterSpacing: 4,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    album.title,
                    style: DeckText.heading.copyWith(fontSize: 30),
                  ),
                  Text(
                    album.artist,
                    style: DeckText.body.copyWith(
                      fontSize: 22,
                      color: Colors.white70,
                    ),
                  ),
                  const Spacer(),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(Icons.skip_previous_rounded, size: 44),
                      Icon(Icons.pause_circle_filled_rounded, size: 76),
                      Icon(Icons.skip_next_rounded, size: 44),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Implicit animations playground.
// ─────────────────────────────────────────────────────────────────────────────
Widget _animBody(BuildContext context, int step) => const _AnimPlayground();

class _AnimPlayground extends StatefulWidget {
  const _AnimPlayground();

  @override
  State<_AnimPlayground> createState() => _AnimPlaygroundState();
}

class _AnimPlaygroundState extends State<_AnimPlayground> {
  static const _curves = <(String, Curve)>[
    ('linear', Curves.linear),
    ('easeInOut', Curves.easeInOut),
    ('easeOutBack', Curves.easeOutBack),
    ('elasticOut', Curves.elasticOut),
    ('bounceOut', Curves.bounceOut),
  ];
  static const _durations = [300, 800, 1500];

  int _curve = 3;
  int _ms = 800;
  bool _toggled = false;

  @override
  Widget build(BuildContext context) {
    final curve = _curves[_curve];
    final width = _toggled ? 320.0 : 160.0;
    final radius = _toggled ? 160.0 : 24.0;
    final color = _toggled ? 'DeckColors.pink' : 'DeckColors.blue';
    final align = _toggled ? 'Alignment.centerRight' : 'Alignment.centerLeft';
    final code =
        '''
AnimatedAlign(
  alignment: $align,
  duration: Duration(milliseconds: $_ms),
  curve: Curves.${curve.$1},
  child: AnimatedContainer(
    duration: Duration(milliseconds: $_ms),
    curve: Curves.${curve.$1},
    width: ${width.toInt()},
    height: ${width.toInt()},
    decoration: BoxDecoration(
      color: $color,
      borderRadius: BorderRadius.circular(${radius.toInt()}),
    ),
  ),
)''';

    return SplitContent(
      leftFlex: 9,
      rightFlex: 11,
      left: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('curve', style: DeckText.caption),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var i = 0; i < _curves.length; i++)
                _Chip(
                  label: _curves[i].$1,
                  selected: i == _curve,
                  onTap: () => setState(() => _curve = i),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text('duration', style: DeckText.caption),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: [
              for (final d in _durations)
                _Chip(
                  label: '${d}ms',
                  selected: d == _ms,
                  onTap: () => setState(() => _ms = d),
                ),
            ],
          ),
          const SizedBox(height: 22),
          Expanded(
            child: CodePanel(
              code,
              language: 'dart',
              fileName: 'animated.dart',
              accent: DeckColors.dart,
              fontSize: 18,
            ),
          ),
        ],
      ),
      right: DemoFrame(
        accent: DeckColors.cyan,
        hint: 'クリックでアニメーション',
        child: GestureDetector(
          onTap: () => setState(() => _toggled = !_toggled),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: ColoredBox(
              color: const Color(0xFF0E0E16),
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: AnimatedAlign(
                  alignment: _toggled
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  duration: Duration(milliseconds: _ms),
                  curve: curve.$2,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: _ms),
                    curve: curve.$2,
                    width: width,
                    height: width,
                    decoration: BoxDecoration(
                      color: _toggled ? DeckColors.pink : DeckColors.blue,
                      borderRadius: BorderRadius.circular(radius),
                      boxShadow: [
                        BoxShadow(
                          color: (_toggled ? DeckColors.pink : DeckColors.blue)
                              .withValues(alpha: 0.5),
                          blurRadius: 50,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Pill(
          label,
          color: selected ? DeckColors.cyan : DeckColors.textTertiary,
          filled: selected,
          fontSize: 20,
          mono: true,
        ),
      ),
    );
  }
}
