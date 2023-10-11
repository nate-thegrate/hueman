import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:rive/rive.dart' as rive;
import 'package:super_hueman/data/structs.dart';
import 'package:super_hueman/data/super_color.dart';
import 'package:super_hueman/data/super_container.dart';
import 'package:super_hueman/data/widgets.dart';
import 'package:super_hueman/pages/intro.dart';

class Intro6Tutorial extends StatefulWidget {
  const Intro6Tutorial({super.key});

  @override
  State<Intro6Tutorial> createState() => _Intro6TutorialState();
}

class _Intro6TutorialState extends State<Intro6Tutorial> {
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
    await sleep(1);
    setState(() {
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
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Fader(
            visible,
            duration: duration,
            child: pages[page - 1],
          ),
        ),
      );
}

class _Page1 extends StatefulWidget {
  const _Page1(this.nextPage);
  final void Function() nextPage;

  @override
  State<_Page1> createState() => _Page1State();
}

class _Page1State extends State<_Page1> {
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
                const EasyText("Let's combine the primary colors,\nfor real this time."),
                const Spacer(flex: 4),
                ContinueButton(onPressed: () async {
                  setState(weBallin);
                  await sleep(5);
                  setState(noSpins);
                  setState(bestPart);
                  await sleep(8);
                  widget.nextPage();
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

class _Page2State extends SafeState<_Page2> {
  bool showPrinter = false, showButton = false;

  @override
  void initState() {
    super.initState();
    sleep(3.25, then: () => setState(() => showPrinter = true));
    sleep(4.5, then: () => setState(() => showButton = true));
  }

  static const colorText = Text.rich(
    textAlign: TextAlign.center,
    TextSpan(
      style: TextStyle(fontSize: 24),
      children: [
        ColorTextSpan(SuperColors.cyan, fontWeight: FontWeight.bold),
        TextSpan(text: ', '),
        ColorTextSpan(SuperColors.magenta, fontWeight: FontWeight.bold),
        TextSpan(text: ', and '),
        ColorTextSpan(SuperColors.yellow, fontWeight: FontWeight.bold),
        TextSpan(text: '.'),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final screenSize = context.screenSize;
    final imgSize = min(screenSize.width * .8, screenSize.height - 120 * .8);
    return Column(
      children: [
        const Spacer(flex: 2),
        colorText,
        const Spacer(),
        Fader(
          showPrinter,
          child: const EasyText("That's what printers use!"),
        ),
        const Spacer(),
        Fader(
          showPrinter,
          child: SizedBox(
            width: imgSize,
            height: imgSize,
            child: Image.asset('assets/ink_cartridge.png'),
          ),
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

class _Page3State extends SafeState<_Page3> with DelayedPress {
  bool showQuestion = false, showcase = false, printing = false, showButton = false;

  void animate() async {
    await sleep(4);
    setState(() => showQuestion = true);
    await sleep(4);
    setState(() => showcase = true);
    await sleep(1.5);
    setState(() => printing = true);
    await sleep(2.5);
    setState(() => showButton = true);
  }

  @override
  void initState() {
    super.initState();
    animate();
  }

  static const shouldntPrintersUse = Text.rich(
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: 24),
    TextSpan(
      children: [
        TextSpan(text: "But shouldn't they use "),
        ColorTextSpan(SuperColors.red),
        TextSpan(text: '/'),
        ColorTextSpan(SuperColors.green),
        TextSpan(text: '/'),
        ColorTextSpan(SuperColors.blue),
        TextSpan(text: " ink\nif that's what our eyes are built for?"),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 2),
        _PrinterAnimation(showcase, printing),
        const Spacer(),
        shouldntPrintersUse,
        const Spacer(flex: 2),
        Fader(
          showQuestion,
          child: const Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'How do you print '),
                ColorTextSpan(SuperColors.red),
                TextSpan(text: ', a primary color,\nwithout any red ink?'),
              ],
            ),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24),
          ),
        ),
        const Spacer(flex: 2),
        Fader(
          showButton,
          child: OutlinedButton(
              onPressed: delayed(widget.nextPage),
              child: const Padding(
                padding: EdgeInsets.only(top: 10, bottom: 13),
                child: Text(
                  'wow, good question!',
                  style: TextStyle(fontSize: 18),
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
              style: TextStyle(
                color: SuperColors.black,
                fontSize: 42,
                fontWeight: FontWeight.bold,
              ),
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

class _Page4State extends State<_Page4> {
  bool showThanks = true, expanded = false, showText = true, lightBars = true;

  void animate() async {
    await sleep(2.5);
    setState(() => showThanks = false);

    await sleep(2);
    setState(() => expanded = true);

    await sleep(1);
    for (int i = 0; i < 3; i++) {
      await sleep(0.5);
      setState(() => children[i] = _NeonRGB(SuperColors.primaries[i]));
    }

    await sleep(3);
    setState(() => showText = false);

    await sleep(2);
    setState(() {
      lightBars = false;
      showText = true;
      children = List.filled(5, const Spacer());
    });

    await sleep(1.5);
    setState(() => children[2] = const _SplashCMY(SuperColors.cyan));

    await sleep(0.25);
    setState(() => children[1] = const _SplashCMY(SuperColors.magenta));

    await sleep(0.25);
    setState(() => children[3] = const _SplashCMY(SuperColors.yellow));

    await sleep(7.5);
    widget.nextPage();
  }

  @override
  void initState() {
    super.initState();
    animate();
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
              child: EasyText(
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
                EasyText('Thanks!'),
                FixedSpacer(30),
                EasyText("Here's the answer…"),
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
    final screenSize = context.screenSize;
    final circleSize = max(screenSize.width, screenSize.height * .75) / 10;
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

class _Page5State extends SafeState<_Page5> {
  bool slideIntoPlace = false, showText = true, showArrows = false, showButton = false;
  int counter = 0;
  late final Ticker ticker;

  void animate() async {
    await sleep(2.5);
    setState(() => slideIntoPlace = true);

    await sleep(1.5);
    ticker.start();

    await sleep(5);
    setState(() => showText = false);

    await sleep(1);
    setState(() => showArrows = true);

    await sleep(3);
    setState(() => showButton = true);
  }

  @override
  void initState() {
    super.initState();
    ticker = Ticker((elapsed) => setState(() => counter++));
    animate();
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
              child: _ColorBubbles(counter, showArrows),
            ),
          ),
        ),
        Align(
          alignment: const Alignment(0, -7 / 8),
          child: Fader(showText,
              child: const EasyText("There isn't just one set of primary colors:")),
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
                  const Spacer(flex: 2),
                  Fader(
                    showText,
                    child: const Text(
                      "There's two!",
                      style: TextStyle(fontSize: 24, color: Colors.black),
                    ),
                  ),
                  const Spacer(),
                  _ColorBubbles.subtractive(counter, showArrows),
                  const Spacer(),
                  Fader(
                    showButton,
                    child: Theme(
                        data: ThemeData(useMaterial3: true),
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
    final size = context.screenSize;
    final bubbleSize = min(size.width, size.height / 2 - 50) / 4;
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
  const _ColorBubbles(this.counter, this.showArrows)
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
            style: TextStyle(fontSize: 24, color: subtract ? Colors.black : null),
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
              style: TextStyle(
                color: contrastColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 75),
                child: Text(
                  subtract ? 'absorb ${color.complement.name}' : 'add ${color.name}',
                  style: subtract ? const TextStyle(color: Colors.black) : null,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(15, subtract ? 0 : 25, 15, 0),
                child: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => LinearGradient(
                    colors: subtract ? [Colors.white, color] : [Colors.black, color],
                  ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                  child: const Icon(Icons.trending_flat, size: 125),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 75),
                child: Text(
                  subtract ? 'reflect ${reflectedColors[0]} + ${reflectedColors[1]}' : '',
                  style: const TextStyle(color: Colors.black),
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

class _Page6State extends SafeState<_Page6> {
  static const screenText = [
    EasyText('You know what really rustles my jimmies?'),
    Spacer(flex: 4),
    Text.rich(
      TextSpan(
        children: [
          TextSpan(
              text: 'People who design printers know\n'
                  'that the only way to access the full range of colors\n'
                  'is to use '),
          ColorTextSpan(SuperColors.cyan),
          TextSpan(text: '/'),
          ColorTextSpan(SuperColors.magenta),
          TextSpan(text: '/'),
          ColorTextSpan(SuperColors.yellow),
          TextSpan(text: ','),
        ],
      ),
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 24),
    ),
    Spacer(),
    EasyText('and subtractive mixing applies to all pigments,\n'
        'including markers and watercolors,'),
    Spacer(),
    EasyText('but not once in elementary school art class\n'
        'did I ever hear about cyan or magenta.'),
  ];

  int textProgress = 0;
  late final Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
      const Duration(milliseconds: 3000),
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

class _FinalPageState extends SafeState<_FinalPage> with DelayedPress {
  late final Ticker epicHues;
  bool showButton = false;

  @override
  void initState() {
    super.initState();
    epicHues = epicSetup(setState);
    sleep(4, then: () => setState(() => showButton = true));
  }

  @override
  void dispose() {
    epicHues.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 6),
        const EasyText('But this knowledge gap ends now.'),
        const Spacer(),
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: "It's time to learn "),
              TextSpan(
                text: 'ᴀʟʟ',
                style: TextStyle(
                  color: epicColor,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: ' of the primary color hues.'),
            ],
          ),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24),
        ),
        const Spacer(flex: 5),
        Fader(
          showButton,
          child: OutlinedButton(
            onPressed: delayed(() => Navigator.pushReplacement<void, void>(
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
              child: Text("let's do it", style: TextStyle(fontSize: 24)),
            ),
          ),
        ),
        const Spacer(flex: 2),
      ],
    );
  }
}
