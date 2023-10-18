import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:rive/rive.dart' as rive;
import 'package:super_hueman/data/page_data.dart';
import 'package:super_hueman/data/save_data.dart';
import 'package:super_hueman/data/structs.dart';
import 'package:super_hueman/data/super_color.dart';
import 'package:super_hueman/data/super_container.dart';
import 'package:super_hueman/data/super_state.dart';
import 'package:super_hueman/data/widgets.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends SuperState<StartScreen> {
  void Function() onStop({required double sleepFor, required int controllerIndex}) =>
      () => sleepState(sleepFor - 0.1, () => controllers[controllerIndex].isActive = true);

  late final List<rive.RiveAnimationController> controllers = [
    rive.SimpleAnimation('button spin'),
    rive.OneShotAnimation(
      'button pressed',
      autoplay: false,
      onStop: onStop(sleepFor: 6, controllerIndex: 3),
    ),
    rive.OneShotAnimation(
      'fade in everything',
      onStop: onStop(sleepFor: 10, controllerIndex: 4),
    ),
    rive.OneShotAnimation(
      'mixing',
      autoplay: false,
      onStop: () => sleep(9.85, then: () => context.noTransition(const _CallOutTheLie())),
    ),
    rive.OneShotAnimation('complete lie', autoplay: false),
  ];

  String artboard = 'start button screen';
  Widget callOutTheLie = empty;
  SuperColor backgroundColor = SuperColors.lightBackground;

  void start() {
    setState(() => controllers[1].isActive = true);
    sleep(
      1.48,
      then: () => setState(() {
        artboard = 'fake primaries';
        backgroundColor = SuperColors.bsBackground;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: start,
            child: Rive(
              name: 'color_bs',
              artboard: artboard,
              controllers: controllers,
            ),
          ),
          const _Logo(),
        ],
      ),
      backgroundColor: backgroundColor,
    );
  }
}

class _Logo extends StatefulWidget {
  const _Logo();

  @override
  State<_Logo> createState() => _LogoState();
}

class _LogoState extends SuperState<_Logo> {
  static const List<(String, SuperColor)> letterData = [
    ('H', SuperColors.red),
    ('U', SuperColor(0xF0F000)),
    ('E', SuperColor(0x0060FF)),
    ('man', SuperColor(0x6C4B00)),
  ];
  int lettersVisible = 0;
  double dy = 0;
  Curve curve = Curves.easeInOutQuad;
  Duration duration = halfSec;
  bool exists = true, visible = true;

  @override
  void animate() async {
    await sleep(1.5);
    for (int i = 0; i < 4; i++) {
      await sleepState(0.5, () => lettersVisible++);
    }
    await sleepState(1, () => dy = 0.5);
    await sleepState(0.5, () {
      curve = Curves.easeInQuad;
      duration = oneSec;
      dy = -8;
    });
    await sleepState(1, () => visible = false);
    await sleepState(1, () => exists = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!exists) return empty;
    return Fader(
      visible,
      child: SuperContainer(
        color: SuperColors.lightBackground,
        alignment: Alignment.center,
        child: AnimatedSlide(
          offset: Offset(0, dy),
          duration: duration,
          curve: curve,
          child: EasyRichText(
            style: const TextStyle(fontFamily: 'Gaegu', fontSize: 128),
            [
              for (int i = 0; i < 4; i++)
                TextSpan(
                  text: letterData[i].$1,
                  style: TextStyle(
                    color: lettersVisible > i ? letterData[i].$2 : Colors.transparent,
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}

class _CallOutTheLie extends StatefulWidget {
  const _CallOutTheLie();

  @override
  State<_CallOutTheLie> createState() => _CallOutTheLieState();
}

class _CallOutTheLieState extends SuperState<_CallOutTheLie> {
  @override
  void initState() {
    super.initState();
    sleepState(3, () {
      content = _TruthButton(onPressed: seeTheTruth);
      showButton = true;
    });
  }

  bool showStuff = true, showButton = false;

  void seeTheTruth() async {
    setState(() => showStuff = false);
    await sleepState(2, () {
      title = const Column(
        children: [
          Icon(Icons.headphones_outlined, size: 300),
          Text(
            '(headphones recommended)',
            style: TextStyle(fontSize: 18, letterSpacing: 0.5),
          )
        ],
      );
      content = Center(
        child: ContinueButton(onPressed: () {
          setState(() => showStuff = false);
          sleep(2, then: () => context.noTransition(const _FirstLaunchMenu()));
        }),
      );
    });
    await sleepState(0.2, () => showStuff = true);
  }

  Widget title = const Text(
    'Except that was\na complete lie.',
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: 48),
  );

  Widget content = empty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Fader(
          showStuff,
          duration: const Duration(milliseconds: 600),
          child: Column(
            children: [
              const Spacer(flex: 2),
              title,
              const Spacer(),
              Fader(
                showButton,
                child: SizedBox(height: 80, child: content),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TruthButton extends StatefulWidget {
  const _TruthButton({required this.onPressed});
  final void Function() onPressed;

  @override
  State<_TruthButton> createState() => _TruthButtonState();
}

class _TruthButtonState extends State<_TruthButton> {
  late final Ticker ticker;

  @override
  void initState() {
    super.initState();
    ticker = epicSetup(setState);
    setState(() => epicHue = 0);
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: SuperColors.darkBackground,
        elevation: epicSine * 6,
        shadowColor: Colors.white,
      ),
      onPressed: widget.onPressed,
      child: const Padding(
        padding: EdgeInsets.only(bottom: 5),
        child: Text(
          'see the truth',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }
}

class _FirstLaunchMenu extends StatefulWidget {
  const _FirstLaunchMenu();

  @override
  State<_FirstLaunchMenu> createState() => _FirstLaunchMenuState();
}

class _FirstLaunchMenuState extends State<_FirstLaunchMenu> {
  late final Ticker ticker;
  int counter = 1;
  Widget? introButton;
  bool showAll = false, expanded = false, expanded2 = false;
  static const showAllDuration = Duration(milliseconds: 1200),
      expandDuration = Duration(milliseconds: 600);

  void expand() {
    setState(() => expanded = true);
    sleep(1, then: () => setState(() => expanded2 = true));
  }

  @override
  void initState() {
    super.initState();
    epicHue = 0;
    ticker = Ticker(
      (elapsed) => setState(() {
        if (++counter % 3 == 0) epicHue = (epicHue + 1) % 360;
        return switch (counter) {
          1400 => setState(() => showAll = true),
          1600 => expand(),
          1650 => setState(() => introButton = const _IntroButton(expandDuration)),
          _ => null,
        };
      }),
    )..start();
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  double get girth {
    final double x = counter / 3;
    const int peak = 345;
    final double val = x < peak ? x : (x - peak) * peak / (peak - 360) + peak;
    return val * min(context.screenWidth, context.screenHeight - 39) / 350;
  }

  static const buffer = Expanded(
    child: SuperContainer(color: SuperColors.darkBackground),
  );
  static const buffer2 = Expanded(
    child: SuperContainer(
      color: SuperColors.darkBackground,
      height: 39,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final padding =
        expanded ? const EdgeInsets.only(bottom: 34) : const EdgeInsets.only(right: 17);
    final transparentHUEman = Padding(
      padding: padding + const EdgeInsets.only(bottom: 5),
      child: EasyRichText(
        style: const TextStyle(fontSize: 31, color: Colors.transparent),
        [
          const TextSpan(text: 'super'),
          TextSpan(
            text: 'ʜᴜᴇ',
            style: TextStyle(color: epicColor, fontSize: 32, fontWeight: FontWeight.w500),
          ),
          const TextSpan(text: 'man'),
        ],
      ),
    );

    return Scaffold(
      body: counter < 360 * 3
          ? Center(
              child: SuperContainer(
                margin: const EdgeInsets.only(top: 39),
                width: girth,
                decoration: BoxDecoration(shape: BoxShape.circle, color: epicColor),
              ),
            )
          : Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 220,
                        child: Stack(
                          children: [
                            Center(
                              child: AnimatedPadding(
                                duration: oneSec,
                                curve: Curves.easeInOutQuart,
                                padding: padding,
                                child: SuperHUEman(epicColor),
                              ),
                            ),
                            Row(
                              children: [
                                buffer2,
                                AnimatedSize(
                                  duration: showAllDuration,
                                  curve: curve,
                                  child: SizedBox(width: showAll ? 200 : 4),
                                ),
                                buffer2,
                                const FixedSpacer.horizontal(20),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SuperContainer(
                        decoration: BoxDecoration(border: Border.all(color: epicColor, width: 2)),
                        child: SexyBox(
                          child: SizedBox(
                            width: expanded ? 300 : context.screenWidth,
                            height: expanded2 ? 200 : 0,
                            child: introButton,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    buffer,
                    AnimatedSize(
                      duration: showAllDuration,
                      curve: curve,
                      child: SizedBox(width: showAll ? context.screenWidth : 47),
                    ),
                    buffer,
                  ],
                ),
                Fader(
                  !showAll,
                  duration: showAllDuration,
                  child: Center(child: transparentHUEman),
                ),
              ],
            ),
    );
  }
}

class _IntroButton extends StatefulWidget {
  const _IntroButton(this.duration);
  final Duration duration;

  @override
  State<_IntroButton> createState() => _IntroButtonState();
}

class _IntroButtonState extends State<_IntroButton> {
  late final Ticker epicHues;
  SuperColor color = epicColor;

  @override
  void initState() {
    super.initState();
    Tutorials.started = true;
    epicHues = Ticker((elapsed) => setState(() => color = epicColor))..start();
  }

  @override
  void dispose() {
    epicHues.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeIn(
        duration: widget.duration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'intro (3 colors)',
              style: TextStyle(color: SuperColors.white80, fontSize: 20),
            ),
            const FixedSpacer(25),
            SuperButton(
              'start',
              color: color,
              onPressed: () => context.goto(Pages.intro3),
            ),
            const FixedSpacer(10),
          ],
        ),
      ),
    );
  }
}
