import 'package:hueman/data/page_data.dart';
import 'package:hueman/data/super_color.dart';
import 'package:hueman/data/super_text.dart';
import 'package:hueman/pages/score.dart';
import 'package:hueman/pages/hue_typing_game.dart';
import 'package:hueman/data/save_data.dart';
import 'package:hueman/data/structs.dart';
import 'package:hueman/data/widgets.dart';

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
  Widget get midRoundDisplay => SuperText('hues found: $numCorrect / $numColors');

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
    final Widget roundLabel = SuperText('round ${round + 1} / 30');
    if (round == 0) return roundLabel;
    final Widget accuracyDesc = SuperText('accuracy: ${accuracy.round()}%');

    return Column(children: [roundLabel, accuracyDesc]);
  }

  @override
  Widget get finalDetails => Text(
        '(${colorsPerMinute.toStringAsFixed(1)} colors per minute) '
        '\u00d7 (${accuracy.round()}% accuracy)',
        style: const SuperStyle.sans(size: 18, color: Colors.white54),
      );

  @override
  Widget get finalScore => Text(
        (colorsPerMinute * accuracy).round().toString(),
        style: const SuperStyle.sans(size: 32),
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
      case 3 when !tutorialIntro3:
        scoreKeeper = TutorialScoreKeeper(3, scoring: giveScore);
        saveData('tutorialIntro3', true);
        tutorialIntro3 = true;
      case 6 when !tutorialIntro6:
        scoreKeeper = TutorialScoreKeeper(6, scoring: giveScore);
        saveData('tutorialIntro6', true);
        tutorialIntro6 = true;
      case 0xC when !tutorialIntroC:
        scoreKeeper = TutorialScoreKeeper(0xC, scoring: giveScore);
        saveData('tutorialIntroC', true);
        tutorialIntroC = true;
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
    if (scoreKeeper == null && !tutorialCasual) {
      sleep(
        1,
        then: () => showDialog(
          context: context,
          builder: (context) => const AlertDialog(
            title: Text(
              'playing in casual mode',
              textAlign: TextAlign.center,
            ),
            content: Text(
              'no timers or scorekeeping,\njust you and hue :)',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
      saveData('tutorialCasual', true);
      tutorialCasual = true;
    }
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
  Widget build(BuildContext context) {
    if (externalKeyboard) {
      return KeyboardGame(
        color: color,
        hueFocusNode: hueFocusNode!,
        hueController: textFieldController!,
        hueDialogBuilder: hueDialogBuilder,
        generateHue: () => setState(generateHue),
        scoreKeeper: scoreKeeper,
      );
    }
    return NumPadGame(
      color: color,
      numPad: (submit) => NumPad(numPadController!, submit: submit),
      numPadVal: numPadController!.displayValue,
      hueDialogBuilder: hueDialogBuilder,
      scoreKeeper: scoreKeeper,
      generateHue: () => setState(generateHue),
    );
  }
}
