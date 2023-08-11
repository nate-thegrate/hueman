import 'dart:math';
import 'gameplay_screen.dart';
import 'package:flutter/material.dart';
import 'package:super_hueman/reference.dart';

class IntenseMode extends StatefulWidget {
  final bool master;
  const IntenseMode([String? master, Key? key])
      : master = master == "master",
        super(key: key);

  @override
  State<IntenseMode> createState() => _IntenseModeState();
}

class _IntenseModeState extends State<IntenseMode> {
  var hueFocusNode = FocusNode();
  var hueController = TextEditingController();

  int hue = rng.nextInt(360);
  double saturation = 1;
  double get value => widget.master ? 4 / 3 - saturation : 1;
  int get guess => hueController.value.toInt();

  int get offBy {
    int diff(int a, int b) => (a - b).abs();
    final int hueDiff = diff(hue, guess);
    return min(hueDiff, diff(hueDiff, 360));
  }

  int get accuracy => (pow(1 - offBy / 180, 2) * 100).round();
  void generateHue() {
    int newHue = rng.nextInt(300);
    if (newHue + 30 >= hue) {
      newHue += 60;
    }
    hue = newHue;
    hue = 0;
    if (widget.master) {
      saturation = 1 - rng.nextDouble() * 2 / 3;
    }
  }

  Color get color => hsv(hue, saturation, value);

  String get text => (offBy == 0)
      ? "SUPER!"
      : (offBy <= 1)
          ? "Just 1 away?!"
          : (offBy <= 5)
              ? "Fantastic!"
              : (offBy <= 10)
                  ? "Great job!"
                  : (offBy <= 20)
                      ? "Nicely done."
                      : "oof…";

  Widget get graphic =>
      offBy == 0 ? const HundredPercentGrade() : PercentGrade(accuracy: accuracy, color: color);

  @override
  Widget build(BuildContext context) {
    return GameScreen(
      color: color,
      hueFocusNode: hueFocusNode,
      hueController: hueController,
      hueDialogBuilder: (context) => HueDialog(text, guess, hue, graphic),
      generateHue: () => setState(generateHue),
    );
  }
}
