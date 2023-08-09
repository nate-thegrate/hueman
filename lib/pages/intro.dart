import 'gameplay_screen.dart';
import 'package:flutter/material.dart';
import 'package:super_hueman/reference.dart';

class IntroMode extends StatefulWidget {
  const IntroMode({super.key});

  @override
  State<IntroMode> createState() => _IntroModeState();
}

class _IntroModeState extends State<IntroMode> {
  final hueField = FocusNode();
  final hueController = TextEditingController();

  late int hue;
  int get guess => hueController.value.toInt();
  final List<int> hueChoices = [0, 60, 120, 180, 240, 300];
  final List<int> recentChoices = [];
  void generateHue() {
    hue = hueChoices.removeAt(rng.nextInt(hueChoices.length));
    if (recentChoices.length > 2) {
      hueChoices.add(recentChoices.removeAt(0));
    }
    recentChoices.add(hue);
  }

  Color get color => hsv(hue, 1, 1);

  String colorName(Color c) => {
        "Color(0xffff0000)": "red",
        "Color(0xffffff00)": "yellow",
        "Color(0xff00ff00)": "green",
        "Color(0xff00ffff)": "cyan",
        "Color(0xff0000ff)": "blue",
        "Color(0xffff00ff)": "magenta",
      }[c.toString()]!;

  @override
  void initState() {
    super.initState();
    generateHue();
  }

  Widget get graphic => Container(
        decoration: BoxDecoration(
            border: Border.all(color: color, width: 4), color: contrastWith(color).withAlpha(0x40)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            colorName(color),
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    submit() async {
      await showDialog(
        context: context,
        builder: (context) => HueDialog(
          (hue == guess) ? "Nice work!" : "Incorrect…",
          guess,
          hue,
          graphic,
        ),
      );
      setState(generateHue);
      hueController.clear();
      hueField.requestFocus();
    }

    return GameScreen(
      color: color,
      hueField: hueField,
      hueController: hueController,
      submit: submit,
    );
  }
}
