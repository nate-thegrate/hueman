/// intro `0x0C`

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:super_hueman/data/structs.dart';
import 'package:super_hueman/data/super_color.dart';
import 'package:super_hueman/data/super_container.dart';
import 'package:super_hueman/data/widgets.dart';

class IntroCTutorial extends StatefulWidget {
  /// intro `0x0C`
  const IntroCTutorial({super.key});

  @override
  State<IntroCTutorial> createState() => _IntroCTutorialState();
}

class _IntroCTutorialState extends State<IntroCTutorial> {
  bool visible = false;
  late final pages = [
    _Page1(nextPage),
    _Page2(nextPage),
    _Page3(nextPage),
    _Page4(nextPage),
    _Page5(nextPage),
    _Page6(nextPage),
  ];
  int page = 1;

  Duration duration = oneSec;

  void nextPage() async {
    setState(() => duration = halfSec);
    setState(() => visible = false);
    await sleep(1);
    setState(() => page++);
    setState(() => visible = true);
  }

  @override
  void initState() {
    super.initState();
    sleep(1, then: () => setState(() => visible = true));
  }

  Color? backgroundColor;

  @override
  Widget build(BuildContext context) => Scaffold(
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

class _Page1 extends StatefulWidget {
  const _Page1(this.nextPage);
  final void Function() nextPage;

  @override
  State<_Page1> createState() => _Page1State();
}

class _Page1State extends SafeState<_Page1> with DelayedPress {
  int progress = 0;
  void advance() => setState(() => progress++);

  void animate() async {
    await sleep(7, then: advance); // somethin funky
    await sleep(4, then: advance); // show questions
    await sleep(2, then: advance); // show buttons
  }

  late VoidCallback trickQuestion = delayed(() async {
    advance(); // hide everything

    await sleep(1);
    setState(() => funkyText = const EasyText('Yeah sorry, that was a trick question.'));
    advance();

    await sleep(2);
    setState(() => questionText = const EasyText("Here's the RGB:"));
    advance();

    await sleep(1, then: advance); // show RGB
    await sleep(7, then: advance); // show continue button
  });

  void tryAgain() async {
    advance(); // overlay

    await sleep(1.5);
    setState(() {
      funkyText = empty;
      questionText = empty;
    });
    advance(); // overlay desc

    await sleep(4, then: advance); // overlay try again
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
    animate();
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
                  ColorTextSpan(SuperColors.red),
                  TextSpan(text: ' was just getting lighter and darker,\nbut the '),
                  ColorTextSpan(SuperColors.visibleBlue),
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
        _RGB.r => SuperColor.hsv(0, 0.25, 0.125),
        _RGB.g => SuperColor.hsv(120, 0.25, 0.125),
        _RGB.b => SuperColor.hsv(240, 0.25, 0.125),
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
          boxShadow: const [BoxShadow(offset: Offset(1, 3), blurRadius: 3)],
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

class _Page2State extends SafeState<_Page2> {
  bool visible = false;

  void animate() async {}

  @override
  void initState() {
    super.initState();
    animate();
  }

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [],
    );
  }
}

class _Page3 extends StatefulWidget {
  const _Page3(this.nextPage);
  final void Function() nextPage;

  @override
  State<_Page3> createState() => _Page3State();
}

class _Page3State extends SafeState<_Page3> {
  bool visible = false;

  void animate() async {}

  @override
  void initState() {
    super.initState();
    animate();
  }

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [],
    );
  }
}

class _Page4 extends StatefulWidget {
  const _Page4(this.nextPage);
  final void Function() nextPage;

  @override
  State<_Page4> createState() => _Page4State();
}

class _Page4State extends SafeState<_Page4> {
  bool visible = false;

  void animate() async {}

  @override
  void initState() {
    super.initState();
    animate();
  }

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [],
    );
  }
}

class _Page5 extends StatefulWidget {
  const _Page5(this.nextPage);
  final void Function() nextPage;

  @override
  State<_Page5> createState() => _Page5State();
}

class _Page5State extends SafeState<_Page5> {
  bool visible = false;

  void animate() async {}

  @override
  void initState() {
    super.initState();
    animate();
  }

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [],
    );
  }
}

class _Page6 extends StatefulWidget {
  const _Page6(this.nextPage);
  final void Function() nextPage;

  @override
  State<_Page6> createState() => _Page6State();
}

class _Page6State extends SafeState<_Page6> {
  bool visible = false;

  void animate() async {}

  @override
  void initState() {
    super.initState();
    animate();
  }

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [],
    );
  }
}