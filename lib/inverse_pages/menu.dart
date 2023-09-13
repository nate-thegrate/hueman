import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:super_hueman/data/save_data.dart';
import 'package:super_hueman/data/structs.dart';
import 'package:super_hueman/data/super_container.dart';
import 'package:super_hueman/data/widgets.dart';

enum MenuPage { main, settings, tenseSelect }

class InverseMenu extends StatefulWidget {
  const InverseMenu({super.key});

  @override
  State<InverseMenu> createState() => _InverseMenuState();
}

class _InverseMenuState extends State<InverseMenu> with SingleTickerProviderStateMixin {
  late final Ticker inverseHues;
  late final AnimationController controller;
  bool inverting = false;
  List<Widget> children = [];
  MenuPage menuPage = MenuPage.main;
  bool get mainMenu => menuPage == MenuPage.main;

  @override
  void initState() {
    super.initState();
    inverseHues = inverseSetup(setState);
    controller = AnimationController(duration: oneSec, vsync: this);
    if (inverted) {
      visible = false;
      exists = false;
    } else {
      inverted = true;
      sleep(0.01, then: () => setState(() => visible = false));
      sleep(0.6, then: () => setState(() => exists = false));
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

  bool visible = true;
  bool exists = true;

  @override
  Widget build(BuildContext context) {
    children = <MenuPage, List<Widget>>{
      MenuPage.main: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('super', style: titleStyle),
            const FixedSpacer.horizontal(1),
            Text('HUE', style: hueStyle),
            const FixedSpacer.horizontal(1),
            const Text('man', style: titleStyle),
          ],
        ),
        const FixedSpacer(67),
        NavigateButton(Pages.trivial, color: inverseColor),
        const FixedSpacer(33),
        SuperButton(
          'tense',
          color: inverseColor,
          onPressed: () => setState(() => menuPage = MenuPage.tenseSelect),
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
        NavigateButton(Pages.inverseSandbox, color: inverseColor),
      ],
      MenuPage.settings: [
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
        ...Tutorials.ads
            ? [
                SuperContainer(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'get notified when\nthe next game comes out!',
                    textAlign: TextAlign.center,
                    style:
                        Theme.of(context).textTheme.labelSmall!.copyWith(color: Colors.black87),
                  ),
                ),
                Center(
                    child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: inverseColor, width: 2),
                    foregroundColor: inverseColor,
                    shadowColor: inverseColor,
                  ),
                  onPressed: gotoWebsite('https://google.com/'),
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(2.5, 5, 2.5, 10),
                    child: Text('sign up', style: TextStyle(fontSize: 24)),
                  ),
                )),
              ]
            : [
                Center(
                    child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: inverseColor, width: 2),
                    foregroundColor: inverseColor,
                    shadowColor: inverseColor,
                  ),
                  onPressed: () => context.goto(Pages.ads),
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(24, 5, 24, 10),
                    child: Text('ads', style: TextStyle(fontSize: 24)),
                  ),
                ))
              ],
        const FixedSpacer(25),
        Center(
          child: OutlinedButton(
            onPressed: () {
              Future animate() async {
                controller.forward();
                await sleep(0.5);
                setState(() => inverting = true);
                await sleep(0.6);
              }

              animate().then((_) => context.invert());
            },
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
      MenuPage.tenseSelect: [
        const Text('tense', textAlign: TextAlign.center, style: titleStyle),
        const FixedSpacer(50),
        NavigateButton(Pages.tenseVibrant, color: inverseColor),
        const FixedSpacer(33),
        NavigateButton(Pages.tenseMixed, color: inverseColor),
        const FixedSpacer(20),
        ...casualMode
            ? []
            : [
                const FixedSpacer(20),
                const Text(
                  'you get a bonus when\nanswering correctly with\na full health bar!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
              ],
      ],
    }[menuPage]!;

    return Theme(
      data: ThemeData(
        useMaterial3: true,
        checkboxTheme: CheckboxThemeData(fillColor: MaterialStatePropertyAll(inverseColor)),
      ),
      child: Stack(
        children: [
          Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
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
                  SuperContainer(
                    decoration: BoxDecoration(
                      border: Border.all(color: inverseColor, width: 2),
                    ),
                    width: 300,
                    padding: const EdgeInsets.all(50),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 250),
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
          exists
              ? Fader(
                  visible,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOutQuad,
                  child: const SuperContainer(color: SuperColors.lightBackground),
                )
              : empty,
        ],
      ),
    );
  }
}
