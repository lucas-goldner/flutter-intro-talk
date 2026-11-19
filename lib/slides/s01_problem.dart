import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';
import 'package:flutter_intro_talk/core/shaders/shader_assets.dart';
import 'package:flutter_intro_talk/core/shaders/shader_view.dart';
import 'package:flutter_intro_talk/core/widgets/templates.dart';

final List<FlutterDeckSlideWidget> titleAndProblemSlides = [
  StatementSlideWidget(route: '/t1', statement: 'テスト'),
  CodeSlideWidget(
    route: '/t2',
    title: 'コード',
    code: 'void main() {}',
    fileName: 'main.dart',
    points: const ['a', 'b'],
  ),
  QuizSlideWidget(
    route: '/t3',
    question: '質問？',
    options: const ['はい', 'いいえ'],
    answer: 1,
    explanation: '説明',
  ),
  InteractiveSlideWidget(route: '/t4', title: 'shader', builder: _b),
];
Widget _b(BuildContext c, int s) => ShaderView(
  asset: ShaderAssets.galaxyButton,
  setUniforms: (sh, f) {
    sh.getUniformVec2('uSize').set(f.size.width, f.size.height);
    sh.getUniformFloat('uTime').set(f.time);
    sh.getUniformFloat('uHover').set(f.hover);
    sh.getUniformVec2('uMouse').set(f.pointer.dx, f.pointer.dy);
  },
);
