/// intro `0xC`
library;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hueman/data/structs.dart';
import 'package:hueman/data/super_color.dart';
import 'package:hueman/data/super_container.dart';
import 'package:hueman/data/super_state.dart';
import 'package:hueman/data/super_text.dart';
import 'package:hueman/data/widgets.dart';
import 'package:hueman/pages/intro.dart';

class IntroCTutorial extends StatefulWidget {
  /// intro `0xC`
  const IntroCTutorial({super.key});

  @override
  State<IntroCTutorial> createState() => _IntroCTutorialState();
}

class _IntroCTutorialState extends SuperState<IntroCTutorial> {
  bool visible = false;
  late final pages = [
    _Page1(nextPage),
    _Page2(nextPage),
    _Page3(nextPage),
    const _FinalPage(),
  ];
  int page = 1;

  Duration duration = oneSec;

  void nextPage() async {
    setState(() {
      duration = halfSec;
      visible = false;
    });
    await sleepState(1, () {
      page++;
      visible = true;
    });
  }

  @override
  void initState() {
    super.initState();
    musicPlayer.stop();
    sleep(1, then: () => setState(() => visible = true));
  }

  Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Fader(
            visible,
            duration: duration,
            child: pages[page - 1],
          ),
        ),
      ),
      backgroundColor: backgroundColor,
    );
  }
}

class _Page1 extends StatefulWidget {
  const _Page1(this.nextPage);
  final void Function() nextPage;

  @override
  State<_Page1> createState() => _Page1State();
}

class _Page1State extends SuperState<_Page1> with SinglePress {
  int progress = 0;
  void advance() => setState(() => progress++);

  @override
  void animate() async {
    await sleep(7, then: advance); // somethin funky
    await sleep(4, then: advance); // show questions
    await sleep(2, then: advance); // show buttons
  }

  late VoidCallback trickQuestion = singlePress(() async {
    advance(); // hide everything

    await sleepState(
      1,
      () => funkyText = const SuperText('Yeah sorry, that was a trick question.'),
    );
    advance();

    await sleepState(2, () => questionText = const SuperText("Here's the RGB:"));
    advance();

    await sleep(1, then: advance); // show RGB
    await sleep(7, then: advance); // show continue button
  });

  void tryAgain() async {
    advance(); // overlay

    await sleepState(1.5, () {
      funkyText = empty;
      questionText = empty;
    });
    advance(); // overlay desc

    await sleep(5, then: advance); // overlay try again
    await sleep(6, then: advance); // hide overlay text
    await sleep(1.5, then: advance); // show orange
    await sleep(7, then: advance); // finally done
  }

  late final Ticker ticker;
  int counter = 0x28;
  static const _cycleLength = 0x100;

  @override
  void initState() {
    super.initState();
    ticker = Ticker((elapsed) => setState(() => counter = (counter + 1) % _cycleLength))..start();
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  Widget funkyText = const SuperText('Something funky is going on\nwith these colors…');
  Widget questionText = const SuperText("What's changing?");
  Widget tryAgainBody = empty;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final double funSine = (sin((counter) / _cycleLength * 2 * pi) + 1) / 2;
      final int greenVal = (0x40 * (2 - (funSine + funSine.squared))).round();
      final SuperColor funRed, funBlue;
      funRed = progress >= 12
          ? SuperColor.rgb(0xFF, greenVal, 0)
          : SuperColor.rgb((0xFF * (1 - funSine / 2)).round(), 0, 0);
      funBlue = SuperColor.rgb(0, greenVal, 0xFF);
      final boxWidth = context.screenWidth * .4;

      final bool lookatRGB = progress >= 7;
      final List<Widget> trickButtons = [
        _TrickButton(
          funSine,
          lookatRGB,
          constraints: constraints,
          funRed,
          onPressed: trickQuestion,
        ),
        _TrickButton(
          funSine,
          lookatRGB,
          constraints: constraints,
          funBlue,
          onPressed: trickQuestion,
          blue: true,
        ),
      ];
      final Widget continueButton = progress > 10
          ? ContinueButton(key: const Key('1'), onPressed: widget.nextPage)
          : ContinueButton(key: const Key('2'), onPressed: tryAgain);
      return Stack(
        children: [
          Column(
            children: [
              const Spacer(),
              if (progress > 10) const Spacer(),
              Expanded(
                flex: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SuperContainer(width: boxWidth, color: funRed),
                    SuperContainer(width: boxWidth, color: funBlue),
                  ],
                ),
              ),
              const Spacer(),
              Fader(
                progress != 0 && progress != 4,
                child: funkyText,
              ),
              const Spacer(),
              Fader(
                switch (progress) { 2 || 3 || > 5 => true, _ => false },
                child: questionText,
              ),
              if (progress < 10) const Spacer(flex: 2),
              Fader(
                progress == 3 || progress > 6,
                child: AnimatedSize(
                  duration: oneSec,
                  curve: curve,
                  child: Row(mainAxisSize: MainAxisSize.min, children: trickButtons),
                ),
              ),
              const Spacer(),
              SexyBox(
                child: lookatRGB
                    ? Fader(progress == 8 || progress == 14, child: continueButton)
                    : empty,
              ),
              const Spacer(),
            ],
          ),
          if (progress > 8 && progress < 14) _SecondTry(progress),
        ],
      );
    });
  }
}

class _SecondTry extends StatelessWidget {
  const _SecondTry(this.progress);
  final int progress;

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      child: Fader(
        progress < 13,
        child: SuperContainer(
          color: SuperColors.darkBackground,
          alignment: Alignment.center,
          child: Column(
            children: [
              const Spacer(flex: 4),
              Fader(
                progress > 9 && progress < 12,
                child: const SuperRichText([
                  TextSpan(text: 'The '),
                  ColorTextSpan.red,
                  TextSpan(text: ' was just getting lighter and darker,\nbut the '),
                  ColorTextSpan.visibleBlue,
                  TextSpan(text: ' was changing hue.'),
                ]),
              ),
              const Spacer(),
              Fader(
                progress > 10 && progress < 12,
                child: const SuperText(
                    "Let's try it again:\nthis time, both colors are gonna act the same way."),
              ),
              const Spacer(flex: 4),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrickButton extends StatelessWidget {
  const _TrickButton(
    this.funSine,
    this.lookatRGB,
    this.funColor, {
    required this.constraints,
    required this.onPressed,
    this.blue = false,
  });
  final BoxConstraints constraints;
  final double funSine;
  final SuperColor funColor;
  final bool lookatRGB, blue;
  final void Function() onPressed;

  String get label => blue ? 'the hue' : 'the shade';

  @override
  Widget build(BuildContext context) {
    return SuperContainer(
      width: context.screenWidth / 2,
      alignment: Alignment.center,
      child: lookatRGB
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints.loose(const Size.fromWidth(300)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        _Slider(_RGB.r, constraints: constraints, funColor.red),
                        _Slider(_RGB.g, constraints: constraints, funColor.green),
                        _Slider(_RGB.b, constraints: constraints, blue ? 0xFF : 0),
                      ],
                    ),
                  ),
                ),
                const FixedSpacer(5),
                SuperText('hue: ${funColor.hue.round()}°'),
              ],
            )
          : OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: SuperColors.darkBackground,
                shadowColor: Colors.white,
              ),
              onPressed: onPressed,
              child: Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 9),
                child: Text(
                  label,
                  style: const SuperStyle.sans(size: 20, weight: 100),
                ),
              ),
            ),
    );
  }
}

enum _RGB { r, g, b }

class _Slider extends StatelessWidget {
  const _Slider(this.rgb, this.val, {required this.constraints});
  final BoxConstraints constraints;
  final _RGB rgb;
  final int val;

  SuperColor get color => switch (rgb) {
        _RGB.r => SuperColor.rgb(val, 0, 0),
        _RGB.g => SuperColor.rgb(0, val, 0),
        _RGB.b => SuperColor.rgb(0, 0, val),
      };

  SuperColor get bgColor => switch (rgb) {
        _RGB.r => SuperColor.hsv(0, 0.2, 1 / 4),
        _RGB.g => SuperColor.hsv(120, 0.2, 1 / 4),
        _RGB.b => SuperColor.hsv(240, 0.2, 1 / 4),
      };

  @override
  Widget build(BuildContext context) {
    final double height = constraints.maxHeight * 2 / 3 - 50;
    return Expanded(
      child: SuperContainer(
        height: height,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.all(Radius.circular(0x100)),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.symmetric(horizontal: min(context.screenWidth / 2, 300) * .06),
        alignment: Alignment.bottomCenter,
        child: SuperContainer(color: color, height: height * val / 0xFF),
      ),
    );
  }
}

class _Page2 extends StatefulWidget {
  const _Page2(this.nextPage);
  final void Function() nextPage;

  @override
  State<_Page2> createState() => _Page2State();
}

class _Page2State extends SuperState<_Page2> {
  bool showBlue = false, showNames = false;
  int numVisible = 1;
  void advance() => setState(() => numVisible++);

  @override
  Future<void> animate() async {
    await sleep(7, then: advance);
    await sleep(7, then: advance);
    await sleep(7, then: advance);

    await sleepState(3, () => numVisible = 0);
    await sleepState(1, () => showBlue = true);

    await sleep(3, then: advance);
    await sleep(5, then: advance);
    await sleep(6, then: advance);
    await sleep(4, then: advance);

    setState(() => showNames = true);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      const colorBoxFlex = 8;
      final colorBoxHeight = constraints.calcSize(
        (w, h) => min(w * colorBoxFlex / (2 * colorBoxFlex + 3), min(h / 3, h - 250)),
      );
      final double size = min(context.screenWidth / 23, 20);

      return Column(
        children: [
          FixedSpacer(colorBoxHeight / colorBoxFlex),
          SizedBox(
            height: colorBoxHeight,
            child: Row(
              children: [
                const Spacer(),
                Expanded(
                  flex: colorBoxFlex,
                  child: AnimatedContainer(
                    duration: const Duration(seconds: 3),
                    decoration: BoxDecoration(
                      color: showBlue ? SuperColors.blue : SuperColors.red,
                      boxShadow: const [BoxShadow(blurRadius: 5, spreadRadius: 2)],
                    ),
                    alignment: Alignment.center,
                    child: showNames
                        ? const FadeIn(
                            child: Text(
                              'blue',
                              style: SuperStyle.sans(
                                size: 36,
                                weight: 800,
                                color: SuperColors.darkBackground,
                              ),
                            ),
                          )
                        : empty,
                  ),
                ),
                const Spacer(),
                Expanded(
                  flex: colorBoxFlex,
                  child: AnimatedContainer(
                    duration: const Duration(seconds: 3),
                    decoration: BoxDecoration(
                      color: showBlue ? SuperColors.azure : SuperColors.orange,
                      boxShadow: const [BoxShadow(blurRadius: 5, spreadRadius: 2)],
                    ),
                    alignment: Alignment.center,
                    child: showNames
                        ? const FadeIn(
                            child: Text(
                              'azure',
                              style: SuperStyle.sans(
                                size: 36,
                                weight: 800,
                                color: SuperColors.darkBackground,
                              ),
                            ),
                          )
                        : empty,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (showBlue) ...[
                  Fader(
                    numVisible >= 1,
                    child: SuperText(
                      'These "shades of blue"\nare really two different colors.',
                      style: SuperStyle.sans(size: size),
                    ),
                  ),
                  Fader(
                    numVisible >= 2,
                    child: SuperRichText(
                      style: SuperStyle.sans(size: size),
                      const [
                        TextSpan(text: 'And just like with '),
                        ColorTextSpan.red,
                        TextSpan(text: ' & '),
                        ColorTextSpan.orange,
                        TextSpan(text: ',\nour brains can be trained to distinguish them.'),
                      ],
                    ),
                  ),
                  Fader(
                    numVisible >= 3,
                    child: SuperText(
                      'We just need a better color vocabulary.',
                      style: SuperStyle.sans(size: size),
                    ),
                  ),
                  Fader(numVisible >= 4, child: ContinueButton(onPressed: widget.nextPage)),
                ] else ...[
                  Fader(
                    numVisible >= 1,
                    child: SuperText(
                      'Back in the 1400s,\n'
                      'both of these colors were called "red",\n'
                      'and people had trouble telling them apart.',
                      style: SuperStyle.sans(size: size),
                    ),
                  ),
                  Fader(
                    numVisible >= 2,
                    child: SuperText(
                      'But then in the 1500s,\n'
                      'somebody decided that orange (the fruit)\n'
                      'should also be a color name.',
                      style: SuperStyle.sans(size: size),
                      pad: false,
                    ),
                  ),
                  Fader(
                    numVisible >= 3,
                    child: SuperRichText(
                      style: SuperStyle.sans(size: size),
                      pad: false,
                      const [
                        TextSpan(text: 'And now that '),
                        TextSpan(
                          text: 'orange',
                          style: SuperStyle.sans(
                            weight: 600,
                            width: 87.5,
                            color: SuperColors.orange,
                          ),
                        ),
                        TextSpan(text: ' is in our color vocabulary,\ndistinguishing it from '),
                        TextSpan(
                          text: 'red',
                          style: SuperStyle.sans(
                            weight: 600,
                            width: 87.5,
                            color: SuperColors.red,
                          ),
                        ),
                        TextSpan(text: ' is second-nature.'),
                      ],
                    ),
                  ),
                  empty,
                ],
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _Page3 extends StatefulWidget {
  const _Page3(this.nextPage);
  final void Function() nextPage;

  @override
  State<_Page3> createState() => _Page3State();
}

class _Page3State extends SuperState<_Page3> {
  bool showLeftDesc = false,
      expandLeft = false,
      showLeftLabels = false,
      showRightDesc = false,
      showButton = false;
  int rightLinesExpanded = 0, rightLabelsShown = 0;

  @override
  void animate() async {
    await sleepState(2, () => showLeftDesc = true);
    await sleepState(3, () => expandLeft = true);
    await sleepState(2, () => showLeftLabels = true);
    await sleepState(8, () => showRightDesc = true);

    await sleep(1);
    for (int i = 0; i < 12; i++) {
      await sleepState(0.1, () => rightLinesExpanded++);
    }

    await sleep(1);
    for (int i = 0; i < 12; i++) {
      await sleepState(0.5, () => rightLabelsShown++);
    }

    await sleepState(2, () => showButton = true);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Fader(
                  showLeftDesc,
                  child: const Text(
                    'on the left: the color vocabulary I grew up with',
                    style: SuperStyle.sans(size: 20, weight: 100),
                    softWrap: false,
                  ),
                ),
                Fader(
                  showRightDesc,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'on the right: color names from',
                        style: SuperStyle.sans(size: 20, weight: 100),
                        softWrap: false,
                      ),
                      SizedBox(
                        height: 33,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: SuperColors.azure,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                          ),
                          onPressed: () => gotoWebsite(
                            'https://en.wikipedia.org/wiki/Tertiary_color#RGB_or_CMYK_primary,_secondary,_and_tertiary_colors',
                          ),
                          child: const Text(
                            'Wikipedia',
                            style: SuperStyle.sans(
                              size: 20,
                              weight: 100,
                              width: 87.5,
                              letterSpacing: 1 / 3,
                              extraBold: true,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: LayoutBuilder(builder: (context, constraints) {
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        for (final color in _OldVocab.colors)
                          _VocabLine(
                            constraints,
                            color.degreeSpan,
                            expandLeft,
                            showLeftLabels,
                            color.name,
                            color.color,
                          )
                      ],
                    ),
                  ),
                  const SuperContainer(
                    height: double.infinity,
                    width: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: _VocabLine.gradient,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        for (int i = 0; i < 12; i++)
                          _VocabLine.better(
                            constraints,
                            i < rightLinesExpanded,
                            i < rightLabelsShown,
                            SuperColors.twelveHues[i],
                          )
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
        Fader(showButton, child: ContinueButton(onPressed: widget.nextPage)),
        const FixedSpacer(20),
      ],
    );
  }
}

class _VocabLine extends StatelessWidget {
  const _VocabLine(
      this.constraints, this.flex, this.expanded, this.showLabel, this.label, this.color)
      : onLeftSide = false;
  const _VocabLine.better(this.constraints, this.expanded, this.showLabel, this.color)
      : label = null,
        flex = 30,
        onLeftSide = true;

  final BoxConstraints constraints;
  final String? label;
  final SuperColor color;
  final int flex;
  final bool expanded, onLeftSide, showLabel;

  @override
  Widget build(BuildContext context) {
    final Widget name = Fader(
      showLabel,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Text(
          label ?? color.name,
          style: SuperStyle.sans(
            size: constraints.calcSize((w, h) => min((w - 75) / 12, (h) / 0x20)),
            weight: 100,
            height: -1 / 3,
          ),
        ),
      ),
    );
    final Widget line = SuperContainer(
      width: 8,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(0xFF),
      ),
      child: SexyBox(
          child: expanded ? const SizedBox.expand() : const SizedBox(width: double.infinity)),
    );
    final List<Widget> children = onLeftSide ? [line, name] : [const Spacer(), name, line];

    return Expanded(
      flex: flex,
      child: Row(children: children),
    );
  }

  static const gradient = [
    SuperColor(0xFF0040),
    SuperColor(0xFF0000),
    SuperColor(0xFF4000),
    SuperColor(0xFF8000),
    SuperColor(0xFFBF00),
    SuperColor(0xFFFF00),
    SuperColor(0xBFFF00),
    SuperColor(0x80FF00),
    SuperColor(0x40FF00),
    SuperColor(0x00FF00),
    SuperColor(0x00FF40),
    SuperColor(0x00FF80),
    SuperColor(0x00FFBF),
    SuperColor(0x00FFFF),
    SuperColor(0x00BFFF),
    SuperColor(0x0080FF),
    SuperColor(0x0040FF),
    SuperColor(0x0000FF),
    SuperColor(0x4000FF),
    SuperColor(0x8000FF),
    SuperColor(0xBF00FF),
    SuperColor(0xFF00FF),
    SuperColor(0xFF00BF),
    SuperColor(0xFF0080),
    SuperColor(0xFF0040),
  ];
}

class _OldVocab {
  const _OldVocab(this.degreeSpan, this.color, this.name);
  final int degreeSpan;
  final String name;
  final SuperColor color;

  static const colors = [
    _OldVocab(30, SuperColors.red, 'red'),
    _OldVocab(30, SuperColors.orange, 'orange'),
    _OldVocab(30, SuperColors.yellow, 'yellow'),
    _OldVocab(80, SuperColors.green, 'green'),
    _OldVocab(25, SuperColor(0x00F8CC), 'turquoise'),
    _OldVocab(75, SuperColor(0x0060FF), 'blue'),
    _OldVocab(40, SuperColor(0xA000F0), 'purple'),
    _OldVocab(50, SuperColor(0xFF20B0), 'pink'),
  ];
}

class _FinalPage extends StatefulWidget {
  const _FinalPage();

  @override
  State<_FinalPage> createState() => _FinalPageState();
}

class _FinalPageState extends EpicState<_FinalPage> with SinglePress {
  bool superDifficult = false, letsDoIt = false, expandButton = false;

  @override
  void animate() async {
    await sleepState(3, () => superDifficult = true);
    await sleepState(3, () => letsDoIt = true);
    await sleepState(1 / 3, () => expandButton = true);
  }

  @override
  Widget build(BuildContext context) {
    final SuperColor color = epicColor;
    const double size = 30;
    const space = TextSpan(text: ' ', style: SuperStyle.sans(size: 1));
    return AnimatedContainer(
      duration: oneSec,
      width: 333,
      height: 444,
      decoration: letsDoIt
          ? BoxDecoration(border: Border.all(color: color, width: 2))
          : const BoxDecoration(),
      child: Column(
        children: [
          const Spacer(),
          const SuperText('6 new hues at once.'),
          const FixedSpacer(25),
          Fader(
            superDifficult,
            child: SuperRichText(
              style: const SuperStyle.sans(size: size, weight: 250),
              [
                const TextSpan(text: 'super'),
                space,
                TextSpan(
                  text: 'DIFFICULT',
                  style: SuperStyle.sans(size: size * 0.7, color: color, weight: 800),
                ),
                space,
                const TextSpan(text: '.'),
              ],
            ),
          ),
          const Spacer(),
          Fader(
            letsDoIt,
            child: ElevatedButton(
              onPressed: singlePress(() => Navigator.pushReplacement<void, void>(
                    context,
                    MaterialPageRoute<void>(builder: (context) => const IntroMode(12)),
                  )),
              style: ElevatedButton.styleFrom(
                backgroundColor: epicColor,
                foregroundColor: Colors.black,
              ),
              child: SexyBox(
                child: expandButton
                    ? const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          "let's do it",
                          style: SuperStyle.sans(
                            size: 24,
                            weight: 350,
                            extraBold: true,
                            letterSpacing: 0.5,
                          ),
                        ),
                      )
                    : empty,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
