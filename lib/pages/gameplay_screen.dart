import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:super_hueman/reference.dart';

class GameScreen extends StatelessWidget {
  final Color color;
  final FocusNode hueFocusNode;
  final TextEditingController hueController;
  final WidgetBuilder hueDialogBuilder;
  final void Function() generateHue;
  const GameScreen({
    required this.color,
    required this.hueFocusNode,
    required this.hueController,
    required this.hueDialogBuilder,
    required this.generateHue,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    void submit() async {
      await showDialog(context: context, builder: hueDialogBuilder);
      generateHue();
      hueController.clear();
      hueFocusNode.requestFocus();
    }

    TextEditingValue textFormatFunction(TextEditingValue oldValue, TextEditingValue newValue) {
      if (newValue.toInt() >= 100 && autoSubmit) submit();
      return (newValue.toInt() < 360)
          ? newValue
          : const TextEditingValue(text: '359', selection: TextSelection.collapsed(offset: 3));
    }

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
          'back',
          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
        ),
      ),
    );
    final colorBox = Container(width: 300, height: 300, color: color);
    final whatsTheHue = Text(
      'What\'s the hue?',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headlineMedium,
    );
    final textField = SizedBox(
      width: 100,
      child: TextField(
        focusNode: hueFocusNode,
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
          child: Text('submit', style: TextStyle(fontSize: 16)),
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

class _AnswerFeedback extends StatelessWidget {
  final int val;
  final String text;
  const _AnswerFeedback(this.val, {required this.text}); //, super.key});
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

const double _gradeWidth = 200;

class _PercentBar extends StatefulWidget {
  final Color color;
  final double width;
  const _PercentBar([this.width = _gradeWidth, this.color = Colors.black]);
  @override
  State<_PercentBar> createState() => _PercentBarState();
}

class _PercentBarState extends State<_PercentBar> {
  double width = 0;

  @override
  void initState() {
    super.initState();
    sleep(.1).then((_) => setState(() => width = widget.width / 2));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      color: widget.color,
      width: width,
      height: width / (widget.color == Colors.black ? 10 : 15),
    );
  }
}

class HundredPercentGrade extends StatefulWidget {
  const HundredPercentGrade({super.key});

  @override
  State<HundredPercentGrade> createState() => _HundredPercentGradeState();
}

class _HundredPercentGradeState extends State<HundredPercentGrade> {
  late final Ticker ticker;
  Color c = epicColor;
  double lineWidth = 0;

  @override
  void initState() {
    super.initState();
    ticker = Ticker((_) => setState(() => c = epicColor));
    ticker.start();
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Widget line = _PercentBar();
    const Widget fullLine = Row(children: [line, filler, line]);
    const TextStyle style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 30,
      color: Colors.black,
    );

    return Container(
      margin: const EdgeInsets.all(20),
      width: _gradeWidth,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          fullLine,
          Container(
            color: c,
            child: Container(
              constraints: const BoxConstraints.expand(height: 60),
              alignment: Alignment.center,
              child: const Text('100', style: style),
            ),
          ),
          fullLine,
        ],
      ),
    );
  }
}

class PercentGrade extends StatelessWidget {
  final int accuracy;
  final Color color;

  const PercentGrade({
    required this.accuracy,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Widget line = _PercentBar(accuracy * 2, color);
    final Widget fullLine = Row(children: [line, filler, line]);
    const TextStyle style = TextStyle(
      fontSize: 18,
      shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
    );
    return Container(
      margin: const EdgeInsets.all(10),
      width: _gradeWidth,
      height: 50,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          fullLine,
          Container(
            color: color.withAlpha(0xff * accuracy ~/ 200),
            child: Container(
              constraints: const BoxConstraints.expand(height: 30),
              alignment: Alignment.center,
              child: Text('$accuracy%', style: style),
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
      : isSuper = text == 'SUPER!';

  @override
  State<HueDialog> createState() => _HueDialogState();
}

class _HueDialogState extends State<HueDialog> {
  late final Ticker? ticker;

  void _listenForEnter(RawKeyEvent value) {
    if (value.logicalKey.keyLabel.contains('Enter')) {
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
      // elevation: widget.isSuper ? (30 - ((epicIndex % 60) - 30).abs()) / 1.5 : null,
      elevation: widget.isSuper ? (sin((epicHue) / 360 * 2 * pi * 6) + 1) * 10 : null,
      shadowColor: widget.isSuper ? epicColor : null,
      surfaceTintColor: widget.isSuper ? epicColor : null,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.graphic,
          const SizedBox(height: 20),
          _AnswerFeedback(widget.guess, text: 'Your answer:'),
          _AnswerFeedback(widget.hue, text: 'Correct answer:'),
        ],
      ),
    );
  }
}
