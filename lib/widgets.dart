import 'package:flutter/material.dart';
import 'package:super_hueman/pages/intense.dart';
import 'package:super_hueman/structs.dart';
import 'dart:math';

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

const Widget empty = SizedBox.shrink();

class FixedSpacer extends StatelessWidget {
  final double size;
  final bool horizontal;
  const FixedSpacer(this.size, {super.key}) : horizontal = false;
  const FixedSpacer.horizontal(this.size, {super.key}) : horizontal = true;

  @override
  Widget build(BuildContext context) =>
      horizontal ? SizedBox(width: size) : SizedBox(height: size);
}

class MenuButton extends StatelessWidget {
  final String label;
  final void Function() onPressed;
  final Color color;
  const MenuButton(this.label, {required this.color, required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            backgroundColor: color, foregroundColor: inverted ? Colors.white : Colors.black),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(label, style: const TextStyle(fontSize: 24)),
        ),
      );
}

class NavigateButton extends StatelessWidget {
  final Pages page;
  final Color color;
  const NavigateButton(this.page, {required this.color, super.key});

  @override
  Widget build(BuildContext context) => MenuButton(
        page(),
        color: color,
        onPressed: () => context.goto(page),
      );
}

class GameScreen extends StatelessWidget {
  final Color color;
  final FocusNode hueFocusNode;
  final TextEditingController hueController;
  final WidgetBuilder hueDialogBuilder;
  final ScoreKeeper? scoreKeeper;
  final void Function() generateHue;
  final Widget? image;
  const GameScreen({
    required this.color,
    required this.hueFocusNode,
    required this.hueController,
    required this.hueDialogBuilder,
    required this.scoreKeeper,
    required this.generateHue,
    this.image,
    super.key,
  });

  Color? get backgroundColor {
    final ScoreKeeper? sk = scoreKeeper;
    if (sk is MasterScoreKeeper) {
      final int colorVal = ((100 - sk.rank + (sk.rank % 25)) * 0.18).round();
      return Color.fromARGB(255, colorVal, colorVal, colorVal);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    void submit() {
      showDialog(context: context, builder: hueDialogBuilder).then((_) {
        scoreKeeper?.scoreTheRound();
        scoreKeeper?.roundCheck(context);
        generateHue();
        hueController.clear();
        hueFocusNode.requestFocus();
      });
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
        backgroundColor: Colors.black26,
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
    final colorBox = image == null
        ? [Container(width: 400, height: 400, color: color)]
        : [
            image!,
            const Spacer(),
            Container(width: 500, height: 150, color: color),
          ];
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

    Widget mainContent = Center(
      child: Column(
        children: <Widget>[
          const Spacer(flex: 2),
          backButton,
          const FixedSpacer(50),
          ...colorBox,
          const Spacer(),
          whatsTheHue,
          const FixedSpacer(50),
          textField,
          const FixedSpacer(25),
          submitButton,
          const Spacer(flex: 2),
          scoreKeeper?.midRoundDisplay ?? empty,
          const Spacer(),
        ],
      ),
    );

    final sk = scoreKeeper;
    if (sk is MasterScoreKeeper) {
      mainContent = RankBars(sk.rank, color: color, child: mainContent);
    }

    return Scaffold(body: mainContent, backgroundColor: backgroundColor);
  }
}

class RankBars extends StatelessWidget {
  final int rank;
  final Color color;
  final Widget child;
  const RankBars(this.rank, {required this.color, required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final int activeIndex = rank ~/ 25 + 1;
    final List<Color> rankBarColors = [
      Colors.black12,
      Colors.white12,
      Colors.white24,
      Colors.white38,
      color,
    ];

    final List<(Color, double)> rankBarData = [
      for (int i = 0; i < rankBarColors.length; i++)
        (
          rankBarColors[i],
          i < activeIndex
              ? screenHeight
              : i == activeIndex
                  ? screenHeight * (rank % 25) / 25
                  : 0
        )
    ];

    final Widget rankBar = SizedBox(
      width: 25,
      child: Stack(
        children: [
          for (final (color, height) in rankBarData)
            Column(
              children: [
                const Spacer(),
                AnimatedSize(
                  duration: const Duration(milliseconds: 750),
                  curve: Curves.easeOutCubic,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 750),
                    curve: Curves.easeOutCubic,
                    color: color,
                    height: height,
                  ),
                ),
              ],
            ),
        ],
      ),
    );

    return Row(children: [rankBar, Expanded(child: child), rankBar]);
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
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        color: widget.color,
        width: width,
        height: width / (widget.color == Colors.black ? 10 : 15),
      );
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

class ColorNameBox extends StatelessWidget {
  final Color color;
  const ColorNameBox(this.color, {super.key});

  @override
  Widget build(BuildContext context) => Container(
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
    sleep(widget.isSuper ? 1 : 0.2).then((_) => addListener(_listenForEnter));
  }

  @override
  void dispose() {
    yeetListener(_listenForEnter);
    ticker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
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
        elevation: widget.isSuper ? (sin((epicHue) / 360 * 2 * pi * 6) + 1) * 10 : null,
        shadowColor: widget.isSuper ? epicColor : null,
        surfaceTintColor: widget.isSuper ? epicColor : null,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.graphic,
            const FixedSpacer(20),
            _AnswerFeedback(widget.guess, text: 'Your answer:'),
            _AnswerFeedback(widget.hue, text: 'Correct answer:'),
            ...(mastery || !widget.isSuper)
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
      );
}
