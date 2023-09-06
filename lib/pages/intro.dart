import 'package:super_hueman/pages/score.dart';
import 'package:super_hueman/pages/hue_typing_game.dart';
import 'package:super_hueman/save_data.dart';
import 'package:super_hueman/structs.dart';
import 'package:super_hueman/widgets.dart';

import 'package:flutter/material.dart';

class IntroMode extends StatefulWidget {
  final int numColors;
  const IntroMode(this.numColors, {super.key});

  @override
  State<IntroMode> createState() => _IntroModeState();
}

// TODO: TutorialScoreKeeper

class IntroScoreKeeper implements ScoreKeeper {
  int round = 0;
  int numCorrect = 0;

  final Stopwatch stopwatch = Stopwatch();

  final int numColors;
  final Function scoring;
  IntroScoreKeeper({required this.numColors, required this.scoring});

  @override
  void scoreTheRound() => scoring();

  @override
  void roundCheck(BuildContext context) {
    if (round == 29) {
      Navigator.pushReplacement(
          context, MaterialPageRoute<void>(builder: (context) => ScoreScreen(this)));
    }
  }

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
  Pages get page => {
        3: Pages.intro3,
        6: Pages.intro6,
        12: Pages.intro12,
      }[numColors]!;
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

  late final IntroScoreKeeper? scoreKeeper;
  void giveScore() {
    if (guess == hue) scoreKeeper?.numCorrect++;
    scoreKeeper?.round++;
  }

  void generateHue() {
    numPadController?.clear();
    hue = hueChoices.removeAt(rng.nextInt(hueChoices.length));
    if (recentChoices.length >= widget.numColors ~/ 2) {
      hueChoices.add(recentChoices.removeAt(0));
    }
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
    scoreKeeper =
        casualMode ? null : IntroScoreKeeper(scoring: giveScore, numColors: widget.numColors);
    scoreKeeper?.stopwatch.start();
    hueChoices.addAll([for (int i = 0; i < 360; i += 360 ~/ widget.numColors) i]);
    generateHue();
    hueFocusNode?.requestFocus();
  }

  @override
  void dispose() {
    scoreKeeper?.stopwatch.stop();
    super.dispose();
  }

  Widget hueDialogBuilder(context) => HueDialog(
        (hue == guess) ? 'Nice work!' : 'Incorrect…',
        guess,
        hue,
        ColorNameBox(color),
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
