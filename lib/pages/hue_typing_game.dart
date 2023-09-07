/// Contains resources used in `intro.dart` and `intense.dart`

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:super_hueman/pages/intense_master.dart';
import 'package:super_hueman/save_data.dart';
import 'package:super_hueman/structs.dart';
import 'package:super_hueman/widgets.dart';

const double _gradeWidth = 200;

class _NumberButton extends StatelessWidget {
  final int number;
  final NumPadController controller;
  final void Function() submit;
  const _NumberButton(int i, {required this.controller, required this.submit})
      : number = i == 10 ? 0 : i + 1;

  Icon? get icon => {
        10: const Icon(Icons.backspace, color: SuperColors.white80, size: 32),
        12: const Icon(Icons.done, color: SuperColors.white80, size: 36),
      }[number];

  Widget get child =>
      icon ??
      Text(
        number.toString(),
        style: const TextStyle(fontSize: 32, color: SuperColors.white80),
      );

  void onPressed() {
    switch (number) {
      case 10:
        controller.backspace();
      case 12:
        submit();
      default:
        controller.type(number);
        if (autoSubmit && controller.displayValue.length == 3) submit();
    }
  }

  bool get disabled => number == 12 && controller.displayValue == '';

  void onLongPress() => controller.clear();

  @override
  Widget build(BuildContext context) => Container(
        width: 125,
        height: 100,
        padding: const EdgeInsets.all(2),
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.black54,
            shape: const BeveledRectangleBorder(),
          ),
          onPressed: disabled ? null : onPressed,
          onLongPress: number == 10 ? onLongPress : null,
          child: child,
        ),
      );
}

class NumPad extends StatelessWidget {
  final NumPadController numPadController;
  final void Function() submit;
  const NumPad(this.numPadController, {required this.submit, super.key});

  @override
  Widget build(BuildContext context) => Column(
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

class NumPadController {
  String displayValue = '';
  final StateSetter setState;
  NumPadController(this.setState);

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

  void clear() => setState(() => displayValue = '');
}

class _RankBars extends StatelessWidget {
  final int rank;
  final Color color;
  const _RankBars(this.rank, {required this.color});

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
    final double screenHeight = MediaQuery.of(context).size.height;

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
  final int val;
  final String text;
  const _AnswerFeedback(this.val, {required this.text}); //, super.key});
  static const TextStyle _style = TextStyle(fontSize: 16);

  @override
  Widget build(BuildContext context) => Row(children: [
        const Spacer(),
        SizedBox(width: 130, child: Text(text, textAlign: TextAlign.end, style: _style)),
        const SizedBox(width: 10),
        Text(val.toString(), style: _style),
        const Expanded(flex: 3, child: empty),
      ]);
}

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
    sleep(.1, then: () => setState(() => width = widget.width / 2));
  }

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: curve,
        color: widget.color,
        width: width,
        height: width / (widget.color == Colors.black ? 10 : 15),
      );
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
    final Widget fullLine = Row(children: [line, const Spacer(), line]);
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
    const Widget line = _PercentBar();
    const Widget fullLine = Row(children: [line, Spacer(), line]);
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
            color: color,
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
  Widget build(BuildContext context) => Stack(
        children: [
          AlertDialog(
            title: Text(
              widget.text,
              textAlign: TextAlign.center,
              style: isSuper
                  ? TextStyle(
                      shadows: const [Shadow(blurRadius: 8)],
                      fontSize: 42,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
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
                ...(hueMaster || !isSuper)
                    ? []
                    : [
                        const FixedSpacer(20),
                        Text(
                          'all game modes\nunlocked!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: epicColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            shadows: const [Shadow(color: Colors.black, blurRadius: 5)],
                          ),
                        ),
                      ]
              ],
            ),
          ),
          unclickable
              ? Container(
                  constraints: const BoxConstraints.expand(),
                  color: Colors.transparent,
                )
              : empty,
        ],
      );
}

class _GameScreen extends StatelessWidget {
  final List<Widget> userInput;
  final Widget? image;
  final Color color;
  final ScoreKeeper? scoreKeeper;
  const _GameScreen(this.userInput, this.image, this.color, this.scoreKeeper);

  @override
  Widget build(BuildContext context) {
    final sk = scoreKeeper;
    final bars = (sk is MasterScoreKeeper) ? _RankBars(sk.rank, color: color) : empty;

    final double colorBoxWidth = context.screenWidth * 2 / 3;
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
                const GoBack(),
                const Spacer(),
                ...image == null
                    ? [
                        Container(
                          width: colorBoxWidth,
                          height: min(colorBoxWidth, context.screenHeight - 700),
                          color: color,
                        )
                      ]
                    : [
                        image!,
                        ...littleBitSquished
                            ? []
                            : [
                                const Spacer(),
                                Container(width: colorBoxWidth, height: 150, color: color),
                              ],
                      ],
                const Spacer(),
                const Text(
                  'What\'s the hue?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Segoe UI',
                    fontSize: 28,
                    letterSpacing: 0,
                  ),
                ),
                ...userInput,
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
  final Color color;
  final FocusNode hueFocusNode;
  final TextEditingController hueController;
  final WidgetBuilder hueDialogBuilder;
  final ScoreKeeper? scoreKeeper;
  final void Function() generateHue;
  final Widget? image;
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
        SizedBox(
          width: 100,
          child: TextField(
            onChanged: (text) => (autoSubmit && text.length == 3) ? submit() : (),
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
              child: Text('submit', style: TextStyle(fontSize: 16)),
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
  final Color color;
  final NumPad Function(void Function()) numPad;
  final String numPadVal;
  final WidgetBuilder hueDialogBuilder;
  final ScoreKeeper? scoreKeeper;
  final void Function() generateHue;
  final Widget? image;
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
        Center(child: Text(numPadVal, style: const TextStyle(fontSize: 32))),
        const Spacer(),
        numPad(submit),
      ],
      image,
      color,
      scoreKeeper,
    );
  }
}
