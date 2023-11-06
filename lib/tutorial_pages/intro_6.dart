import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:rive/rive.dart' as rive;
import 'package:hueman/data/structs.dart';
import 'package:hueman/data/super_color.dart';
import 'package:hueman/data/super_container.dart';
import 'package:hueman/data/super_state.dart';
import 'package:hueman/data/super_text.dart';
import 'package:hueman/data/widgets.dart';
import 'package:hueman/pages/intro.dart';

class Intro6Tutorial extends StatefulWidget {
  const Intro6Tutorial({super.key});

  @override
  State<Intro6Tutorial> createState() => _Intro6TutorialState();
}

class _Intro6TutorialState extends SuperState<Intro6Tutorial> {
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
    setState(() => visible = false);
    await sleepState(1, () {
      page++;
      duration = oneSec;
    });
    setState(() => visible = true);
  }

  @override
  void initState() {
    super.initState();
    sleep(1, then: () => setState(() => visible = true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: page != 5,
        bottom: page != 5,
        child: Center(
          child: Fader(
            visible,
            duration: duration,
            child: pages[page - 1],
          ),
        ),
      ),
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
  final controllers = [
    rive.SimpleAnimation('spin'),
    rive.OneShotAnimation('combine', autoplay: false),
    rive.OneShotAnimation('2 at a time', autoplay: false),
  ];

  bool get stagnant => !controllers[1].isActive;
  void weBallin() => controllers[1].isActive = true;
  void bestPart() => controllers[2].isActive = true;
  void noSpins() => controllers[0].isActive = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Rive(name: 'color_truth', controllers: controllers),
        Fader(
          stagnant,
          child: Center(
            child: Column(
              children: [
                const Spacer(),
                const SuperText("Let's combine the primary colors,\nfor real this time."),
                const Spacer(flex: 4),
                ContinueButton(onPressed: () async {
                  setState(weBallin);
                  await sleepState(5, noSpins);
                  setState(bestPart);
                  await sleep(8, then: widget.nextPage);
                }),
                const Spacer(),
              ],
            ),
          ),
        ),
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
  bool showPrinter = false, showButton = false;

  @override
  void initState() {
    super.initState();
    sleep(3.25, then: () => setState(() => showPrinter = true));
    sleep(4.5, then: () => setState(() => showButton = true));
  }

  @override
  Widget build(BuildContext context) {
    final imgSize = context.calcSize((w, h) => min(w * .8, (h - 120) * .6));
    return Column(
      children: [
        const Spacer(flex: 2),
        const SuperRichText([
          ColorTextSpan(SuperColors.cyan, fontWeight: 900),
          TextSpan(text: ', '),
          ColorTextSpan(SuperColors.magenta, fontWeight: 900),
          TextSpan(text: ', and '),
          ColorTextSpan(SuperColors.yellow, fontWeight: 900),
          TextSpan(text: '.'),
        ]),
        const Spacer(),
        Fader(
          showPrinter,
          child: const SuperText("That's what printers use!"),
        ),
        const Spacer(),
        Fader(
          showPrinter,
          child: SizedBox(width: imgSize, child: Image.asset('assets/ink_cartridge.jpg')),
        ),
        const Spacer(flex: 2),
        Fader(showButton, child: ContinueButton(onPressed: widget.nextPage)),
        const Spacer(),
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

class _Page3State extends SuperState<_Page3> with SinglePress {
  bool showQuestion = false, showcase = false, printing = false, showButton = false;

  @override
  void animate() async {
    await sleepState(4, () => showQuestion = true);
    await sleepState(4, () => showcase = true);
    await sleepState(1.5, () => printing = true);
    await sleepState(2.5, () => showButton = true);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 2),
        _PrinterAnimation(showcase, printing),
        const Spacer(),
        const SuperRichText([
          TextSpan(text: "But shouldn't they use "),
          ColorTextSpan.red,
          TextSpan(text: '/'),
          ColorTextSpan.green,
          TextSpan(text: '/'),
          ColorTextSpan.blue,
          TextSpan(text: "\nif that's what human eyes are built for?"),
        ]),
        const Spacer(flex: 2),
        Fader(
          showQuestion,
          child: const SuperRichText([
            TextSpan(text: 'How do you print '),
            ColorTextSpan.red,
            TextSpan(text: ', a primary color,\nwithout any red ink?'),
          ]),
        ),
        const Spacer(flex: 2),
        Fader(
          showButton,
          child: OutlinedButton(
              onPressed: singlePress(widget.nextPage),
              child: const Padding(
                padding: EdgeInsets.only(top: 10, bottom: 13),
                child: Text(
                  'wow, good question!',
                  style: SuperStyle.sans(size: 18),
                ),
              )),
        ),
        const Spacer(),
      ],
    );
  }
}

class _PrinterAnimation extends StatelessWidget {
  const _PrinterAnimation(this.showcase, this.printing);
  final bool showcase, printing;

  static const _curve = Curves.easeOutQuad;
  static const _duration = Duration(milliseconds: 2000);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Center(
          child: SexyBox(
            child: showcase
                ? const SuperContainer(
                    width: 400,
                    height: 333,
                    color: Colors.black,
                  )
                : empty,
          ),
        ),
        AnimatedContainer(
          duration: _duration,
          curve: _curve,
          margin: const EdgeInsets.only(top: 167),
          width: 150,
          height: printing ? 75 : 0,
          color: SuperColors.red,
        ),
        const Icon(Icons.print, size: 300),
        AnimatedContainer(
          duration: _duration,
          curve: _curve,
          margin: const EdgeInsets.only(top: 33),
          width: 300,
          height: printing ? 56 : 0,
          color: SuperColors.black,
        ),
        if (printing)
          const Padding(
            padding: EdgeInsets.only(top: 175),
            child: Text(
              '?',
              style: SuperStyle.sans(color: SuperColors.black, size: 42, weight: 800),
            ),
          ),
      ],
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
  bool showThanks = true, expanded = false, showText = true, lightBars = true;

  @override
  void animate() async {
    await sleepState(2.5, () => showThanks = false);
    await sleepState(2, () => expanded = true);

    await sleep(1);
    for (int i = 0; i < 3; i++) {
      await sleepState(0.5, () => children[i] = _NeonRGB(SuperColors.primaries[i]));
    }

    await sleepState(3, () => showText = false);
    await sleepState(2, () {
      lightBars = false;
      showText = true;
      children = List.filled(5, const Spacer());
    });
    await sleepState(1.5, () => children[2] = const _SplashCMY(SuperColors.cyan));
    await sleepState(0.25, () => children[1] = const _SplashCMY(SuperColors.magenta));
    await sleepState(0.25, () => children[3] = const _SplashCMY(SuperColors.yellow));

    await sleep(7.5, then: widget.nextPage);
  }

  List<Widget> children = List.filled(3, const Spacer());

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            const Spacer(flex: 2),
            Fader(
              showText,
              child: SuperText(
                lightBars
                    ? 'A screen starts as black,\nand then adds red/green/blue light.'
                    : 'But printers start with a white paper,\n'
                        'and then add ink that absorbs different frequencies.',
              ),
            ),
            const Spacer(),
            Expanded(
                flex: 15,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(1.5),
                      child: SexyBox(
                        child: ConstrainedBox(
                          constraints: expanded
                              ? const BoxConstraints.expand()
                              : BoxConstraints.loose(const Size(double.infinity, 0)),
                          child: ClipRect(
                            child: SuperContainer(
                              color: lightBars ? Colors.black : Colors.white,
                              child: Row(children: children),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SuperContainer(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: SuperColors.darkBackground,
                          width: 3,
                        ),
                      ),
                    )
                  ],
                )),
            const Spacer(flex: 2),
          ],
        ),
        Fader(
          showThanks,
          child: const SuperContainer(
            color: SuperColors.darkBackground,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SuperText('Thanks!'),
                FixedSpacer(30),
                SuperText("Here's the answer…"),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NeonRGB extends StatefulWidget {
  const _NeonRGB(this.color);
  final SuperColor color;

  @override
  State<_NeonRGB> createState() => _NeonRGBState();
}

class _NeonRGBState extends State<_NeonRGB> {
  late final buildup = [
    widget.color.withAlpha(0x00),
    widget.color.withAlpha(0x01),
    widget.color.withAlpha(0x01),
    widget.color.withAlpha(0x02),
    widget.color.withAlpha(0x03),
    widget.color.withAlpha(0x04),
    widget.color.withAlpha(0x06),
    widget.color.withAlpha(0x08),
    widget.color.withAlpha(0x0a),
    widget.color.withAlpha(0x0e),
    widget.color.withAlpha(0x13),
    widget.color.withAlpha(0x19),
    widget.color.withAlpha(0x22),
    widget.color.withAlpha(0x2D),
    widget.color.withAlpha(0x3C),
    widget.color.withAlpha(0x51),
    widget.color.withAlpha(0x6C),
    widget.color.withAlpha(0x90),
    widget.color.withAlpha(0xC0),
    widget.color,
    widget.color,
    widget.color,
  ];
  late final windDown = buildup.reversed;
  double scale = 1;

  @override
  void initState() {
    super.initState();
    sleep(2, then: () => setState(() => scale = 50));
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FadeIn(
        duration: const Duration(seconds: 2),
        child: Stack(
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 2000),
              scale: scale,
              curve: Curves.easeInQuart,
              child: SuperContainer(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [...buildup, ...windDown],
                  ),
                  backgroundBlendMode: BlendMode.screen,
                ),
              ),
            ),
            Center(
              child: SuperContainer(
                width: context.screenWidth / 16,
                decoration: BoxDecoration(
                  color: widget.color,
                  backgroundBlendMode: BlendMode.screen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashCMY extends StatefulWidget {
  const _SplashCMY(this.color);
  final SuperColor color;

  @override
  State<_SplashCMY> createState() => _SplashCMYState();
}

class _SplashCMYState extends State<_SplashCMY> {
  double scale = 0;

  @override
  void initState() {
    super.initState();
    quickly(() => setState(() => scale = 20));
  }

  @override
  Widget build(BuildContext context) {
    final circleSize = context.calcSize((w, h) => max(w, h * .75) / 10);
    return Expanded(
      child: Align(
        alignment: widget.color == SuperColors.cyan
            ? const Alignment(0, -1 / 3)
            : const Alignment(0, 1 / 3),
        child: AnimatedScale(
          duration: const Duration(seconds: 8),
          scale: scale,
          child: AnimatedContainer(
            duration: oneSec,
            decoration: BoxDecoration(
              color: SuperColor.hsl(widget.color.hue, 1, 0.5 + 0x09 / 0x100),
              shape: BoxShape.circle,
              backgroundBlendMode: BlendMode.multiply,
            ),
            width: circleSize,
            height: circleSize,
          ),
        ),
      ),
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
  bool slideIntoPlace = false, showText = true, showArrows = false, showButton = false;
  int counter = 0;
  late final Ticker ticker;

  @override
  void animate() async {
    await sleepState(2.5, () => slideIntoPlace = true);
    await sleep(1.5);
    ticker.start();
    await sleepState(5, () => showText = false);
    await sleepState(1, () => showArrows = true);
    await sleepState(3, () => showButton = true);
  }

  @override
  void initState() {
    super.initState();
    ticker = Ticker((elapsed) => setState(() => counter++));
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: AnimatedSlide(
            offset: slideIntoPlace ? const Offset(0, 0) : const Offset(0, -1),
            duration: halfSec,
            curve: Curves.easeInQuad,
            child: SuperContainer(
              color: Colors.black,
              height: context.screenHeight / 2,
              alignment: Alignment.center,
              child: _ColorBubbles.additive(counter, showArrows),
            ),
          ),
        ),
        Align(
          alignment: const Alignment(0, -7 / 8),
          child: Fader(showText,
              child: const SuperText("There isn't just one set of primary colors:")),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedSlide(
            offset: slideIntoPlace ? const Offset(0, 0) : const Offset(0, 1),
            duration: halfSec,
            curve: Curves.easeInQuad,
            child: SuperContainer(
              color: Colors.white,
              height: context.screenHeight / 2,
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  if (!showArrows)
                    Fader(
                      showText,
                      child: const Text(
                        "There's two!",
                        style: SuperStyle.sans(size: 24, color: Colors.black),
                      ),
                    ),
                  const Spacer(),
                  SuperContainer(child: _ColorBubbles.subtractive(counter, showArrows)),
                  const Spacer(),
                  Fader(
                    showButton,
                    child: Theme(
                        data: ThemeData(useMaterial3: true, fontFamily: 'nunito sans'),
                        child: ContinueButton(onPressed: widget.nextPage)),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ColorBubble extends StatefulWidget {
  const _ColorBubble(this.counter, {required this.color});
  final int counter;
  final SuperColor color;

  @override
  State<_ColorBubble> createState() => _ColorBubbleState();
}

class _ColorBubbleState extends State<_ColorBubble> {
  static const root3over2 = 0.8660254037844386;
  late final offset = switch (widget.color) {
    SuperColors.red || SuperColors.cyan => const Offset(0, -root3over2),
    SuperColors.green || SuperColors.magenta => const Offset(-1, root3over2),
    SuperColors.blue || SuperColors.yellow => const Offset(1, root3over2),
    _ => throw Error(),
  };
  late final BlendMode blendMode =
      SuperColors.primaries.contains(widget.color) ? BlendMode.screen : BlendMode.multiply;

  @override
  Widget build(BuildContext context) {
    final bubbleSize = context.calcSize((w, h) => min(w, h / 2 - 50) / 4);
    final counter = widget.counter;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: bubbleSize / 2.5),
      child: Transform.translate(
        offset: Offset(
          offset.dx * bubbleSize / 3,
          sin(counter / 25) * 6 + offset.dy * bubbleSize / 3,
        ),
        child: Transform.scale(
          scaleY: 1 + sin(counter / 25 + pi / 6) * .025,
          child: AnimatedScale(
            duration: halfSec,
            scale: counter > 15 ? 1 : 0,
            curve: curve,
            child: SuperContainer(
              width: bubbleSize,
              height: bubbleSize,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
                backgroundBlendMode: blendMode,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorBubbles extends StatelessWidget {
  const _ColorBubbles.additive(this.counter, this.showArrows)
      : colors = SuperColors.primaries,
        subtract = false;
  const _ColorBubbles.subtractive(this.counter, this.showArrows)
      : colors = SuperColors.subtractivePrimaries,
        subtract = true;
  final int counter;
  final bool subtract, showArrows;
  final List<SuperColor> colors;

  int get cycle => (counter ~/ 200) % 3;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Fader(
          showArrows,
          child: Text(
            subtract ? 'Subtractive primary colors' : 'Additive primary colors',
            style: SuperStyle.sans(size: 24, color: subtract ? Colors.black : null),
          ),
        ),
        Stack(
          children: [
            _ColorBubble(counter, color: colors[0]),
            _ColorBubble(counter - 10, color: colors[1]),
            _ColorBubble(counter - 16, color: colors[2]),
          ],
        ),
        SexyBox(
          child: showArrows ? FadeIn(child: _ColorArrows(colors[cycle], subtract)) : empty,
        ),
      ],
    );
  }
}

class _ColorArrows extends StatelessWidget {
  const _ColorArrows(this.color, this.subtract);
  final SuperColor color;
  final bool subtract;

  @override
  Widget build(BuildContext context) {
    final subtractedColor = subtract ? color.complement : color;
    final contrastColor = subtract ? SuperColors.black : SuperColors.white;
    final List<String> reflectedColors = [
      for (final primary in SuperColors.primaries)
        if (primary != subtractedColor) primary.name
    ];
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SuperContainer(
            decoration: BoxDecoration(
              border: Border.all(color: contrastColor, width: 3),
            ),
            width: 100,
            height: 100,
            alignment: Alignment.center,
            child: Text(
              subtract ? 'white' : 'black',
              style: SuperStyle.sans(color: contrastColor, size: 18, weight: 800),
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 75),
                child: Text(
                  subtract ? 'absorb ${color.complement.name}' : 'add ${color.name}',
                  style: subtract ? const SuperStyle.sans(color: Colors.black) : null,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(15, subtract ? 0 : 25, 15, 0),
                child: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => LinearGradient(
                    colors: subtract ? [Colors.white, color] : [Colors.black, color],
                  ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                  child: const Icon(Icons.trending_flat, size: 118),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 75),
                child: Text(
                  subtract ? 'reflect ${reflectedColors[0]} + ${reflectedColors[1]}' : '',
                  style: const SuperStyle.sans(color: Colors.black),
                ),
              )
            ],
          ),
          SuperContainer(
            decoration: BoxDecoration(
              border: Border.all(color: contrastColor, width: 3),
              color: color,
            ),
            width: 100,
            height: 100,
          ),
        ],
      ),
    );
  }
}

class _Page6 extends StatefulWidget {
  const _Page6(this.nextPage);
  final void Function() nextPage;

  @override
  State<_Page6> createState() => _Page6State();
}

class _Page6State extends SuperState<_Page6> {
  static const screenText = [
    SuperText('You know what rustles my jimmies?'),
    Spacer(flex: 4),
    SuperRichText([
      TextSpan(
        text: 'People who design printers know that\n'
            'the only way to access the full color range\n'
            'is to use ',
      ),
      ColorTextSpan.cyan,
      TextSpan(text: '/'),
      ColorTextSpan.magenta,
      TextSpan(text: '/'),
      ColorTextSpan.yellow,
      TextSpan(text: ','),
    ]),
    Spacer(),
    SuperText('and subtractive mixing applies to all pigments,\n'
        'including markers and watercolors,'),
    Spacer(),
    SuperText('but not once in my elementary school art class\n'
        'did we learn about cyan or magenta.'),
  ];

  int textProgress = 0;
  late final Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => setState(() => textProgress++),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 4),
        for (int i = 0; i < screenText.length; i++)
          switch (screenText[i]) {
            Spacer() => screenText[i],
            _ => Fader(i <= textProgress, child: screenText[i]),
          },
        const Spacer(flex: 4),
        Fader(
          textProgress >= screenText.length,
          child: ContinueButton(onPressed: widget.nextPage),
        ),
        const Spacer(flex: 2),
      ],
    );
  }
}

class _FinalPage extends StatefulWidget {
  const _FinalPage();

  @override
  State<_FinalPage> createState() => _FinalPageState();
}

class _FinalPageState extends EpicState<_FinalPage> with SinglePress {
  bool showButton = false;

  @override
  void animate() => sleepState(4, () => showButton = true);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 6),
        const SuperText('But this knowledge gap ends now.'),
        const Spacer(),
        SuperRichText([
          const TextSpan(text: "It's time to learn "),
          TextSpan(
            text: 'ALL',
            style: SuperStyle.sans(
              color: epicColor,
              size: 17,
              weight: 800,
              width: 87.5,
              letterSpacing: 1,
            ),
          ),
          const TextSpan(text: '\nof the primary color hues.'),
        ]),
        const Spacer(flex: 5),
        Fader(
          showButton,
          child: OutlinedButton(
            onPressed: singlePress(() => Navigator.pushReplacement<void, void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const IntroMode(6),
                  ),
                )),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: epicColor, width: 2),
              foregroundColor: epicColor,
              backgroundColor: SuperColors.darkBackground,
              shadowColor: epicColor,
              elevation: epicSine * 5,
            ),
            child: const Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 14),
              child: Text("let's do it", style: SuperStyle.sans(size: 24)),
            ),
          ),
        ),
        const Spacer(flex: 2),
      ],
    );
  }
}
