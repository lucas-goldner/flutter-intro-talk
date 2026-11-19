// Pumps every slide of every section at 1920×1080 and steps through all of
// its beats, failing on any exception (layout overflow included).
//
//   flutter test test/slides_smoke_test.dart                 # whole deck
//   flutter test test/slides_smoke_test.dart --plain-name s07 # one section
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_deck/flutter_deck.dart';
import 'package:flutter_intro_talk/main.dart';
import 'package:flutter_intro_talk/slides/s01_problem.dart';
import 'package:flutter_intro_talk/slides/s02_benefits.dart';
import 'package:flutter_intro_talk/slides/s03_counter.dart';
import 'package:flutter_intro_talk/slides/s04_trees.dart';
import 'package:flutter_intro_talk/slides/s05_touch_journey.dart';
import 'package:flutter_intro_talk/slides/s06_widget_types.dart';
import 'package:flutter_intro_talk/slides/s07_state.dart';
import 'package:flutter_intro_talk/slides/s08_architecture.dart';
import 'package:flutter_intro_talk/slides/s09_rendering.dart';
import 'package:flutter_intro_talk/slides/s10_beyond.dart';
import 'package:flutter_intro_talk/slides/s11_native.dart';
import 'package:flutter_intro_talk/slides/s12_ai.dart';
import 'package:flutter_intro_talk/slides/s13_testing.dart';
import 'package:flutter_intro_talk/slides/s14_genui.dart';
import 'package:flutter_intro_talk/slides/s15_gallery.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final sections = <String, List<FlutterDeckSlideWidget>>{
    's01': titleAndProblemSlides,
    's02': agendaAndBenefitsSlides,
    's03': counterSlides,
    's04': treeSlides,
    's05': touchJourneySlides,
    's06': widgetTypeSlides,
    's07': stateSlides,
    's08': architectureSlides,
    's09': renderingSlides,
    's10': beyondSlides,
    's11': nativeSlides,
    's12': aiSlides,
    's13': testingSlides,
    's14': genUiSlides,
    's15': gallerySlides,
  };

  test('routes are unique across the deck', () {
    final routes = [
      for (final s in sections.values) ...s.map((w) => w.configuration.route),
    ];
    expect(routes.toSet().length, routes.length);
  });

  for (final MapEntry(key: name, value: slides) in sections.entries) {
    for (final slide in slides) {
      final route = slide.configuration.route;
      testWidgets('$name $route', (tester) async {
        tester.view.physicalSize = const Size(1920, 1080);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(FlutterIntroDeck(slides: [slide]));
        await tester.pump(const Duration(milliseconds: 600));

        for (var i = 1; i < slide.configuration.steps; i++) {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
          await tester.pump(const Duration(milliseconds: 700));
        }
        await tester.pump(const Duration(seconds: 2));
        expect(tester.takeException(), isNull);

        // Unmount so tickers and timers are disposed inside the test.
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 1));
      });
    }
  }
}
