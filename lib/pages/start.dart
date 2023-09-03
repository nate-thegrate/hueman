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
  void Function() onStop(double sleepyTime, void Function() fn) =>
      () => sleep(sleepyTime).then((_) => setState(fn));

  late final List<RiveAnimationController> controllers = [
    SimpleAnimation('button spin'),
    OneShotAnimation(
      'button pressed',
      autoplay: false,
      onStop: onStop(5.9, () => controllers[3].isActive = true),
    ),
    OneShotAnimation(
      'fade in everything',
      onStop: onStop(9.9, () => controllers[4].isActive = true),
    ),
    OneShotAnimation(
      'mixing',
      autoplay: false,
      onStop: onStop(9.8, () => callOutTheLie = const _CallOutTheLie()),
    ),
    OneShotAnimation('complete lie', autoplay: false),
  ];

  double get aspectRatio => context.screenWidth / context.screenHeight;
  double get padding => aspectRatio - 9 / 16 * context.screenWidth;

  String artboard = 'start button screen';
  Widget callOutTheLie = empty;
  SuperColor backgroundColor = SuperColors.lightBackground;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          setState(() => controllers[1].isActive = true);
          sleep(1.48).then((_) => setState(() {
                artboard = 'fake primaries';
                backgroundColor = SuperColors.bullshitBackground;
              }));
        },
        child: Stack(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints.loose(
                  Size(context.screenHeight * 2 / 3, double.infinity),
                ),
                child: RiveAnimation.asset(
                  'assets/animations/color_bullshit.riv',
                  artboard: artboard,
                  fit: BoxFit.cover,
                  controllers: controllers,
                ),
              ),
            ),
            callOutTheLie,
          ],
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

class _CallOutTheLieState extends State<_CallOutTheLie> {
  late final Ticker ticker;

  @override
  void initState() {
    super.initState();
    ticker = epicSetup(setState);
    sleep(3).then((_) => setState(() => showButton = true));
  }

  bool showButton = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const Spacer(flex: 2),
            const Text(
              'Except that was\na complete lie.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 48),
            ),
            const Spacer(),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 600),
              opacity: showButton ? 1 : 0,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: SuperColors.darkBackground,
                  elevation: (sin((epicHue) / 360 * 2 * pi * 6) + 1) * 6,
                  shadowColor: Colors.white,
                ),
                onPressed: showButton ? () {} : null,
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 15),
                  child: Text('see the truth',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w400)),
                ),
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
