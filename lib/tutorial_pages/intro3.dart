import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:super_hueman/data/color_lists.dart';
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
    const _FinalPage(),
  ];
  int page = 1;

  Duration duration = oneSec;

  void nextPage() async {
    setState(() => duration = halfSec);
    if (page == 5) setState(() => backgroundColor = Colors.black);
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

class _EasyText extends StatelessWidget {
  final String data;
  final double size;
  const _EasyText(this.data, {this.size = 24});

  @override
  Widget build(BuildContext context) {
    return Text(data, textAlign: TextAlign.center, style: TextStyle(fontSize: size));
  }
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
        const _EasyText(
          'Humans have color vision\n'
          'because the retina has 3 types of cone cells.',
          size: 32,
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

class _RGBAnimation extends StatelessWidget {
  final Duration duration;
  final bool colorVisible, textVisible;
  final SuperColor color;
  final double margin;

  const _RGBAnimation(
    this.color, {
    required this.colorVisible,
    required this.textVisible,
    required this.duration,
    required this.margin,
  });

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

class _Page2State extends State<_Page2> {
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
    return Column(
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
                    child: const _EasyText(
                      'These 3 cone cell types can be stimulated separately\n'
                      'using 3 different light frequencies.',
                    ),
                  ),
                  const FixedSpacer(48),
                  Fader(
                    visible,
                    duration: duration,
                    child: const _EasyText('We perceive them as 3 colors.'),
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
            duration: const Duration(milliseconds: 300),
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
    gradient: SweepGradient(colors: orbColors),
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
              DecoratedBox(
                decoration: rainbow,
                child: SizedBox(width: width, height: width),
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
  final SuperColor epicColor;
  final double width;
  final bool opaque;
  const _OrbCenter(this.epicColor, {required this.width, this.opaque = false});

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              opaque ? epicColor : epicColor.withAlpha(0x80),
              epicColor.withAlpha(0),
            ],
          ),
        ),
        child: SizedBox(width: width, height: width),
      );
}

class _Page3State extends State<_Page3> {
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
        const _EasyText('This screen uses the standard RGB color space.'),
        const FixedSpacer(25),
        Fader(
          eachPixelVisible,
          child: const _EasyText(
            'Each pixel has a number between 0 and 255\n'
            'to represent how bright each color channel should be.',
          ),
        ),
        const Spacer(flex: 2),
        Fader(
          visible,
          child: const _EasyText(
            'With 256 different levels for red, green, and blue,\n'
            'this device is able to display',
          ),
        ),
        const Spacer(),
        SizedBox(
          height: 415,
          child: unleashTheOrb ? const _ColorOrb() : empty,
        ),
        const Spacer(flex: 3),
        Fader(
          buttonVisible,
          child: ContinueButton(onPressed: buttonVisible ? widget.nextPage : null),
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

  static const List<(String line, double timeToRead)> text = [
    ("Let's take green", 2.5),
    ('and add a bit of red.', 2),
    ('', 2),
    ('How would you describe that color?', 2),
    ('', 2),
    ('You could call it by its RGB value,', 3.5),
    ('or just make up a name for it.', 1.5),
  ];

  static const bitOfRed = DecoratedBox(
    decoration: BoxDecoration(
      backgroundBlendMode: BlendMode.screen,
      color: SuperColor(0x800000),
    ),
    child: SizedBox.expand(),
  );

  static const List<(String, SuperColor)> colorCode = [
    ('red: 128', SuperColor(0x800000)),
    ('green: 255', SuperColor(0x00FF00)),
    ('blue: 0', SuperColor(0x000000)),
  ];

  late final colorCodeBox = Container(
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
    return Column(
      children: [
        const Spacer(flex: 2),
        for (int i = 0; i < text.length; i++)
          text[i].$1.isEmpty
              ? const Spacer()
              : Fader(
                  i <= textProgress,
                  child: _EasyText(text[i].$1),
                ),
        const Spacer(),
        Expanded(
            flex: 3,
            child: SizedBox(
              width: min(context.screenWidth * 2 / 3, 800),
              child: Stack(
                children: [
                  const ColoredBox(color: SuperColors.green, child: SizedBox.expand()),
                  Fader(
                    textProgress > 0,
                    curve: curve,
                    child: AnimatedSlide(
                      duration: halfSec,
                      offset: textProgress > 1 ? Offset.zero : const Offset(0, -1),
                      curve: Curves.easeInQuad,
                      child: bitOfRed,
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
          child: ContinueButton(onPressed: textProgress > 7 ? widget.nextPage : null),
        ),
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
  bool wishVisible = false, tooBadVisible = false, justKidding = false, buttonVisible = false;
  late final Ticker epicHues;

  @override
  void initState() {
    super.initState();
    animate();
  }

  @override
  void dispose() {
    epicHues.dispose();
    super.dispose();
  }

  void animate() async {
    await sleep(0.75);
    setState(() => wishVisible = true);

    await sleep(0.5);
    for (int i = 0; i < hsvWidth * hsvHeight; i++) {
      await sleep(0.05);
      setState(() => hsvGrid[i] = (tile: hsvGrid[i].tile, scale: 1 + 1 / 16));
    }

    await sleep(2);
    setState(() => tooBadVisible = true);

    await sleep(4.5);
    setState(() => justKidding = true);

    await sleep(2);
    epicHues = epicSetup(setState);
    setState(() => buttonVisible = true);
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
              child: const _EasyText(
                'I wish I could describe every shade of this color\nwith a single name.',
              ),
            ),
            const Spacer(),
            Fader(
              tooBadVisible,
              child: const _EasyText("Too bad there's no way to do that…"),
            ),
            const Spacer(flex: 2),
          ],
        ),
        justKidding
            ? _JustKidding(
                duration: duration,
                buttonVisible: buttonVisible,
                color: epicColor,
                nextPage: widget.nextPage,
              )
            : empty,
      ],
    );
  }
}

class _JustKidding extends StatelessWidget {
  final Duration duration;
  final bool buttonVisible;
  final SuperColor color;
  final void Function() nextPage;

  const _JustKidding({
    required this.duration,
    required this.buttonVisible,
    required this.color,
    required this.nextPage,
  });

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      duration: duration,
      child: ColoredBox(
        color: Colors.black,
        child: SizedBox.expand(
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
      ),
    );
  }
}

class _Page6 extends StatefulWidget {
  final void Function() nextPage;
  const _Page6(this.nextPage);

  @override
  State<_Page6> createState() => _Page6State();
}

class _Page6State extends State<_Page6> {
  Widget overlay = const ColoredBox(
    color: Colors.black,
    child: SizedBox.expand(
      child: Center(
        child: _EasyText('finding a hue\ncan be done in two steps.', size: 36),
      ),
    ),
  );
  static const overlay2 = ColoredBox(color: Colors.black, child: SizedBox.expand());
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
      if (step == 4) {
        animateHue = Ticker(smoothHue)..start();
      }
    }

    await sleep(4.5);
    widget.nextPage();
  }

  @override
  void initState() {
    super.initState();
    animate();
  }

  @override
  Widget build(BuildContext context) {
    final width = min(context.screenWidth * 0.8, context.screenHeight * .8 - 250);
    final hue = _hue.ceil();

    return Stack(
      children: [
        Column(
          children: [
            const Spacer(flex: 4),
            const _EasyText('Step 1: Find a color wheel.'),
            const Spacer(),
            Fader(
              step >= 2,
              child: const _EasyText(
                'Step 2: Measure the angle to your color, starting at red.',
              ),
            ),
            const Spacer(flex: 4),
            _MeasuringOrb(step: step, width: width, duration: duration, hue: '$hue°'),
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

class _MeasuringOrb extends StatelessWidget {
  final int step;
  final double width;
  final Duration duration;
  final String hue;

  const _MeasuringOrb({
    required this.step,
    required this.width,
    required this.duration,
    required this.hue,
  });

  @override
  Widget build(BuildContext context) {
    return Fader(
      step >= 1,
      child: SizedBox(
        width: width + 2,
        height: width,
        child: Stack(
          children: [
            const DecoratedBox(
              decoration: SuperColors.colorWheel,
              child: SizedBox.expand(),
            ),
            Fader(
              step >= 2,
              child: Padding(
                padding: EdgeInsets.fromLTRB(width / 2, width / 2 + 2, 0, 0),
                child: Stack(
                  children: [
                    const Divider(
                      height: 0,
                      color: Colors.black,
                      thickness: 4,
                    ),
                    AnimatedRotation(
                      turns: step >= 4 ? -0.25 : 0,
                      curve: curve,
                      duration: duration,
                      alignment: Alignment.bottomLeft,
                      child: const Divider(
                        height: 0,
                        color: Colors.black,
                        thickness: 4,
                      ),
                    ),
                    Fader(
                      step >= 5,
                      child: Transform.translate(
                        offset: const Offset(-4, 0),
                        child: Transform.rotate(
                          angle: -pi / 2,
                          alignment: Alignment.topLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 4),
                            ),
                            width: 25,
                            height: 25,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Fader(
              step >= 2,
              child: Align(
                alignment: Alignment.topCenter,
                child: Transform.translate(
                    offset: const Offset(-3, -37),
                    child: const Icon(
                      Icons.arrow_drop_down,
                      size: 50,
                      color: SuperColors.chartreuse,
                    )),
              ),
            ),
            Fader(
              step >= 5,
              child: Align(
                alignment: const Alignment(0.2, -0.2),
                child: Text(
                  hue,
                  style: const TextStyle(
                    fontSize: 28,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HueBox extends StatelessWidget {
  final int step;
  final double width;
  final int hue;

  const _HueBox({
    required this.step,
    required this.width,
    required this.hue,
  });

  @override
  Widget build(BuildContext context) {
    final color = SuperColor.hue(hue);

    return SizedBox(
      height: 100 + width / 8,
      child: Center(
        child: Fader(
          step >= 2,
          duration: const Duration(milliseconds: 400),
          child: SexyBox(
            child: Container(
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
                            child: Container(
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
      ),
    );
  }
}

class _FinalPage extends StatefulWidget {
  const _FinalPage();

  @override
  State<_FinalPage> createState() => _FinalPageState();
}

class _FinalPageState extends State<_FinalPage> {
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
    return _FinalPageBoilerplate(
      children: [
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
                      child: _PlayButton(visible: buttonVisible, color: epicColor),
                    )
                  : SizedBox(width: width),
            ),
          ),
        ),
      ],
    );
  }
}

class _FinalPageBoilerplate extends StatelessWidget {
  final List<Widget> children;
  const _FinalPageBoilerplate({required this.children});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: SuperColors.darkBackground,
      child: SizedBox.expand(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
          ),
        ),
      ),
    );
  }
}

class _AreYouReady extends StatelessWidget {
  final SuperColor color;
  const _AreYouReady({required this.color});

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
  final bool visible;
  final SuperColor color;
  const _PlayButton({required this.visible, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'learn the\nprimary color hues',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: SuperColors.white80,
          ),
        ),
        const FixedSpacer(33),
        Fader(
          visible,
          child: SuperButton(
            'play',
            color: color,
            onPressed: () => Navigator.pushReplacement<void, void>(
              context,
              MaterialPageRoute<void>(
                builder: (context) => const IntroMode(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
