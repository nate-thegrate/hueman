import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hueman/data/save_data.dart';
import 'package:hueman/data/structs.dart';
import 'package:hueman/data/super_color.dart';
import 'package:hueman/data/super_text.dart';
import 'package:hueman/data/widgets.dart';

class TriviaButton extends StatelessWidget {
  const TriviaButton(this.color, {required this.constraints, required this.submit, super.key});
  final BoxConstraints constraints;
  final SuperColor color;
  final void Function() Function(SuperColor) submit;

  void Function() get onPressed => submit(color);
  bool get selected => buttonData[color]!;

  @override
  Widget build(BuildContext context) {
    final buttonWidth = constraints.calcSize((w, h) => min(w / 2 - 30, h / 2 - 215));
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: SizedBox(
        width: buttonWidth,
        height: buttonWidth / 3,
        child: DecoratedBox(
          decoration: selected
              ? BoxDecoration(
                  border: Border.all(color: color, width: buttonWidth / 20),
                  boxShadow: const [BoxShadow(blurRadius: 10)],
                )
              : const BoxDecoration(),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: selected ? SuperColors.darkBackground : color,
                shape: const BeveledRectangleBorder(),
                padding: EdgeInsets.zero),
            child: Text(
              color.name,
              style: selected
                  ? SuperStyle.sans(
                      size: buttonWidth / 8,
                      weight: 800,
                      color: color,
                      height: -0.1,
                    )
                  : SuperStyle.sans(
                      size: buttonWidth / 8,
                      weight: 700,
                      color: Colors.black,
                      shadows: const [
                        Shadow(color: Colors.white24, blurRadius: 1),
                        Shadow(color: Colors.white30, blurRadius: 25),
                      ],
                      height: -0.1,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class TriviaQuestion {
  const TriviaQuestion(this.question, this.answers, {required this.explanation});
  final String question;
  final String explanation;
  final List<SuperColor> answers;
}

const List<TriviaQuestion> _allQuestions = [
  TriviaQuestion(
    'What are the secondary subtractive colors?',
    [SuperColors.red, SuperColors.green, SuperColors.blue],
    explanation: 'The three primary additive colors '
        'are also the secondary subtractive colors.\n\n'
        'Likewise, the secondary additive colors are the subtractive primaries: '
        'cyan, magenta, and yellow.',
  ),
  TriviaQuestion(
    'The longest electromagnetic wavelength visible to the human eye is perceived as this color:',
    [SuperColors.red],
    explanation: 'red light has a wavelength of ~700 nm, '
        'roughly 150 times smaller than the width of a human hair.',
  ),
  TriviaQuestion(
    'The highest electromagnetic frequency visible to the human eye is perceived as this color:',
    [SuperColors.violet],
    explanation: 'We tend to think of red light as having the lowest frequency, '
        'but our "red" cones are also stimulated a little bit '
        'by the highest visible light frequencies, and we perceive them as violet.\n\n'
        'Violet photons oscillate at a frequency of 750 THz, '
        'or 750,000,000,000,000 times per second.',
  ),
  TriviaQuestion(
    '"When mixing watercolors, the 3 primary colors are red, yellow, and blue."\n'
    'Only 1 of those 3 colors is correct—which is it?',
    [SuperColors.yellow],
    explanation: 'The subtractive primary colors are cyan, magenta and yellow.\n\n'
        'Subtractive mixing rules apply when mixing pigments (e.g. dyes and inks).',
  ),
  TriviaQuestion(
    'Complementary colors are 180° apart on the color wheel. '
    "What's the complementary color to rose?",
    [SuperColors.spring],
    explanation: 'Spring & rose are "complementary colors" '
        'because they can combine to make white.\n\n'
        'You can find the complement of any color by flipping its RGB values upside down; for example:\n\n'
        'rose – 100% red / 0% green / 50% blue\n'
        'spring – 0% red / 100% green / 50% blue',
  ),
  TriviaQuestion(
    'Which color caused CMYK to have a "K"?',
    [SuperColors.blue],
    explanation: 'CMYK is an abbreviation for the ink colors that printers need:\n'
        'cyan, magenta, yellow, and black.\n\n'
        'Since "B" is already short for "blue" in RGB, '
        'it would be confusing to use a "B" here too.\n\n'
        'So instead, we decided to call black ink "Key" '
        "(since it's the most important type of ink to have).",
  ),
  TriviaQuestion(
    'Which color is also the name of a cloud computing platform?',
    [SuperColors.azure],
    explanation: 'You can use Microsoft Azure to make websites and virtual machines.\n\n'
        "And, of course, it's got an azure logo.",
  ),
  TriviaQuestion(
    "Which 2 color names are different from the names on Wikipedia's color wheel?",
    [SuperColors.chartreuse, SuperColors.spring],
    explanation: "On Wikipedia's color wheel, "
        'these two show up as "chartreuse green" and "spring green" respectively.\n\n'
        'Maybe they thought that "chartreuse" by itself isn\'t a great color name '
        '(which, to be fair, is a valid point) '
        'and that everyone refers to "spring" as a season rather than a color.\n\n'
        'But back in the 1500s, people got used to "orange" being both a color and a fruit, '
        "so I don't think it'll be too hard for us to do something similar right now.",
  ),
  TriviaQuestion(
    "What's my favorite color?",
    [SuperColors.cyan],
    explanation: "100% useless information, but that's what trivia's all about!\n\n"
        'Cyan (along with magenta) is a primary color '
        'that no one seems to be talking about. '
        "Hopefully that's about to change!\n\n"
        '(P.S. if you want to know my least-favorite color, '
        'it starts with a "c" and has a hue of 90 degrees.)',
  ),
  TriviaQuestion(
    'If you were born in August, what color would your birthstone be?',
    [SuperColors.chartreuse],
    explanation: 'According to what I just read on Wikipedia, '
        "Peridot is one of only two gems observed to be formed not in Earth's crust, "
        'but in the molten rock of the upper mantle.',
  ),
  TriviaQuestion(
    'The color "brown" is really just a darker shade of:',
    [SuperColors.orange],
    // ignore: missing_whitespace_between_adjacent_strings, false positive
    explanation: "This is why there's no such thing as a brown light bulb—"
        'if a brown color is vibrant enough, it becomes orange.',
  ),
  TriviaQuestion(
    'These two colors never appear in a rainbow:',
    [SuperColors.magenta, SuperColors.rose],
    explanation: 'Violet wavelengths allow us to see a combination of red and blue, '
        'but the only way to stimulate the red and blue cones equally '
        'is to use two different light frequencies at once.',
  ),
  TriviaQuestion(
    'The most common type of color-blindness involves being unable to tell _____ and _____ apart.',
    [SuperColors.red, SuperColors.green],
    explanation: '"Congenital red-green color blindness" is caused '
        'by a recessive gene in the X-chromosome, '
        'so it affects males more often than females.',
  ),
  TriviaQuestion(
    'The more distant another star is from our solar system, the more _____ it appears to us.',
    [SuperColors.red],
    explanation: 'When we observe stars that are rapidly moving away from us, '
        'the photons are stretched (or "red-shifted") into longer wavelengths.\n\n'
        'Thanks to our expanding universe, '
        'far-away stars are rapidly moving away from our galaxy, '
        'which gives them more of a red hue.',
  ),
  TriviaQuestion(
    'Morpheus offered Neo two pills.',
    [SuperColors.red, SuperColors.blue],
    explanation: 'Even though its name was "the blue pill",\nits hue was much closer to cyan.',
  ),
];

class TriviaMode extends StatefulWidget {
  const TriviaMode({super.key});

  @override
  State<TriviaMode> createState() => _TriviaModeState();
}

class AnsweredEveryQuestion extends StatelessWidget {
  const AnsweredEveryQuestion(this.scoreDesc, {super.key});
  final String scoreDesc;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        fontFamily: 'nunito sans',
        dialogTheme: const DialogThemeData(backgroundColor: SuperColors.lightBackground),
      ),
      child: AlertDialog(
        title: const Text(
          'Congrats!',
          textAlign: TextAlign.center,
          style: SuperStyle.sans(weight: 600, width: 87.5),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "You've answered each trivia question!",
              style: SuperStyle.sans(),
            ),
            if (!casualMode) ...[
              const FixedSpacer(8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('score: ', style: SuperStyle.sans(height: 0)),
                  Text(scoreDesc, style: const SuperStyle.sans(size: 12)),
                ],
              ),
            ],
          ],
        ),
        actions: const [Center(child: GoBack(text: 'back to menu'))],
      ),
    );
  }
}

late Map<SuperColor, bool> buttonData;

class _TriviaModeState extends State<TriviaMode> {
  final triviaQuestions = _allQuestions.toList();

  void resetButtons() => buttonData = {for (final color in SuperColors.twelveHues) color: false};

  List<SuperColor> get selected => [
        for (final entry in buttonData.entries) ...entry.value ? [entry.key] : []
      ];

  List<SuperColor> get correctAnswers => triviaQuestions.first.answers;

  int totalAnswers = 0, totalCorrect = 0;

  @override
  void initState() {
    super.initState();
    inverted = true;
    resetButtons();
    triviaQuestions.shuffle();
    music.play(loop: 'color_trivia');
    if (!Tutorial.trivial()) {
      Tutorial.trivial.complete();
      sleep(
        0.5,
        then: () => showDialog<void>(
          context: context,
          builder: (context) => Theme(
            data: ThemeData(
              useMaterial3: true,
              fontFamily: 'nunito sans',
              dialogTheme: const DialogThemeData(backgroundColor: SuperColors.lightBackground),
            ),
            child: DismissibleDialog(
              title: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Welcome to trivial mode!',
                  softWrap: false,
                  style: SuperStyle.sans(weight: 600, width: 87.5),
                ),
              ),
              content: Text(
                "it's literally just ${_allQuestions.length} color trivia questions.",
                style: const SuperStyle.sans(),
              ),
            ),
          ),
        ),
      );
    }
  }

  void Function() submit(SuperColor color) => () {
        setState(() => buttonData[color] = !buttonData[color]!);

        final List<SuperColor> answers = selected;
        if (answers.length != correctAnswers.length) return;

        bool correct = true;
        for (final correctAnswer in correctAnswers) {
          if (!answers.contains(correctAnswer)) correct = false;
        }

        showDialog<void>(
          context: context,
          builder: (context) => Theme(
            data: ThemeData(
              useMaterial3: true,
              fontFamily: 'nunito sans',
              dialogTheme: const DialogThemeData(backgroundColor: SuperColors.lightBackground),
            ),
            child: DismissibleDialog(
              title: Center(
                child: Text(
                  correct ? 'Correct!' : 'Incorrect.',
                  style: const SuperStyle.sans(weight: 600, width: 87.5),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      for (final color in correctAnswers)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: ColorNameBox.trivial(color),
                        ),
                      const Spacer(),
                    ],
                  ),
                  const FixedSpacer(30),
                  ConstrainedBox(
                      constraints: BoxConstraints.loose(const Size.fromWidth(500)),
                      child: Text(
                        triviaQuestions.first.explanation,
                        style: const SuperStyle.sans(size: 14),
                      )),
                ],
              ),
            ),
          ),
        ).then((_) {
          totalAnswers++;
          if (correct) totalCorrect++;
          setState(resetButtons);
          if (triviaQuestions.length > 1) {
            setState(() => triviaQuestions.removeAt(0));
          } else {
            final String scorePercent = totalCorrect == totalAnswers
                ? 'perfect!'
                : '${(totalCorrect / totalAnswers * 100).toStringAsFixed(1)}%';
            final score = '$scorePercent ($totalCorrect / $totalAnswers)';
            if (!casualMode) Score.trivial.set(totalCorrect);
            showDialog<void>(
              context: context,
              builder: (context) => AnsweredEveryQuestion(score),
              barrierDismissible: false,
            );
          }
        });
      };

  List<Widget> buttons(BoxConstraints constraints) {
    final buttons = <Widget>[];
    for (int i = 0; i < 6; i++) {
      final (leftColor, rightColor) = (SuperColors.twelveHues[i], SuperColors.twelveHues[11 - i]);
      buttons.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TriviaButton(leftColor, constraints: constraints, submit: submit),
          TriviaButton(rightColor, constraints: constraints, submit: submit),
        ],
      ));
    }
    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(useMaterial3: true, fontFamily: 'nunito sans'),
      child: Scaffold(
        body: SafeLayout((context, constraints) {
          final Widget questionText = SizedBox(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Center(
                child: Text(
                  triviaQuestions.first.question,
                  textAlign: TextAlign.center,
                  style: SuperStyle.sans(
                    color: Colors.black,
                    size: constraints.calcSize((w, h) => min(w, h / 2) / 20),
                    weight: 600,
                  ),
                ),
              ),
            ),
          );

          final Widget multipleColorsReminder = SizedBox(
            height: 30,
            child: switch (selected.isEmpty) {
              _ when correctAnswers.length == 1 || correctAnswers.length == selected.length =>
                empty,
              true => Text(
                  'Select ${correctAnswers.length} colors.',
                  style: const SuperStyle.sans(size: 20),
                ),
              false => Text(
                  'Select ${correctAnswers.length - selected.length} more.',
                  style: const SuperStyle.sans(size: 20),
                ),
            },
          );

          final Widget score = Text(
            (casualMode || totalAnswers == 0)
                ? ''
                : 'Score: $totalCorrect / $totalAnswers correct',
            style: const SuperStyle.sans(size: 18),
          );
          return Center(
            child: Column(
              children: [
                const Spacer(),
                const GoBack(),
                questionText,
                multipleColorsReminder,
                ...buttons(constraints),
                score,
              ],
            ),
          );
        }),
        backgroundColor: SuperColors.lightBackground,
      ),
    );
  }
}
