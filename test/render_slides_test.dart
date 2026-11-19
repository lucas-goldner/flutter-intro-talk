// Renders the final beat of every slide to build/shots/<section>_<route>.png
// with real Latin + Japanese fonts, for visual review without a device.
// Fragment shaders and Rive do not paint in the test VM.
//
//   flutter test test/render_slides_test.dart --plain-name s07
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_intro_talk/main.dart';
import 'package:flutter_test/flutter_test.dart';

import 'slides_smoke_test.dart' show deckSections;

Future<void> _font(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final f in files) {
    final bytes = File('test/fonts/$f').readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
}

void main() {
  setUpAll(() async {
    const latin = [
      'Roboto-Regular.ttf',
      'Roboto-Medium.ttf',
      'Roboto-Bold.ttf',
    ];
    const jp = ['NotoSansJP-400.ttf', 'NotoSansJP-700.ttf'];
    await _font('Roboto', latin);
    await _font('.SF UI Display', latin);
    await _font('Hiragino Sans', jp);
    await _font('SF Mono', latin);
    await _font('Menlo', jp);
    await _font('MaterialIcons', ['MaterialIcons-Regular.otf']);
    Directory('build/shots').createSync(recursive: true);
  });

  for (final MapEntry(key: name, value: slides) in deckSections().entries) {
    for (final slide in slides) {
      final route = slide.configuration!.route;
      testWidgets('$name $route', (tester) async {
        tester.view.physicalSize = const Size(1920, 1080);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(FlutterIntroDeck(slides: [slide]));
        await tester.pump(const Duration(milliseconds: 600));
        for (var i = 1; i < slide.configuration!.steps; i++) {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
          await tester.pump(const Duration(milliseconds: 700));
        }
        await tester.pump(const Duration(seconds: 2));

        final view = tester.binding.renderViews.first;
        final layer = view.debugLayer! as OffsetLayer;
        await tester.runAsync(() async {
          final image = await layer.toImage(
            Offset.zero & const Size(1920, 1080),
          );
          final png = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = route.replaceAll('/', '_');
          File(
            'build/shots/$name$file.png',
          ).writeAsBytesSync(png!.buffer.asUint8List());
        });
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 1));
      });
    }
  }
}
