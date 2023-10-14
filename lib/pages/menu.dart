import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:super_hueman/data/page_data.dart';
import 'package:super_hueman/data/save_data.dart';
import 'package:super_hueman/data/structs.dart';
import 'package:super_hueman/data/super_color.dart';
import 'package:super_hueman/data/super_container.dart';
import 'package:super_hueman/data/super_state.dart';
import 'package:super_hueman/data/widgets.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

enum MenuPage { main, settings, introSelect }

class _MainMenuState extends SuperState<MainMenu> with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Ticker epicHues;
  MenuPage menuPage = MenuPage.main;
  bool get mainMenu => menuPage == MenuPage.main;
  bool showMasteryText = false, inverting = false, visible = true, showButtons = true;
  bool? darkBackground = true;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: oneSec, vsync: this);
    epicHues = epicSetup(setState);
    if (inverted) {
      inverted = false;
      quickly(() => setState(() => visible = false));
      sleepState(0.5, () => darkBackground = null);
    } else {
      visible = false;
      darkBackground = null;
      if (!booted) {
        booted = true;
        showButtons = false;
        sleepState(1, () => showButtons = true);
      }
    }
  }

  @override
  void dispose() {
    epicHues.dispose();
    super.dispose();
  }

  List<Widget> get masterSettings => [
        MenuCheckbox(
          'casual mode',
          value: casualMode,
          description: ('play without keeping score', 'keep score when you play'),
          toggle: (value) => setState(() => casualMode = value),
        ),
        const FixedSpacer(50),
        OutlinedButton(
          onPressed: gotoWebsite('https://google.com/'),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: epicColor, width: 2),
            foregroundColor: epicColor,
          ),
          child: const Padding(
            padding: EdgeInsets.only(top: 4, bottom: 10),
            child: Text(
              'report a bug',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
            ),
          ),
        ),
        const FixedSpacer(33),
        OutlinedButton(
          onPressed: () => () async {
            setState(() => inverting = true);
            controller.forward();
            await sleepState(0.7, () => darkBackground = false);
            await sleepState(0.1, () => visible = true);
            await sleep(0.5);
          }()
              .then((_) => context.invert()),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: epicColor, width: 2),
            foregroundColor: epicColor,
            backgroundColor: SuperColors.darkBackground,
            shadowColor: epicColor,
            elevation: epicSine * 5,
          ),
          child: const Padding(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 14),
            child: Text('invert!', style: TextStyle(fontSize: 24)),
          ),
        ),
      ];
  List<Widget> get noviceSettings => [
        Center(
            child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: epicColor, width: 2),
            foregroundColor: epicColor,
            backgroundColor: SuperColors.darkBackground,
            shadowColor: epicColor,
          ),
          onPressed: () {
            if (!showMasteryText) {
              setState(() => showMasteryText = true);
              sleep(4, then: () => setState(() => showMasteryText = false));
            }
          },
          child: const Padding(
            padding: EdgeInsets.only(top: 5, bottom: 10),
            child: Text('more options', style: TextStyle(fontSize: 18)),
          ),
        )),
        AnimatedSize(
          duration: quarterSec,
          curve: curve,
          child: SuperContainer(
            padding: const EdgeInsets.only(top: 2),
            width: double.infinity,
            child: showMasteryText
                ? const Text(
                    'unlock more options\nby playing "intense" mode!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  )
                : null,
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final children = switch (menuPage) {
      MenuPage.main => [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'super',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 0),
                child: Text(
                  'HUE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    color: epicColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                'man',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ],
          ),
          AnimatedSize(
            duration: oneSec,
            curve: curve,
            child: showButtons
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const FixedSpacer(67),
                      SuperButton(
                        'intro',
                        color: epicColor,
                        onPressed: () => setState(() => menuPage = MenuPage.introSelect),
                        noDelay: true,
                      ),
                      const FixedSpacer(33),
                      NavigateButton(Pages.intense, color: epicColor),
                      if (hueMaster)
                        Padding(
                          padding: const EdgeInsets.only(top: 33),
                          child: NavigateButton(Pages.master, color: epicColor),
                        ),
                      const FixedSpacer(67),
                      NavigateButton(Pages.sandbox, color: epicColor),
                    ],
                  )
                : empty,
          ),
        ],
      MenuPage.settings => [
          MenuCheckbox(
            'music',
            value: music,
            description: ('', ''),
            toggle: (value) => setState(() => music = value),
          ),
          MenuCheckbox(
            'sounds',
            value: sounds,
            description: ('', ''),
            toggle: (value) => setState(() => sounds = value),
          ),
          const FixedSpacer(33),
          MenuCheckbox(
            'auto-submit',
            value: autoSubmit,
            description: (
              "'submit' when 3 digits are entered",
              "submit with the 'submit' button"
            ),
            toggle: (value) => setState(() => autoSubmit = value),
          ),
          const FixedSpacer(33),
          MenuCheckbox(
            'external keyboard',
            value: externalKeyboard,
            description: ('type on a keyboard', 'tap buttons on the screen'),
            toggle: (value) => setState(() => externalKeyboard = value),
          ),
          const FixedSpacer(33),
          ...hueMaster ? masterSettings : noviceSettings,
        ],
      MenuPage.introSelect => [
          Text(
            'intro',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const FixedSpacer(55),
          NavigateButton(Pages.intro3, color: epicColor),
          const FixedSpacer(33),
          NavigateButton(Pages.intro6, color: epicColor),
          const FixedSpacer(33),
          NavigateButton(Pages.introC, color: epicColor),
          if (!casualMode)
            const Padding(
              padding: EdgeInsets.only(top: 33),
              child: Text(
                "during 'intro' games,\nquick answers score higher!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60),
              ),
            )
          else if (!Tutorials.casual)
            const Padding(
              padding: EdgeInsets.only(top: 33),
              child: Text(
                'tap a completed intro level\nto play in casual mode',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60),
              ),
            ),
        ],
    };

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Fader(
                  showButtons,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: TextButton(
                      style: mainMenu
                          ? TextButton.styleFrom(
                              foregroundColor: epicColor,
                              backgroundColor: Colors.black,
                            )
                          : TextButton.styleFrom(
                              foregroundColor: Colors.white70,
                              backgroundColor: Colors.black26,
                            ),
                      onPressed: () {
                        if (mainMenu) {
                          setState(() => menuPage = MenuPage.settings);
                        } else {
                          setState(() => menuPage = MenuPage.main);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: mainMenu
                            ? const Padding(
                                padding: EdgeInsets.only(bottom: 2),
                                child: Text(
                                  'settings',
                                  style: TextStyle(fontSize: 16),
                                ),
                              )
                            : const Text(
                                'back',
                                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                              ),
                      ),
                    ),
                  ),
                ),
                SuperContainer(
                  decoration: BoxDecoration(border: Border.all(color: epicColor, width: 2)),
                  width: 300,
                  padding: const EdgeInsets.all(50),
                  child: AnimatedSize(
                    duration: quarterSec,
                    curve: curve,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: children,
                    ),
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
            SuperContainer(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(top: 400),
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
