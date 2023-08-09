import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:super_hueman/reference.dart';

TextEditingValue textFormatFunction(TextEditingValue oldValue, TextEditingValue newValue) =>
    (newValue.toInt() < 360)
        ? newValue
        : const TextEditingValue(text: "359", selection: TextSelection.collapsed(offset: 3));

class GameScreen extends StatelessWidget {
  final Color color;
  final FocusNode hueField;
  final TextEditingController hueController;
  final void Function() submit;
  const GameScreen({
    required this.color,
    required this.hueField,
    required this.hueController,
    required this.submit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = contrastWith(color);
    final backButton = TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white70,
        backgroundColor: Colors.black12,
      ),
      onPressed: () => context.goto(Pages.mainMenu),
      child: const Padding(
        padding: EdgeInsets.all(8),
        child: Text(
          "back",
          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
        ),
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
          foregroundColor: textColor,
        ),
        child: const Padding(
          padding: EdgeInsets.fromLTRB(0, 8, 0, 10),
          child: Text("submit", style: TextStyle(fontSize: 16)),
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
          vspace(50),
          textField,
          vspace(25),
          submitButton,
          vspace(100),
        ],
      ),
    ));
  }
}

class AnswerFeedback extends StatelessWidget {
  final int val;
  final String text;
  const AnswerFeedback(this.val, {required this.text, super.key});
  static const TextStyle _style = TextStyle(fontSize: 16);

  @override
  Widget build(BuildContext context) => Row(children: [
        filler,
        SizedBox(width: 130, child: Text(text, textAlign: TextAlign.end, style: _style)),
        const SizedBox(width: 10),
        Text(val.toString(), style: _style),
        const Expanded(flex: 3, child: empty),
      ]);
}

class PercentGrade extends StatefulWidget {
  final int accuracy;
  final Color color;
  final bool perfect;
  const PercentGrade(this.accuracy, this.color, {super.key}) : perfect = accuracy == 100;
  static const double width = 200;

  @override
  State<PercentGrade> createState() => _PercentGradeState();
}

class _PercentGradeState extends State<PercentGrade> {
  late final Ticker? ticker;
  late Color c;

  @override
  void initState() {
    super.initState();
    c = widget.color;
    ticker = (widget.perfect) ? Ticker((_) => setState(() => c = epicColor)) : null;
    ticker?.start();
  }

  @override
  void dispose() {
    ticker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget line = Container(
      color: (widget.perfect) ? contrastWith(c) : c,
      width: widget.accuracy * PercentGrade.width / 200,
      height: (1 + widget.accuracy / 20).roundToDouble(),
    );
    final Widget fullLine = Row(children: [line, filler, line]);
    final TextStyle style = widget.perfect
        ? const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.black,
            shadows: [Shadow(blurRadius: 4, color: Colors.white)],
          )
        : const TextStyle(
            fontSize: 18,
            shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
          );
    return Container(
      margin: EdgeInsets.all(widget.perfect ? 20 : 10),
      width: PercentGrade.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          fullLine,
          Container(
            color: widget.perfect ? c : c.withAlpha(0xff * widget.accuracy ~/ 200),
            child: Container(
              constraints: BoxConstraints.expand(height: widget.perfect ? 60 : 30),
              alignment: Alignment.center,
              child: Text(
                "${widget.accuracy}%",
                style: style,
              ),
            ),
          ),
          fullLine,
        ],
      ),
    );
  }
}

class HueDialog extends StatefulWidget {
  final String text;
  final int guess, hue;
  final Widget graphic;
  final bool isSuper;
  const HueDialog(this.text, this.guess, this.hue, this.graphic, {super.key})
      : isSuper = text == "SUPER!";

  @override
  State<HueDialog> createState() => _HueDialogState();
}

class _HueDialogState extends State<HueDialog> {
  late final Ticker? ticker;

  void _listenForEnter(RawKeyEvent value) {
    if (value.logicalKey.keyLabel.contains("Enter")) {
      yeetListener(_listenForEnter);
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    ticker = widget.isSuper ? epicSetup(setState) : null;
    sleep(0.2).then((_) => addListener(_listenForEnter));
  }

  @override
  void dispose() {
    yeetListener(_listenForEnter);
    ticker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.text,
        textAlign: TextAlign.center,
        style: widget.isSuper
            ? TextStyle(
                shadows: const [Shadow(blurRadius: 8)],
                fontSize: 42,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                color: epicColor)
            : null,
      ),
      elevation: widget.isSuper ? 25 : null,
      shadowColor: widget.isSuper ? epicColor : null,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.graphic,
          const SizedBox(height: 20),
          AnswerFeedback(widget.guess, text: 'Your answer:'),
          AnswerFeedback(widget.hue, text: 'Correct answer:'),
        ],
      ),
    );
  }
}
