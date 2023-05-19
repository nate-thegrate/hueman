import 'dart:math';
import 'gameplay_screen.dart';
import 'package:flutter/material.dart';
import 'package:super_hueman/reference.dart';

class MasterMode extends StatefulWidget {
  const MasterMode({super.key});

  @override
  State<MasterMode> createState() => _MasterModeState();
}

class _MasterModeState extends State<MasterMode> {
  var hueField = FocusNode();
  var hueController = TextEditingController();

  int hue = rng.nextInt(360);
  double saturation = 1 - rng.nextDouble() * 2 / 3;
  double get value => 4 / 3 - saturation;
  int get guess => hueController.value.toInt();

  int get offBy {
    int diff(int a, int b) => (a - b).abs();
    final int hueDiff = diff(hue, guess);
    return min(hueDiff, diff(hueDiff, 360));
  }

  int get accuracy => ((1 - offBy / 180) * 100).round();
  void generateColor() {
    int newHue = rng.nextInt(300);
    if (newHue + 30 >= hue) {
      newHue += 60;
    }
    hue = newHue;
    saturation = 1 - rng.nextDouble() * 2 / 3;
  }

  Color get c => HSVColor.fromAHSV(1, hue.toDouble(), saturation, value).toColor();
  Color get textColor => contrastWith(c);

  String get text => (offBy == 0)
      ? "AMAZING!"
      : (offBy <= 10)
          ? "Great job!"
          : (offBy <= 20)
              ? "Nicely done."
              : "oof…";

  submit() async {
    await showDialog(
      context: context,
      builder: gradeBuilder(text, guess, hue, percentGrade(accuracy, c)),
    );
    setState(generateColor);
    hueController.clear();
    hueField.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return GameScreen(
      color: c,
      text: textColor,
      hueField: hueField,
      hueController: hueController,
      submit: submit,
      textFormatFunction: textFormatFunction,
    );
  }
}
