import 'package:super_hueman/data/page_data.dart';
import 'package:super_hueman/data/super_color.dart';
import 'package:super_hueman/pages/score.dart';
import 'package:super_hueman/pages/hue_typing_game.dart';
import 'package:super_hueman/data/save_data.dart';
import 'package:super_hueman/data/structs.dart';
import 'package:super_hueman/data/widgets.dart';

import 'package:flutter/material.dart';

class IntroMode extends StatefulWidget {
  const IntroMode(this.numColors, {super.key});
  final int numColors;

  @override
  State<IntroMode> createState() => _IntroModeState();
}

class TutorialQueue extends HueQueue {
  TutorialQueue(super.numColors);

  @override
  int get queuedHue => choices.isEmpty ? 0 : choices.removeAt(0);
}

class TutorialScoreKeeper implements ScoreKeeper {
  TutorialScoreKeeper(this.numColors, {required this.scoring});
  final int numColors;
  int round = 0, numCorrect = 0;
  final VoidCallback scoring;

  @override
  void roundCheck(BuildContext context) {
    if (numCorrect == numColors) {
      final scoreScreen = MaterialPageRoute<void>(builder: (context) => ScoreScreen(this));
      Navigator.pushReplacement(context, scoreScreen);
    }
  }

  @override
  void scoreTheRound() => scoring();

  @override
  Widget get midRoundDisplay => EasyText('hues found: $numCorrect / $numColors');

  @override
  Widget get finalScore => empty;

  @override
  Widget get finalDetails => empty;

  @override
  Pages get page => switch (numColors) {
        3 => Pages.intro3,
        6 => Pages.intro6,
        12 => Pages.introC,
        _ => throw Error(),
      };
}

class IntroScoreKeeper implements ScoreKeeper {
  IntroScoreKeeper({required this.numColors, required this.scoring});
  int round = 0, numCorrect = 0;

  final Stopwatch stopwatch = Stopwatch();

  final int numColors;
  final VoidCallback scoring;

  @override
  void scoreTheRound() => scoring();

  @override
  void roundCheck(BuildContext context) => round == 29
      ? Navigator.pushReplacement(
          context, MaterialPageRoute<void>(builder: (context) => ScoreScreen(this)))
      : null;

  double get colorsPerMinute => 30 * 60 * 1000 / stopwatch.elapsedMilliseconds;
  double get accuracy => numCorrect / round * 100;

  @override
  Widget get midRoundDisplay {
    final Widget roundLabel = EasyText('round ${round + 1} / 30');
    if (round == 0) return roundLabel;
    final Widget accuracyDesc = EasyText('accuracy: ${accuracy.round()}%');

    return Column(children: [roundLabel, accuracyDesc]);
  }

  @override
  Widget get finalDetails => Text(
        '(${colorsPerMinute.toStringAsFixed(1)} colors per minute) '
        '\u00d7 (${accuracy.round()}% accuracy)',
        style: const TextStyle(fontSize: 18, color: Colors.white54),
      );

  @override
  Widget get finalScore => Text(
        (colorsPerMinute * accuracy).round().toString(),
        style: const TextStyle(fontSize: 32),
      );

  @override
  Pages get page => switch (numColors) {
        3 => Pages.intro3,
        6 => Pages.intro6,
        12 => Pages.introC,
        _ => throw Error(),
      };
}

class _IntroModeState extends State<IntroMode> {
  late final FocusNode? hueFocusNode;
  late final TextEditingController? textFieldController;
  late final NumPadController? numPadController;
  String get val => numPadController!.displayValue;
  late int hue;
  int get guess => externalKeyboard ? textFieldController!.value.toInt() : numPadController!.hue;

  late final HueQueue hueQueue;

  late final ScoreKeeper? scoreKeeper;
  void giveScore() {
    switch (scoreKeeper) {
      case IntroScoreKeeper():
        if (guess == hue) (scoreKeeper as IntroScoreKeeper).numCorrect++;
        (scoreKeeper as IntroScoreKeeper).round++;
      case TutorialScoreKeeper():
        if (guess == hue) {
          (scoreKeeper as TutorialScoreKeeper).numCorrect++;
        } else {
          hueQueue.choices.add(hue);
        }
    }
  }

  void generateHue() {
    numPadController?.clear();
    hue = hueQueue.queuedHue;
  }

  SuperColor get color => SuperColor.hue(hue);

  @override
  void initState() {
    super.initState();
    inverted = false;
    if (externalKeyboard) {
      hueFocusNode = FocusNode();
      textFieldController = TextEditingController();
      numPadController = null;
    } else {
      hueFocusNode = null;
      textFieldController = null;
      numPadController = NumPadController(setState);
    }

    switch (widget.numColors) {
      case 3 when !Tutorials.intro3:
        scoreKeeper = TutorialScoreKeeper(3, scoring: giveScore);
        Tutorials.intro3 = true;
      case 6 when !Tutorials.intro6:
        scoreKeeper = TutorialScoreKeeper(6, scoring: giveScore);
        Tutorials.intro6 = true;
      case 0xC when !Tutorials.introC:
        scoreKeeper = TutorialScoreKeeper(0xC, scoring: giveScore);
        Tutorials.introC = true;
      default:
        scoreKeeper =
            casualMode ? null : IntroScoreKeeper(scoring: giveScore, numColors: widget.numColors);
    }

    if (scoreKeeper case final IntroScoreKeeper sk) sk.stopwatch.start();
    hueQueue = scoreKeeper is TutorialScoreKeeper
        ? TutorialQueue(widget.numColors)
        : HueQueue(widget.numColors);
    if (hueQueue case TutorialQueue()) hueQueue.choices.shuffle();
    generateHue();
    hueFocusNode?.requestFocus();
  }

  @override
  void dispose() {
    if (scoreKeeper case final IntroScoreKeeper sk) sk.stopwatch.stop();
    super.dispose();
  }

  Widget hueDialogBuilder(context) => HueDialog(
        (hue == guess) ? 'Nice work!' : 'Incorrect…',
        guess,
        hue,
        IntroGraphic(hue: hue, guess: guess),
      );

  @override
  Widget build(BuildContext context) => externalKeyboard
      ? KeyboardGame(
          color: color,
          hueFocusNode: hueFocusNode!,
          hueController: textFieldController!,
          hueDialogBuilder: hueDialogBuilder,
          generateHue: () => setState(generateHue),
          scoreKeeper: scoreKeeper,
        )
      : NumPadGame(
          color: color,
          numPad: (submit) => NumPad(numPadController!, submit: submit),
          numPadVal: numPadController!.displayValue,
          hueDialogBuilder: hueDialogBuilder,
          scoreKeeper: scoreKeeper,
          generateHue: () => setState(generateHue),
        );
}

class IntroGraphic extends StatefulWidget {
  const IntroGraphic({super.key, required this.hue, required this.guess});
  final int hue, guess;

  @override
  State<IntroGraphic> createState() => _IntroGraphicState();
}

class _IntroGraphicState extends State<IntroGraphic> {
  int step = 3;

  late final SuperColor color = SuperColor.hue(widget.hue);

  @override
  void initState() {
    super.initState();
    quickly(() => setState(() => step++));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ColorNameBox(color),
        MeasuringOrb(
          step: step,
          width: 100,
          duration: oneSec,
          lineColor: SuperColors.tintedDarkBackground,
          hue: widget.hue,
          guess: widget.guess,
        ),
      ],
    );
  }
}
