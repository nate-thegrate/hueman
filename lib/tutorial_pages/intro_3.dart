import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:super_hueman/data/super_color.dart';
import 'package:super_hueman/data/super_container.dart';
import 'package:super_hueman/pages/intro.dart';
import 'package:super_hueman/data/structs.dart';
import 'package:super_hueman/data/widgets.dart';

class Intro3Tutorial extends StatefulWidget {
  const Intro3Tutorial({super.key});

  @override
  State<Intro3Tutorial> createState() => _Intro3TutorialState();
}

class _Intro3TutorialState extends State<Intro3Tutorial> {
  bool visible = false;
  late final pages = [
    _Page1(nextPage),
    _Page2(nextPage),
    _Page3(nextPage),
    _Page4(nextPage),
    _Page5(nextPage),
    _Page6(nextPage),
    _Page7(nextPage),
    const _FinalPage(),
  ];
  int page = 1;

  Duration duration = oneSec;

  void nextPage() async {
    setState(() => duration = halfSec);
    if (page == 6) setState(() => backgroundColor = Colors.black);
    setState(() => visible = false);
    if (page != 2) await sleep(1);
    setState(() {
      page++;
      if (page < 7) duration = oneSec;
    });
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

class _Page1State extends SafeState<_Page1> {
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
        const EasyText(
          'Humans have color vision\n'
          'because the retina has 3 types of cone cells.',
          size: 26,
        ),
        const Spacer(),
        Fader(
          visible,
          child: Image.asset('assets/retina_diagram.png', width: 500),
        ),
        const Spacer(flex: 2),
        Fader(buttonVisible, child: ContinueButton(onPressed: widget.nextPage)),
        const Spacer(),
      ],
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
  bool visible = false, buttonVisible = false;

  final Map<SuperColor, bool> colorVisible = {
    for (final color in SuperColors.primaries) color: false
  };

  void startTransition() async {
    await sleep(6);
    setState(() => visible = true);

    await sleep(4);
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
    return Stack(
      children: [
        Column(
          children: [
            const Spacer(flex: 3),
            AnimatedSize(
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
                        child: const EasyText(
                          'These 3 cone cell types can be stimulated separately\n'
                          'using 3 different light frequencies.',
                        ),
                      ),
                      const FixedSpacer(48),
                      Fader(
                        visible,
                        duration: duration,
                        child: const EasyText('We perceive them as 3 colors.'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            AnimatedPadding(
              duration: squeezeDuration,
              curve: squeezeCurve,
              padding: squeezed
                  ? EdgeInsets.symmetric(horizontal: context.screenWidth / 2)
                  : EdgeInsets.zero,
              child: AnimatedContainer(
                duration: squeezeDuration,
                curve: Curves.easeInQuad,
                height: expanded ? context.screenHeight : 300,
                child: Stack(
                  children: [
                    Row(
                      children: [
                        for (final color in SuperColors.primaries)
                          _RGBAnimation(
                            color,
                            colorVisible: colorVisible[color]!,
                            textVisible: visible,
                            duration: duration,
                            margin: width,
                          ),
                        AnimatedSize(
                          duration: duration,
                          curve: curve,
                          child: SizedBox(width: width),
                        ),
                      ],
                    ),
                    Center(
                      child: AnimatedContainer(
                        duration: squeezeDuration,
                        curve: squeezeCurve,
                        color: squeezed ? Colors.white : const Color(0x00FFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(flex: 4),
          ],
        ),
        Align(
          alignment: const Alignment(0, .75),
          child: Fader(
            visible && buttonVisible,
            child: ContinueButton(onPressed: endTransition),
          ),
        ),
      ],
    );
  }
}

class _RGBAnimation extends StatelessWidget {
  const _RGBAnimation(
    this.color, {
    required this.colorVisible,
    required this.textVisible,
    required this.duration,
    required this.margin,
  });
  final Duration duration;
  final bool colorVisible, textVisible;
  final SuperColor color;
  final double margin;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Fader(
          colorVisible,
          child: AnimatedContainer(
            duration: duration,
            curve: curve,
            color: color,
            alignment: Alignment.center,
            margin: EdgeInsets.only(left: margin),
            child: Fader(
              textVisible,
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
      );
}

class _Page3 extends StatefulWidget {
  const _Page3(this.nextPage);
  final void Function() nextPage;

  @override
  State<_Page3> createState() => _Page3State();
}

class _Page3State extends SafeState<_Page3> {
  bool visible = false, eachPixelVisible = false, unleashTheOrb = false, buttonVisible = false;

  void animate() async {
    final List<(double, void Function())> animation = [
      (5, () => eachPixelVisible = true),
      (8, () => visible = true),
      (5, () => unleashTheOrb = true),
      (3, () => buttonVisible = true),
    ];

    for (final (sleepFor, action) in animation) {
      await sleep(sleepFor);
      setState(action);
    }
  }

  @override
  void initState() {
    super.initState();
    animate();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 3),
        const EasyText('This screen uses the standard RGB color space.'),
        const FixedSpacer(25),
        Fader(
          eachPixelVisible,
          child: const EasyText(
            'Each pixel has a number between 0 and 255\n'
            'to represent how bright each color channel should be.',
          ),
        ),
        const Spacer(flex: 2),
        Fader(
          visible,
          child: const EasyRichText([
            TextSpan(text: 'With 256 different levels for '),
            ColorTextSpan(SuperColors.red),
            TextSpan(text: ', '),
            ColorTextSpan(SuperColors.green),
            TextSpan(text: ', and '),
            ColorTextSpan(SuperColors.visibleBlue),
            TextSpan(text: ',\nthis device is able to display'),
          ]),
        ),
        const Spacer(),
        SizedBox(height: 415, child: unleashTheOrb ? const _ColorOrb() : empty),
        const Spacer(flex: 3),
        Fader(
          buttonVisible,
          child: ContinueButton(onPressed: widget.nextPage),
        ),
        const Spacer(flex: 2),
      ],
    );
  }
}

class _ColorOrb extends StatefulWidget {
  const _ColorOrb();

  @override
  State<_ColorOrb> createState() => _ColorOrbState();
}

class _ColorOrbState extends State<_ColorOrb> {
  late final Ticker ticker;
  int counter = 0;

  @override
  void initState() {
    super.initState();
    ticker = Ticker((_) => setState(() {
          if (++counter % 2 == 0) epicHue = (epicHue + 1) % 360;
        }))
      ..start();
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  static const rainbow = BoxDecoration(
    shape: BoxShape.circle,
    gradient: SweepGradient(colors: SuperColors.orb),
    boxShadow: [BoxShadow(blurRadius: 30)],
  );

  static const over16mil = Text(
    'over\n16 million\ncolors',
    textAlign: TextAlign.center,
    style: TextStyle(
      color: SuperColors.darkBackground,
      fontSize: 56,
      fontWeight: FontWeight.bold,
      height: 1.5,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final double width = min(counter, 100) * 4;
    final SuperColor epic = epicColor;

    return Align(
      alignment: Alignment(0, sin((epicHue) / 360 * 2 * pi * 3)),
      child: SizedBox(
        height: 410,
        child: SizedBox(
          height: width,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SuperContainer(
                decoration: rainbow,
                width: width,
                height: width,
              ),
              _OrbCenter(epic, width: width),
              _OrbCenter(epic, width: width, opaque: true),
              over16mil,
            ],
          ),
        ),
      ),
    );
  }
}

class _OrbCenter extends StatelessWidget {
  const _OrbCenter(this.epicColor, {required this.width, this.opaque = false});
  final SuperColor epicColor;
  final double width;
  final bool opaque;

  @override
  Widget build(BuildContext context) => SuperContainer(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              if (opaque) epicColor else epicColor.withAlpha(0x80),
              epicColor.withAlpha(0),
            ],
          ),
        ),
        width: width,
        height: width,
      );
}

class _Page4 extends StatefulWidget {
  const _Page4(this.nextPage);
  final void Function() nextPage;

  @override
  State<_Page4> createState() => _Page4State();
}

class _Page4State extends SafeState<_Page4> {
  bool showScreenshot = false, sometimesUgotta = false, showButton = false;

  void animate() async {
    final List<VoidCallback> steps = [
      () => showScreenshot = true,
      () => sometimesUgotta = true,
      () => showButton = true,
    ];

    for (final action in steps) {
      await sleep(3);
      setState(action);
    }
  }

  @override
  void initState() {
    super.initState();
    animate();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 4),
        const EasyText("Whether you're making wedding invitations"),
        const Spacer(),
        Image.asset('assets/wedding_invite.png', width: context.screenWidth * 2 / 3),
        const Spacer(flex: 4),
        Fader(
          showScreenshot,
          child: const EasyRichText([
            TextSpan(text: 'or making '),
            TextSpan(
              text: 'code',
              style: TextStyle(fontFamily: 'consolas', color: SuperColor(0x00FFEE)),
            ),
            TextSpan(text: ' for a video game,'),
          ]),
        ),
        const Spacer(),
        Fader(showScreenshot, child: Image.asset('assets/picture_of_itself.png')),
        const Spacer(flex: 4),
        Fader(
          sometimesUgotta,
          child: const EasyText('Sometimes you gotta tell a computer what color you want.'),
        ),
        const Spacer(flex: 3),
        Fader(showButton, child: ContinueButton(onPressed: widget.nextPage)),
        const Spacer(flex: 3),
      ],
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
  int textProgress = 0;

  void animate() async {
    for (final (_, sleepyTime) in text) {
      await sleep(sleepyTime);
      setState(() => textProgress++);
    }
    await sleep(2.5);
    setState(() => textProgress++);
  }

  @override
  void initState() {
    super.initState();
    animate();
  }

  static const List<(Widget line, double timeToRead)> text = [
    (
      EasyRichText([
        TextSpan(text: "Let's take "),
        ColorTextSpan(SuperColors.green),
      ]),
      2.5
    ),
    (
      EasyRichText([
        TextSpan(text: 'and make it just a little bit '),
        ColorTextSpan(SuperColors.yellow),
        TextSpan(text: '.'),
      ]),
      2
    ),
    (Spacer(), 2),
    (EasyText('How would you describe that color?'), 2),
    (Spacer(), 2),
    (EasyText('You could call it by its RGB value,'), 3.5),
    (EasyText('or just make up a name for it.'), 1.5),
  ];

  static const List<(String, SuperColor)> colorCode = [
    ('red: 128', SuperColor(0x800000)),
    ('green: 255', SuperColor(0x00FF00)),
    ('blue: 0', SuperColor(0x000000)),
  ];

  late final colorCodeBox = SuperContainer(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: SuperColors.darkBackground.withAlpha(0x60),
    ),
    margin: EdgeInsets.symmetric(horizontal: context.screenWidth / 16),
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        const Spacer(),
        for (final (desc, color) in colorCode) ...[
          Text(
            desc,
            style: TextStyle(
              fontFamily: 'Consolas',
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const Spacer(),
        ],
      ],
    ),
  );

  static const colorName = Column(
    children: [
      Text(
        '"chartreuse"',
        style: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: SuperColors.darkBackground,
          height: 1.25,
        ),
      ),
      Text(
        '(not a great name tbh)',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: SuperColors.darkBackground,
          letterSpacing: 0,
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final double width = min(context.screenWidth * 2 / 3, 800);
    return Column(
      children: [
        const Spacer(flex: 2),
        for (int i = 0; i < text.length; i++)
          switch (text[i].$1) {
            final Spacer s => s,
            _ => Fader(i <= textProgress, child: text[i].$1),
          },
        const Spacer(),
        Expanded(
            flex: 3,
            child: SizedBox(
              width: width,
              child: Stack(
                children: [
                  const SuperContainer(color: SuperColors.green),
                  Fader(
                    textProgress > 0,
                    curve: curve,
                    child: AnimatedSlide(
                      duration: halfSec,
                      offset: textProgress > 1 ? Offset.zero : const Offset(0, -1),
                      curve: Curves.easeInQuad,
                      child: Align(
                        alignment: Alignment.center,
                        child: AnimatedSize(
                          duration: const Duration(seconds: 3),
                          curve: curve,
                          child: SuperContainer(
                            width: textProgress > 2 ? width : width / 2,
                            decoration: const BoxDecoration(
                              backgroundBlendMode: BlendMode.screen,
                              color: Color(0x80FFFF00),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Fader(textProgress > 4, child: colorCodeBox),
                      const FixedSpacer(30),
                      Fader(textProgress > 5, child: colorName),
                    ],
                  ),
                ],
              ),
            )),
        const Spacer(),
        Fader(
          textProgress > 7,
          child: ContinueButton(onPressed: widget.nextPage),
        ),
        const Spacer(),
      ],
    );
  }
}

class _Page6 extends StatefulWidget {
  const _Page6(this.nextPage);
  final void Function() nextPage;

  @override
  State<_Page6> createState() => _Page6State();
}

class _Page6State extends SafeState<_Page6> with DelayedPress {
  bool wishVisible = false, tooBadVisible = false, justKidding = false, buttonVisible = false;
  late final Ticker? epicHues;

  @override
  void initState() {
    super.initState();
    animate();
  }

  @override
  void dispose() {
    epicHues?.dispose();
    super.dispose();
  }

  void animate() async {
    await sleep(0.75);
    setState(() => wishVisible = true);

    await sleep(0.5);
    for (int i = 0; i < hsvWidth * hsvHeight; i++) {
      await sleep(0.05);
      setState(() => hsvGrid[i] = (tile: hsvGrid[i].tile, scale: 17 / 16));
    }

    await sleep(2);
    setState(() => tooBadVisible = true);

    await sleep(4.5);
    setState(() => justKidding = true);

    await sleep(2);
    setState(() {
      epicHue = 90;
      buttonVisible = true;
    });

    await sleep(0.5);
    if (mounted) {
      epicHues = epicSetup(setState);
      epicHue = 90;
    }
  }

  static const hsvWidth = 9, hsvHeight = 5;
  static const duration = Duration(milliseconds: 250);

  final List<({Widget tile, double scale})> hsvGrid = [
    for (int value = hsvHeight; value > 0; value--)
      for (int saturation = 1; saturation <= hsvWidth; saturation++)
        (
          tile: ColoredBox(
            color: SuperColor.hsv(
              90,
              (saturation + 2) / (hsvWidth + 2),
              (value + 1) / (hsvHeight + 1),
            ),
          ),
          scale: 0,
        )
  ];

  @override
  Widget build(BuildContext context) {
    final tileWidth = context.screenWidth / (hsvWidth + 2);

    return Stack(
      children: [
        Column(
          children: [
            const Spacer(flex: 2),
            SizedBox(
              height: 5 * tileWidth,
              width: context.screenWidth,
              child: GridView.count(
                padding: EdgeInsets.symmetric(horizontal: tileWidth),
                primary: false,
                crossAxisCount: hsvWidth,
                children: [
                  for (final item in hsvGrid)
                    AnimatedScale(scale: item.scale, duration: duration, child: item.tile)
                ],
              ),
            ),
            const Spacer(),
            Fader(
              wishVisible,
              child: const EasyText(
                'I wish I could describe every shade of this color\nwith a single name.',
              ),
            ),
            const Spacer(),
            Fader(
              tooBadVisible,
              child: const EasyText("Too bad there's no way to do that…"),
            ),
            const Spacer(flex: 2),
          ],
        ),
        if (justKidding)
          _JustKidding(
            duration: duration,
            buttonVisible: buttonVisible,
            color: epicColor,
            nextPage: delayed(widget.nextPage),
          ),
      ],
    );
  }
}

class _JustKidding extends StatelessWidget {
  const _JustKidding({
    required this.duration,
    required this.buttonVisible,
    required this.color,
    required this.nextPage,
  });
  final Duration duration;
  final bool buttonVisible;
  final SuperColor color;
  final void Function() nextPage;

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      duration: duration,
      child: SuperContainer(
        color: Colors.black,
        width: double.infinity,
        child: Column(
          children: [
            const Spacer(),
            const Text(
              'just kidding  :)',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w100),
            ),
            const Spacer(flex: 3),
            Fader(
              buttonVisible,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: color,
                  side: BorderSide(color: color, width: 2),
                  shadowColor: color,
                  elevation: epicSine * 8,
                ),
                onPressed: nextPage,
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(25, 10, 25, 15),
                  child: Text(
                    'HUE',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _Page7 extends StatefulWidget {
  const _Page7(this.nextPage);
  final void Function() nextPage;

  @override
  State<_Page7> createState() => _Page7State();
}

class _Page7State extends State<_Page7> {
  Widget overlay = const SuperContainer(
    color: Colors.black,
    alignment: Alignment.center,
    child: EasyText('finding a hue\ncan be done in two steps.', size: 36),
  );
  static const overlay2 = SuperContainer(color: Colors.black);
  bool showOverlay2 = false;

  late final Ticker animateHue;
  int step = 0;
  double _hue = 0;
  static const duration = Duration(seconds: 3);

  void smoothHue(Duration elapsed) {
    if (elapsed >= duration) return animateHue.dispose();

    final double t, newHue;
    t = min(elapsed.inMicroseconds / duration.inMicroseconds, 1);
    newHue = 90 * curve.transform(t);

    setState(() => _hue = newHue);
  }

  void animate() async {
    await sleep(3);
    setState(() => showOverlay2 = true);

    await sleep(1);
    setState(() {
      overlay = empty;
      showOverlay2 = false;
    });

    const List<double> sleepyTime = [3, 3, 1, 5, 3, 1];
    for (final time in sleepyTime) {
      await sleep(time);
      setState(() => step++);
      if (step == 4) animateHue = Ticker(smoothHue)..start();
    }

    await sleep(4.5);
    widget.nextPage();
  }

  @override
  void initState() {
    super.initState();
    animate();
  }

  static const step1 = 'Step 1: Find a color wheel.';
  static const step2 = 'Step 2: Measure the angle to your color, starting at red.';

  @override
  Widget build(BuildContext context) {
    final width = min(context.screenWidth * 0.8, context.screenHeight * .8 - 250);
    final hue = _hue.ceil();

    return Stack(
      children: [
        Column(
          children: [
            const Spacer(flex: 4),
            const EasyText(step1),
            const Spacer(),
            Fader(
              step >= 2,
              child: const EasyText(step2),
            ),
            const Spacer(flex: 4),
            MeasuringOrb(
              step: step,
              width: width,
              duration: duration,
              hue: 90,
              lineColor: Colors.black,
            ),
            const Spacer(flex: 4),
            _HueBox(step: step, width: width, hue: hue),
            const Spacer(flex: 4),
          ],
        ),
        overlay,
        Fader(showOverlay2, child: overlay2),
      ],
    );
  }
}

class _HueBox extends StatelessWidget {
  const _HueBox({
    required this.step,
    required this.width,
    required this.hue,
  });
  final int step;
  final double width;
  final int hue;

  @override
  Widget build(BuildContext context) {
    final color = SuperColor.hue(hue);

    return SuperContainer(
      height: 100 + width / 8,
      alignment: Alignment.center,
      child: Fader(
        step >= 2,
        duration: const Duration(milliseconds: 400),
        child: SexyBox(
          child: SuperContainer(
            width: step < 2 ? 20 : width,
            color: color,
            padding: const EdgeInsets.all(10),
            child: SexyBox(
              child: step < 3
                  ? empty
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SexyBox(
                          child: step < 6
                              ? const SizedBox(height: 75)
                              : SizedBox(
                                  width: width / 2,
                                  child: Center(
                                    child: Text(
                                      '"chartreuse"',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: width * 0.0667,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                        Expanded(
                          child: SuperContainer(
                            color: SuperColors.darkBackground,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(25),
                            child: Text(
                              'hue = $hue',
                              style: TextStyle(color: color, fontSize: width * 0.06),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FinalPage extends StatefulWidget {
  const _FinalPage();

  @override
  State<_FinalPage> createState() => _FinalPageState();
}

class _FinalPageState extends SafeState<_FinalPage> with DelayedPress {
  late final Ticker epicHues;
  bool visible = false, buttonVisible = false, expanded = false;
  double width = 0;

  void animate() async {
    final List<void Function()> animation = [
      () => visible = true,
      () => width = 300,
      () => expanded = true,
      () => buttonVisible = true,
    ];

    for (final action in animation) {
      await sleep(1);
      setState(action);
    }
  }

  late VoidCallback onPressed = delayed(() => Navigator.pushReplacement<void, void>(
        context,
        MaterialPageRoute<void>(builder: (context) => const IntroMode(3)),
      ));

  @override
  void initState() {
    super.initState();
    epicHues = epicSetup(setState);
    animate();
  }

  @override
  void dispose() {
    epicHues.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SuperContainer(
      color: SuperColors.darkBackground,
      alignment: Alignment.center,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        _AreYouReady(color: epicColor),
        const FixedSpacer(50),
        Fader(
          visible,
          child: DecoratedBox(
            decoration: BoxDecoration(border: Border.all(color: epicColor, width: 2)),
            child: SexyBox(
              child: expanded
                  ? SizedBox(
                      width: width,
                      height: 250,
                      child: _PlayButton(
                        visible: buttonVisible,
                        color: epicColor,
                        onPressed: onPressed,
                      ),
                    )
                  : SizedBox(width: width),
            ),
          ),
        ),
      ]),
    );
  }
}

class _AreYouReady extends StatelessWidget {
  const _AreYouReady({required this.color});
  final SuperColor color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const FixedSpacer.horizontal(5),
        Text(
          'are',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: Text(
            'YOU',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          'ready?',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ],
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.visible, required this.color, required this.onPressed});
  final bool visible;
  final SuperColor color;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'intro',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, height: 2),
        ),
        const Text(
          'learn the RGB hues',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: SuperColors.white80,
          ),
        ),
        const FixedSpacer(33),
        Fader(
          visible,
          child: SuperButton(
            'play',
            color: color,
            onPressed: onPressed,
          ),
        ),
        const FixedSpacer(16),
      ],
    );
  }
}
