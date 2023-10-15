import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:super_hueman/data/page_data.dart';
import 'package:super_hueman/data/save_data.dart';
import 'package:super_hueman/data/structs.dart';
import 'package:super_hueman/data/super_color.dart';
import 'package:super_hueman/data/super_container.dart';
import 'package:super_hueman/data/super_state.dart';
import 'package:super_hueman/data/widgets.dart';

enum MenuPage { main, settings, tenseSelect }

class InverseMenu extends StatefulWidget {
  const InverseMenu({super.key});

  @override
  State<InverseMenu> createState() => _InverseMenuState();
}

class _InverseMenuState extends SuperState<InverseMenu> with SingleTickerProviderStateMixin {
  late final Ticker inverseHues;
  late final AnimationController controller = AnimationController(duration: oneSec, vsync: this);
  bool inverting = false, visible = true, exists = true, showButtons = true;
  MenuPage menuPage = MenuPage.main;
  bool get mainMenu => menuPage == MenuPage.main;

  @override
  void initState() {
    super.initState();
    inverseHues = inverseSetup(setState);
    if (inverted) {
      visible = false;
      exists = false;
      if (!booted) {
        booted = true;
        showButtons = false;
        sleepState(1, () => showButtons = true);
      }
    } else {
      inverted = true;
      quickly(() => setState(() => visible = false));
      sleepState(0.6, () => exists = false);
    }
  }

  @override
  void dispose() {
    inverseHues.dispose();
    super.dispose();
  }

  static const TextStyle titleStyle = TextStyle(
    color: Colors.black,
    fontSize: 32,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );
  TextStyle get hueStyle => TextStyle(
        fontSize: 24,
        color: inverseColor,
        fontWeight: FontWeight.bold,
        height: 1.5,
      );

  @override
  Widget build(BuildContext context) {
    final children = switch (menuPage) {
      MenuPage.main => [
          SuperHUEman(inverseColor),
          AnimatedSize(
            duration: oneSec,
            curve: curve,
            child: showButtons
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const FixedSpacer(67),
                      NavigateButton(Pages.trivial, color: inverseColor),
                      const FixedSpacer(33),
                      SuperButton(
                        'tense',
                        color: inverseColor,
                        onPressed: () => setState(() => menuPage = MenuPage.tenseSelect),
                        noDelay: true,
                      ),
                      const FixedSpacer(33),
                      ElevatedButton(
                        onPressed: () => context.goto(Pages.trueMastery),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: inverseColor,
                          foregroundColor: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 15),
                          child: Text(
                            Pages.trueMastery(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 24, height: 0.95),
                          ),
                        ),
                      ),
                      const FixedSpacer(67),
                      NavigateButton(Pages.sandbox, color: inverseColor),
                    ],
                  )
                : empty,
          )
        ],
      MenuPage.settings => [
          MenuCheckbox(
            'music',
            value: music,
            description: const ('', ''),
            toggle: (value) => setState(() => music = value),
          ),
          MenuCheckbox(
            'sounds',
            value: sounds,
            description: const ('', ''),
            toggle: (value) => setState(() => sounds = value),
          ),
          const FixedSpacer(33),
          MenuCheckbox(
            'casual mode',
            value: casualMode,
            description: ('play without keeping score', 'keep score when you play'),
            toggle: (value) => setState(() => casualMode = value),
          ),
          const FixedSpacer(67),
          Center(
            child: OutlinedButton(
              onPressed: () => () async {
                controller.forward();
                await sleepState(0.5, () => inverting = true);
                await sleep(0.6);
              }()
                  .then((_) => context.invert()),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: inverseColor, width: 2),
                foregroundColor: inverseColor,
                backgroundColor: SuperColors.lightBackground,
                shadowColor: inverseColor,
              ),
              child: const Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 16),
                child: Text('revert', style: TextStyle(fontSize: 24)),
              ),
            ),
          ),
        ],
      MenuPage.tenseSelect => [
          const Text('tense', textAlign: TextAlign.center, style: titleStyle),
          const FixedSpacer(50),
          NavigateButton(Pages.tenseVibrant, color: inverseColor),
          const FixedSpacer(33),
          NavigateButton(Pages.tenseVolatile, color: inverseColor),
          const FixedSpacer(20),
          if (!casualMode) ...[
            const FixedSpacer(20),
            const Text(
              'you get a bonus when\nanswering correctly with\na full health bar!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ],
    };

    return Theme(
      data: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        checkboxTheme: CheckboxThemeData(fillColor: MaterialStatePropertyAll(inverseColor)),
      ),
      child: Stack(
        children: [
          Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Fader(
                    showButtons,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: inverseColor,
                          backgroundColor: mainMenu ? Colors.white : Colors.white54,
                        ),
                        onPressed: () => setState(
                          () => menuPage = (mainMenu) ? MenuPage.settings : MenuPage.main,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: mainMenu
                              ? const Padding(
                                  padding: EdgeInsets.only(bottom: 2),
                                  child: Text(
                                    'settings',
                                    style: TextStyle(fontSize: 16, letterSpacing: 0.5),
                                  ),
                                )
                              : const Text(
                                  'back',
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 16,
                                      letterSpacing: 0.5),
                                ),
                        ),
                      ),
                    ),
                  ),
                  SuperContainer(
                    decoration: BoxDecoration(
                      border: Border.all(color: inverseColor, width: 2),
                    ),
                    width: 300,
                    padding: const EdgeInsets.all(50),
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
