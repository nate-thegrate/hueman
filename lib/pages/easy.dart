import 'gameplay_screen.dart';
import 'package:flutter/material.dart';
import 'package:super_hueman/reference.dart';

class EasyMode extends StatefulWidget {
  const EasyMode({super.key});

  @override
  State<EasyMode> createState() => _EasyModeState();
}

class _EasyModeState extends State<EasyMode> {
  final hueField = FocusNode();
  final hueController = TextEditingController();

  int hue = rng.nextInt(6) * 60;
  int get guess => hueController.value.toInt();
  void generateHue() {
    int newHue = rng.nextInt(5) * 60;
    if (newHue >= hue) {
      newHue += 60;
    }
    hue = newHue;
  }

  Color get c => HSVColor.fromAHSV(1, hue.toDouble(), 1, 1).toColor();
  Color get text => contrastWith(c);

  @override
  Widget build(BuildContext context) {
    submit() async {
      await showDialog(
        context: context,
        builder: gradeBuilder(
          (hue == guess) ? "Nice work!" : "Incorrect…",
          guess,
          hue,
          Container(
            decoration: BoxDecoration(
                border: Border.all(color: c, width: 4), color: contrastWith(c).withAlpha(0x40)),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                colorName(c)!, // ?? "#${c.toString().substring(10, 16)}",
                style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ),
      );
      setState(generateHue);
      hueController.clear();
      hueField.requestFocus();
    }

    return GameScreen(
      color: c,
      text: text,
      hueField: hueField,
      hueController: hueController,
      submit: submit,
      textFormatFunction: textFormatFunction,
    );
  }
}
