/// intro `0xC`

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:super_hueman/data/structs.dart';
import 'package:super_hueman/data/super_color.dart';
import 'package:super_hueman/data/super_container.dart';
import 'package:super_hueman/data/super_state.dart';
import 'package:super_hueman/data/widgets.dart';
import 'package:super_hueman/pages/intro.dart';

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
    sleep(1, then: () => setState(() => visible = true));
  }

  Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Fader(
          visible,
          duration: duration,
          child: pages[page - 1],
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
      () => funkyText = const EasyText('Yeah sorry, that was a trick question.'),
    );
    advance();

    await sleepState(2, () => questionText = const EasyText("Here's the RGB:"));
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

  Widget funkyText = const EasyText('Something funky is going on with these colors…');
  Widget questionText = const EasyText("What's changing?");
  Widget tryAgainBody = empty;
  @override
  Widget build(BuildContext context) {
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
      _TrickButton(funSine, lookatRGB, funRed, onPressed: trickQuestion),
      _TrickButton(funSine, lookatRGB, funBlue, onPressed: trickQuestion, blue: true),
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
                child: const EasyRichText([
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
                child: const EasyText(
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
    required this.onPressed,
    this.blue = false,
  });
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
                Row(
                  children: [
                    _Slider(_RGB.r, funColor.red),
                    _Slider(_RGB.g, funColor.green),
                    _Slider(_RGB.b, blue ? 0xFF : 0),
                    FixedSpacer.horizontal(context.screenWidth * 0.04),
                  ],
                ),
                const FixedSpacer(5),
                EasyText('hue: ${funColor.hue.round()}°'),
              ],
            )
          : OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: SuperColors.darkBackground,
                shadowColor: Colors.white,
                elevation: funSine * 10,
              ),
              onPressed: onPressed,
              child: Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 9),
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w100),
                ),
              ),
            ),
    );
  }
}

enum _RGB { r, g, b }

class _Slider extends StatelessWidget {
  const _Slider(this.rgb, this.val);
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
    final double height = context.screenHeight * 2 / 3 - 50;
    return Expanded(
      child: SuperContainer(
        height: height,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.all(Radius.circular(0x100)),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.only(left: context.screenWidth * 0.04),
        alignment: Alignment.bottomCenter,
        child: SuperContainer(
          color: color,
          height: height * val / 0xFF,
        ),
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

  static const List<Widget> text = [
    EasyText(
      'Back in the 1400s,\n'
      'both of these colors were called "red",\n'
      'and people had trouble telling them apart.',
    ),
    EasyText(
      'But then in the 1500s,\n'
      'somebody decided that orange (the fruit)\n'
      'should also be a color name.',
    ),
    EasyRichText([
      TextSpan(text: 'And now that '),
      ColorTextSpan.orange,
      TextSpan(text: ' is in our color vocabulary,\ndistinguishing it from '),
      ColorTextSpan.red,
      TextSpan(text: ' is second-nature.'),
    ]),
    empty,
  ];

  late final List<Widget> text2 = [
    const EasyText('These "shades of blue"\nare really two different colors.'),
    const EasyRichText([
      TextSpan(text: 'And just like with '),
      ColorTextSpan.red,
      TextSpan(text: ' & '),
      ColorTextSpan.orange,
      TextSpan(text: ',\nour brains can be trained to distinguish them.'),
    ]),
    const EasyText('We just need a better color vocabulary.'),
    ContinueButton(onPressed: widget.nextPage),
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = context.screenSize;
    const colorBoxFlex = 8;
    final colorBoxHeight = min(
      screenSize.height / 3,
      min(
        screenSize.width * colorBoxFlex / (2 * colorBoxFlex + 3),
        screenSize.height - 250,
      ),
    );

    final List<Widget> children = showBlue ? text2 : text;

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
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
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
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
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
              for (int i = 0; i < children.length; i++) Fader(numVisible > i, child: children[i])
            ],
          ),
        ),
      ],
    );
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
    final left = Column(
      children: [
        for (final color in _OldVocab.colors)
          _VocabLine(color.degreeSpan, expandLeft, showLeftLabels, color.name, color.color)
      ],
    );

    final right = Column(
      children: [
        for (int i = 0; i < 12; i++)
          _VocabLine.better(
            i < rightLinesExpanded,
            i < rightLabelsShown,
            SuperColors.twelveHues[i],
          )
      ],
    );

    return Column(
      children: [
        SuperContainer(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Fader(
                showLeftDesc,
                child: const Text(
                  'on the left: the color vocabulary I grew up with',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w100),
                ),
              ),
              Fader(
                showRightDesc,
                child: const Text(
                  'on the right: my color vocabulary now',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w100),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Row(
              children: [
                Expanded(child: left),
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
                Expanded(child: right),
              ],
            ),
          ),
        ),
        Fader(showButton, child: ContinueButton(onPressed: widget.nextPage)),
        const FixedSpacer(20),
      ],
    );
  }
}

class _VocabLine extends StatelessWidget {
  const _VocabLine(this.flex, this.expanded, this.showLabel, this.label, this.color)
      : onLeftSide = false;
  const _VocabLine.better(this.expanded, this.showLabel, this.color)
      : label = null,
        flex = 30,
        onLeftSide = true;

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
          style: TextStyle(
            fontSize: (context.screenHeight - 0x80) / 0x20,
            fontWeight: FontWeight.w100,
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
    _OldVocab(50, SuperColor(0xFF30B0), 'pink'),
  ];
}

class _FinalPage extends StatefulWidget {
  const _FinalPage();

  @override
  State<_FinalPage> createState() => _FinalPageState();
}

class _FinalPageState extends SuperState<_FinalPage> with SinglePress {
  bool superDifficult = false, letsDoIt = false, expandButton = false;
  late final Ticker epicHues;

  @override
  void animate() async {
    await sleep(3);
    setState(() => superDifficult = true);

    await sleepState(3, () => letsDoIt = true);
    await sleepState(1 / 3, () => expandButton = true);
  }

  @override
  void initState() {
    super.initState();
    epicHues = epicSetup(setState);
  }

  @override
  void dispose() {
    epicHues.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SuperColor color = epicColor;

    return AnimatedContainer(
      duration: oneSec,
      width: 400,
      height: 500,
      decoration: letsDoIt
          ? BoxDecoration(border: Border.all(color: color, width: 2))
          : const BoxDecoration(),
      child: Column(
        children: [
          const Spacer(),
          const EasyText('6 new hues at once.'),
          const FixedSpacer(25),
          Fader(
            superDifficult,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const EasyText('super', size: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 0),
                  child: Text(
                    'ᴅɪғғɪᴄᴜʟᴛ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      color: color,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2 / 3,
                    ),
                  ),
                ),
                const EasyText('.', size: 30),
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
                        padding: EdgeInsets.all(10),
                        child: Text("let's do it", style: TextStyle(fontSize: 30)),
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
