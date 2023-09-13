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

class TutorialScoreKeeper implements ScoreKeeper {
  TutorialScoreKeeper({required this.numColors});
  final int numColors;
  int round = 0;

  @override
  void roundCheck(BuildContext context) => (round + 1 == totalRounds)
      ? Navigator.pushReplacement(
          context, MaterialPageRoute<void>(builder: (context) => ScoreScreen(this)))
      : ();

  @override
  void scoreTheRound() => round++;

  @override
  Widget get midRoundDisplay =>
      Text('round ${round + 1} / $totalRounds', style: const TextStyle(fontSize: 24));

  @override
  Widget get finalScore => empty;

  @override
  Widget get finalDetails => empty;

  @override
  Pages get page => switch (numColors) {
        3 => Pages.intro3,
        6 => Pages.intro6,
        12 => Pages.intro12,
        _ => null,
      }!;

  late final int totalRounds = switch (numColors) {
    3 => 10,
    6 => 15,
    12 => 20,
    _ => null,
  }!;
}

class IntroScoreKeeper implements ScoreKeeper {
  IntroScoreKeeper({required this.numColors, required this.scoring});
  int round = 0;
  int numCorrect = 0;

  final Stopwatch stopwatch = Stopwatch();

  final int numColors;
  final Function scoring;

  @override
  void scoreTheRound() => scoring();

  @override
  void roundCheck(BuildContext context) => (round == 29)
      ? Navigator.pushReplacement(
          context, MaterialPageRoute<void>(builder: (context) => ScoreScreen(this)))
      : ();

  double get colorsPerMinute => 30 * 60 * 1000 / stopwatch.elapsedMilliseconds;
  double get accuracy => numCorrect / round * 100;

  @override
  Widget get midRoundDisplay {
    const TextStyle style = TextStyle(fontSize: 24);
    final Widget roundLabel = Text('round ${round + 1} / 30', style: style);
    if (round == 0) return roundLabel;
    final Widget accuracyDesc = Text('accuracy: ${accuracy.round()}%', style: style);

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
        12 => Pages.intro12,
        _ => null,
      }!;
}

class _IntroModeState extends State<IntroMode> {
  late final FocusNode? hueFocusNode;
  late final TextEditingController? hueController;
  late final NumPadController? numPadController;
  String get val => numPadController!.displayValue;
  late int hue;
  int get guess =>
      externalKeyboard ? hueController!.value.toInt() : int.parse(numPadController!.displayValue);

  final List<int> hueChoices = [];
  final List<int> recentChoices = [];

  late final ScoreKeeper? scoreKeeper;
  void giveScore() {
    if (scoreKeeper case final IntroScoreKeeper sk) {
      if (guess == hue) sk.numCorrect++;
      sk.round++;
    }
  }

  void generateHue() {
    numPadController?.clear();
    hue = hueChoices.removeAt(rng.nextInt(hueChoices.length));
    if (recentChoices.length >= widget.numColors ~/ 2) hueChoices.add(recentChoices.removeAt(0));
    recentChoices.add(hue);
  }

  SuperColor get color => SuperColor.hue(hue);

  @override
  void initState() {
    super.initState();
    inverted = false;
    if (externalKeyboard) {
      hueFocusNode = FocusNode();
      hueController = TextEditingController();
      numPadController = null;
    } else {
      hueFocusNode = null;
      hueController = null;
      numPadController = NumPadController(setState);
    }

    if (Tutorials.intro3) {
      scoreKeeper =
          casualMode ? null : IntroScoreKeeper(scoring: giveScore, numColors: widget.numColors);
    } else {
      scoreKeeper = TutorialScoreKeeper(numColors: widget.numColors);
      Tutorials.intro3 = true;
    }
    if (scoreKeeper case final IntroScoreKeeper sk) sk.stopwatch.start();
    hueChoices.addAll([for (int hue = 0; hue < 360; hue += 360 ~/ widget.numColors) hue]);
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
        Column(
          children: [
            ColorNameBox(color),
            MeasuringOrb(step: 4, width: 100, duration: const Duration(seconds: 3), hue: hue),
            //TODO: finish
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => externalKeyboard
      ? KeyboardGame(
          color: color,
          hueFocusNode: hueFocusNode!,
          hueController: hueController!,
          hueDialogBuilder: hueDialogBuilder,
          generateHue: () => setState(generateHue),
          scoreKeeper: scoreKeeper,
        )
      : NumPadGame(
          color: color,
          numPad: (void Function() submit) => NumPad(numPadController!, submit: submit),
          numPadVal: numPadController!.displayValue,
          hueDialogBuilder: hueDialogBuilder,
          scoreKeeper: scoreKeeper,
          generateHue: () => setState(generateHue),
        );
}
