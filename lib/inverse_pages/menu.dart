import 'package:flutter/material.dart';
import 'package:super_hueman/data/page_data.dart';
import 'package:super_hueman/data/save_data.dart';
import 'package:super_hueman/data/structs.dart';
import 'package:super_hueman/data/super_color.dart';
import 'package:super_hueman/data/super_container.dart';
import 'package:super_hueman/data/super_state.dart';
import 'package:super_hueman/data/super_text.dart';
import 'package:super_hueman/data/widgets.dart';
import 'package:super_hueman/tutorial_pages/true_mastery.dart';

enum MenuPage { main, settings, tenseSelect, howToWin }

class InverseMenu extends StatefulWidget {
  const InverseMenu({super.key});

  @override
  State<InverseMenu> createState() => _InverseMenuState();
}

class _InverseMenuState extends InverseState<InverseMenu>
    with SingleTickerProviderStateMixin, SinglePress {
  late final AnimationController controller = AnimationController(duration: oneSec, vsync: this);
  bool inverting = false, visible = true, exists = true, trueMastery = false, showButtons = true;
  late int hintsVisible;
  MenuPage menuPage = MenuPage.main;
  bool get mainMenu => menuPage == MenuPage.main;

  @override
  void initState() {
    super.initState();
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

  static const SuperStyle titleStyle = SuperStyle.sans(
    color: Colors.black,
    size: 32,
    height: 1.3,
  );

  static const hints = [
    'make sure casual mode\nis  ☑ enabled.',
    'go to "true mastery".',
    'tap the color code button.',
    'watch how the values for\nred/green/blue change\nwhen you tap the button.',
    'convert each value to\nhexadecimal, then type\nthem in and "submit".',
    'If you\'re stuck, you can\nGoogle "base 10 to base\n16" for some extra help.',
  ];

  @override
  Widget build(BuildContext context) {
    final color = inverseColor;
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
                      NavigateButton(Pages.trivial, color: color, isNew: !Tutorials.trivial),
                      const FixedSpacer(33),
                      SuperButton(
                        'tense',
                        color: color,
                        onPressed: () => setState(() => menuPage = MenuPage.tenseSelect),
                        noDelay: true,
                        isNew: !Tutorials.tense,
                      ),
                      if (Tutorials.trivial && Tutorials.tense && Tutorials.sandbox) ...[
                        const FixedSpacer(33),
                        ElevatedButton(
                          onPressed: singlePress(() {
                            if (!Tutorials.trueMastery) {
                              setState(() => trueMastery = true);
                              sleep(
                                6,
                                then: () => context.noTransition(const TrueMasteryTutorial()),
                              );
                            } else {
                              context.goto(Pages.trueMastery);
                            }
                          }),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            foregroundColor: Colors.white,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.fromLTRB(0, 8, 0, 13),
                            child: Text(
                              'true\nmastery',
                              textAlign: TextAlign.center,
                              style: SuperStyle.sans(
                                size: 24,
                                weight: 350,
                                extraBold: true,
                                letterSpacing: 0.5,
                                height: 0.95,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const FixedSpacer(67),
                      NavigateButton(Pages.sandbox, color: color, isNew: !Tutorials.sandbox),
                    ],
                  )
                : const SizedBox(width: 150),
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
              child: const Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 14),
                child: Text('revert', style: SuperStyle.sans(size: 24)),
              ),
            ),
          ),
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
    };

    Widget settingsButton;
    if (mainMenu) {
      settingsButton = TextButton(
        style: TextButton.styleFrom(
          foregroundColor: color,
          backgroundColor: Colors.white,
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
          foregroundColor: color,
          backgroundColor: Colors.white54,
        ),
        onPressed: () => setState(() => menuPage = MenuPage.main),
        child: const Padding(
          padding: EdgeInsets.fromLTRB(8, 7, 8, 8),
          child: Text('back', style: SuperStyle.sans(size: 16, weight: 100)),
        ),
      );
    }

    return Theme(
      data: ThemeData(
        useMaterial3: true,
        fontFamily: 'nunito sans',
        checkboxTheme: CheckboxThemeData(fillColor: MaterialStatePropertyAll(color)),
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
