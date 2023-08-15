import 'package:super_hueman/pages/game_end.dart';
import 'package:super_hueman/structs.dart';
import 'package:super_hueman/widgets.dart';

import 'package:flutter/material.dart';

class IntroMode extends StatefulWidget {
  final int numColors;
  const IntroMode(this.numColors, {super.key});

  @override
  State<IntroMode> createState() => _IntroModeState();
}

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
          context, MaterialPageRoute<void>(builder: (context) => GameEnd(this)));
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
        '(${colorsPerMinute.toStringAsFixed(1)} colors per minute) \u00d7 (${accuracy.round()}% accuracy)',
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
  final hueFocusNode = FocusNode();
  final hueController = TextEditingController();

  late int hue;
  int get guess => hueController.value.toInt();
  final List<int> hueChoices = [];
  final List<int> recentChoices = [];

  late final IntroScoreKeeper? scoreKeeper;
  void giveScore() {
    if (guess == hue) scoreKeeper?.numCorrect++;
    scoreKeeper?.round++;
  }

  void generateHue() {
    hue = hueChoices.removeAt(rng.nextInt(hueChoices.length));
    if (recentChoices.length >= widget.numColors ~/ 2) {
      hueChoices.add(recentChoices.removeAt(0));
    }
    recentChoices.add(hue);
  }

  Color get color => hsv(hue, 1, 1);

  @override
  void initState() {
    super.initState();
    scoreKeeper =
        casualMode ? null : IntroScoreKeeper(scoring: giveScore, numColors: widget.numColors);
    scoreKeeper?.stopwatch.start();
    hueChoices.addAll([for (int i = 0; i < 360; i += 360 ~/ widget.numColors) i]);
    generateHue();
    hueFocusNode.requestFocus();
  }

  @override
  void dispose() {
    scoreKeeper?.stopwatch.stop();
    super.dispose();
  }

  Widget get graphic => Container(
        decoration:
            BoxDecoration(border: Border.all(color: color, width: 4), color: Colors.black38),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            colorNames[color.hexCode]!,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      );

  String get text => (hue == guess) ? 'Nice work!' : 'Incorrect…';

  @override
  Widget build(BuildContext context) {
    return GameScreen(
      color: color,
      hueFocusNode: hueFocusNode,
      hueController: hueController,
      hueDialogBuilder: (context) => HueDialog(text, guess, hue, graphic),
      generateHue: () => setState(generateHue),
      scoreKeeper: scoreKeeper,
    );
  }
}
