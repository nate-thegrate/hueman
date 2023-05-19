import 'dart:math';
import 'gameplay_screen.dart';
import 'package:flutter/material.dart';
import 'package:super_hueman/reference.dart';

class IntenseMode extends StatefulWidget {
  const IntenseMode({super.key});

  @override
  State<IntenseMode> createState() => _IntenseModeState();
}

class _IntenseModeState extends State<IntenseMode> {
  var hueField = FocusNode();
  var hueController = TextEditingController();

  int hue = rng.nextInt(360);
  int get guess => hueController.value.toInt();

  int get offBy {
    int diff(int a, int b) => (a - b).abs();
    final int hueDiff = diff(hue, guess);
    return min(hueDiff, diff(hueDiff, 360));
  }

  int get accuracy => ((1 - offBy / 180) * 100).round();
  void generateHue() {
    int newHue = rng.nextInt(300);
    if (newHue + 30 >= hue) {
      newHue += 60;
    }
    hue = newHue;
  }

  Color get c => HSVColor.fromAHSV(1, hue.toDouble(), 1, 1).toColor();
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
    setState(generateHue);
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
