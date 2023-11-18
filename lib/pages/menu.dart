import 'package:flutter/material.dart';
import 'package:hueman/data/page_data.dart';
import 'package:hueman/data/save_data.dart';
import 'package:hueman/data/structs.dart';
import 'package:hueman/data/super_color.dart';
import 'package:hueman/data/super_container.dart';
import 'package:hueman/data/super_state.dart';
import 'package:hueman/data/super_text.dart';
import 'package:hueman/data/widgets.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

enum MenuPage { main, settings, introSelect }

class _MainMenuState extends EpicState<MainMenu>
    with SingleTickerProviderStateMixin, SinglePress {
  late final AnimationController controller;
  MenuPage menuPage = MenuPage.main;
  bool get mainMenu => menuPage == MenuPage.main;
  bool showMasteryText = false,
      inverting = false,
      visible = true,
      showButtons = true,
      newChallenge = !Tutorial.intense();
  bool? darkBackground = true;

  @override
  void animate() async {
    controller = AnimationController(duration: oneSec, vsync: this);
    if (inverted) {
      saveData('inverted', false);
      inverted = false;
      quickly(() => setState(() => visible = false));
      await sleepState(0.5, () => darkBackground = null);
    } else {
      visible = false;
      darkBackground = null;
      if (!booted) {
        showButtons = false;
        await sleepState(1, () => showButtons = true);
        booted = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = epicColor;
    final List<Widget> masterSettings = [
      MenuCheckbox(
        'casual mode',
        key: const Key('casual mode'),
        value: casualMode,
        description: ('play without keeping score', 'keep score when you play'),
        toggle: (value) => saveData('casualMode', value).then(
          (_) => setState(() => casualMode = value),
        ),
      ),
      const FixedSpacer(33),
      FeedbackButton(color),
      const FixedSpacer(15),
      Center(
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: color, width: 2),
            foregroundColor: color,
            backgroundColor: SuperColors.darkBackground,
            shadowColor: color,
          ),
          onPressed: () {
            if (Tutorial.aiCertificate()) {
              context.goto(Pages.aiCertificate);
              return;
            }
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text(
                  'Heads up!',
                  textAlign: TextAlign.center,
                  style: SuperStyle.sans(),
                ),
                content: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'This "AI certificate" is just an excuse to brag.\n\n'
                    'Proceed at your own discretion.',
                    style: SuperStyle.sans(),
                  ),
                ),
                actions: [
                  const WarnButton(),
                  WarnButton(action: () => context.goto(Pages.aiCertificate)),
                ],
                actionsAlignment: MainAxisAlignment.spaceEvenly,
              ),
            );
          },
          child: const Padding(
            padding: EdgeInsets.fromLTRB(3.5, 7, 3.5, 10),
            child: Text('AI certificate', style: SuperStyle.sans(size: 18)),
          ),
        ),
      ),
      if (Tutorial.master()) ...[
        const FixedSpacer(18),
        OutlinedButton(
          onPressed: () async {
            Tutorial.sawInversion.complete();
            setState(() => inverting = true);
            controller.forward();
            await sleepState(0.7, () => darkBackground = false);
            await sleepState(0.1, () => visible = true);
            await sleep(0.5, then: context.invert);
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: color, width: 2),
            foregroundColor: color,
            backgroundColor: SuperColors.darkBackground,
            shadowColor: color,
            elevation: epicSine * 5,
          ),
          child: const Padding(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 14),
            child: Text('invert!', style: SuperStyle.sans(size: 24)),
          ),
        ),
      ],
    ];
    final List<Widget> noviceSettings = [
      const FixedSpacer(10),
      FeedbackButton(color),
      const FixedSpacer(18),
      Center(
          child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color, width: 2),
          foregroundColor: color,
          backgroundColor: SuperColors.darkBackground,
          shadowColor: color,
        ),
        onPressed: () {
          if (!showMasteryText) {
            setState(() => showMasteryText = true);
            sleep(4, then: () => setState(() => showMasteryText = false));
          }
        },
        child: const Padding(
          padding: EdgeInsets.only(top: 7, bottom: 10),
          child: Text('more options', style: SuperStyle.sans(size: 18)),
        ),
      )),
      AnimatedSize(
        duration: quarterSec,
        curve: curve,
        child: SuperContainer(
          padding: const EdgeInsets.only(top: 2),
          width: double.infinity,
          child: showMasteryText
              ? Text(
                  Tutorial.intense()
                      ? 'to unlock more options,\nfind a hue in "intense" mode!'
                      : 'unlock more options\nby playing "intense" mode!',
                  textAlign: TextAlign.center,
                  style: const SuperStyle.sans(color: Colors.white70),
                )
              : null,
        ),
      ),
    ];

    final children = switch (menuPage) {
      MenuPage.main => [
          SuperHUEman(color),
          AnimatedSize(
            key: const ObjectKey(MenuPage.main),
            duration: halfSec,
            curve: curve,
            child: showButtons
                ? SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const FixedSpacer(67),
                        SuperButton(
                          'intro',
                          color: color,
                          onPressed: () => setState(() => menuPage = MenuPage.introSelect),
                          noDelay: true,
                          isNew: !Tutorial.introC(),
                        ),
                        if (Tutorial.introC()) ...[
                          const FixedSpacer(33),
                          if (Tutorial.intense())
                            NavigateButton(Pages.intense, color: color)
                          else if (newChallenge)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                surfaceTintColor: Colors.transparent,
                                shadowColor: color,
                                elevation: 1,
                              ),
                              onPressed: singlePress(() => setState(() => newChallenge = false)),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                                child: Text(
                                  'a new challenge',
                                  style: SuperStyle.sans(
                                    size: 20,
                                    width: 87.5,
                                    letterSpacing: 0.33,
                                    weight: 300,
                                    extraBold: true,
                                    color: color,
                                  ),
                                ),
                              ),
                            )
                          else
                            FadeIn(
                              child: NavigateButton(Pages.intense, color: color, isNew: true),
                            ),
                          if (Score.superHue())
                            Padding(
                              padding: const EdgeInsets.only(top: 33),
                              child: NavigateButton(
                                Pages.master,
                                color: color,
                                isNew: !Tutorial.master(),
                              ),
                            ),
                          const FixedSpacer(67),
                          NavigateButton(
                            Pages.sandbox,
                            color: color,
                            isNew: !Tutorial.sandbox(),
                          ),
                        ],
                      ],
                    ),
                  )
                : flat,
          ),
        ],
      MenuPage.settings => [
          // MenuCheckbox(
          //   'music',
          //   value: music,
          //   description: ('', ''),
          //   toggle: (value) => setState(() => music = value),
          // ),
          // MenuCheckbox(
          //   'sounds',
          //   value: sounds,
          //   description: ('', ''),
          //   toggle: (value) => setState(() => sounds = value),
          // ),
          // const FixedSpacer(33),
          if (Tutorial.intro6()) ...[
            MenuCheckbox(
              'hue typing',
              key: const Key('hue typing'),
              value: hueTyping,
              description: ('type a number', 'tap a circle'),
              toggle: (value) => saveData('hueTyping', value).then(
                (_) => setState(() => hueTyping = value),
              ),
            ),
            const FixedSpacer(18),
            if (hueTyping) ...[
              MenuCheckbox(
                'external keyboard',
                key: const Key('external keyboard'),
                value: externalKeyboard,
                description: ('type on a keyboard', 'tap buttons on the screen'),
                toggle: (value) => saveData('externalKeyboard', value).then(
                  (_) => setState(() => externalKeyboard = value),
                ),
              ),
              const FixedSpacer(18),
            ] else ...[
              MenuCheckbox(
                'hue ruler',
                key: const Key('hue circle ruler'),
                value: hueRuler,
                description: ('helpful tick marks on the circle', 'Use the Force, Luke.'),
                toggle: (value) => saveData('hueRuler', value).then(
                  (_) => setState(() => hueRuler = value),
                ),
              ),
              const FixedSpacer(18),
            ],
          ],
          if (Score.superHue()) ...masterSettings else ...noviceSettings,
        ],
      MenuPage.introSelect => [
          const Text(
            'intro',
            textAlign: TextAlign.center,
            style: SuperStyle.sans(size: 32, weight: 100),
          ),
          const FixedSpacer(18),
          if (casualMode) ...[
            const FixedSpacer(33),
            NavigateButton(Pages.intro3, color: color, isNew: !Tutorial.intro3()),
            if (Tutorial.intro3()) ...[
              const FixedSpacer(33),
              NavigateButton(Pages.intro6, color: color, isNew: !Tutorial.intro6()),
            ],
          ],
          if (Tutorial.intro6()) ...[
            const FixedSpacer(33),
            NavigateButton(Pages.introC, color: color, isNew: !Tutorial.introC()),
          ],
          if (Tutorial.mastered()) ...[
            const FixedSpacer(33),
            NavigateButton(Pages.intro18, color: color),
          ],
          if (!casualMode)
            const Padding(
              padding: EdgeInsets.only(top: 33),
              child: Text(
                "during 'intro' games,\nquick answers score higher!",
                textAlign: TextAlign.center,
                style: SuperStyle.sans(color: Colors.white60),
              ),
            )
          else if (Tutorial.intro3() && !Tutorial.casual())
            const Padding(
              padding: EdgeInsets.only(top: 33),
              child: Text(
                'tap a completed intro level\nto play in casual mode',
                textAlign: TextAlign.center,
                style: SuperStyle.sans(color: Colors.white60),
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
            backgroundColor: Colors.black,
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
            foregroundColor: Colors.white70,
            backgroundColor: Colors.black26,
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          onPressed: () => setState(() => menuPage = MenuPage.main),
          child: const Text('back', style: SuperStyle.sans(size: 16, weight: 100, height: 2)),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Fader(showButtons, child: settingsButton),
                const FixedSpacer(30),
                SuperContainer(
                  decoration: BoxDecoration(border: Border.all(color: color, width: 2)),
                  width: 300,
                  padding: const EdgeInsets.all(50),
                  child: AnimatedSize(
                    duration: quarterSec,
                    curve: curve,
                    child: Column(mainAxisSize: MainAxisSize.min, children: children),
                  ),
                ),
              ],
            ),
          ),
          if (inverting) ...[
            const SuperContainer(
              decoration: BoxDecoration(
                backgroundBlendMode: BlendMode.difference,
                color: SuperColors.inverting,
              ),
            ),
            Center(
              child: ScaleTransition(
                scale: Tween<double>(begin: 12, end: 0).animate(controller),
                child: SuperContainer(
                  height: context.screenWidth / 4,
                  decoration: const BoxDecoration(
                    backgroundBlendMode: BlendMode.difference,
                    color: SuperColors.inverting,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
          if (darkBackground != null)
            Fader(
              visible,
              duration: halfSec,
              curve: Curves.easeInOutQuad,
              child: SuperContainer(
                color: darkBackground! ? SuperColors.darkBackground : SuperColors.lightBackground,
              ),
            ),
        ],
      ),
    );
  }
}
