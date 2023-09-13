import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:super_hueman/data/color_lists.dart';
import 'package:super_hueman/data/super_container.dart';
import 'package:super_hueman/pages/score.dart';
import 'package:super_hueman/data/save_data.dart';
import 'package:super_hueman/data/structs.dart';
import 'package:super_hueman/data/widgets.dart';

class TenseScoreKeeper implements ScoreKeeper {
  TenseScoreKeeper({required this.page});
  @override
  final Pages page;

  static const maxHealth = 25;
  bool healthBarFlash = false;
  int round = 1, health = 13, overfills = 0;
  late String rank;

  void updateHealth(bool gotItRight) {
    if (gotItRight) {
      if (health == maxHealth) {
        overfills++;
        healthBarFlash = true;
        sleep(1 / 3, then: () => healthBarFlash = false);
      } else {
        health = min(health + 3, maxHealth);
      }
    } else {
      health = max(health - 5, 0);
    }
  }

  @override
  void roundCheck(BuildContext context) => (health > 0)
      ? round++
      : Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(builder: (context) => ScoreScreen(this)),
        );

  @override
  void scoreTheRound() {}

  /// health bar
  @override
  Widget get midRoundDisplay => SuperContainer(
        width: 500,
        height: 60,
        padding: const EdgeInsets.all(5),
        alignment: Alignment.centerLeft,
        decoration: const BoxDecoration(
          border: Border.fromBorderSide(
            BorderSide(color: Colors.black12, width: 5),
          ),
        ),
        child: AnimatedContainer(
          width: 480 * health / 25,
          duration: expandDuration,
          curve: curve,
          color: healthBarFlash ? Colors.white : Colors.black12,
        ),
      );

  @override
  Widget get finalScore => Text(
        (round * (overfills + 1)).toString(),
        style: const TextStyle(fontSize: 32),
      );

  @override
  Widget get finalDetails {
    String desc = 'survived $round rounds!';
    if (overfills > 0) {
      desc += '\n\u00d7${overfills + 1} bonus! '
          '($overfills health bar overfill${overfills > 1 ? 's' : ''})';
    }
    return Text(
      desc,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 18, color: Colors.black54),
    );
  }
}

class Target extends StatelessWidget {
  const Target(this.label, this.value, {super.key});
  final String label;
  final dynamic value;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(child: Text('$label:', textAlign: TextAlign.right)),
          const FixedSpacer.horizontal(15),
          Expanded(child: Text(value.toString())),
        ],
      );
}

class TenseMode extends StatefulWidget {
  const TenseMode(this.mode, {super.key});
  final String mode;

  @override
  State<TenseMode> createState() => _TenseModeState();
}

const expandDuration = Duration(milliseconds: 500);

class _TenseModeState extends State<TenseMode> with TickerProviderStateMixin {
  Map<String, int> tension = {for (final color in SuperColors.twelveHues) color.name: 15};

  List<int> get tensionList => tension.values.toList();
  String get tensionRank => tensionList
      .fold(0.0, (previousValue, element) => previousValue + 125 / element)
      .toStringAsFixed(2);

  late final TenseScoreKeeper? scoreKeeper;

  late int hue, offset, gap;
  final List<int> hueChoices = [for (int i = 0; i < 360; i += 30) i];
  final List<int> recentChoices = [];
  int? selectedHue;

  late final List<AnimationController> controllers;
  late final Ticker inverseHues;
  static const animationTime = 25;
  static const duration = Duration(milliseconds: animationTime);

  String get name => SuperColor.hue(hue).name;

  Color get color => anyColor(hue);

  double itsLerpinTime = rng.nextDouble();
  double cosineShit(double x) => (1 - cos(pi * x)) / 2;
  double get solidMix => cosineShit(cosineShit(itsLerpinTime));

  Color anyColor(int hue) => {
        'vibrant': SuperColor.hue(hue),
        'mixed': Color.lerp(epicColors[hue], inverseColors[hue], solidMix)!,
      }[widget.mode]!;

  bool showDetails = false, showReaction = false;
  void tapReaction() {
    setState(() => showReaction = false);
    scoreKeeper?.rank = tensionRank;
    scoreKeeper?.roundCheck(context);
    generateHue();
  }

  void generateHue() {
    hue = hueChoices.removeAt(rng.nextInt(hueChoices.length));
    if (recentChoices.length >= 6) {
      hueChoices.add(recentChoices.removeAt(0));
    }
    recentChoices.add(hue);

    offset = rng.nextInt(4);
    itsLerpinTime = rng.nextDouble();
    gap = tension[name]!;
  }

  @override
  void initState() {
    super.initState();
    inverted = true;
    scoreKeeper = casualMode
        ? null
        : TenseScoreKeeper(
            page: {
            'vibrant': Pages.tenseVibrant,
            'mixed': Pages.tenseMixed,
          }[widget.mode]!);
    inverseHues = inverseSetup(setState);
    controllers = [
      for (int i = 0; i < 4; i++) AnimationController(duration: duration, vsync: this)
    ];
    generateHue();
  }

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }
    inverseHues.dispose();
    super.dispose();
  }

  static const style = TextStyle(
    fontFamily: 'Consolas',
    color: SuperColors.white80,
    fontSize: 20,
    inherit: false,
    height: 5 / 3,
  );

  Widget get tensionDesc {
    final double height = min(800, context.screenHeight - 400);
    return AnimatedContainer(
      duration: expandDuration,
      curve: curve,
      height: !showDetails ? 0 : height,
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
            child: Text(
              ' tension value = Δ hue between options\n'
              ' smaller value = higher difficulty\n\n'
              'Each answer alters the respective color tension value by ±1.\n'
              'Current values are listed below.\n',
            ),
          ),
          for (final entry in tension.entries) Target(entry.key, entry.value.toString()),
          const FixedSpacer(20),
          Target('average', tensionList.average.toStringAsFixed(2)),
          Target('tension_rank', tensionRank),
        ]),
      ),
    );
  }

  Widget get target => SuperContainer(
        width: 500,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: SuperColors.darkBackground,
            boxShadow: [
              BoxShadow(
                  color: SuperColors.darkBackground.withAlpha(128),
                  blurRadius: 10,
                  offset: const Offset(0, 10))
            ]),
        padding: const EdgeInsets.symmetric(vertical: 50),
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(children: [
            Target('hue', '$hue°'),
            Target(widget.mode == 'vibrant' ? 'color' : 'color [mixed]', name),
            Target('color_code', SuperColor(color.value - SuperColor.opaque).hexCode),
            Target('tension', tension[name]),
            casualMode ? empty : Target('round', scoreKeeper!.round),
            tensionDesc,
          ]),
        ),
      );

  Widget get button2by2 {
    return AnimatedContainer(
      duration: expandDuration,
      curve: curve,
      height: showDetails ? 0 : 420,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < 4; i += 2)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int j = i; j < i + 2; j++)
                    () {
                      final int h = (hue + gap * (j - offset)) % 360;
                      const double shadowSize = 2;
                      return GestureDetector(
                        onTap: () async {
                          controllers[j].forward(from: 1);
                          await sleep(.1);
                          setState(() {
                            selectedHue = h;
                            showReaction = true;
                            tension[name] =
                                max(min(tension[name]! + ((h == hue) ? -1 : 1), 179), 1);

                            final sk = scoreKeeper;
                            if (sk is TenseScoreKeeper) sk.updateHealth(h == hue);
                          });
                          controllers[j].reverse();
                        },
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0),
                            end: const Offset(0, 0.01),
                          ).animate(controllers[j]),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: ClipRect(
                              //TODO: figure out what's going on here
                              child: Stack(
                                children: [
                                  SuperContainer(
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(boxShadow: [
                                      BoxShadow(color: anyColor(h)),
                                      BoxShadow(
                                        color: Color.lerp(Colors.white, anyColor(h), 0.75)!,
                                        offset: const Offset(1, 2),
                                        spreadRadius: -shadowSize,
                                        blurRadius: shadowSize * 2,
                                      ),
                                      BoxShadow(
                                        color: anyColor(h),
                                        offset: const Offset(3, 5),
                                        spreadRadius: -shadowSize * 2,
                                        blurRadius: shadowSize,
                                      ),
                                    ]),
                                  ),
                                  SuperContainer(
                                    width: 200,
                                    height: 200,
                                    color: showReaction && h != hue ? Colors.black45 : null,
                                    alignment: const Alignment(0.08, -0.05),
                                    child: Opacity(
                                      opacity: showReaction ? 1 : 0,
                                      child: Text(
                                        '$h°',
                                        style: TextStyle(
                                            color: (showReaction &&
                                                    selectedHue == h &&
                                                    selectedHue != hue)
                                                ? Colors.red
                                                : Colors.black,
                                            fontSize: 40),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }()
                ],
              )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Theme(
        data: ThemeData(useMaterial3: true, textTheme: const TextTheme(bodyMedium: style)),
        child: Scaffold(
          body: Stack(
            children: [
              Center(
                child: Column(
                  children: [
                    const Spacer(),
                    const GoBack(),
                    const Spacer(),
                    target,
                    const Spacer(),
                    button2by2,
                    const Spacer(flex: 2),
                    TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.black12,
                          foregroundColor: SuperColors.darkBackground,
                        ),
                        onPressed: () => setState(() => showDetails = !showDetails),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Text(
                            showDetails ? '[hide details]' : '[show tension details]',
                            style: const TextStyle(fontFamily: 'Consolas', fontSize: 16),
                          ),
                        )),
                    const FixedSpacer(15),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 100),
                      child: casualMode || showDetails
                          ? const SizedBox(width: double.infinity)
                          : scoreKeeper!.midRoundDisplay,
                    ),
                    const FixedSpacer(15),
                  ],
                ),
              ),
              showReaction
                  ? Splendid(
                      correct: selectedHue == hue,
                      onTap: tapReaction,
                      gradientCycle: inverseHue,
                    )
                  : empty,
            ],
          ),
          backgroundColor: SuperColors.lightBackground,
        ),
      );
}

class Splendid extends StatelessWidget {
  const Splendid(
      {required this.correct, required this.onTap, required this.gradientCycle, super.key});
  final void Function() onTap;
  final num gradientCycle;
  final bool correct;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: SuperContainer(
          constraints: const BoxConstraints.expand(),
          color: Colors.transparent,
          alignment: const Alignment(0, 0.72),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: correct
                    ? Text(
                        'Splendid!',
                        style: TextStyle(
                          fontFamily: 'Consolas',
                          fontSize: 50,
                          shadows: [
                            for (double i = 2; i <= 20; i += 2)
                              Shadow(color: Colors.white, blurRadius: i),
                            for (int i = 0; i < 10; i++) const Shadow(blurRadius: 1)
                          ],
                        ),
                      )
                    : Text(
                        correct ? 'Splendid!' : '[incorrect]',
                        style: const TextStyle(
                          color: SuperColors.darkBackground,
                          fontFamily: 'Consolas',
                        ),
                      ),
              ),
              correct
                  ? ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) => LinearGradient(colors: [
                        for (int i = 0; i < 360; i += 10)
                          SuperColor.hue((gradientCycle + i) % 360)
                      ]).createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Splendid!',
                          style: TextStyle(
                            fontFamily: 'Consolas',
                            fontSize: 50,
                          ),
                        ),
                      ),
                    )
                  : empty,
            ],
          ),
        ),
      );
}
