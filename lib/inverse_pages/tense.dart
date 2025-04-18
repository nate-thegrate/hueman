import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hueman/data/page_data.dart';
import 'package:hueman/data/save_data.dart';
import 'package:hueman/data/structs.dart';
import 'package:hueman/data/super_color.dart';
import 'package:hueman/data/super_state.dart';
import 'package:hueman/data/super_text.dart';
import 'package:hueman/data/widgets.dart';
import 'package:hueman/pages/score.dart';

class TenseScoreKeeper implements ScoreKeeper {
  TenseScoreKeeper({required this.page});
  @override
  final Pages page;

  static const maxHealth = 25;
  bool healthBarFlash = false;
  int round = 1, health = 13, overfills = 0;
  late String rank;

  void updateHealth(bool gotItRight, StateSetter setState) {
    if (gotItRight) {
      if (health == maxHealth) {
        overfills++;
        setState(() => healthBarFlash = true);
        sleep(1 / 3, then: () => setState(() => healthBarFlash = false));
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
  Widget get midRoundDisplay => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
            width: 500,
            height: 60,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                border: Border.fromBorderSide(
                  BorderSide(color: Colors.black12, width: 5),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedContainer(
                    width: 480 * health / 25,
                    duration: expandDuration,
                    curve: curve,
                    color: healthBarFlash ? Colors.white : Colors.black12,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  @override
  int get scoreVal => round * (overfills + 1);

  @override
  String get finalDetails {
    final String desc = 'survived $round rounds!';
    if (overfills == 0) return desc;
    return '$desc\n'
        '\u00d7${overfills + 1} bonus! '
        '($overfills health bar overfill${overfills > 1 ? 's' : ''})';
  }
}

class Target extends StatelessWidget {
  const Target(this.label, this.value, {super.key});
  final String label;
  final dynamic value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text('$label:', textAlign: TextAlign.right)),
        const FixedSpacer(15),
        Expanded(child: Text(value.toString())),
      ],
    );
  }
}

class _NoMoreChartreuse extends StatefulWidget {
  const _NoMoreChartreuse();

  @override
  State<_NoMoreChartreuse> createState() => _NoMoreChartreuseState();
}

class _NoMoreChartreuseState extends InverseState<_NoMoreChartreuse> {
  @override
  Widget build(BuildContext context) {
    return DismissibleDialog(
      title: const Text('Tension Rank 500'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text.rich(
              textAlign: TextAlign.center,
              softWrap: false,
              TextSpan(
                children: [
                  TextSpan(
                    text: '"no more chartreuse" unlocked!',
                    style: SuperStyle.gaegu(
                      size: 27,
                      weight: FontWeight.bold,
                      color: inverseColor,
                      shadows: const [
                        Shadow(color: Colors.white, blurRadius: 1),
                        Shadow(color: Colors.white, blurRadius: 2),
                        Shadow(color: Colors.white, blurRadius: 3),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Text(
            Tutorial.gameEnd()
                ? "go 'even further' to find the button!"
                : 'find the button after beating the game!',
            textAlign: TextAlign.left,
            style: const SuperStyle.sans(),
          ),
          const FixedSpacer(6),
        ],
      ),
    );
  }
}

class TenseMode extends StatefulWidget {
  const TenseMode(this.mode, {super.key}) : volatile = mode == 'volatile';
  final String mode;
  final bool volatile;

  @override
  State<TenseMode> createState() => _TenseModeState();
}

const expandDuration = Duration(milliseconds: 500);

class _ButtonData {
  _ButtonData(this.controller);
  int hue = 0;
  SuperColor color = SuperColors.black;
  AnimationController controller;

  void update(int hue, SuperColor color) {
    this.hue = hue;
    this.color = color;
  }

  @override
  String toString() => 'ButtonData(hue: $hue, color: $color)';
}

class _TenseModeState extends State<TenseMode> with TickerProviderStateMixin {
  Map<String, int> tension = {
    for (final color in (variety ? SuperColors.allNamedHues : SuperColors.twelveHues))
      color.name: 15
  };

  List<int> get tensionList => tension.values.toList();
  String get tensionRank => tensionList
      .fold(0.0, (previousValue, element) => previousValue + 125 / element)
      .toStringAsFixed(2);

  late final TenseScoreKeeper? scoreKeeper = switch (widget.volatile) {
    _ when casualMode => null,
    true => TenseScoreKeeper(page: Pages.tenseVolatile),
    false => TenseScoreKeeper(page: Pages.tenseVibrant),
  };

  late int hue;
  final HueQueue hueQueue = HueQueue(variety ? 24 : 12);
  int? selectedHue;

  static const animationTime = 25;
  static const duration = Duration(milliseconds: animationTime);

  late List<_ButtonData> buttonData = [
    for (int i = 0; i < 4; i++) _ButtonData(AnimationController(duration: duration, vsync: this))
  ];

  String get name => SuperColor.hue(hue).name;
  late SuperColor color;

  bool showDetails = false, showReaction = false;
  void tapReaction() {
    if (!enableMusic && !Platform.isAndroid) sfx.play('tense_reset');
    setState(() => showReaction = false);
    scoreKeeper?.rank = tensionRank;
    scoreKeeper?.roundCheck(context);
    generateHue();
    if (!Tutorial.tensed() && double.parse(tensionRank) >= 500) {
      Tutorial.tensed.complete();
      showDialog<void>(context: context, builder: (context) => const _NoMoreChartreuse());
    }
  }

  void generateHue() {
    hue = hueQueue.queuedHue;

    final int offset = rng.nextInt(4);
    final int gap = tension[name]!;
    final double? luminance = widget.volatile ? rng.nextDouble().squared.clamp(.05, .6) : null;

    color = SuperColor.hue(hue, luminance);
    for (int j = 0; j < 4; j++) {
      final buttonHue = (hue + gap * (j - offset)) % 360;
      buttonData[j].update(
        buttonHue,
        buttonHue == hue ? color : SuperColor.hue(buttonHue, luminance),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    inverted = true;
    music.play(loop: 'casual_2');
    generateHue();
    if (!Tutorial.tense()) {
      Tutorial.tense.complete();
      sleep(
        0.5,
        then: () => showDialog<void>(
          context: context,
          builder: (context) => Theme(
            data: ThemeData(
              useMaterial3: true,
              dialogTheme: const DialogThemeData(backgroundColor: SuperColors.lightBackground),
            ),
            child: const DismissibleDialog(
              title: Text(
                'Tense mode',
                style: SuperStyle.sans(weight: 600, width: 87.5),
              ),
              content: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Stretch your limits!\n\n'
                  'The difficulty for each color will adjust\n'
                  'based on your performance.\n\n'
                  'Good luck!',
                  softWrap: false,
                  style: SuperStyle.sans(),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    for (final data in buttonData) {
      data.controller.dispose();
    }
    super.dispose();
  }

  static const style = SuperStyle.mono(
    color: SuperColors.white80,
    size: 16,
    weight: 600,
    inherit: false,
    height: 5 / 3,
  );

  Widget tensionDesc(BoxConstraints constraints) {
    final double height = min(800, constraints.maxHeight - 400);
    return AnimatedContainer(
      duration: expandDuration,
      curve: curve,
      height: !showDetails ? 0 : height,
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
            child: Text(
              'tension value = Δ hue between options\n'
              'smaller value = higher difficulty\n\n'
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

  Widget target(BoxConstraints constraints) => FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            width: 390,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: SuperColors.darkBackground,
                boxShadow: [
                  BoxShadow(
                      color: SuperColors.darkBackground.withAlpha(128),
                      blurRadius: 10,
                      offset: const Offset(0, 10))
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 33),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Column(children: [
                    Target('hue', '$hue°'),
                    Target(widget.volatile ? 'source_color' : 'color', name),
                    Target(
                        'color_code', SuperColor(color.toARGB32() - SuperColor.opaque).hexCode),
                    Target('tension', tension[name]),
                    if (!casualMode) Target('round', scoreKeeper!.round),
                    tensionDesc(constraints),
                  ]),
                ),
              ),
            ),
          ),
        ),
      );

  void Function() _select(int j) => () async {
        final bool correct = buttonData[j].hue == hue;
        buttonData[j].controller.forward(from: 1);

        if (correct) {
          sfx.play(
            scoreKeeper?.health == TenseScoreKeeper.maxHealth
                ? 'tense_overfill'
                : 'tense_correct',
          );
        } else {
          sfx.play('tense_wrong');
        }
        await sleep(.1);
        setState(() {
          selectedHue = buttonData[j].hue;
          showReaction = true;
          tension[name] = (tension[name]! + (correct ? -1 : 1)).clamp(1, 90);
          scoreKeeper?.updateHealth(correct, setState);
        });
        buttonData[j].controller.reverse();
      };

  Widget button2by2(BoxConstraints constraints) => AnimatedContainer(
        duration: expandDuration,
        curve: curve,
        height: showDetails
            ? 0
            : constraints.calcSize((w, h) => min(w, min(h - 270 - (casualMode ? 0 : 100), 420))),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < 4; i += 2)
                Row(mainAxisSize: MainAxisSize.min, children: [
                  for (int j = i; j < i + 2; j++)
                    _TenseButton(
                      constraints: constraints,
                      targetHue: hue,
                      buttonHue: buttonData[j].hue,
                      selectedHue: selectedHue,
                      controller: buttonData[j].controller,
                      color: buttonData[j].color,
                      select: _select(j),
                      showReaction: showReaction,
                    ),
                ])
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        fontFamily: 'nunito sans',
        textTheme: const TextTheme(bodyMedium: style),
      ),
      child: Scaffold(
        body: SafeLayout((context, constraints) {
          return Stack(
            children: [
              Center(
                child: Column(
                  children: [
                    const Spacer(),
                    const GoBack(),
                    const Spacer(),
                    target(constraints),
                    const Spacer(),
                    button2by2(constraints),
                    const Spacer(flex: 2),
                    SizedBox(
                      height: 30,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.black12,
                          foregroundColor: SuperColors.darkBackground,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        onPressed: () => setState(() => showDetails = !showDetails),
                        child: Text(
                          showDetails ? '[hide details]' : '[tension details]',
                          style: const SuperStyle.mono(size: 12),
                        ),
                      ),
                    ),
                    const FixedSpacer(15),
                    AnimatedSize(
                      duration: Durations.short2,
                      child: casualMode || showDetails ? flat : scoreKeeper!.midRoundDisplay,
                    ),
                    if (!casualMode) const FixedSpacer(15),
                  ],
                ),
              ),
              if (showReaction)
                Splendid(
                  correct: selectedHue == hue,
                  onTap: tapReaction,
                ),
            ],
          );
        }),
        backgroundColor: SuperColors.lightBackground,
      ),
    );
  }
}

class _TenseButton extends StatelessWidget {
  const _TenseButton({
    required this.constraints,
    required this.targetHue,
    required this.buttonHue,
    required this.selectedHue,
    required this.controller,
    required this.color,
    required this.select,
    required this.showReaction,
  });

  final BoxConstraints constraints;
  final int targetHue, buttonHue;
  final int? selectedHue;
  final AnimationController controller;
  final Color color;
  final void Function() select;
  final bool showReaction;

  bool get wrongChoice => showReaction && selectedHue == buttonHue && selectedHue != targetHue;

  @override
  Widget build(BuildContext context) {
    const double shadowSize = 2;
    final double width = constraints.calcSize(
      (w, h) => min((w / 2) - 20, min((h - 250) / 2 - (casualMode ? 20 : 70), 200)),
    );
    return GestureDetector(
      onTap: select,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0, 0.01),
        ).animate(controller),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: ClipRect(
            child: SizedBox(
              width: width,
              height: width,
              child: Stack(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(color: color),
                      BoxShadow(
                        color: Color.lerp(Colors.white, color, 0.75)!,
                        offset: const Offset(1, 2),
                        spreadRadius: -shadowSize,
                        blurRadius: shadowSize * 2,
                      ),
                      BoxShadow(
                        color: color,
                        offset: const Offset(3, 5),
                        spreadRadius: -shadowSize * 2,
                        blurRadius: shadowSize,
                      ),
                    ]),
                    child: emptyContainer,
                  ),
                  ColoredBox(
                    color: showReaction && buttonHue != targetHue
                        ? Colors.black45
                        : Colors.transparent,
                    child: Align(
                      alignment: const Alignment(0.08, -0.05),
                      child: Opacity(
                        opacity: showReaction ? 1 : 0,
                        child: Text(
                          '$buttonHue°',
                          style: SuperStyle.sans(
                            size: 40,
                            extraBold: true,
                            color: wrongChoice ? Colors.red : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Splendid extends StatefulWidget {
  const Splendid({required this.correct, required this.onTap, super.key});
  final void Function() onTap;
  final bool correct;

  @override
  State<Splendid> createState() => _SplendidState();
}

class _SplendidState extends InverseState<Splendid> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Align(
        alignment: const Alignment(0, 0.72),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: widget.correct
                  ? Text(
                      'Splendid!',
                      style: SuperStyle.mono(
                        size: 50,
                        shadows: [
                          for (double i = 2; i <= 20; i += 2)
                            Shadow(color: Colors.white, blurRadius: i),
                          for (int i = 0; i < 10; i++) const Shadow(blurRadius: 1)
                        ],
                      ),
                    )
                  : const Text(
                      '[incorrect]',
                      style: SuperStyle.mono(color: SuperColors.darkBackground),
                    ),
            ),
            if (widget.correct)
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => LinearGradient(colors: [
                  for (int i = 0; i < 360; i += 10) SuperColor.hue((inverseHue + i) % 360)
                ]).createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'Splendid!',
                    style: SuperStyle.mono(size: 50),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
