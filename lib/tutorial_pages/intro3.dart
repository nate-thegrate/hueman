import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:super_hueman/structs.dart';
import 'package:super_hueman/widgets.dart';

class Intro3Tutorial extends StatefulWidget {
  const Intro3Tutorial({super.key});

  @override
  State<Intro3Tutorial> createState() => _Intro3TutorialState();
}

class _Intro3TutorialState extends State<Intro3Tutorial> {
  bool visible = false;
  int page = 1;
  // ignore: constant_identifier_names
  static const Duration _1sec = Duration(seconds: 1), _halfSec = Duration(milliseconds: 500);
  Duration duration = _1sec;

  void nextPage() async {
    setState(() => duration = _halfSec);
    setState(() => visible = false);
    if (page != 2) await sleep(1);
    setState(() {
      page++;
      duration = _1sec;
    });
    setState(() => visible = true);
  }

  @override
  void initState() {
    super.initState();
    sleep(1, then: () => setState(() => visible = true));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Fader(
            visible,
            duration: duration,
            child: [
              _Page1(nextPage),
              _Page2(nextPage),
              _Page3(nextPage),
              _Page4(nextPage),
              _Page5(nextPage),
            ][page - 1],
          ),
        ),
      );
}

class _Page1 extends StatefulWidget {
  final void Function() nextPage;
  const _Page1(this.nextPage);

  @override
  State<_Page1> createState() => _Page1State();
}

class _Page1State extends State<_Page1> {
  bool visible = false, buttonVisible = false;

  @override
  void initState() {
    super.initState();
    sleep(4, then: () => setState(() => visible = true));
    sleep(6, then: () => setState(() => buttonVisible = true));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 2),
        const Text(
          'Humans have color vision\n'
          'because the retina has 3 types of cone cells.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 32),
        ),
        const Spacer(),
        Fader(
          visible,
          child: Image.asset(
            'assets/retina_diagram.png',
            width: 500,
          ),
        ),
        const Spacer(flex: 2),
        Fader(buttonVisible, child: ContinueButton(onPressed: visible ? widget.nextPage : null)),
        const Spacer(),
      ],
    );
  }
}

class _Page2 extends StatefulWidget {
  final void Function() nextPage;
  const _Page2(this.nextPage);

  @override
  State<_Page2> createState() => _Page2State();
}

class _Page2State extends State<_Page2> {
  bool visible = false, buttonVisible = false;

  final Map<SuperColor, bool> colorVisible = {
    for (final color in SuperColors.primaries) color: false
  };

  void startTransition() async {
    await sleep(6);
    setState(() => visible = true);
    await sleep(4.5);
    for (final color in SuperColors.primaries) {
      setState(() => colorVisible[color] = true);
      await sleep(1);
    }
    setState(() => buttonVisible = true);
  }

  void endTransition() async {
    setState(() => visible = false);

    await Future.delayed(duration);
    setState(() => expanded = true);

    await Future.delayed(duration);
    setState(() => squeezed = true);

    await Future.delayed(squeezeDuration);
    widget.nextPage();
  }

  @override
  void initState() {
    super.initState();
    startTransition();
  }

  static const duration = Duration(milliseconds: 1500);
  static const squeezeDuration = Duration(seconds: 2);
  static const squeezeCurve = Curves.easeInExpo;

  bool expanded = false;
  bool squeezed = false;

  @override
  Widget build(BuildContext context) {
    final double width = expanded ? 0 : context.screenWidth / 25;
    final colors = Row(
      children: [
        for (final color in SuperColors.primaries)
          Expanded(
            child: Fader(
              colorVisible[color]!,
              child: AnimatedContainer(
                duration: duration,
                curve: curve,
                color: color,
                alignment: Alignment.center,
                margin: EdgeInsets.only(left: width),
                child: Fader(
                  visible,
                  duration: duration,
                  curve: curve,
                  child: Text(
                    color.name,
                    style: const TextStyle(
                      color: SuperColors.darkBackground,
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(color: Colors.white12, blurRadius: 1),
                        Shadow(color: Colors.white12, blurRadius: 4),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        AnimatedSize(
          duration: duration,
          curve: curve,
          child: SizedBox(width: width),
        ),
      ],
    );
    final description = AnimatedSize(
      duration: duration,
      curve: curve,
      child: SizedBox(
        height: expanded ? 0 : null,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Fader(
                visible || !buttonVisible,
                duration: duration,
                child: const Text(
                  'These 3 cone cell types can be stimulated separately\n'
                  'using 3 different light frequencies.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24),
                ),
              ),
              const FixedSpacer(48),
              Fader(
                visible,
                duration: duration,
                child: const Text(
                  'We perceive them as 3 colors.',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return Column(
      children: [
        const Spacer(flex: 3),
        description,
        const Spacer(),
        AnimatedPadding(
          duration: squeezeDuration,
          curve: squeezeCurve,
          padding: squeezed
              ? EdgeInsets.symmetric(horizontal: context.screenWidth / 2)
              : EdgeInsets.zero,
          child: AnimatedContainer(
            duration: squeezeDuration,
            height: expanded ? context.screenHeight : 300,
            child: Stack(
              children: [
                colors,
                Center(
                  child: AnimatedContainer(
                    duration: squeezeDuration,
                    curve: squeezeCurve,
                    constraints: const BoxConstraints.expand(),
                    color: squeezed ? Colors.white : const Color(0x00FFFFFF),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(flex: 2),
        Fader(
          visible && buttonVisible,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 500),
            child: squeezed ? empty : ContinueButton(onPressed: endTransition),
          ),
        ),
        const Spacer(flex: 2),
      ],
    );
  }
}

class _Page3 extends StatefulWidget {
  final void Function() nextPage;
  const _Page3(this.nextPage);

  @override
  State<_Page3> createState() => _Page3State();
}

class _Page3State extends State<_Page3> {
  late final Ticker ticker;
  int counter = 0;

  void animate() async {
    await sleep(5);
    setState(() => eachPixelVisible = true);
    await sleep(8);
    setState(() => visible = true);
    await sleep(5);
    ticker = Ticker((_) => setState(
          () => (++counter % 2 == 0) ? epicHue = (epicHue + 1) % 360 : (),
        ))
      ..start();
    await sleep(3);
    setState(() => buttonVisible = true);
  }

  @override
  void initState() {
    super.initState();
    animate();
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  final rainbow = BoxDecoration(
    shape: BoxShape.circle,
    gradient: SweepGradient(
      colors: [
        for (int hue = 360; hue >= 0; hue -= 5)
          Color.lerp(
            SuperColor.hue(hue),
            epicColors[hue % 360],
            diff(0.5, SuperColor.hue(hue).computeLuminance()),
          )!
      ],
    ),
    boxShadow: const [BoxShadow(blurRadius: 30)],
  );

  bool visible = false, eachPixelVisible = false, buttonVisible = false;
  @override
  Widget build(BuildContext context) {
    final width = min(counter, 90) * 400 / 90;
    final Color epicFull = epicColor,
        epicHalf = epicColor.withAlpha(0x80),
        epicClear = epicColor.withAlpha(0);
    final epicCircle = AnimatedContainer(
      duration: const Duration(milliseconds: 1),
      curve: curve,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [epicFull, epicClear]),
      ),
      width: width,
    );
    final epicCircle2 = AnimatedContainer(
      duration: const Duration(milliseconds: 1),
      curve: curve,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [epicHalf, epicClear]),
      ),
      width: width,
    );

    final floatingCircle = Container(
      height: 415,
      alignment: Alignment(0, sin((epicHue) / 360 * 2 * pi * 3)),
      child: SizedBox(
        height: 410,
        child: SizedBox(
          height: width,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 1),
                curve: curve,
                decoration: rainbow,
                width: width,
              ),
              epicCircle,
              epicCircle2,
              const Text(
                'over\n16 million\ncolors',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: SuperColors.darkBackground,
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Column(
      children: [
        const Spacer(flex: 3),
        const Text(
          'This screen uses the standard RGB color space.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24),
        ),
        const FixedSpacer(25),
        Fader(
          eachPixelVisible,
          child: const Text(
            'Each pixel has a number between 0 and 255\n'
            'to represent how bright each color channel should be.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24),
          ),
        ),
        const Spacer(flex: 2),
        Fader(
          visible,
          child: const Text(
            'With 256 different levels for red, green, and blue,\n'
            'this device is able to display',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24),
          ),
        ),
        const Spacer(),
        floatingCircle,
        const Spacer(flex: 3),
        Fader(
          buttonVisible,
          child: ContinueButton(onPressed: counter > 0 ? widget.nextPage : null),
        ),
        const Spacer(flex: 2),
      ],
    );
  }
}

class _Page4 extends StatefulWidget {
  final void Function() nextPage;
  const _Page4(this.nextPage);

  @override
  State<_Page4> createState() => _Page4State();
}

class _Page4State extends State<_Page4> {
  bool visible = false, buttonVisible = false;

  @override
  void initState() {
    super.initState();
    sleep(4, then: () => setState(() => visible = true));
    sleep(6, then: () => setState(() => buttonVisible = true));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 2),
        const Text(
          'You can describe a color\nby listing out the red, green, and blue values.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24),
        ),
        const Spacer(),
        Fader(
          visible,
          child: const Text(
            "But wouldn't it be great if every color had a single word\n"
            'that could describe every shade?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24),
          ),
        ),
        const Spacer(flex: 2),
        Fader(buttonVisible, child: ContinueButton(onPressed: widget.nextPage)),
        const Spacer(),
      ],
    );
  }
}

class _Page5 extends StatefulWidget {
  final void Function() nextPage;
  const _Page5(this.nextPage);

  @override
  State<_Page5> createState() => _Page5State();
}

class _Page5State extends State<_Page5> {
  bool visible = false, buttonVisible = false;

  @override
  void initState() {
    super.initState();
    sleep(4, then: () => setState(() => visible = true));
    sleep(6, then: () => setState(() => buttonVisible = true));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 2),
        const Text(
          'Fortunately, we can do exactly that.\nAll we need is a color wheel.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24),
        ),
        const Spacer(),
        Fader(
          visible,
          child: const Text(
            'Put red, green, and blue an equal distance apart on the wheel,',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24),
          ),
        ),
        const Spacer(),
        Fader(
          visible,
          child: const Text(
            'and then fill the rest in.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24),
          ),
        ),
        const Spacer(flex: 2),
        Fader(buttonVisible, child: ContinueButton(onPressed: widget.nextPage)),
        const Spacer(),
      ],
    );
  }
}
