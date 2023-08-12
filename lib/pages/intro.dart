import 'gameplay_screen.dart';
import 'package:flutter/material.dart';
import 'package:super_hueman/reference.dart';

class IntroMode extends StatefulWidget {
  final int numColors;
  const IntroMode(this.numColors, {super.key});

  @override
  State<IntroMode> createState() => _IntroModeState();
}

class _IntroModeState extends State<IntroMode> {
  final hueFocusNode = FocusNode();
  final hueController = TextEditingController();

  late int hue;
  int get guess => hueController.value.toInt();
  final List<int> hueChoices = [];
  final List<int> recentChoices = [];
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
    hueChoices.addAll([for (int i = 0; i < 360; i += 360 ~/ widget.numColors) i]);
    generateHue();
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
    );
  }
}
