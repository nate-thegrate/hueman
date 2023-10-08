import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:super_hueman/data/super_color.dart';
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
  Map<String, int> tension = {for (final color in SuperColors.twelveHues) color.name: 15};

  List<int> get tensionList => tension.values.toList();
  String get tensionRank => tensionList
      .fold(0.0, (previousValue, element) => previousValue + 125 / element)
      .toStringAsFixed(2);

  late final TenseScoreKeeper? scoreKeeper = casualMode
      ? null
      : TenseScoreKeeper(page: widget.volatile ? Pages.tenseVolatile : Pages.tenseVibrant);

  late int hue;
  final HueQueue hueQueue = HueQueue([for (int i = 0; i < 360; i += 30) i]);
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
    setState(() => showReaction = false);
    scoreKeeper?.rank = tensionRank;
    scoreKeeper?.roundCheck(context);
    generateHue();
  }

  void generateHue() {
    hue = hueQueue.queuedHue;

    final int offset = rng.nextInt(4);
    final int gap = tension[name]!;
    final double? luminance =
        widget.volatile ? rng.nextDouble().squared.stayInRange(.05, .6) : null;

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
    generateHue();
  }

  @override
  void dispose() {
    for (final data in buttonData) {
      data.controller.dispose();
    }
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
            Target(widget.volatile ? 'source_color' : 'color', name),
            Target('color_code', SuperColor(color.value - SuperColor.opaque).hexCode),
            Target('tension', tension[name]),
            casualMode ? empty : Target('round', scoreKeeper!.round),
            tensionDesc,
          ]),
        ),
      );

  void Function() _select(int j) => () async {
        buttonData[j].controller.forward(from: 1);
        await sleep(.1);
        final bool correct = buttonData[j].hue == hue;
        setState(() {
          selectedHue = buttonData[j].hue;
          showReaction = true;
          tension[name] = (tension[name]! + (correct ? -1 : 1)).stayInRange(1, 90);
          scoreKeeper?.updateHealth(correct);
        });
        buttonData[j].controller.reverse();
      };

  Widget get button2by2 => AnimatedContainer(
        duration: expandDuration,
        curve: curve,
        height: showDetails ? 0 : 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < 4; i += 2)
                Row(mainAxisSize: MainAxisSize.min, children: [
                  for (int j = i; j < i + 2; j++)
                    _TenseButton(
                      targetHue: hue,
                      buttonHue: buttonData[j].hue,
                      selectedHue: selectedHue,
                      controller: buttonData[j].controller,
                      color: buttonData[j].color,
                      select: _select(j),
                      showReaction: showReaction,
                    )
                ])
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Theme(
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
                  )
                : empty,
          ],
        ),
        backgroundColor: SuperColors.lightBackground,
      ),
    );
  }
}

class _TenseButton extends StatelessWidget {
  const _TenseButton({
    required this.targetHue,
    required this.buttonHue,
    required this.selectedHue,
    required this.controller,
    required this.color,
    required this.select,
    required this.showReaction,
  });

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
    return GestureDetector(
      onTap: select,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0),
          end: const Offset(0, 0.01),
        ).animate(controller),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: ClipRect(
            child: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                children: [
                  SuperContainer(
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
                  ),
                  SuperContainer(
                    color: showReaction && buttonHue != targetHue ? Colors.black45 : null,
                    alignment: const Alignment(0.08, -0.05),
                    child: Opacity(
                      opacity: showReaction ? 1 : 0,
                      child: Text(
                        '$buttonHue°',
                        style: TextStyle(
                          fontSize: 40,
                          color: wrongChoice ? Colors.red : Colors.black,
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

class _SplendidState extends State<Splendid> {
  late final Ticker hues;
  @override
  void initState() {
    super.initState();
    hues = inverseSetup(setState);
  }

  @override
  void dispose() {
    hues.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: widget.onTap,
        child: SuperContainer(
          color: Colors.transparent,
          alignment: const Alignment(0, 0.72),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: widget.correct
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
                        widget.correct ? 'Splendid!' : '[incorrect]',
                        style: const TextStyle(
                          color: SuperColors.darkBackground,
                          fontFamily: 'Consolas',
                        ),
                      ),
              ),
              widget.correct
                  ? ShaderMask(
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
