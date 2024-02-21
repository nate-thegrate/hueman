import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart' as rive;
import 'package:hueman/data/page_data.dart';
import 'package:hueman/data/save_data.dart';
import 'package:hueman/data/structs.dart';
import 'package:hueman/data/super_color.dart';
import 'package:hueman/data/super_container.dart';
import 'package:hueman/data/super_state.dart';
import 'package:hueman/data/super_text.dart';
import 'package:hueman/data/widgets.dart';

extension _Direction on DragEndDetails {
  AxisDirection get direction => switch (velocity.pixelsPerSecond.direction) {
        > 3 / 4 * pi || < -3 / 4 * pi => AxisDirection.left,
        > pi / 4 => AxisDirection.down,
        < -pi / 4 => AxisDirection.up,
        _ => AxisDirection.right,
      };
}

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
      onStop: () {
        sleep(4 - androidLatency, then: () => playSound('speedup'));
        sleep(9.85, then: () => context.noTransition(const _CallOutTheLie()));
        if (Platform.isIOS) {
          sleep(6.5, then: () {
            setState(() => glitchy = true);
            ticker = Ticker((_) => setState(() => flicker = !flicker))..start();
          });
        }
      },
    ),
    rive.OneShotAnimation('complete lie', autoplay: false),
  ];

  String artboard = 'start button screen';
  bool glitchy = false, flicker = false;
  Ticker? ticker;
  SuperColor backgroundColor = SuperColors.lightBackground;
  final FocusNode focusNode = FocusNode();

  void start() async {
    externalKeyboard = switch (Theme.of(context).platform) {
      TargetPlatform.android || TargetPlatform.iOS => false,
      _ => true,
    };
    saveData('externalKeyboard', externalKeyboard);

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
  void initState() {
    super.initState();
    addListener(konamiKey);
  }

  @override
  void dispose() {
    yeetListener(konamiKey);
    super.dispose();
  }

  int konamiSwipes = 0;
  bool speedrun = false;

  bool konamiKey(KeyEvent event) {
    if (event is KeyUpEvent || event is KeyRepeatEvent) return false;

    final AxisDirection? direction = switch (event.logicalKey) {
      LogicalKeyboardKey.arrowUp => AxisDirection.up,
      LogicalKeyboardKey.arrowDown => AxisDirection.down,
      LogicalKeyboardKey.arrowLeft => AxisDirection.left,
      LogicalKeyboardKey.arrowRight => AxisDirection.right,
      _ => null,
    };
    if (direction != null) updateKonami(direction);
    return true;
  }

  void konamiSwipe(DragEndDetails details) => updateKonami(details.direction);

  void updateKonami(AxisDirection direction) {
    konamiSwipes = switch ((konamiSwipes, direction)) {
      (1 || 2, AxisDirection.up) => 2,
      (_, AxisDirection.up) => 1,
      (2 || 3, AxisDirection.down) => konamiSwipes + 1,
      (4 || 6, AxisDirection.left) => konamiSwipes + 1,
      (5 || 7, AxisDirection.right) => konamiSwipes + 1,
      _ => 0,
    };
    if (konamiSwipes == 8) setState(() => speedrun = true);
  }

  void konamiButton() {
    if (konamiSwipes < 10) {
      setState(() => konamiSwipes++);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (context) => const _TheGoodStuff()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: start,
              onPanEnd: konamiSwipe,
              child: Rive(
                name: 'color_bs',
                artboard: artboard,
                controllers: controllers,
              ),
            ),
            const _Logo(),
            if (glitchy) Flicker(flicker, SuperColors.bsBackground),
            if (speedrun)
              SuperContainer(
                color: Colors.black45,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (final (i, text) in ['b', 'a', 'start'].indexed)
                      SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: i + 8 == konamiSwipes ? konamiButton : null,
                          style: ElevatedButton.styleFrom(backgroundColor: SuperColors.bsBrown),
                          child: Text(
                            text,
                            style: const SuperStyle.sans(size: 24),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
      backgroundColor: backgroundColor,
    );
  }
}

class _TheGoodStuff extends StatefulWidget {
  const _TheGoodStuff();

  @override
  State<_TheGoodStuff> createState() => _TheGoodStuffState();
}

class _TheGoodStuffState extends State<_TheGoodStuff> with SinglePress {
  int numToSkip = 0;
  @override
  Widget build(BuildContext context) {
    const labels = [
      'color misinformation',
      'additive primaries',
      'subtractive primaries',
      'scientific color vocab',
      'hex color codes',
    ];
    final style = ElevatedButton.styleFrom(
      backgroundColor: SuperColors.bsBrown,
      foregroundColor: Colors.white,
    );
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        checkboxTheme: const CheckboxThemeData(
          fillColor: MaterialStatePropertyAll(SuperColors.bsBrown),
          side: BorderSide.none,
        ),
      ),
      child: Scaffold(
        body: Center(
          child: Column(
            children: [
              const Spacer(flex: 4),
              const SuperText(
                "Let's skip to\nthe good stuff!",
                style: SuperStyle.gaegu(size: 32),
              ),
              const Spacer(),
              const SuperText(
                "Select the concepts you're already familiar with, and jump right into the action.",
                style: SuperStyle.gaegu(size: 18),
              ),
              const Spacer(),
              for (final (i, label) in labels.indexed)
                GestureDetector(
                  onTap: () => setState(() => numToSkip = i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: i <= numToSkip,
                            onChanged: (_) => setState(() => numToSkip = i),
                          ),
                        ),
                        const FixedSpacer.horizontal(10),
                        SizedBox(
                          width: 200,
                          child: Text(
                            label,
                            style: const SuperStyle.sans(size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const Spacer(),
              Row(
                children: [
                  const Spacer(flex: 4),
                  ElevatedButton(
                    onPressed: () => context.noTransition(const StartScreen()),
                    style: style,
                    child: const Text('go back', style: SuperStyle.sans(size: 18)),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: singlePress(noDelay: true, () async {
                      for (int i = 0; i <= numToSkip; i++) {
                        await Tutorial.values[i].complete();
                      }
                      context.goto(Pages.menu);
                    }),
                    style: style,
                    child: const Text('continue', style: SuperStyle.sans(size: 18)),
                  ),
                  const Spacer(flex: 4),
                ],
              ),
              const Spacer(flex: 4),
            ],
          ),
        ),
        backgroundColor: SuperColors.bsBackground,
      ),
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
  Duration duration = halfSec;
  bool exists = true, visible = true;

  @override
  void animate() async {
    await sleep(1.5);
    if (!Platform.isAndroid) sleep(0.75, then: () => playSound('ryb'));
    for (int i = 0; i < 4; i++) {
      await sleepState(0.75, () => lettersVisible++);
    }
    await sleepState(2, () => visible = false);
    await sleepState(1, () => exists = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!exists) return empty;
    final size = context.screenWidth / 4;
    return Fader(
      visible,
      child: SuperContainer(
        color: SuperColors.lightBackground,
        alignment: Alignment.center,
        child: SuperRichText([
          for (int i = 0; i < 4; i++)
            TextSpan(
              text: letterData[i].$1,
              style: SuperStyle.gaegu(
                size: size,
                color: lettersVisible > i ? letterData[i].$2 : Colors.transparent,
              ),
            ),
        ]),
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
  void animate() async {
    await sfxPlayer.stop();
    await sleepState(3, () => showButton = true);
  }

  bool showStuff = true, showButton = false, headphones = false;

  void seeTheTruth() async {
    setState(() => showStuff = false);
    await sleepState(2, () {
      headphones = true;
      showStuff = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Fader(
            showStuff,
            duration: const Duration(milliseconds: 600),
            child: Column(
              children: [
                const Spacer(flex: 2),
                headphones
                    ? const Column(
                        children: [
                          Icon(Icons.headphones_outlined, size: 300),
                          Text(
                            '(headphones recommended)',
                            style: SuperStyle.sans(size: 16, letterSpacing: 0.5),
                          ),
                        ],
                      )
                    : const Text(
                        'Except that was\na complete lie.',
                        textAlign: TextAlign.center,
                        style: SuperStyle.sans(size: 32),
                      ),
                const Spacer(),
                Fader(
                  showButton,
                  child: SizedBox(
                    height: 60,
                    child: headphones
                        ? Center(
                            child: ContinueButton(
                              onPressed: () {
                                setState(() => showStuff = false);
                                sleep(
                                  2,
                                  then: () => context.noTransition(const _FirstLaunchMenu()),
                                );
                              },
                            ),
                          )
                        : _TruthButton(onPressed: seeTheTruth),
                  ),
                ),
                const Spacer(),
              ],
            ),
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

class _TruthButtonState extends EpicState<_TruthButton> {
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
        padding: EdgeInsets.only(bottom: 4),
        child: Text('see the truth', style: SuperStyle.sans(size: 24)),
      ),
    );
  }
}

class _FirstLaunchMenu extends StatefulWidget {
  const _FirstLaunchMenu();

  @override
  State<_FirstLaunchMenu> createState() => _FirstLaunchMenuState();
}

class _FirstLaunchMenuState extends EpicState<_FirstLaunchMenu> {
  late final Ticker ticker;
  double progress = 0;
  bool showAll = false, expanded = false, expanded2 = false, showButton = false;
  static const showAllDuration = Duration(milliseconds: 1200);

  void expand() async {
    setState(() => showAll = true);
    await sleepState(2, () => expanded = true);
    await sleepState(1, () => expanded2 = true);
    await sleepState(1, () => showButton = true);
  }

  @override
  void animate() async {
    inverted = false;
    epicHue = 0;
    playSound('see_the_truth');
    await sleep(androidLatency);
    sleep(18, then: expand);
    ticker = Ticker((elapsed) {
      setState(() => progress = (elapsed.inMilliseconds - 4000) / 10000);
      if (progress >= 1) ticker.stop();
    })
      ..start();
    Tutorial.started.complete();
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  static const buffer = Expanded(
    child: SuperContainer(color: SuperColors.darkBackground),
  );
  static const buffer2 = Expanded(
    child: SuperContainer(color: SuperColors.darkBackground, height: 39),
  );

  @override
  Widget build(BuildContext context) {
    final padding =
        expanded ? const EdgeInsets.only(bottom: 34) : const EdgeInsets.only(right: 17);
    const double size = 30;
    const space = TextSpan(text: ' ', style: SuperStyle.sans(size: 1));
    final color = epicColor;
    final transparentHUEman = Padding(
      padding: padding + const EdgeInsets.only(bottom: 5),
      child: SuperRichText(
        style: const SuperStyle.sans(size: size, weight: 250),
        [
          const TextSpan(
            text: 'super',
            style: SuperStyle.sans(
              size: size,
              weight: 250,
              color: Colors.transparent,
            ),
          ),
          space,
          TextSpan(
            text: 'HUE',
            style: SuperStyle.sans(
              size: size * 0.7,
              color: color,
              weight: 800, //Platform.isIOS ? 800 : (progress * 575 - 1440).stayInRange(200, 800),
            ),
          ),
          space,
          const TextSpan(
            text: 'man',
            style: SuperStyle.sans(
              size: size,
              weight: 250,
              color: Colors.transparent,
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      body: SafeLayout((context, constraints) {
        if (progress < 0) {
          final double x = progress * -2.5;
          final double size = constraints.calcSize((w, h) => min(w, h) * x);
          return Center(
            child: SuperContainer(
              width: size,
              height: size,
              decoration: BoxDecoration(
                border: Border.all(color: color, width: 2),
                color: x > .5 ? null : color.withOpacity((1 - 2 * x).squared),
              ),
            ),
          );
        } else if (progress < 1) {
          final double x = progress * 360;
          const int peak = 345;
          final double val =
              x < peak ? x.squared / peak : (x - peak) * peak / (peak - 360) + peak;
          final girth = val * min(constraints.maxWidth, constraints.maxHeight) / 350;
          return Center(
            child: SuperContainer(
              margin: const EdgeInsets.only(top: 39),
              width: girth,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              alignment: Alignment.center,
              child: _Squares(girth * 16 / (16 * root2over2 - 1) * root2over2),
            ),
          );
        }
        return Stack(
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
                            child: SuperHUEman(color),
                          ),
                        ),
                        Row(
                          children: [
                            buffer2,
                            AnimatedSize(
                              duration: showAllDuration,
                              curve: curve,
                              child: SizedBox(width: showAll ? 200 : 0),
                            ),
                            buffer2,
                            const FixedSpacer.horizontal(20),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SuperContainer(
                    decoration: BoxDecoration(border: Border.all(color: color, width: 2)),
                    child: SexyBox(
                      child: SizedBox(
                        width: expanded ? 300 : context.screenWidth,
                        height: expanded2 ? 200 : 0,
                        child: showButton ? _IntroButton(color) : null,
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
                  child: SizedBox(width: showAll ? context.screenWidth : 45),
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
        );
      }),
    );
  }
}

const root2over2 = 0.7071067811865476;

class _Squares extends StatelessWidget {
  const _Squares(this.width);
  final double width;

  @override
  Widget build(BuildContext context) {
    final borderWidth = width / 32;
    final double size = max(width * root2over2 - 2 * borderWidth, 1);
    return Transform.rotate(
      angle: 64 / size + pi / 6,
      child: SuperContainer(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border.all(color: SuperColors.darkBackground, width: borderWidth),
        ),
        alignment: Alignment.center,
        child: size * root2over2 < 2 ? null : _Squares(size),
      ),
    );
  }
}

class _IntroButton extends StatelessWidget {
  const _IntroButton(this.color);
  final SuperColor color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeIn(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'intro (3 colors)',
              style: SuperStyle.sans(color: SuperColors.white80, size: 20),
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
