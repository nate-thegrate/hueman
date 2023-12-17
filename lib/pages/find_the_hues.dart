/// Contains resources used in `intro.dart` and `intense_master.dart`
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
      width: min((context.screenWidth - 55) / 3, 125),
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

class RankBars extends StatelessWidget {
  const RankBars(this.rank, {super.key, required this.color});
  final int rank;
  final Color color;

  static const duration = Duration(milliseconds: 750);

  int get activeIndex => rank ~/ 25 + 1;

  @override
  Widget build(BuildContext context) {
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
                color: switch (i) {
                  0 => Colors.black12,
                  1 => Colors.white12,
                  2 => Colors.white24,
                  3 => Colors.white38,
                  _ => color,
                },
                height: switch (i - activeIndex) {
                  < 0 => context.screenHeight,
                  0 => context.screenHeight * (rank % 25) / 25,
                  _ => 0,
                },
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
      margin: const EdgeInsets.symmetric(vertical: 20),
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
        GestureDetector(
          onTap: unclickable ? null : () => Navigator.of(context).pop(),
          child: AlertDialog(
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
                  : const SuperStyle.sans(weight: 200, extraBold: true, letterSpacing: 0.5),
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
                if (!Score.superHue() && isSuper) ...[
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
        ),
        if (unclickable) const SuperContainer(color: Colors.transparent),
      ],
    );
  }
}

class _HueTypingScreen extends StatelessWidget {
  const _HueTypingScreen(this.userInput, this.image, this.color, this.scoreKeeper);
  final List<Widget> userInput;
  final Widget? Function(BoxConstraints constraints) image;
  final Color color;
  final ScoreKeeper? scoreKeeper;

  @override
  Widget build(BuildContext context) {
    final sk = scoreKeeper;
    final bars = (sk is MasterScoreKeeper) ? RankBars(sk.rank, color: color) : empty;

    final double colorBoxWidth = context.screenWidth * 0.75;

    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          bars,
          Expanded(
            child: SafeLayout((context, constraints) {
              return Column(
                children: <Widget>[
                  const Spacer(),
                  if (sk is! TutorialScoreKeeper) const GoBack(),
                  const Spacer(),
                  if (image(constraints) == null) ...[
                    SuperContainer(
                      width: colorBoxWidth,
                      height: min(
                        colorBoxWidth,
                        constraints.maxHeight -
                            (sk is MasterScoreKeeper && !externalKeyboard ? 530 : 400),
                      ),
                      color: color,
                    )
                  ] else
                    image(constraints)!,
                  const Spacer(),
                  const Text(
                    "What's the hue?",
                    textAlign: TextAlign.center,
                    style: SuperStyle.sans(size: 24, letterSpacing: 0),
                  ),
                  ...userInput,
                  const Spacer(),
                  scoreKeeper?.midRoundDisplay ?? empty,
                  if (scoreKeeper != null) const Spacer(),
                ],
              );
            }),
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
    required this.image,
    super.key,
  });
  final Color color;
  final FocusNode hueFocusNode;
  final TextEditingController hueController;
  final WidgetBuilder hueDialogBuilder;
  final ScoreKeeper? scoreKeeper;
  final void Function() generateHue;
  final Widget? Function(BoxConstraints constraints) image;

  @override
  Widget build(BuildContext context) {
    void submit() async {
      if (scoreKeeper case final IntroScoreKeeper sk) {
        if (sk.round >= sk.rounds - 1) sk.stopwatch.stop();
      }
      await showDialog(context: context, builder: hueDialogBuilder);
      scoreKeeper?.scoreTheRound();
      scoreKeeper?.roundCheck(context);
      generateHue();
      hueController.clear();
      hueFocusNode.requestFocus();
    }

    final hueValidation = TextInputFormatter.withFunction(
      (oldValue, newValue) {
        if (newValue.text.length > 3) return oldValue;
        if (newValue.toInt() < 360) return newValue;
        return const TextEditingValue(text: '359', selection: TextSelection.collapsed(offset: 3));
      },
    );

    return _HueTypingScreen(
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
            style: const SuperStyle.sans(size: 18),
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
            child: Text(
              'submit',
              style: SuperStyle.sans(size: 18, extraBold: true, letterSpacing: 1 / 3),
            ),
          ),
        ),
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
    required this.image,
    super.key,
  });
  final Color color;
  final NumPad Function(void Function() submit) numPad;
  final String numPadVal;
  final WidgetBuilder hueDialogBuilder;
  final ScoreKeeper? scoreKeeper;
  final void Function() generateHue;
  final Widget? Function(BoxConstraints constraints) image;

  @override
  Widget build(BuildContext context) {
    void submit() async {
      if (scoreKeeper case final IntroScoreKeeper sk) {
        if (sk.round >= sk.rounds - 1) sk.stopwatch.stop();
      }
      await showDialog(context: context, builder: hueDialogBuilder);
      scoreKeeper?.scoreTheRound();
      scoreKeeper?.roundCheck(context);
      generateHue();
    }

    return _HueTypingScreen(
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
        if (SuperColors.allNamedHues.contains(color)) ColorNameBox(color),
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

class CircleGame extends StatefulWidget {
  const CircleGame({
    super.key,
    required this.color,
    required this.numColors,
    required this.generateHue,
    required this.updateGuess,
    required this.hueDialogBuilder,
    required this.scoreKeeper,
    required this.image,
  });
  final int numColors;
  final SuperColor color;
  final VoidCallback generateHue;
  final ValueChanged<int> updateGuess;
  final WidgetBuilder hueDialogBuilder;
  final ScoreKeeper? scoreKeeper;
  final Widget? Function(BoxConstraints constraints) image;

  @override
  State<CircleGame> createState() => _CircleGameState();
}

class _CircleGameState extends State<CircleGame> {
  int? guess;
  int lastGuess = 0;

  int computeAngle(double x, double y) {
    if (x == 0 || y == 0) {
      return switch ((x, y)) {
        (0, > 0) => 90,
        (< 0, 0) => 180,
        (0, < 0) => 270,
        _ => 0,
      };
    }
    final quadrantAngle = atan(y.abs() / x.abs()) * 180 / pi;
    final exactAngle = switch ((x, y)) {
      (> 0, > 0) => quadrantAngle,
      (< 0, > 0) => 180 - quadrantAngle,
      (< 0, < 0) => quadrantAngle + 180,
      _ => 360 - quadrantAngle,
    };
    return exactAngle.round() % 360;
  }

  void submit(_) async {
    widget.updateGuess(lastGuess);
    setState(() => guess = null);
    if (widget.scoreKeeper case final IntroScoreKeeper sk) {
      if (sk.round >= sk.rounds - 1) sk.stopwatch.stop();
    }
    await showDialog(
      context: context,
      builder: widget.hueDialogBuilder,
    );
    widget.scoreKeeper?.scoreTheRound();
    widget.scoreKeeper?.roundCheck(context);
    widget.generateHue();
  }

  @override
  Widget build(BuildContext context) {
    const duration = Duration(milliseconds: 100);
    return Scaffold(
      body: SafeLayout((context, constraints) {
        final circleSize = constraints.calcSize(
          (w, h) => min(w - 66, (widget.image(constraints) == null ? h : h / 2) - 200),
        );
        final margin = circleSize / 32;
        void touchRecognition(details) {
          final Offset offset = details.localPosition;
          final int angle = computeAngle(
            offset.dx - circleSize / 2,
            -offset.dy + circleSize / 2,
          );
          setState(() {
            guess = angle.roundToNearest(360 ~/ widget.numColors);
            lastGuess = guess!;
          });
        }

        return Center(
          child: Column(
            children: [
              const Spacer(flex: 2),
              if (widget.scoreKeeper is! TutorialScoreKeeper) const GoBack(),
              const Spacer(flex: 2),
              if (widget.image(constraints) case final Widget img) ...[
                Expanded(flex: 16, child: img),
                const Spacer(flex: 3),
              ],
              GestureDetector(
                onPanStart: touchRecognition,
                onPanUpdate: touchRecognition,
                onPanEnd: submit,
                child: SuperContainer(
                  width: circleSize,
                  height: circleSize,
                  padding: EdgeInsets.all(margin),
                  child: SuperContainer(
                    decoration: BoxDecoration(
                      color: widget.color,
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.rotate(
                          angle: -lastGuess * pi / 180,
                          child: Row(
                            children: [
                              const Spacer(),
                              Transform.rotate(
                                angle: lastGuess * pi / 180,
                                child: SuperContainer(
                                  width: circleSize / 2,
                                  height: circleSize / 2,
                                  alignment: Alignment.center,
                                  child: Fader(
                                    hueRuler && guess != null,
                                    duration: duration,
                                    child: SuperText(
                                      '$lastGuess°',
                                      style: SuperStyle.sans(
                                        size: circleSize / 6,
                                        weight: 600,
                                        color: widget.color.computeLuminance() < 0.0722
                                            ? SuperColors.lightBackground
                                            : SuperColors.darkBackground,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Fader(
                                  guess != null,
                                  duration: duration,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Transform.translate(
                                      offset: Offset(circleSize * 0.13, 0),
                                      child: RotatedBox(
                                        quarterTurns: 1,
                                        child: Icon(
                                          Icons.arrow_drop_down,
                                          size: circleSize / 6,
                                          color: widget.color,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (hueRuler)
                          for (int i = 0;
                              i < 360;
                              i += switch (widget.numColors) {
                            3 || 6 || 12 || 24 => 360 ~/ widget.numColors,
                            _ when Tutorial.mastered() => 15,
                            _ => 30,
                          })
                            _TickMark(i, circleSize),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 2),
              if (widget.scoreKeeper case final ScoreKeeper sk)
                AnimatedSize(duration: quarterSec, child: sk.midRoundDisplay),
              const Spacer(),
            ],
          ),
        );
      }),
    );
  }
}

class _TickMark extends StatelessWidget {
  const _TickMark(this.hue, this.circleSize);
  final int hue;
  final double circleSize;

  @override
  Widget build(BuildContext context) {
    final (double width, double height) = switch (hue % 60) {
      0 => (12, 24),
      30 => (36, 48),
      _ => (108, 72),
    };
    return Transform.rotate(
      angle: hue * pi / 180,
      child: Align(
        alignment: Alignment.centerRight,
        child: Transform.translate(
          offset: const Offset(1, 0),
          child: SuperContainer(
            width: circleSize / width,
            height: circleSize / height,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(100),
                bottomLeft: Radius.circular(100),
              ),
              color: SuperColors.darkBackground,
            ),
          ),
        ),
      ),
    );
  }
}
