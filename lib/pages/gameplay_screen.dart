import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:super_hueman/reference.dart';

class GameScreen extends StatelessWidget {
  final Color color, text;
  final FocusNode hueField;
  final TextEditingController hueController;
  final void Function() submit;
  final TextEditingValue Function(TextEditingValue, TextEditingValue) textFormatFunction;
  const GameScreen({
    required this.color,
    required this.text,
    required this.hueField,
    required this.hueController,
    required this.submit,
    required this.textFormatFunction,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final backButton = TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white70,
        backgroundColor: Colors.black12,
      ),
      onPressed: () => context.goto(Pages.mainMenu),
      child: const Text(
        "back",
        style: TextStyle(fontWeight: FontWeight.normal),
      ),
    );
    final colorBox = Container(
      width: 300,
      height: 300,
      color: color,
    );
    final whatsTheHue = Text(
      'What\'s the hue?',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headlineMedium,
    );
    final textField = SizedBox(
      width: 100,
      child: TextField(
        focusNode: hueField,
        controller: hueController,
        onSubmitted: (_) => submit(),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(border: OutlineInputBorder()),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          TextInputFormatter.withFunction(textFormatFunction)
        ],
      ),
    );
    final submitButton = ElevatedButton(
        onPressed: submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: text,
        ),
        child: const Padding(
          padding: EdgeInsets.only(bottom: 2),
          child: Text("submit"),
        ));
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          backButton,
          vspace(50),
          colorBox,
          vspace(100),
          whatsTheHue,
          vspace(30),
          textField,
          vspace(20),
          submitButton,
          vspace(100),
        ],
      ),
    ));
  }
}

TextEditingValue textFormatFunction(TextEditingValue oldValue, TextEditingValue newValue) =>
    (newValue.toInt() < 360)
        ? newValue
        : const TextEditingValue(text: "359", selection: TextSelection.collapsed(offset: 3));

class AnswerFeedback extends StatelessWidget {
  final int val;
  final String text;
  const AnswerFeedback(this.val, {required this.text, super.key});

  @override
  Widget build(BuildContext context) => Row(children: [
        SizedBox(width: 130, child: Text(text, textAlign: TextAlign.end)),
        const SizedBox(width: 10),
        Text(val.toString()),
      ]);
}

Widget percentGrade(int accuracy, Color c) {
  const double width = 200;
  final bool perfect = accuracy == 100;
  final Widget line = Container(
    color: (perfect) ? contrastWith(c) : c,
    width: accuracy * width / 200,
    height: (1 + accuracy / 20).roundToDouble(),
  );
  final Widget fullLine = Row(children: [line, filler, line]);
  return SizedBox(
    width: width,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        fullLine,
        Container(
          color: perfect ? c : c.withAlpha(0xff * accuracy ~/ 200),
          child: Container(
            constraints: const BoxConstraints.expand(height: 30),
            alignment: Alignment.center,
            child: Text(
              "$accuracy%",
              style: TextStyle(
                fontWeight: perfect ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
                color: perfect ? contrastWith(c) : null,
              ),
            ),
          ),
        ),
        fullLine,
      ],
    ),
  );
}

gradeBuilder(String text, int guess, int hue, [Widget graphic = empty]) =>
    (BuildContext context) => AlertDialog(
          title: Text(text, textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              graphic,
              const SizedBox(height: 20),
              AnswerFeedback(guess, text: 'Your answer:'),
              AnswerFeedback(hue, text: 'Correct answer:'),
            ],
          ),
        );
