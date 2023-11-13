import 'package:hueman/data/page_data.dart';
import 'package:hueman/data/super_color.dart';
import 'package:hueman/data/super_text.dart';
import 'package:hueman/pages/score.dart';
import 'package:hueman/pages/hue_typing_game.dart';
import 'package:hueman/data/save_data.dart';
import 'package:hueman/data/structs.dart';
import 'package:hueman/data/widgets.dart';

import 'package:flutter/material.dart';

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
  Widget get midRoundDisplay {
    final String possibleValues =
        List.generate(numColors, (i) => i * 360 ~/ numColors).join(', ');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SuperText('hues found: $numCorrect / $numColors'),
        const FixedSpacer(10),
        SuperText(
          'possible hue values: $possibleValues',
          style: const SuperStyle.sans(size: 14),
        ),
      ],
    );
  }

  @override
  int get scoreVal => throw Error();

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
  int get scoreVal => (colorsPerMinute * accuracy).round();

  @override
  Pages get page => switch (numColors) {
        3 => Pages.intro3,
        6 => Pages.intro6,
        12 => Pages.introC,
        _ => throw Error(),
      };
}

class IntroMode extends StatefulWidget {
  const IntroMode(this.numColors, {super.key});
  final int numColors;

  @override
  State<IntroMode> createState() => _IntroModeState();
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
    final sk = scoreKeeper;
    switch (sk) {
      case IntroScoreKeeper():
        if (guess == hue) sk.numCorrect++;
        sk.round++;
      case TutorialScoreKeeper():
        if (guess == hue) {
          sk.numCorrect++;
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

    void firstHues() => sleep(
          1,
          then: () => showDialog(
            context: context,
            builder: (context) => const AlertDialog(
              title: Text(
                'Find the hues!',
                textAlign: TextAlign.center,
                style: SuperStyle.sans(weight: 200, extraBold: true),
              ),
              content: Text(
                "Type a number between 0 and 359\nand check to see if it's right.",
                textAlign: TextAlign.center,
                style: SuperStyle.sans(),
              ),
            ),
          ),
        );

    switch (widget.numColors) {
      case 3 when !Tutorial.intro3():
        scoreKeeper = TutorialScoreKeeper(3, scoring: giveScore);
        Tutorial.intro3.complete();
        firstHues();
      case 6 when !Tutorial.intro6():
        scoreKeeper = TutorialScoreKeeper(6, scoring: giveScore);
        Tutorial.intro6.complete();
      case 0xC when !Tutorial.introC():
        scoreKeeper = TutorialScoreKeeper(0xC, scoring: giveScore);
        Tutorial.introC.complete();
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
    if (scoreKeeper == null && !Tutorial.casual()) {
      sleep(
        1,
        then: () => showDialog(
          context: context,
          builder: (context) => const AlertDialog(
            title: Text(
              'playing in casual mode',
              textAlign: TextAlign.center,
              style: SuperStyle.sans(),
            ),
            content: Text(
              'no timers or scorekeeping,\njust you and hue :)',
              textAlign: TextAlign.center,
              style: SuperStyle.sans(),
            ),
          ),
        ),
      );
      Tutorial.casual.complete();
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
