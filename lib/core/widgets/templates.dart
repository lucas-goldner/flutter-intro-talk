import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';
import 'package:flutter_intro_talk/core/theme/kaigi_theme.dart';
import 'package:flutter_intro_talk/core/widgets/code_panel.dart';
import 'package:flutter_intro_talk/core/widgets/deck_components.dart';
import 'package:flutter_intro_talk/core/widgets/deck_scaffold.dart';
import 'package:flutter_intro_talk/core/widgets/motion.dart';
import 'package:flutter_intro_talk/core/widgets/wwdc_background.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data-driven slide templates. Most "talking" slides in the deck are one of
// these, so the deck stays visually consistent and each section file only
// hand-builds the slides that need a bespoke interactive demo.
//
// All templates hide the flutter_deck header (the slide draws its own title)
// and pass `title` to the configuration so the navigation drawer reads well.
// ─────────────────────────────────────────────────────────────────────────────

const _noHeader = FlutterDeckHeaderConfiguration(showHeader: false);

/// One full-bleed sentence.
class StatementSlideWidget extends FlutterDeckSlideWidget {
  // Not const: the configuration is built from constructor arguments.
  StatementSlideWidget({
    required String route,
    required this.statement,
    super.key,
    this.subtitle,
    this.eyebrow,
    this.mood = GradientMood.hero,
    this.gradient,
  }) : super(
         configuration: FlutterDeckSlideConfiguration(
           route: route,
           title: statement,
           header: _noHeader,
         ),
       );

  final String statement;
  final String? subtitle;
  final String? eyebrow;
  final GradientMood mood;
  final Gradient? gradient;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.custom(
      builder: (context) => StatementSlide(
        statement: statement,
        subtitle: subtitle,
        eyebrow: eyebrow,
        mood: mood,
        gradient: gradient,
      ),
    );
  }
}

/// Section divider with an oversized numeral.
class DividerSlideWidget extends FlutterDeckSlideWidget {
  // Not const: the configuration is built from constructor arguments.
  DividerSlideWidget({
    required String route,
    required this.number,
    required this.label,
    required this.title,
    super.key,
    this.subtitle,
    this.mood = GradientMood.violet,
    this.accent = DeckColors.cyan,
  }) : super(
         configuration: FlutterDeckSlideConfiguration(
           route: route,
           title: '$number  $title',
           header: _noHeader,
         ),
       );

  final String number;
  final String label;
  final String title;
  final String? subtitle;
  final GradientMood mood;
  final Color accent;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.custom(
      builder: (context) => PartDivider(
        number: number,
        label: label,
        title: title,
        subtitle: subtitle,
        mood: mood,
        accent: accent,
      ),
    );
  }
}

/// Title + bullets that reveal one per step.
class BulletSlideWidget extends FlutterDeckSlideWidget {
  // Not const: the configuration is built from constructor arguments.
  BulletSlideWidget({
    required String route,
    required this.title,
    required this.bullets,
    super.key,
    this.eyebrow,
    this.footnote,
    this.accent = DeckColors.cyan,
    this.mood = GradientMood.cool,
    this.reveal = true,
    this.side,
  }) : super(
         configuration: FlutterDeckSlideConfiguration(
           route: route,
           title: title,
           header: _noHeader,
           steps: reveal ? bullets.length : 1,
         ),
       );

  final String title;
  final List<String> bullets;
  final String? eyebrow;
  final String? footnote;
  final Color accent;
  final GradientMood mood;
  final bool reveal;

  /// Optional widget shown to the right of the bullets.
  final Widget? side;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.custom(
      builder: (context) => FlutterDeckSlideStepsBuilder(
        builder: (context, step) {
          final list = BulletList(
            items: bullets,
            accent: accent,
            visibleCount: reveal ? step : null,
          );
          return DeckSlide(
            eyebrow: eyebrow,
            title: title,
            footnote: footnote,
            mood: mood,
            child: side == null
                ? list
                : SplitContent(
                    left: list,
                    right: side!,
                    leftFlex: 5,
                    rightFlex: 5,
                  ),
          );
        },
      ),
    );
  }
}

/// A card for [CardGridSlideWidget].
class CardSpec {
  const CardSpec({
    required this.title,
    required this.lines,
    this.badge,
    this.accent = DeckColors.cyan,
  });

  final String title;
  final List<String> lines;
  final String? badge;
  final Color accent;
}

/// Grid of [TitledCard]s that reveal one per step.
class CardGridSlideWidget extends FlutterDeckSlideWidget {
  // Not const: the configuration is built from constructor arguments.
  CardGridSlideWidget({
    required String route,
    required this.title,
    required this.cards,
    super.key,
    this.eyebrow,
    this.footnote,
    this.columns = 2,
    this.childAspectRatio = 2.1,
    this.mood = GradientMood.cool,
    this.reveal = true,
  }) : super(
         configuration: FlutterDeckSlideConfiguration(
           route: route,
           title: title,
           header: _noHeader,
           steps: reveal ? cards.length : 1,
         ),
       );

  final String title;
  final List<CardSpec> cards;
  final String? eyebrow;
  final String? footnote;
  final int columns;
  final double childAspectRatio;
  final GradientMood mood;
  final bool reveal;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.custom(
      builder: (context) => FlutterDeckSlideStepsBuilder(
        builder: (context, step) => DeckSlide(
          eyebrow: eyebrow,
          title: title,
          footnote: footnote,
          mood: mood,
          child: GridView.count(
            crossAxisCount: columns,
            childAspectRatio: childAspectRatio,
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (var i = 0; i < cards.length; i++)
                StaggerIn(
                  visible: !reveal || step > i,
                  child: TitledCard(
                    badge: cards[i].badge,
                    title: cards[i].title,
                    lines: cards[i].lines,
                    accent: cards[i].accent,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Code on the right, short explanation bullets on the left.
class CodeSlideWidget extends FlutterDeckSlideWidget {
  // Not const: the configuration is built from constructor arguments.
  CodeSlideWidget({
    required String route,
    required this.title,
    required this.code,
    required this.fileName,
    super.key,
    this.eyebrow,
    this.points = const [],
    this.footnote,
    this.language = 'dart',
    this.fontSize = 20,
    this.mood = GradientMood.calm,
  }) : super(
         configuration: FlutterDeckSlideConfiguration(
           route: route,
           title: title,
           header: _noHeader,
           steps: points.isEmpty ? 1 : points.length,
         ),
       );

  final String title;
  final String code;
  final String fileName;
  final String? eyebrow;
  final List<String> points;
  final String? footnote;
  final String language;
  final double fontSize;
  final GradientMood mood;

  @override
  FlutterDeckSlide build(BuildContext context) {
    final accent = switch (language) {
      'dart' => DeckColors.dart,
      'swift' => DeckColors.orange,
      'kotlin' => DeckColors.purple,
      'json' => DeckColors.green,
      'yaml' => DeckColors.green,
      'bash' => DeckColors.textSecondary,
      _ => DeckColors.glsl,
    };
    return FlutterDeckSlide.custom(
      builder: (context) => FlutterDeckSlideStepsBuilder(
        builder: (context, step) {
          final panel = CodePanel(
            code,
            language: language,
            fileName: fileName,
            fontSize: fontSize,
            accent: accent,
          );
          return DeckSlide(
            eyebrow: eyebrow,
            title: title,
            footnote: footnote,
            mood: mood,
            intensity: 0.45,
            child: points.isEmpty
                ? panel
                : SplitContent(
                    leftFlex: 4,
                    rightFlex: 7,
                    left: BulletList(
                      items: points,
                      accent: accent,
                      fontSize: 27,
                      visibleCount: step,
                    ),
                    right: panel,
                  ),
          );
        },
      ),
    );
  }
}

/// Audience quiz. Click an option to add a vote (count hands in the room),
/// press → to reveal the answer.
class QuizSlideWidget extends FlutterDeckSlideWidget {
  // Not const: the configuration is built from constructor arguments.
  QuizSlideWidget({
    required String route,
    required this.question,
    required this.options,
    required this.answer,
    super.key,
    this.explanation,
    this.eyebrow = 'QUIZ',
  }) : super(
         configuration: FlutterDeckSlideConfiguration(
           route: route,
           title: 'クイズ：$question',
           header: _noHeader,
           steps: 2,
         ),
       );

  final String question;
  final List<String> options;
  final int answer;
  final String? explanation;
  final String eyebrow;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.custom(
      builder: (context) => FlutterDeckSlideStepsBuilder(
        builder: (context, step) => _Quiz(
          eyebrow: eyebrow,
          question: question,
          options: options,
          answer: answer,
          explanation: explanation,
          revealed: step >= 2,
        ),
      ),
    );
  }
}

class _Quiz extends StatefulWidget {
  const _Quiz({
    required this.eyebrow,
    required this.question,
    required this.options,
    required this.answer,
    required this.explanation,
    required this.revealed,
  });

  final String eyebrow;
  final String question;
  final List<String> options;
  final int answer;
  final String? explanation;
  final bool revealed;

  @override
  State<_Quiz> createState() => _QuizState();
}

class _QuizState extends State<_Quiz> {
  late final List<int> _votes = List.filled(widget.options.length, 0);

  static const _letters = ['A', 'B', 'C', 'D', 'E'];
  static const _colors = [
    DeckColors.cyan,
    DeckColors.pink,
    DeckColors.orange,
    DeckColors.purple,
    DeckColors.green,
  ];

  @override
  Widget build(BuildContext context) {
    final total = _votes.fold<int>(0, (a, b) => a + b);
    return Stack(
      fit: StackFit.expand,
      children: [
        const WwdcBackground(mood: GradientMood.warm, intensity: 0.6),
        Padding(
          padding: const EdgeInsets.fromLTRB(110, 70, 110, 70),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Pill(
                    '🙋 会場に質問',
                    color: DeckColors.orange,
                    fontSize: 18,
                  ),
                  const SizedBox(width: 18),
                  Text(widget.eyebrow, style: DeckText.eyebrow),
                  const Spacer(),
                  Text(
                    'クリックで投票 ・ → で答え合わせ',
                    style: DeckText.caption.copyWith(color: Colors.white38),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              GradientText(widget.question, style: DeckText.title),
              const SizedBox(height: 44),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    for (var i = 0; i < widget.options.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _QuizOption(
                          letter: _letters[i],
                          text: widget.options[i],
                          color: _colors[i % _colors.length],
                          votes: _votes[i],
                          share: total == 0 ? 0 : _votes[i] / total,
                          state: !widget.revealed
                              ? _OptionState.open
                              : i == widget.answer
                              ? _OptionState.correct
                              : _OptionState.wrong,
                          onTap: () => setState(() => _votes[i]++),
                        ),
                      ),
                  ],
                ),
              ),
              AnimatedOpacity(
                opacity: widget.revealed && widget.explanation != null ? 1 : 0,
                duration: const Duration(milliseconds: 400),
                child: Footnote(
                  widget.explanation ?? '',
                  color: DeckColors.green,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum _OptionState { open, correct, wrong }

class _QuizOption extends StatelessWidget {
  const _QuizOption({
    required this.letter,
    required this.text,
    required this.color,
    required this.votes,
    required this.share,
    required this.state,
    required this.onTap,
  });

  final String letter;
  final String text;
  final Color color;
  final int votes;
  final double share;
  final _OptionState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = switch (state) {
      _OptionState.open => color,
      _OptionState.correct => DeckColors.green,
      _OptionState.wrong => DeckColors.textTertiary,
    };
    return AnimatedOpacity(
      opacity: state == _OptionState.wrong ? 0.4 : 1,
      duration: const Duration(milliseconds: 350),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            height: 92,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: c.withValues(
                  alpha: state == _OptionState.correct ? 1 : 0.45,
                ),
                width: state == _OptionState.correct ? 3 : 1.5,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Vote bar fills from the left.
                Positioned.fill(
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: share,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      color: c.withValues(alpha: 0.16),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: c.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: c, width: 2),
                          ),
                          child: Text(
                            letter,
                            style: DeckText.heading.copyWith(
                              fontSize: 26,
                              color: c,
                              height: 1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 26),
                        Expanded(
                          child: Text(
                            text,
                            style: DeckText.heading.copyWith(fontSize: 34),
                          ),
                        ),
                        if (votes > 0)
                          Text(
                            '$votes 票',
                            style: DeckText.body.copyWith(
                              color: c,
                              fontSize: 26,
                            ),
                          ),
                        if (state == _OptionState.correct) ...[
                          const SizedBox(width: 18),
                          const Icon(
                            Icons.check_circle_rounded,
                            color: DeckColors.green,
                            size: 44,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bespoke slide body with the standard [DeckSlide] chrome and step support.
/// Use for interactive slides: `steps` beats, builder gets the current step.
class InteractiveSlideWidget extends FlutterDeckSlideWidget {
  // Not const: the configuration is built from constructor arguments.
  InteractiveSlideWidget({
    required String route,
    required this.title,
    required this.builder,
    super.key,
    this.eyebrow,
    this.footnote,
    this.mood = GradientMood.cool,
    this.intensity = 0.5,
    int steps = 1,
  }) : super(
         configuration: FlutterDeckSlideConfiguration(
           route: route,
           title: title,
           header: _noHeader,
           steps: steps,
         ),
       );

  final String title;
  final String? eyebrow;
  final String? footnote;
  final GradientMood mood;
  final double intensity;
  final Widget Function(BuildContext context, int step) builder;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.custom(
      builder: (context) => FlutterDeckSlideStepsBuilder(
        builder: (context, step) => DeckSlide(
          eyebrow: eyebrow,
          title: title,
          footnote: footnote,
          mood: mood,
          intensity: intensity,
          child: builder(context, step),
        ),
      ),
    );
  }
}
