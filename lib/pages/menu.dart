import 'package:flutter/material.dart';
import 'package:super_hueman/data/page_data.dart';
import 'package:super_hueman/data/save_data.dart';
import 'package:super_hueman/data/structs.dart';
import 'package:super_hueman/data/super_color.dart';
import 'package:super_hueman/data/super_container.dart';
import 'package:super_hueman/data/super_state.dart';
import 'package:super_hueman/data/super_text.dart';
import 'package:super_hueman/data/widgets.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

enum MenuPage { main, settings, introSelect }

class _MainMenuState extends EpicState<MainMenu> with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  MenuPage menuPage = MenuPage.main;
  bool get mainMenu => menuPage == MenuPage.main;
  bool showMasteryText = false, inverting = false, visible = true, showButtons = true;
  bool? darkBackground = true;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: oneSec, vsync: this);
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
  Widget build(BuildContext context) {
    final color = epicColor;
    final List<Widget> masterSettings = [
      MenuCheckbox(
        'casual mode',
        value: casualMode,
        description: ('play without keeping score', 'keep score when you play'),
        toggle: (value) => setState(() => casualMode = value),
      ),
      const FixedSpacer(50),
      _BugReport(color),
      if (Tutorials.master) ...[
        const FixedSpacer(33),
        OutlinedButton(
          onPressed: () async {
            Tutorials.sawInversion = true;
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
      _BugReport(color),
      const FixedSpacer(20),
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
              ? const Text(
                  'unlock more options\nby playing "intense" mode!',
                  textAlign: TextAlign.center,
                  style: SuperStyle.sans(color: Colors.white70),
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
                          isNew: !Tutorials.introC,
                        ),
                        if (Tutorials.introC) ...[
                          const FixedSpacer(33),
                          NavigateButton(Pages.intense, color: color, isNew: !Tutorials.intense),
                          if (hueMaster)
                            Padding(
                              padding: const EdgeInsets.only(top: 33),
                              child: NavigateButton(
                                Pages.master,
                                color: color,
                                isNew: !Tutorials.master,
                              ),
                            ),
                          const FixedSpacer(67),
                          NavigateButton(
                            Pages.sandbox,
                            color: color,
                            isNew: !Tutorials.sandbox,
                          ),
                        ],
                      ],
                    ),
                  )
                : flat,
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
          const Text(
            'intro',
            textAlign: TextAlign.center,
            style: SuperStyle.sans(size: 32, weight: 100),
          ),
          const FixedSpacer(55),
          NavigateButton(Pages.intro3, color: color, isNew: !Tutorials.intro3),
          if (Tutorials.intro3) ...[
            const FixedSpacer(33),
            NavigateButton(Pages.intro6, color: color, isNew: !Tutorials.intro6),
          ],
          if (Tutorials.intro6) ...[
            const FixedSpacer(33),
            NavigateButton(Pages.introC, color: color, isNew: !Tutorials.introC),
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
          else if (Tutorials.intro3)
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
      settingsButton = TextButton(
        style: TextButton.styleFrom(
          foregroundColor: color,
          backgroundColor: Colors.black,
        ),
        onPressed: () => setState(() => menuPage = MenuPage.settings),
        child: const Padding(
          padding: EdgeInsets.fromLTRB(8, 7, 8, 10),
          child: Text('settings', style: SuperStyle.sans(size: 16, width: 87.5)),
        ),
      );
      if (Tutorials.master && !Tutorials.sawInversion) {
        settingsButton = BrandNew(color: color, child: settingsButton);
      }
    } else {
      settingsButton = TextButton(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white70,
          backgroundColor: Colors.black26,
        ),
        onPressed: () => setState(() => menuPage = MenuPage.main),
        child: const Padding(
          padding: EdgeInsets.fromLTRB(8, 7, 8, 8),
          child: Text('back', style: SuperStyle.sans(size: 16, weight: 100)),
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

class _BugReport extends StatelessWidget {
  const _BugReport(this.color);
  final SuperColor color;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => gotoWebsite('https://forms.gle/H9k2LhzJtWRfU1Q2A'),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color, width: 2),
        foregroundColor: color,
      ),
      child: const Padding(
        padding: EdgeInsets.fromLTRB(4, 6, 4, 8),
        child: Text('report a bug', style: SuperStyle.sans(size: 18)),
      ),
    );
  }
}
