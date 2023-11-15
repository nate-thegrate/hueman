import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hueman/data/page_data.dart';
import 'package:hueman/data/save_data.dart';
import 'package:hueman/data/structs.dart';
import 'package:hueman/data/super_color.dart';
import 'package:hueman/data/super_container.dart';
import 'package:hueman/data/super_state.dart';
import 'package:hueman/data/super_text.dart';
import 'package:hueman/data/widgets.dart';
import 'package:hueman/tutorial_pages/true_mastery.dart';

enum MenuPage { main, settings, tenseSelect, howToWin, highScores, reset }

class InverseMenu extends StatefulWidget {
  const InverseMenu({super.key});

  @override
  State<InverseMenu> createState() => _InverseMenuState();
}

class _InverseMenuState extends InverseState<InverseMenu>
    with SingleTickerProviderStateMixin, SinglePress {
  late final AnimationController controller = AnimationController(duration: oneSec, vsync: this);
  bool inverting = false, visible = true, exists = true, trueMastery = false, showButtons = true;
  late bool showResetButton;
  late int hintsVisible;
  MenuPage menuPage = MenuPage.main;
  bool get mainMenu => menuPage == MenuPage.main;

  @override
  void animate() async {
    if (inverted) {
      visible = false;
      exists = false;
      if (!booted) {
        showButtons = false;
        await sleepState(1, () => showButtons = true);
        booted = true;
      }
    } else {
      saveData('inverted', true);
      inverted = true;
      quickly(() => setState(() => visible = false));
      sleepState(0.6, () => exists = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const SuperStyle titleStyle = SuperStyle.sans(
      color: Colors.black,
      size: 32,
      height: 1.3,
    );
    const hints = [
      'make sure casual mode\nis  ☑ enabled.',
      'go to "true mastery".',
      'tap the color code button.',
      'watch how the values for\nred/green/blue change\nwhen you tap the button.',
      'convert each value to\nhexadecimal, then type\nthem in and "submit".',
      'If you\'re stuck, you can\nGoogle "base 10 to base\n16" for some extra help.',
    ];

    final color = inverseColor;
    final furtherColor = evenFurther ? SuperColor.hue(inverseHue, 0.35) : null;

    final trueMasteryButton = Padding(
      padding: const EdgeInsets.only(top: 33),
      child: ElevatedButton(
        onPressed: singlePress(() {
          if (evenFurther) {
            context.goto(Pages.evenFurther);
          } else if (!Tutorial.trueMastery() &&
              Theme.of(context).platform != TargetPlatform.iOS) {
            setState(() => trueMastery = true);
            sleep(
              6,
              then: () => context.noTransition(const TrueMasteryTutorial()),
            );
          } else {
            context.goto(Pages.trueMastery);
          }
        }),
        style: evenFurther
            ? ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: furtherColor,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                shadowColor: furtherColor,
              )
            : ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
              ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 13),
          child: SizedBox(
            width: 85,
            child: Text(
              evenFurther ? 'even\nfurther' : 'true\nmastery',
              textAlign: TextAlign.center,
              style: SuperStyle.sans(
                size: 24,
                width: 87.5,
                weight: evenFurther ? 450 : 350,
                extraBold: true,
                letterSpacing: 2 / 3,
                height: 0.95,
              ),
            ),
          ),
        ),
      ),
    );
    final children = switch (menuPage) {
      MenuPage.main => [
          SuperHUEman(color),
          AnimatedSize(
            duration: oneSec,
            curve: curve,
            child: showButtons
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const FixedSpacer(67),
                      NavigateButton(Pages.trivial, color: color, isNew: !Tutorial.trivial()),
                      const FixedSpacer(33),
                      SuperButton(
                        'tense',
                        color: color,
                        onPressed: () => setState(() => menuPage = MenuPage.tenseSelect),
                        noDelay: true,
                        isNew: !Tutorial.tense(),
                      ),
                      if (Tutorial.gameEnd())
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Opacity(
                              opacity: 0,
                              child: Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: IconButton(
                                  onPressed: null,
                                  icon: Icon(Icons.autorenew),
                                ),
                              ),
                            ),
                            trueMasteryButton,
                            Padding(
                              padding: const EdgeInsets.only(top: 33, left: 8),
                              child: IconButton(
                                style: IconButton.styleFrom(foregroundColor: color),
                                onPressed: () {
                                  setState(() => evenFurther = !evenFurther);
                                  saveData('evenFurther', evenFurther);
                                },
                                icon: const Icon(Icons.autorenew),
                              ),
                            ),
                          ],
                        )
                      else if (Tutorial.trivial() && Tutorial.tense() && Tutorial.sandbox())
                        trueMasteryButton,
                      const FixedSpacer(67),
                      NavigateButton(Pages.sandbox, color: color, isNew: !Tutorial.sandbox()),
                    ],
                  )
                : const SizedBox(width: 150),
          )
        ],
      MenuPage.settings => [
          // MenuCheckbox(
          //   'music',
          //   value: music,
          //   description: const ('', ''),
          //   toggle: (value) => saveData('music', value).then(
          //     (_) => setState(() => music = value),
          //   ),
          // ),
          // MenuCheckbox(
          //   'sounds',
          //   value: sounds,
          //   description: const ('', ''),
          //   toggle: (value) => saveData('sounds', value).then(
          //     (_) => setState(() => sounds = value),
          //   ),
          // ),
          // const FixedSpacer(33),
          MenuCheckbox(
            'casual mode',
            value: casualMode,
            description: ('play without keeping score', 'keep score when you play'),
            toggle: (value) => saveData('casualMode', value).then(
              (_) => setState(() => casualMode = value),
            ),
          ),
          const FixedSpacer(67),
          if (Tutorial.gameEnd()) ...[
            Center(
              child: OutlinedButton(
                onPressed: () {
                  setState(() => menuPage = MenuPage.highScores);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: color, width: 2),
                  foregroundColor: color,
                  padding: EdgeInsets.zero,
                ),
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(19, 6, 19, 7),
                  child: Text(
                    'high scores',
                    style: SuperStyle.sans(size: 16, weight: 600),
                  ),
                ),
              ),
            ),
            const FixedSpacer(25),
          ] else if (Tutorial.trueMastery()) ...[
            Center(
              child: OutlinedButton(
                onPressed: () {
                  hintsVisible = 0;
                  setState(() => menuPage = MenuPage.howToWin);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: color, width: 2),
                  foregroundColor: color,
                ),
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(3, 6, 3, 7),
                  child: Text(
                    'how to win',
                    style: SuperStyle.sans(size: 16, weight: 600),
                  ),
                ),
              ),
            ),
            const FixedSpacer(25),
          ],
          Center(
            child: OutlinedButton(
              onPressed: () async {
                controller.forward();
                await sleepState(0.5, () => inverting = true);
                await sleep(0.6, then: context.invert);
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: color, width: 2),
                foregroundColor: color,
              ),
              child: const SuperContainer(
                padding: EdgeInsets.only(top: 10, bottom: 14),
                width: 75,
                child: SuperText('revert', style: SuperStyle.sans(size: 24), pad: false),
              ),
            ),
          ),
          if (Tutorial.evenFurther()) ...[
            const FixedSpacer(25),
            Center(
              child: OutlinedButton(
                onPressed: () {
                  showResetButton = false;
                  setState(() => menuPage = MenuPage.reset);
                  sleepState(2, () => showResetButton = true);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: color, width: 2),
                  foregroundColor: color,
                ),
                child: const SuperContainer(
                  padding: EdgeInsets.only(top: 10, bottom: 14),
                  width: 75,
                  child: SuperText('reset', style: SuperStyle.sans(size: 24), pad: false),
                ),
              ),
            ),
          ],
        ],
      MenuPage.tenseSelect => [
          const Text('tense', textAlign: TextAlign.center, style: titleStyle),
          const FixedSpacer(50),
          NavigateButton(Pages.tenseVibrant, color: color),
          const FixedSpacer(33),
          NavigateButton(Pages.tenseVolatile, color: color),
          const FixedSpacer(20),
          if (!casualMode) ...[
            const FixedSpacer(20),
            const Text(
              'you get a bonus when\nanswering correctly with\na full health bar!',
              textAlign: TextAlign.center,
              style: SuperStyle.sans(color: Colors.black54),
            ),
          ],
        ],
      MenuPage.howToWin => [
          Text(
            "If you're ready to finish the game, you can follow these steps:",
            style: SuperStyle.sans(color: color, size: 16, weight: 500),
          ),
          for (int i = 1; i <= 6; i++)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$i:  ',
                    style: SuperStyle.sans(color: color, size: 16, weight: 500),
                  ),
                  if (hintsVisible >= i)
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Text(hints[i - 1], style: const SuperStyle.sans(width: 96)),
                    ),
                ],
              ),
            ),
          if (hintsVisible < 6) const FixedSpacer(33),
          if (hintsVisible < 6)
            Center(
              child: OutlinedButton(
                onPressed: () => setState(() => hintsVisible++),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: color, width: 2),
                  foregroundColor: color,
                ),
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(0, 8, 0, 10),
                  child: Text('show next hint', style: SuperStyle.sans(size: 18)),
                ),
              ),
            ),
        ],
      MenuPage.highScores => [
          const Text('High Scores', style: SuperStyle.mono(size: 24)),
          const FixedSpacer(33),
          const Align(
            alignment: Alignment.centerLeft,
            child: _ScoreLog(),
          ),
        ],
      MenuPage.reset => [
          Text(
            'Reset?',
            style: SuperStyle.sans(size: 32, extraBold: true, letterSpacing: 0.5, color: color),
          ),
          const FixedSpacer(25),
          SuperText(
            Score.noneSet
                ? 'This will delete\n your game progress.\n\n'
                    '(It usually deletes\nhigh scores too,\n'
                    "but you always did\ncasual mode so you\n don't have any lol)"
                : 'This will delete\nyour high scores\nand game progress.',
            style: const SuperStyle.mono(weight: 500),
          ),
          const FixedSpacer(50),
          Fader(
            showResetButton,
            child: SizedBox(
              height: 60,
              child: OutlinedButton(
                onPressed: showResetButton ? reset : null,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: color, width: 2),
                  foregroundColor: color,
                  backgroundColor: SuperColors.lightBackground,
                  shadowColor: color,
                  elevation: (sin(6 * 2 * pi * (inverseHue) / 360) + 1) * 5,
                ),
                child: SexyBox(
                  child: showResetButton
                      ? const Padding(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 2),
                          child: Text("let's do it", style: SuperStyle.sans(size: 24)),
                        )
                      : empty,
                ),
              ),
            ),
          ),
        ],
    };

    Widget settingsButton;
    if (mainMenu) {
      settingsButton = TextButton(
        style: TextButton.styleFrom(
          foregroundColor: color,
          backgroundColor: Colors.white,
        ),
        onPressed: () => setState(() => menuPage = MenuPage.settings),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 2, 8, 5) + context.iOSpadding,
          child: const Text('settings', style: SuperStyle.sans(size: 16, width: 87.5)),
        ),
      );
      if (Tutorial.master() && !Tutorial.sawInversion()) {
        settingsButton = BrandNew(color: color, child: settingsButton);
      }
    } else {
      settingsButton = TextButton(
        style: TextButton.styleFrom(
          foregroundColor: color,
          backgroundColor: Colors.white54,
        ),
        onPressed: () => setState(() => menuPage = MenuPage.main),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 2, 8, 3) + context.iOSpadding,
          child: const Text('back', style: SuperStyle.sans(size: 16, weight: 100)),
        ),
      );
    }

    return Theme(
      data: ThemeData(
        useMaterial3: true,
        fontFamily: 'nunito sans',
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStatePropertyAll(color),
          side: BorderSide.none,
        ),
      ),
      child: Stack(
        children: [
          Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Fader(showButtons, child: settingsButton),
                  const FixedSpacer(30),
                  SuperContainer(
                    decoration: BoxDecoration(border: Border.all(color: color, width: 2)),
                    width: 300,
                    padding: EdgeInsets.symmetric(horizontal: mainMenu ? 0 : 50, vertical: 50),
                    child: AnimatedSize(
                      duration: quarterSec,
                      curve: curve,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: menuPage == MenuPage.settings
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.center,
                        children: children,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: SuperColors.lightBackground,
          ),
          SuperContainer(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(top: 275),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0, end: 12).animate(controller),
              child: SuperContainer(
                width: context.screenWidth / 4,
                height: context.screenWidth / 4,
                decoration: const BoxDecoration(
                  color: SuperColors.inverting,
                  backgroundBlendMode: BlendMode.difference,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Fader(
                  inverting,
                  duration: const Duration(milliseconds: 300),
                  child: const SuperContainer(color: SuperColors.darkBackground),
                ),
              ),
            ),
          ),
          trueMastery ? _TrueMasteryAnimation(color) : empty,
          if (exists)
            Fader(
              visible,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOutQuad,
              child: const SuperContainer(color: SuperColors.lightBackground),
            ),
        ],
      ),
    );
  }
}

class _ScoreLog extends StatefulWidget {
  const _ScoreLog();

  @override
  State<_ScoreLog> createState() => _ScoreLogState();
}

class _ScoreLogState extends SuperState<_ScoreLog> {
  final description = Score.noneSet
      ? '[no scores set]'
      : [
          for (final score in Score.allScores)
            if (score()) '${(score.label).padRight(14)} -> ${score.value}'
        ].join('\n');
  String cursor = '';
  void blink() => cursor.isEmpty ? cursor = '▌' : cursor = '';
  int lettersShown = 0;

  @override
  void animate() async {
    await sleepState(1 / 3, blink);
    await sleepState(2 / 3, blink);
    await sleepState(2 / 3, blink);
    for (final char in description.characters) {
      if (char == ' ') {
        await sleep(0.04);
        lettersShown++;
      } else {
        await sleepState(0.04, () => lettersShown++);
        if (char == '>') await sleep(0.15);
      }
    }
    await sleepState(2 / 3, blink);
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      description.substring(0, lettersShown) + cursor,
      style: const SuperStyle.mono(size: 13, weight: 600),
    );
  }
}

class _TrueMasteryAnimation extends StatefulWidget {
  const _TrueMasteryAnimation(this.color);
  final SuperColor color;

  @override
  State<_TrueMasteryAnimation> createState() => _TrueMasteryAnimationState();
}

class _TrueMasteryAnimationState extends SuperState<_TrueMasteryAnimation> {
  bool showHues = false;
  @override
  void animate() => quickly(() => setState(() => showHues = true));

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Fader(
          showHues,
          duration: const Duration(seconds: 2),
          curve: Curves.easeOutCubic,
          child: SuperContainer(color: widget.color),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 210),
          child: Text(
            'true\nmastery',
            textAlign: TextAlign.center,
            style: SuperStyle.sans(
              size: 24,
              weight: 350,
              extraBold: true,
              letterSpacing: 0.5,
              height: 0.95,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        Fader(
          showHues,
          duration: const Duration(seconds: 6),
          child: const SuperContainer(color: Colors.white),
        ),
      ],
    );
  }
}
