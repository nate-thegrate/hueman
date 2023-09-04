import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:rive/rive.dart';
import 'package:super_hueman/save_data.dart';
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
      onStop: () => sleep(9.9).then((_) => context.noTransition(const _CallOutTheLie())),
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

class _CallOutTheLieState extends State<_CallOutTheLie> {
  late final Ticker ticker;

  @override
  void initState() {
    super.initState();
    ticker = epicSetup(setState);
    sleep(3).then((_) => setState(() => showButton = true));
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  bool showButton = false;

  void toMenu() {
    inverted = true;
    context.invert(); // TODO: make special animated menu for first launch
  }

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
                onPressed: showButton ? toMenu : null,
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
