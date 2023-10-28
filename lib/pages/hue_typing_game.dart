/// Contains resources used in `intro.dart` and `intense.dart`
library;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:hueman/data/super_color.dart';
import 'package:hueman/data/super_container.dart';
import 'package:hueman/data/super_state.dart';
import 'package:hueman/data/super_text.dart';
import 'package:hueman/pages/intense_master.dart';
import 'package:hueman/data/save_data.dart';
import 'package:hueman/data/structs.dart';
import 'package:hueman/data/widgets.dart';
import 'package:hueman/pages/intro.dart';

const double _gradeWidth = 200;

class _NumberButton extends StatelessWidget {
  const _NumberButton(int i, {required this.controller, required this.submit})
      : number = i == 10 ? 0 : i + 1;
  final int number;
  final NumPadController controller;
  final void Function() submit;

  static const color = SuperColors.white80;
  Widget get child => switch (number) {
        10 => const Icon(Icons.backspace, color: color, size: 32),
        12 => const Icon(Icons.done, color: color, size: 36),
        _ => Text(
            number.toString(),
            style: const SuperStyle.sans(size: 32, color: color),
          ),
      };

  void type() => controller.type(number);

  void Function()? get onPressed => switch (number) {
        10 => controller.backspace,
        12 when controller.displayValue.isEmpty => null,
        12 => submit,
        _ => type,
      };

  void Function()? get onLongPress => number == 10 ? controller.clear : null;

  ButtonStyle get style => TextButton.styleFrom(
        backgroundColor: Colors.black54,
        shape: const BeveledRectangleBorder(),
      );

  @override
  Widget build(BuildContext context) {
    return SuperContainer(
      width: 125,
      height: 75,
      padding: const EdgeInsets.all(2),
      child: TextButton(
        style: style,
        onPressed: onPressed,
        onLongPress: onLongPress,
        child: child,
      ),
    );
  }
}

class NumPad extends StatelessWidget {
  const NumPad(this.numPadController, {required this.submit, super.key});
  final NumPadController numPadController;
  final void Function() submit;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int row = 0; row < 4; row++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = row * 3; i < row * 3 + 3; i++)
                _NumberButton(i, controller: numPadController, submit: submit),
            ],
          )
      ],
    );
  }
}

class NumPadController {
  NumPadController(this.setState);
  String displayValue = '';
  final StateSetter setState;

  int get hue => int.parse(displayValue);

  void type(int number) => setState(() {
        if (displayValue.length < 3) {
          displayValue += number.toString();
          if (hue >= 360) displayValue = '359';
        }
      });

  void backspace() => setState(() {
        if (displayValue.isNotEmpty) {
          displayValue = displayValue.substring(0, displayValue.length - 1);
        }
      });

  void clear() => displayValue = '';
}

class _RankBars extends StatelessWidget {
  const _RankBars(this.rank, {required this.color});
  final int rank;
  final Color color;

  static const duration = Duration(milliseconds: 750);

  static const List<Color> barColors = [
    Colors.black12,
    Colors.white12,
    Colors.white24,
    Colors.white38,
  ];

  @override
  Widget build(BuildContext context) {
    final int activeIndex = rank ~/ 25 + 1;
    final double screenHeight = context.screenHeight;

    double barHeight(int i) => (i < activeIndex)
        ? screenHeight
        : (i == activeIndex)
            ? screenHeight * (rank % 25) / 25
            : 0;

    return Stack(
      children: [
        for (int i = 0; i < 5; i++)
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedSize(
              duration: duration,
              curve: curve,
              child: AnimatedContainer(
                width: 25,
                duration: duration,
                curve: curve,
                color: i == 4 ? color : barColors[i],
                height: barHeight(i),
              ),
            ),
          ),
      ],
    );
  }
}

class _AnswerFeedback extends StatelessWidget {
  const _AnswerFeedback(this.val, {required this.text});
  final int val;
  final String text; //, super.key});
  static const SuperStyle style = SuperStyle.sans(size: 16);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        SizedBox(width: 130, child: Text(text, textAlign: TextAlign.end, style: style)),
        const FixedSpacer.horizontal(10),
        Text(val.toString(), style: style),
        const Spacer(flex: 3),
      ],
    );
  }
}

class _PercentBar extends StatefulWidget {
  const _PercentBar([this.width = _gradeWidth, this.color = Colors.black]);
  final Color color;
  final double width;
  @override
  State<_PercentBar> createState() => _PercentBarState();
}

class _PercentBarState extends State<_PercentBar> {
  double width = 0;

  @override
  void initState() {
    super.initState();
    sleep(.1, then: () => setState(() => width = widget.width / 2));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: curve,
      color: widget.color,
      width: width,
      height: width / (widget.color == Colors.black ? 10 : 15),
    );
  }
}

class PercentGrade extends StatelessWidget {
  const PercentGrade({
    required this.accuracy,
    required this.color,
    super.key,
  });
  final int accuracy;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final Widget line = _PercentBar(accuracy * 2, color);
    final Widget fullLine = Row(children: [line, const Spacer(), line]);
    const style = SuperStyle.sans(
      size: 18,
      shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
    );
    return SuperContainer(
      margin: const EdgeInsets.all(10),
      width: _gradeWidth,
      height: 50,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          fullLine,
          ColoredBox(
            color: color.withAlpha(0xff * accuracy ~/ 200),
            child: SuperContainer(
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

class HundredPercentGrade extends StatefulWidget {
  const HundredPercentGrade({super.key});

  @override
  State<HundredPercentGrade> createState() => _HundredPercentGradeState();
}

class _HundredPercentGradeState extends State<HundredPercentGrade> {
  late final Ticker epicHues;
  SuperColor color = epicColor;
  double lineWidth = 0;

  @override
  void initState() {
    super.initState();
    epicHues = Ticker((_) => setState(() => color = epicColor))..start();
  }

  @override
  void dispose() {
    epicHues.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const line = _PercentBar();
    const fullLine = Row(children: [line, Spacer(), line]);
    const style = SuperStyle.sans(weight: 800, size: 30, color: Colors.black);

    return SuperContainer(
      margin: const EdgeInsets.all(20),
      width: _gradeWidth,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          fullLine,
          ColoredBox(
            color: color,
            child: const SuperContainer(
              constraints: BoxConstraints.expand(height: 60),
              alignment: Alignment.center,
              child: Text('100', style: style),
            ),
          ),
          fullLine,
        ],
      ),
    );
  }
}

class HueDialog extends StatefulWidget {
  const HueDialog(this.text, this.guess, this.hue, this.graphic, {super.key})
      : isSuper = text == 'SUPER!';
  final String text;
  final int guess, hue;
  final Widget graphic;
  final bool isSuper;

  @override
  State<HueDialog> createState() => _HueDialogState();
}

class _HueDialogState extends State<HueDialog> {
  late final Ticker? epicHues;

  void _listenForEnter(RawKeyEvent value) {
    if (value.logicalKey.keyLabel.contains('Enter')) {
      yeetListener(_listenForEnter);
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    epicHues = widget.isSuper ? epicSetup(setState) : null;
    sleep(
      widget.isSuper ? 1.5 : 0.2,
      then: () {
        addListener(_listenForEnter);
        setState(() => unclickable = false);
      },
    );
  }

  @override
  void dispose() {
    yeetListener(_listenForEnter);
    epicHues?.dispose();
    super.dispose();
  }

  late final bool isSuper = widget.isSuper;
  late bool unclickable = isSuper;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AlertDialog(
          title: Text(
            widget.text,
            textAlign: TextAlign.center,
            style: isSuper
                ? SuperStyle.sans(
                    shadows: const [Shadow(blurRadius: 8)],
                    size: 42,
                    italic: true,
                    weight: 800,
                    color: epicColor,
                  )
                : null,
          ),
          elevation: isSuper ? epicSine * 10 : null,
          shadowColor: isSuper ? epicColor : null,
          surfaceTintColor: isSuper ? epicColor : null,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.graphic,
              const FixedSpacer(20),
              _AnswerFeedback(widget.guess, text: 'Your answer:'),
              _AnswerFeedback(widget.hue, text: 'Correct answer:'),
              if (!hueMaster && isSuper) ...[
                const FixedSpacer(20),
                Text(
                  'all game modes\nunlocked!',
                  textAlign: TextAlign.center,
                  style: SuperStyle.sans(
                    color: epicColor,
                    weight: 800,
                    size: 24,
                    shadows: const [Shadow(color: Colors.black, blurRadius: 5)],
                  ),
                ),
              ]
            ],
          ),
        ),
        if (unclickable) const SuperContainer(color: Colors.transparent),
      ],
    );
  }
}

class _GameScreen extends StatelessWidget {
  const _GameScreen(this.userInput, this.image, this.color, this.scoreKeeper);
  final List<Widget> userInput;
  final Widget? image;
  final Color color;
  final ScoreKeeper? scoreKeeper;

  @override
  Widget build(BuildContext context) {
    final sk = scoreKeeper;
    final bars = (sk is MasterScoreKeeper) ? _RankBars(sk.rank, color: color) : empty;

    final double colorBoxWidth = context.screenWidth * 0.75;
    final bool littleBitSquished =
        image != null && context.screenHeight < 1200 && !externalKeyboard;

    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          bars,
          Expanded(
            child: Column(
              children: <Widget>[
                const Spacer(),
                if (sk is! TutorialScoreKeeper) const GoBack(),
                const Spacer(),
                if (image == null) ...[
                  SuperContainer(
                    width: colorBoxWidth,
                    height: min(colorBoxWidth, context.screenHeight - 600),
                    color: color,
                  )
                ] else ...[
                  image!,
                  if (!littleBitSquished) ...[
                    const Spacer(),
                    SuperContainer(width: colorBoxWidth, height: 150, color: color),
                  ],
                ],
                const Spacer(),
                const Text(
                  'What\'s the hue?',
                  textAlign: TextAlign.center,
                  style: SuperStyle.sans(size: 28, letterSpacing: 0),
                ),
                ...userInput,
                const Spacer(),
                scoreKeeper?.midRoundDisplay ?? empty,
                const Spacer(),
              ],
            ),
          ),
          bars,
        ],
      ),
      backgroundColor: (sk is MasterScoreKeeper)
          ? Color.lerp(SuperColors.darkBackground, Colors.black, (sk.rank ~/ 25) / 4)!
          : SuperColors.darkBackground,
    );
  }
}

class KeyboardGame extends StatelessWidget {
  const KeyboardGame({
    required this.color,
    required this.hueFocusNode,
    required this.hueController,
    required this.hueDialogBuilder,
    required this.scoreKeeper,
    required this.generateHue,
    this.image,
    super.key,
  });
  final Color color;
  final FocusNode hueFocusNode;
  final TextEditingController hueController;
  final WidgetBuilder hueDialogBuilder;
  final ScoreKeeper? scoreKeeper;
  final void Function() generateHue;
  final Widget? image;

  @override
  Widget build(BuildContext context) {
    void submit() => showDialog(context: context, builder: hueDialogBuilder).then((_) {
          scoreKeeper?.scoreTheRound();
          scoreKeeper?.roundCheck(context);
          generateHue();
          hueController.clear();
          hueFocusNode.requestFocus();
        });

    final hueValidation = TextInputFormatter.withFunction(
      (oldValue, newValue) => newValue.text.length > 3
          ? oldValue
          : newValue.toInt() < 360
              ? newValue
              : const TextEditingValue(
                  text: '359',
                  selection: TextSelection.collapsed(offset: 3),
                ),
    );

    return _GameScreen(
      [
        const FixedSpacer(20),
        SizedBox(
          width: 100,
          child: TextField(
            focusNode: hueFocusNode,
            controller: hueController,
            onSubmitted: (_) => submit(),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, hueValidation],
          ),
        ),
        const FixedSpacer(25),
        ElevatedButton(
            onPressed: submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: contrastWith(color),
            ),
            child: const Padding(
              padding: EdgeInsets.fromLTRB(0, 8, 0, 10),
              child: Text('submit', style: SuperStyle.sans(size: 16)),
            )),
        const Spacer(flex: 2),
      ],
      image,
      color,
      scoreKeeper,
    );
  }
}

class NumPadGame extends StatelessWidget {
  const NumPadGame({
    required this.color,
    required this.numPad,
    required this.numPadVal,
    required this.hueDialogBuilder,
    required this.scoreKeeper,
    required this.generateHue,
    this.image,
    super.key,
  });
  final Color color;
  final NumPad Function(void Function() submit) numPad;
  final String numPadVal;
  final WidgetBuilder hueDialogBuilder;
  final ScoreKeeper? scoreKeeper;
  final void Function() generateHue;
  final Widget? image;

  @override
  Widget build(BuildContext context) {
    void submit() => showDialog(context: context, builder: hueDialogBuilder).then((_) {
          scoreKeeper?.scoreTheRound();
          scoreKeeper?.roundCheck(context);
          generateHue();
        });

    return _GameScreen(
      [
        const Spacer(),
        Center(child: Text(numPadVal, style: const SuperStyle.sans(size: 32))),
        const Spacer(),
        numPad(submit),
      ],
      image,
      color,
      scoreKeeper,
    );
  }
}

class IntroGraphic extends StatefulWidget {
  const IntroGraphic({super.key, required this.hue, required this.guess});
  final int hue, guess;

  @override
  State<IntroGraphic> createState() => _IntroGraphicState();
}

class _IntroGraphicState extends State<IntroGraphic> {
  int step = 3;

  late final SuperColor color = SuperColor.hue(widget.hue);

  @override
  void initState() {
    super.initState();
    quickly(() => setState(() => step++));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ColorNameBox(color),
        MeasuringOrb(
          step: step,
          width: 100,
          duration: oneSec,
          lineColor: SuperColors.tintedDarkBackground,
          hue: widget.hue,
          guess: widget.guess,
        ),
      ],
    );
  }
}
