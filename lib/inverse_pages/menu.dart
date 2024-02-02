import 'dart:io';
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

enum MenuPage {
  main,
  settings,
  tenseSelect,
  howToWin,
  highScores,
  fullCompletion,
  reset;

  EdgeInsets get padding => switch (this) {
        main => const EdgeInsets.symmetric(vertical: 50),
        howToWin || highScores => const EdgeInsets.all(25),
        fullCompletion => const EdgeInsets.all(33),
        _ => const EdgeInsets.all(50),
      };
}

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
    musicPlayer.stop();
    if (inverted) {
      visible = false;
      exists = false;
      if (!booted) {
        showButtons = false;
        sleepState(1, () => showButtons = true);
        booted = true;
      }
    } else {
      saveData('inverted', true);
      inverted = true;
      quickly(() => setState(() => visible = false));
      sleepState(0.6, () => exists = false);
    }
    playMusic(once: 'invert_1', loop: 'invert_2');
  }

  @override
  void dispose() {
    paused = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const SuperStyle titleStyle = SuperStyle.sans(
      color: Colors.black,
      size: 32,
      height: 1.3,
    );
    const hints = [
      'enable ☑ casual mode, and go to\n"true mastery".',
      'tap the color code button and\nsee how the RGB values change.',
      'convert each value to hexadecimal,\nthen type them in and "submit".',
      '[link]',
    ];

    final color = inverseColor;
    final furtherColor = SuperColors.evenFurther[inverseHue];

    final currentCompletion = [
      Tutorial.mastered(),
      Tutorial.tensed(),
      Score.scoresToBeat.isEmpty,
    ];
    const completionDesc = [
      'see every "master" pic',
      'tension rank 500',
      'beat my high scores',
    ];
    const completionDetails = [
      "Slow down and enjoy the sights. Or speed through them, that's fine too!",
      'Easiest to achieve when "variety" and\n'
          '"casual mode" are enabled.\n'
          'Or turn casual mode off to get a head start on the last item here!',
      "No worries if you don't beat me at my own game (literally).\n"
          "But if you do, that's super impressive.",
    ];

    final trueMasteryButton = Padding(
      padding: const EdgeInsets.only(top: 33),
      child: ElevatedButton(
        onPressed: fullCompletion
            ? () => setState(() => menuPage = MenuPage.fullCompletion)
            : singlePress(() {
                if (showEvenFurther) {
                  context.goto(Pages.evenFurther);
                } else if (!Tutorial.trueMastery() && !Platform.isIOS) {
                  setState(() => trueMastery = true);
                  sleep(
                    7,
                    then: () => context.noTransition(const TrueMasteryTutorial()),
                  );
                } else {
                  context.goto(Pages.trueMastery);
                }
              }),
        style: switch (showEvenFurther) {
          _ when fullCompletion => ElevatedButton.styleFrom(
              backgroundColor: furtherColor,
              foregroundColor: Colors.white,
            ),
          true => ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: furtherColor,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              shadowColor: furtherColor,
            ),
          false => ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
            ),
        },
        child: SuperContainer(
          margin: const EdgeInsets.fromLTRB(0, 8, 0, 13),
          width: fullCompletion ? null : 85,
          child: Text(
            fullCompletion
                ? 'full\ncompletion'
                : showEvenFurther
                    ? 'even\nfurther'
                    : 'true\nmastery',
            textAlign: TextAlign.center,
            style: SuperStyle.sans(
              size: 24,
              width: 87.5,
              weight: showEvenFurther ? 450 : 350,
              extraBold: true,
              letterSpacing: 2 / 3,
              height: 0.95,
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
                      if (Tutorial.trueMastery())
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
                                  if (!Tutorial.gameEnd()) {
                                    hintsVisible = 0;
                                    setState(() => menuPage = MenuPage.howToWin);
                                    return;
                                  }
                                  if (fullCompletion) {
                                    setState(() => fullCompletion = false);
                                    saveData('fullCompletion', fullCompletion);
                                  } else if (showEvenFurther && Tutorial.evenFurther()) {
                                    setState(() {
                                      showEvenFurther = false;
                                      fullCompletion = true;
                                    });
                                    saveData('showEvenFurther', false);
                                    saveData('fullCompletion', true);
                                  } else {
                                    setState(() => showEvenFurther = !showEvenFurther);
                                    saveData('showEvenFurther', showEvenFurther);
                                  }
                                },
                                icon: Tutorial.gameEnd()
                                    ? const Icon(Icons.autorenew)
                                    : Transform.scale(
                                        scale: 1.5,
                                        child: const Icon(Icons.help_outline),
                                      ),
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
          MenuCheckbox(
            'music',
            value: music,
            description: ('', ''),
            toggle: (checked) {
              setState(() => music = checked);
              saveData('music', music);
              if (checked) {
                if (paused) {
                  musicPlayer.resume();
                } else {
                  playMusic(once: 'invert_1', loop: 'invert_2');
                }
              } else {
                musicPlayer.pause();
                paused = true;
              }
            },
          ),
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
          ],
          Center(
            child: OutlinedButton(
              onPressed: () async {
                await musicPlayer.stop();
                controller.forward();
                playSound('revert_button');
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
          FixedSpacer(Tutorial.mastered() ? 25 : 50),
          if (Tutorial.mastered()) ...[
            Padding(
              padding: const EdgeInsets.only(left: 0),
              child: MenuCheckbox(
                variety ? 'variety' : 'vanilla',
                description: ('0x18 colors'.padLeft(25), '0x0C colors'.padLeft(25)),
                value: variety,
                toggle: (val) => variety = val,
              ),
            ),
            const FixedSpacer(33),
          ],
          NavigateButton(Pages.tenseVibrant,
              color: variety ? furtherColor : color, further: variety),
          const FixedSpacer(33),
          NavigateButton(Pages.tenseVolatile,
              color: variety ? furtherColor : color, further: variety),
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
            style: SuperStyle.sans(color: color, size: 16, width: 92, extraBold: true),
          ),
          for (final (i, hint) in hints.indexed)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${i + 1}:  ',
                    style: SuperStyle.sans(color: color, size: 16, weight: 500),
                  ),
                  if (hintsVisible > i)
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: hint == '[link]'
                          ? Text.rich(
                              TextSpan(children: [
                                TextSpan(
                                  text: 'tap here',
                                  style: linkStyle,
                                  recognizer:
                                      hyperlink('https://hue-man.app/tips/#beat-the-game'),
                                ),
                                const TextSpan(text: ' for more info.'),
                              ]),
                              style: const SuperStyle.sans(width: 96))
                          : Text(hint, style: const SuperStyle.sans(width: 96)),
                    ),
                ],
              ),
            ),
          if (hintsVisible < hints.length) ...[
            const FixedSpacer(33),
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
        ],
      MenuPage.highScores => [
          const Text('High Scores', style: SuperStyle.mono(size: 24)),
          const FixedSpacer(33),
          const Align(
            alignment: Alignment.centerLeft,
            child: _ScoreLog(),
          ),
        ],
      MenuPage.fullCompletion => [
          if (currentCompletion.contains(false)) ...[
            for (final (i, done) in currentCompletion.indexed) ...[
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    Opacity(
                      opacity: 2 / 3,
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(value: done, onChanged: null),
                      ),
                    ),
                    const FixedSpacer.horizontal(10),
                    Text(completionDesc[i], style: const SuperStyle.sans()),
                  ],
                ),
              ),
              if (!done)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    completionDetails[i],
                    style: const SuperStyle.sans(color: Colors.black54, size: 11),
                  ),
                ),
              const FixedSpacer(10),
            ],
            if (Tutorial.mastered() && Tutorial.tensed())
              Align(
                alignment: Alignment.centerLeft,
                child: SuperRichText(
                  pad: false,
                  align: TextAlign.left,
                  style: const SuperStyle.mono(size: 10, weight: 500, color: Colors.black54),
                  [
                    const TextSpan(text: '\n-------- scores to beat --------'),
                    for (final score in Score.scoresToBeat)
                      TextSpan(
                        text: '\n${score.label.padRight(19)} ${score.value}/${score.mine}',
                      ),
                  ],
                ),
              ),
          ] else
            const SuperRichText(
              pad: false,
              [
                TextSpan(text: 'This is for you, champ.\n\n', style: SuperStyle.sans(size: 18)),
                TextSpan(text: '🏆', style: SuperStyle.sans(size: 125)),
              ],
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
      settingsButton = SizedBox(
        height: 33,
        child: TextButton(
          style: TextButton.styleFrom(
            foregroundColor: color,
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          onPressed: () => setState(() => menuPage = MenuPage.settings),
          child: const Text(
            'settings',
            style: SuperStyle.sans(size: 16, width: 87.5, height: 2),
          ),
        ),
      );
      if (Tutorial.master() && !Tutorial.sawInversion()) {
        settingsButton = BrandNew(color: color, child: settingsButton);
      }
    } else {
      settingsButton = SizedBox(
        height: 33,
        child: TextButton(
          style: TextButton.styleFrom(
            foregroundColor: color,
            backgroundColor: Colors.white54,
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          onPressed: () => setState(() => menuPage = MenuPage.main),
          child: const Text('back', style: SuperStyle.sans(size: 16, weight: 100, height: 2)),
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
                    padding: menuPage.padding,
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
          Center(
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
          if (trueMastery) _TrueMasteryAnimation(color),
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
            if (score()) '${(score.label).padRight(19)} -> ${score.value}'
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
  bool fadeToWhite = false;
  @override
  void animate() => sleepState(1, () => fadeToWhite = true);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        FadeIn(
          duration: oneSec,
          curve: Curves.easeOutCubic,
          child: SuperContainer(color: widget.color),
        ),
        Fader(
          fadeToWhite,
          duration: const Duration(seconds: 6),
          curve: Curves.easeOutQuad,
          child: const Text(
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
          fadeToWhite,
          duration: const Duration(seconds: 6),
          child: const SuperContainer(color: Colors.white),
        ),
      ],
    );
  }
}
