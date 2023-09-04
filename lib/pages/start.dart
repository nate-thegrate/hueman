import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:rive/rive.dart';
import 'package:super_hueman/structs.dart';
import 'package:super_hueman/widgets.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  void Function() onStop({required double sleepFor, required int controllerIndex}) =>
      () => sleep(sleepFor - 0.1)
          .then((_) => setState(() => controllers[controllerIndex].isActive = true));

  late final List<RiveAnimationController> controllers = [
    SimpleAnimation('button spin'),
    OneShotAnimation(
      'button pressed',
      autoplay: false,
      onStop: onStop(sleepFor: 6, controllerIndex: 3),
    ),
    OneShotAnimation(
      'fade in everything',
      onStop: onStop(sleepFor: 10, controllerIndex: 4),
    ),
    OneShotAnimation(
      'mixing',
      autoplay: false,
      onStop: () => sleep(9.85).then((_) => context.noTransition(const _CallOutTheLie())),
    ),
    OneShotAnimation('complete lie', autoplay: false),
  ];

  double get aspectRatio => context.screenWidth / context.screenHeight;
  double get padding => aspectRatio - 9 / 16 * context.screenWidth;

  String artboard = 'start button screen';
  Widget callOutTheLie = empty;
  SuperColor backgroundColor = SuperColors.lightBackground;

  void start() {
    setState(() => controllers[1].isActive = true);
    sleep(1.48).then((_) => setState(() {
          artboard = 'fake primaries';
          backgroundColor = SuperColors.bullshitBackground;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: start,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints.loose(
              Size(context.screenHeight * 2 / 3, double.infinity),
            ),
            child: RiveAnimation.asset(
              'assets/animations/color_bs.riv',
              artboard: artboard,
              fit: BoxFit.cover,
              controllers: controllers,
            ),
          ),
        ),
      ),
      backgroundColor: backgroundColor,
    );
  }
}

class _CallOutTheLie extends StatefulWidget {
  const _CallOutTheLie();

  @override
  State<_CallOutTheLie> createState() => _CallOutTheLieState();
}

class _TruthButton extends StatefulWidget {
  final void Function() onPressed;
  const _TruthButton({required this.onPressed});

  @override
  State<_TruthButton> createState() => __TruthButtonState();
}

class __TruthButtonState extends State<_TruthButton> {
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
        elevation: (sin((epicHue) / 360 * 2 * pi * 6) + 1) * 6,
        shadowColor: Colors.white,
      ),
      onPressed: widget.onPressed,
      child: const Padding(
        padding: EdgeInsets.only(bottom: 5),
        child: Text('see the truth', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w400)),
      ),
    );
  }
}

class _CallOutTheLieState extends State<_CallOutTheLie> {
  @override
  void initState() {
    super.initState();
    sleep(3).then((_) => setState(() {
          content = _TruthButton(onPressed: seeTheTruth);
          showButton = true;
        }));
  }

  bool showStuff = true;
  bool showButton = false;

  void seeTheTruth() => () async {
        setState(() => showStuff = false);
        await sleep(2);
        setState(() {
          title = const Icon(Icons.headphones_outlined, size: 300);
          content = const Text(
            '(headphones recommended)',
            style: TextStyle(fontSize: 18, letterSpacing: 0.5),
          );
        });
        await sleep(0.2);
        setState(() => showStuff = true);
        await sleep(4.5);
        setState(() => showStuff = false);
        await sleep(2);
      }()
          .then((value) => context.noTransition(const _FirstLaunchMenu()));

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
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 600),
          opacity: showStuff ? 1 : 0,
          child: Column(
            children: [
              const Spacer(flex: 2),
              title,
              const Spacer(),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 600),
                opacity: showButton ? 1 : 0,
                child: SizedBox(height: 80, child: content),
              ),
              const Spacer(flex: 2),
            ],
          ),
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
  bool showAll = false;
  bool expanded = false;
  Widget? introButton;
  static const duration = Duration(milliseconds: 1200);
  @override
  void initState() {
    super.initState();
    epicHue = 0;
    ticker = Ticker((elapsed) => setState(() {
          counter++;
          if (counter % 3 == 0) epicHue = (epicHue + 1) % 360;
          switch (counter) {
            case 1400:
              return setState(() => showAll = true);
            case 1600:
              return setState(() => expanded = true);
            case 1650:
              return setState(() => introButton = const _IntroButton(duration));
          }
        }))
      ..start();
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  double get girth {
    final double x = counter / 3;
    assert(x < 360);

    const int peak = 345;
    final double val = x < peak ? x : (x - peak) * peak / (peak - 360) + peak;
    return val * min(context.screenWidth, context.screenHeight) / 350;
  }

  @override
  Widget build(BuildContext context) {
    final superHUEman = [
      Text(
        'super',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 0),
        child: Text(
          'HUE',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            color: epicColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      AnimatedContainer(
        duration: duration,
        curve: curve,
        padding: EdgeInsets.only(right: expanded ? 0 : 22),
        child: Text(
          'man',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
    ];

    const buffer = Expanded(
        child: ColoredBox(
      color: SuperColors.darkBackground,
      child: SizedBox.expand(),
    ));
    const buffer2 = Expanded(
        child: ColoredBox(
      color: SuperColors.darkBackground,
      child: SizedBox(height: 39),
    ));
    return Scaffold(
      body: counter < 360 * 3
          ? Center(
              child: Container(
                width: girth,
                height: girth,
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
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: superHUEman,
                              ),
                            ),
                            Row(
                              children: [
                                buffer2,
                                AnimatedSize(
                                  duration: duration,
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
                      AnimatedContainer(
                        duration: duration,
                        curve: curve,
                        width: expanded ? 300 : context.screenWidth,
                        height: expanded ? 250 : 0,
                        margin: expanded ? const EdgeInsets.only(top: 50) : EdgeInsets.zero,
                        decoration: BoxDecoration(border: Border.all(color: epicColor, width: 2)),
                        child: introButton,
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    buffer,
                    AnimatedSize(
                      duration: duration,
                      curve: curve,
                      child: SizedBox(width: showAll ? context.screenWidth : 4),
                    ),
                    buffer,
                  ],
                ),
                AnimatedOpacity(
                  duration: duration,
                  opacity: showAll ? 0 : 1,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Opacity(opacity: 0, child: superHUEman[0]),
                          superHUEman[1],
                          Opacity(opacity: 0, child: superHUEman[2]),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _IntroButton extends StatefulWidget {
  final Duration duration;
  const _IntroButton(this.duration);

  @override
  State<_IntroButton> createState() => __IntroButtonState();
}

class __IntroButtonState extends State<_IntroButton> {
  late final Ticker epicHues;
  SuperColor color = epicColor;

  @override
  void initState() {
    super.initState();
    epicHues = Ticker((elapsed) => setState(() => color = epicColor))..start();
    sleep(0.1).then((_) => setState(() => exists = true));
    sleep(1.5).then((_) => setState(() => visible = true));
  }

  @override
  void dispose() {
    epicHues.dispose();
    super.dispose();
  }

  bool exists = false, visible = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: widget.duration,
      child: exists
          ? Center(
              child: AnimatedOpacity(
                opacity: visible ? 1 : 0,
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
                  ],
                ),
              ),
            )
          : empty,
    );
  }
}
