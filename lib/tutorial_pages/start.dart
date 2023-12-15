import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
        sleep(4, then: () => playMusic(once: 'speedup'));
        sleep(9.85, then: () => context.noTransition(const _CallOutTheLie()));
      },
    ),
    rive.OneShotAnimation('complete lie', autoplay: false),
  ];

  String artboard = 'start button screen';
  Widget callOutTheLie = empty;
  SuperColor backgroundColor = SuperColors.lightBackground;

  void start() async {
    externalKeyboard =
        ![TargetPlatform.android, TargetPlatform.iOS].contains(Theme.of(context).platform);
    saveData('externalKeyboard', externalKeyboard);

    final size = context.screenSize;
    if ((size.width < 350 || size.height < 667) &&
        ![TargetPlatform.android, TargetPlatform.iOS].contains(Theme.of(context).platform)) {
      await showDialog(
        context: context,
        builder: (context) => const _ScreenSizeAlert(),
        barrierDismissible: false,
      );
    }
    setState(() => controllers[1].isActive = true);
    sleep(
      1.48,
      then: () => setState(() {
        artboard = 'fake primaries';
        backgroundColor = SuperColors.bsBackground;
      }),
    );
  }

  int konamiSwipes = 0;
  bool speedrun = false;

  void updateKonami(DragEndDetails details) {
    konamiSwipes = switch ((konamiSwipes, details.direction)) {
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
              onPanEnd: updateKonami,
              child: Rive(
                name: 'color_bs',
                artboard: artboard,
                controllers: controllers,
              ),
            ),
            const _Logo(),
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
                      )
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
      'starting animation',
      '3 colors',
      '6 colors',
      '12 colors',
      'sandbox',
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
                "Mark the tutorials you've already seen, and jump right into the action.",
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
                          width: 30,
                          child: Checkbox(
                              value: i <= numToSkip,
                              onChanged: (_) => setState(() => numToSkip = i)),
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

class _ScreenSizeAlert extends StatefulWidget {
  const _ScreenSizeAlert();

  @override
  State<_ScreenSizeAlert> createState() => _ScreenSizeAlertState();
}

class _ScreenSizeAlertState extends State<_ScreenSizeAlert> {
  bool showRecommendation = false;

  bool get looksGood => context.screenWidth >= 350 && context.screenHeight >= 667;

  static const color = SuperColors.bsBrown;
  late final continueButton = SizedBox(
    width: 50,
    height: 50,
    child: Stack(
      children: [
        const Center(child: Icon(Icons.arrow_forward, color: color)),
        SizedBox.expand(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(side: const BorderSide(color: color)),
            onPressed: () => setState(() => showRecommendation = true),
            child: empty,
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final size = context.screenSize;
    final (String width, String height) = (
      size.width.toStringAsFixed(1),
      size.height.toStringAsFixed(1),
    );
    final List<Widget> children = switch (Theme.of(context).platform) {
      _ when !showRecommendation => const [
          Text(
            '(this is measured in "logical pixels": '
            'values may be smaller than actual display specs '
            'on a high-resolution screen.)\n\n',
            style: SuperStyle.sans(size: 12),
          ),
          Text("The game should work fine, but there's no guarantee.", style: SuperStyle.sans()),
        ],
      TargetPlatform.android || TargetPlatform.iOS => throw UnimplementedError(),
      TargetPlatform.linux => const [
          Text(
            "It looks like you're running linux. "
            'I was thinking about typing out instructions '
            'for how to increase your display resolution, '
            'but you probably know how to do that better than I do lol',
            style: SuperStyle.sans(),
          )
        ],
      TargetPlatform.macOS => const [
          Text(
            'If you want to play on this Mac, here are a few ideas:\n',
            style: SuperStyle.sans(),
          ),
          Text(
            ' • Click the green button to make this a full-screen window.',
            style: SuperStyle.sans(),
          ),
          Text(
            ' • Go to System Settings → Displays and select "more space".',
            style: SuperStyle.sans(),
          ),
        ],
      TargetPlatform.windows => const [
          Text(
            'If you want to play on this PC, here are a few ideas:\n',
            style: SuperStyle.sans(),
          ),
          Text(
            " • Maximize the size of this window, if it isn't already filling up your screen.",
            style: SuperStyle.sans(),
          ),
          Text(
            ' • Go to Display Settings. '
            'Reduce "Scale" to 100% and change "Display Resolution" to the biggest size.',
            style: SuperStyle.sans(),
          ),
          Text(
            ' • Taskbar Settings → Taskbar behaviors → "Automatically hide the taskbar"',
            style: SuperStyle.sans(),
          ),
        ],
      TargetPlatform.fuchsia => const [
          Text(
            'If you built this from source code on Fuscia, '
            "hopefully you know what you're doing lol",
            style: SuperStyle.sans(),
          ),
        ],
    };

    final popButton = OutlinedButton(
      style: OutlinedButton.styleFrom(side: const BorderSide(color: SuperColors.bsBrown)),
      onPressed: Navigator.of(context).pop,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(
          looksGood ? 'looks good!' : "I'll just risk it",
          style: const SuperStyle.sans(weight: 200, extraBold: true, letterSpacing: 0.5),
        ),
      ),
    );

    return Theme(
      data: ThemeData(
        useMaterial3: true,
        fontFamily: 'nunito sans',
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: color,
          onPrimary: color,
          secondary: color,
          onSecondary: color,
          error: color,
          onError: color,
          background: SuperColors.bsBackground,
          onBackground: SuperColors.bsBackground,
          surface: color,
          onSurface: color,
        ),
      ),
      child: AlertDialog(
        title: const Text(
          'screen size alert!',
          style: SuperStyle.sans(extraBold: true, letterSpacing: 1 / 3),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('minimum recommended size:', style: SuperStyle.sans()),
            const Text('350 x 667 pixels\n', style: SuperStyle.mono(weight: 700)),
            const Text('this screen:', style: SuperStyle.sans()),
            Text(
              '$width x $height pixels\n',
              style: const SuperStyle.mono(weight: 700),
            ),
            ...children
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          if (showRecommendation || looksGood) popButton else continueButton,
        ],
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
  double dy = 0;
  Curve curve = Curves.easeInOutQuad;
  Duration duration = halfSec;
  bool exists = true, visible = true;

  @override
  void animate() async {
    await sleep(1.5);
    sleep(0.75, then: () => playSound('ryb'));
    for (int i = 0; i < 4; i++) {
      await sleepState(0.75, () => lettersVisible++);
    }
    await sleepState(1, () => dy = 0.5);
    await sleepState(0.5, () {
      curve = Curves.easeInQuad;
      duration = oneSec;
      dy = -8;
    });
    await sleepState(1 / 3, () => visible = false);
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
        child: AnimatedSlide(
          offset: Offset(0, dy),
          duration: duration,
          curve: curve,
          child: SuperRichText([
            for (int i = 0; i < 4; i++)
              TextSpan(
                text: letterData[i].$1,
                style: SuperStyle.gaegu(
                  size: size,
                  color: lettersVisible > i ? letterData[i].$2 : Colors.transparent,
                ),
              )
          ]),
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
  void animate() async {
    await musicPlayer.stop();
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
                          )
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
  Widget? introButton;
  bool showAll = false, expanded = false, expanded2 = false;
  static const showAllDuration = Duration(milliseconds: 1200);
  // ,
  //     expandDuration = Duration(milliseconds: 600);

  void expand() async {
    setState(() => showAll = true);
    await sleepState(2, () => expanded = true);
    await sleepState(1, () => expanded2 = true);
    await sleepState(
      1,
      () => setState(() => introButton = const _IntroButton()),
    );
  }

  @override
  void animate() {
    inverted = false;
    epicHue = 0;
    playMusic(once: 'see_the_truth', loop: 'verity_1');
    sleep(18, then: expand);
    ticker = Ticker(
      (elapsed) {
        setState(() => progress = elapsed.inMilliseconds / 14000);
        if (progress >= 1) ticker.stop();
      },
    )..start();
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
              color: epicColor,
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
        if (progress < 1) {
          final double x = progress * 360;
          const int peak = 345;
          final double val =
              x < peak ? x.squared / peak : (x - peak) * peak / (peak - 360) + peak;
          final girth = val * min(constraints.maxWidth, constraints.maxHeight) / 350;
          return Center(
            child: SuperContainer(
              margin: const EdgeInsets.only(top: 39),
              width: girth,
              decoration: BoxDecoration(shape: BoxShape.circle, color: epicColor),
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
                            child: SuperHUEman(epicColor),
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

class _IntroButton extends StatefulWidget {
  const _IntroButton();

  @override
  State<_IntroButton> createState() => _IntroButtonState();
}

class _IntroButtonState extends State<_IntroButton> {
  late final Ticker epicHues;
  SuperColor color = epicColor;

  @override
  void initState() {
    super.initState();
    Tutorial.started.complete();
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
