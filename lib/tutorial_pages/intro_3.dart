import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hueman/data/super_color.dart';
import 'package:hueman/data/super_container.dart';
import 'package:hueman/data/super_state.dart';
import 'package:hueman/data/super_text.dart';
import 'package:hueman/pages/intro.dart';
import 'package:hueman/data/structs.dart';
import 'package:hueman/data/widgets.dart';

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
    setState(() {
      duration = halfSec;
      if (page == 6) backgroundColor = Colors.black;
    });
    if (page != 2) {
      await quickly(() => setState(() => visible = false));
      await sleep(1);
    }
    setState(() {
      page++;
      if (page < 7) duration = oneSec;
    });
    await quickly(() => setState(() => visible = true));
  }

  @override
  void initState() {
    super.initState();
    sleep(1, then: () => setState(() => visible = true));
  }

  Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final mainContent = Center(
      child: Fader(
        visible,
        duration: duration,
        child: pages[page - 1],
      ),
    );
    return Scaffold(
      body: page == 2 ? mainContent : SafeArea(child: mainContent),
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

class _Page1State extends SuperState<_Page1> {
  bool weSee = false, imageVisible = false, buttonVisible = false;

  @override
  void animate() async {
    await sleepState(4, () => weSee = true);
    await sleepState(3, () => imageVisible = true);
    await sleepState(2, () => buttonVisible = true);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 2),
        const SuperText(
          'Humans have trichromatic vision.',
        ),
        const Spacer(),
        Fader(
          weSee,
          child: const SuperText(
            'We see colors because of\n'
            '3 types of cone cells in the retina.',
          ),
        ),
        const Spacer(),
        Fader(
          imageVisible,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Image.asset('assets/retina_diagram.png', width: 500),
          ),
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

class _Page2State extends SuperState<_Page2> {
  bool visible = false, buttonVisible = false;

  final Map<SuperColor, bool> colorVisible = {
    for (final color in SuperColors.primaries) color: false
  };

  @override
  void animate() async {
    await sleepState(4, () => visible = true);

    await sleep(4);
    for (final color in SuperColors.primaries) {
      await sleepState(1, () => colorVisible[color] = true);
    }
    await sleepState(1, () => buttonVisible = true);
  }

  void endTransition() async {
    setState(() => visible = false);

    final secs = duration.inMilliseconds / 1000;
    await sleepState(secs, () => expanded = true);
    await sleepState(secs, () => squeezed = true);

    await Future.delayed(squeezeDuration);
    widget.nextPage();
  }

  static const duration = Duration(milliseconds: 1500);
  static const squeezeDuration = Duration(seconds: 2);

  bool expanded = false, squeezed = false;

  @override
  Widget build(BuildContext context) {
    final double width = expanded ? 0 : context.screenWidth / 25;
    return Column(
      children: [
        const Spacer(flex: 3),
        AnimatedSize(
          duration: duration,
          curve: curve,
          child: expanded
              ? null
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeIn(
                      child: Fader(
                        visible || !buttonVisible,
                        duration: duration,
                        child: const SuperText(
                          'These 3 cone cell types\nreact to different light frequencies.\n',
                        ),
                      ),
                    ),
                    Fader(
                      visible,
                      duration: duration,
                      child: const SuperText(
                        'They send signals to the brain,\nwhich we perceive as 3 colors.',
                      ),
                    ),
                  ],
                ),
        ),
        const Spacer(),
        AnimatedPadding(
          duration: squeezeDuration,
          curve: Curves.easeInExpo,
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
                    curve: Curves.easeInExpo,
                    color: squeezed ? Colors.white : const Color(0x00FFFFFF),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(flex: 2),
        AnimatedSize(
          duration: duration,
          curve: curve,
          child: buttonVisible && !visible
              ? null
              : Fader(
                  buttonVisible,
                  child: ContinueButton(onPressed: endTransition),
                ),
        ),
        const Spacer(flex: 2),
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
  Widget build(BuildContext context) {
    return Expanded(
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
              style: const SuperStyle.sans(
                color: SuperColors.darkBackground,
                size: 32,
                weight: 600,
                extraBold: true,
                width: 96,
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
}

class _Page3 extends StatefulWidget {
  const _Page3(this.nextPage);
  final void Function() nextPage;

  @override
  State<_Page3> createState() => _Page3State();
}

class _Page3State extends SuperState<_Page3> {
  bool visible = false, eachPixelVisible = false, unleashTheOrb = false, buttonVisible = false;

  @override
  void animate() async {
    final List<(double, void Function())> animation = [
      (4, () => eachPixelVisible = true),
      (8, () => visible = true),
      (5, () => unleashTheOrb = true),
      (3, () => buttonVisible = true),
    ];

    for (final (sleepFor, action) in animation) {
      await sleepState(sleepFor, action);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 3),
        const SuperText('This screen uses\nthe standard RGB color space.'),
        const FixedSpacer(25),
        Fader(
          eachPixelVisible,
          child: const SuperText(
            'The brightness of each color channel\nis a value between 0 and 255.',
          ),
        ),
        const Spacer(flex: 2),
        Fader(
          visible,
          child: const SuperRichText([
            TextSpan(text: 'With 256 different levels for '),
            ColorTextSpan.red,
            TextSpan(text: ', '),
            ColorTextSpan.green,
            TextSpan(text: ', and '),
            ColorTextSpan.visibleBlue,
            TextSpan(text: ', this device can display'),
          ]),
        ),
        const Spacer(),
        SizedBox(height: 345, child: unleashTheOrb ? const _ColorOrb() : empty),
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
    style: SuperStyle.sans(
      color: SuperColors.darkBackground,
      size: 48,
      weight: 800,
      height: 1.5,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final double width = min(counter, 80) * 4;
    final SuperColor epic = epicColor;

    return Align(
      alignment: Alignment(0, sin((epicHue) / 360 * 2 * pi * 3)),
      child: SizedBox(
        height: 330,
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
  Widget build(BuildContext context) {
    return SuperContainer(
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
}

class _Page4 extends StatefulWidget {
  const _Page4(this.nextPage);
  final void Function() nextPage;

  @override
  State<_Page4> createState() => _Page4State();
}

class _Page4State extends SuperState<_Page4> {
  bool showScreenshot = false, sometimesUgotta = false, showButton = false;

  @override
  void animate() async {
    final List<VoidCallback> steps = [
      () => showScreenshot = true,
      () => sometimesUgotta = true,
      () => showButton = true,
    ];

    for (final action in steps) {
      await sleepState(3, action);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 4),
        const SuperText("Whether you're making wedding invitations"),
        const Spacer(),
        Expanded(
          flex: 20,
          child: Align(
            alignment: Alignment.topCenter,
            child: Image.asset('assets/wedding_invite.png', width: context.screenWidth * 2 / 3),
          ),
        ),
        const Spacer(flex: 4),
        Fader(
          showScreenshot,
          child: const SuperRichText([
            TextSpan(text: 'or making '),
            TextSpan(
              text: 'code',
              style: SuperStyle.mono(color: SuperColor(0x00FFEE), weight: 600, size: 21),
            ),
            TextSpan(text: ' for a video game,'),
          ]),
        ),
        const Spacer(),
        Fader(
          showScreenshot,
          child: ConstrainedBox(
            constraints: BoxConstraints.loose(Size.fromHeight(context.screenHeight / 3)),
            // Image is out of date, but it looked nicer then so we're just keeping it
            child: Image.asset('assets/picture_of_itself.png', width: 1000),
          ),
        ),
        const Spacer(flex: 4),
        Fader(
          sometimesUgotta,
          child: const SuperText('sometimes you gotta tell a computer\nwhat color you want.'),
        ),
        const Spacer(flex: 4),
        Fader(showButton, child: ContinueButton(onPressed: widget.nextPage)),
        const Spacer(flex: 4),
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

class _Page5State extends SuperState<_Page5> {
  int textProgress = 0;

  @override
  void animate() async {
    for (final (_, sleepyTime) in text) {
      await sleepState(sleepyTime, () => textProgress++);
    }
    await sleepState(2.5, () => textProgress++);
  }

  static const List<(Widget line, double timeToRead)> text = [
    (
      SuperRichText([
        TextSpan(text: "Let's take "),
        ColorTextSpan.green,
      ]),
      2.5
    ),
    (
      SuperRichText([
        TextSpan(text: 'and make it just a little bit '),
        ColorTextSpan.yellow,
        TextSpan(text: '.'),
      ]),
      2
    ),
    (Spacer(), 2),
    (SuperText('How do we describe this color?'), 2),
    (Spacer(), 2),
    (SuperText('You could say its RGB values,'), 3.5),
    (SuperText('or just make up a name for it.'), 1.5),
  ];

  static const List<(String, SuperColor)> colorCode = [
    ('128', SuperColor(0x800000)),
    ('255', SuperColor(0x00FF00)),
    ('0', SuperColor(0x000000)),
  ];

  late final colorCodeBox = SuperContainer(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: SuperColors.darkBackground.withAlpha(0x60),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 45),
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        const Spacer(),
        for (final (desc, color) in colorCode) ...[
          Text(desc, style: SuperStyle.mono(size: 48, weight: 900, color: color)),
          const Spacer(),
        ],
      ],
    ),
  );

  static const colorName = Column(
    children: [
      Text(
        '"chartreuse"',
        style: SuperStyle.sans(
          size: 64,
          weight: 750,
          width: 87.5,
          color: SuperColors.darkBackground,
          height: 1,
        ),
      ),
      Text(
        '(not a good name tbh)',
        style: SuperStyle.sans(
          weight: 100,
          extraBold: true,
          width: 96,
          color: SuperColors.darkBackground,
          size: 18,
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
          switch (text[i].$1) {
            final Spacer s => s,
            _ => Fader(i <= textProgress, child: text[i].$1),
          },
        const Spacer(),
        Expanded(
            flex: 4,
            child: FittedBox(
              child: SizedBox(
                width: 500,
                height: 300,
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
                            child: Opacity(
                              opacity: 0.5,
                              child: SuperContainer(
                                width: textProgress > 2 ? 500 : 250,
                                color: SuperColors.yellow,
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

class _Page6State extends EpicState<_Page6> with SinglePress {
  bool wishVisible = false, tooBadVisible = false, justKidding = false, buttonVisible = false;

  @override
  void initState() {
    super.initState();
    epicHues.stop();
  }

  @override
  void animate() async {
    await sleepState(0.75, () => wishVisible = true);

    await sleep(0.5);
    for (int i = 0; i < hsvWidth * hsvHeight; i++) {
      await sleepState(0.05, () => hsvGrid[i] = (tile: hsvGrid[i].tile, scale: 17 / 16));
    }
    await sleepState(4, () => tooBadVisible = true);
    await sleepState(4, () => justKidding = true);
    await sleepState(2, () {
      epicHue = 90;
      buttonVisible = true;
    });
    await sleep(0.5);
    if (mounted) {
      epicHues.start();
      epicHue = 90;
    }
  }

  /// number of rows/columns in HSV grid
  static const hsvWidth = 9, hsvHeight = 5;
  static const duration = quarterSec;

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
    return LayoutBuilder(builder: (context, constraints) {
      final tileWidth = constraints.calcSize(
        (w, h) => min(w / hsvWidth, (h - 50) / hsvHeight),
      );
      final double size = min(context.screenWidth / 22, 20);
      return Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              const Spacer(flex: 2),
              SizedBox(
                height: tileWidth * (hsvHeight - 1),
                width: tileWidth * hsvWidth,
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
                child: SuperText(
                  'I just wish I could describe every shade\n'
                  'with a single name (that isn\'t "chartreuse").',
                  style: SuperStyle.sans(size: size),
                  pad: false,
                ),
              ),
              const Spacer(),
              Fader(
                tooBadVisible,
                child: SuperText(
                  "Too bad there's no way to do that…",
                  style: SuperStyle.sans(size: size),
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
          if (justKidding)
            JustKidding(
              'HUE',
              buttonVisible: buttonVisible,
              color: epicColor,
              onPressed: singlePress(widget.nextPage),
            ),
        ],
      );
    });
  }
}

class _Page7 extends StatefulWidget {
  const _Page7(this.nextPage);
  final void Function() nextPage;

  @override
  State<_Page7> createState() => _Page7State();
}

class _Page7State extends SuperState<_Page7> {
  Widget overlay = const SuperContainer(
    color: Colors.black,
    alignment: Alignment.center,
    child: SuperText(
      'finding a hue\ncan be done in two steps.',
      style: SuperStyle.sans(size: 24),
    ),
  );
  static const overlay2 = SuperContainer(color: Colors.black);
  bool showOverlay2 = false;

  late final Ticker animateHue;
  int step = 0;
  double hue = 0;
  static const duration = Duration(seconds: 3);

  void smoothHue(Duration elapsed) {
    final double t, newHue;
    t = min(elapsed.inMilliseconds / duration.inMilliseconds, 1);
    newHue = 90 * curve.transform(t);
    setState(() => hue = newHue);

    if (t == 1) animateHue.dispose();
  }

  @override
  void animate() async {
    await sleepState(3, () => showOverlay2 = true);

    await sleepState(1, () {
      overlay = empty;
      showOverlay2 = false;
    });

    const List<double> sleepyTime = [3, 3, 1, 5, 3, 1];
    for (final time in sleepyTime) {
      await sleepState(time, () => step++);
      if (step == 4) animateHue = Ticker(smoothHue)..start();
    }

    await sleep(4.5, then: widget.nextPage);
  }

  static const step1 = 'Step 1: Find a color wheel.';
  static const step2 = 'Step 2: Measure the angle to your color, starting at red.';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.calcSize((w, h) => min(w * 0.8, h * 0.8 - 250));
      return Stack(
        children: [
          Column(
            children: [
              const Spacer(flex: 4),
              const SuperText(step1),
              const Spacer(),
              Fader(step >= 2, child: const SuperText(step2)),
              const Spacer(flex: 4),
              MeasuringOrb(
                step: step,
                width: width,
                duration: duration,
                hue: 90,
                lineColor: Colors.black,
              ),
              const Spacer(flex: 4),
              _HueBox(step: step, width: width, hue: hue.ceil()),
              const Spacer(flex: 4),
            ],
          ),
          overlay,
          Fader(showOverlay2, child: overlay2),
        ],
      );
    });
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
      height: width / 4,
      alignment: Alignment.center,
      child: Fader(
        step >= 2,
        duration: const Duration(milliseconds: 400),
        child: SexyBox(
          child: SuperContainer(
            width: step < 2 ? 20 : width,
            color: color,
            padding: EdgeInsets.all(width / 48),
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
                                      style: SuperStyle.sans(
                                        color: Colors.black,
                                        size: width * 0.0667,
                                        weight: 800,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                        Expanded(
                          child: SuperContainer(
                            color: SuperColors.darkBackground,
                            alignment: Alignment.center,
                            child: Text(
                              'hue = $hue',
                              style: SuperStyle.sans(color: color, size: width * 0.06),
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

class _FinalPageState extends EpicState<_FinalPage> with SinglePress {
  bool visible = false, buttonVisible = false, expanded = false;
  double width = 0;

  @override
  void animate() async {
    final List<void Function()> animation = [
      () => visible = true,
      () => width = 300,
      () => expanded = true,
      () => buttonVisible = true,
    ];

    for (final action in animation) {
      await sleepState(1, action);
    }
  }

  late VoidCallback onPressed = singlePress(() => Navigator.pushReplacement<void, void>(
        context,
        MaterialPageRoute<void>(builder: (context) => const IntroMode(3)),
      ));

  @override
  Widget build(BuildContext context) {
    final color = epicColor;
    return SuperContainer(
      color: SuperColors.darkBackground,
      alignment: Alignment.center,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        _AreYouReady(color: color),
        const FixedSpacer(50),
        Fader(
          visible,
          child: DecoratedBox(
            decoration: BoxDecoration(border: Border.all(color: color, width: 2)),
            child: SexyBox(
              child: expanded
                  ? SizedBox(
                      width: width,
                      height: 250,
                      child: _PlayButton(
                        visible: buttonVisible,
                        color: color,
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
    const double size = 30;
    const space = TextSpan(text: ' ', style: SuperStyle.sans(size: 3));
    return SuperRichText(
      style: const SuperStyle.sans(size: size, weight: 250),
      [
        const TextSpan(text: 'are'),
        space,
        TextSpan(
          text: 'YOU',
          style: SuperStyle.sans(size: size * 0.7, color: color, weight: 800),
        ),
        space,
        const TextSpan(text: 'ready?'),
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
          style: SuperStyle.sans(size: 24, height: 2),
        ),
        const Text(
          'learn the RGB hues',
          textAlign: TextAlign.center,
          style: SuperStyle.sans(size: 16, color: SuperColors.white80),
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
