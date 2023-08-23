import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:super_hueman/save_data.dart';
import 'package:super_hueman/structs.dart';
import 'package:super_hueman/widgets.dart';

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
    controller = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    if (inverted) {
      opacity = 0;
      exists = false;
    } else {
      inverted = true;
      sleep(0.01).then((_) => setState(() => opacity = 0));
      sleep(0.6).then((_) => setState(() => exists = false));
    }
  }

  @override
  void dispose() {
    inverseHues.dispose();
    super.dispose();
  }

  static const superStyle = TextStyle(
    color: Colors.black,
    fontFamily: 'Segoe UI',
    fontSize: 32.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.25,
  );

  TextStyle get titleTheme =>
      Theme.of(context).textTheme.headlineLarge!.copyWith(color: Colors.black);
  TextStyle get hueTheme => TextStyle(
        fontSize: 24,
        color: inverseColor,
        fontWeight: FontWeight.bold,
      );

  double opacity = 1;
  bool exists = true;

  @override
  Widget build(BuildContext context) {
    children = <MenuPage, List<Widget>>{
      MenuPage.main: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('super', style: titleTheme),
            const FixedSpacer.horizontal(1),
            Text('HUE', style: hueTheme),
            const FixedSpacer.horizontal(1),
            Text('man', style: titleTheme),
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
              foregroundColor: inverted ? Colors.white : Colors.black),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 15),
            child: Text(Pages.trueMastery(),
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, height: 0.95)),
          ),
        ),
        const FixedSpacer(67),
        NavigateButton(Pages.inverseSandbox, color: inverseColor),
      ],
      MenuPage.settings: [
        MenuCheckbox(
          'casual mode',
          value: casualMode,
          description: ('play without keeping score', 'keep score when you play'),
          toggle: (value) => setState(() => casualMode = value),
        ),
        const FixedSpacer(67),
        ...clickedOnAds
            ? [
                Container(
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

              animate().then((value) => context.invert());
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
        const Text(
          'tense',
          textAlign: TextAlign.center,
          style: superStyle,
        ),
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
                  Container(
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
          Align(
            alignment: const Alignment(0, 0.43),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0, end: 3).animate(controller),
              child: ClipOval(
                child: Container(
                  width: context.screenWidth,
                  height: context.screenWidth,
                  decoration: const BoxDecoration(
                    color: SuperColors.inverting,
                    backgroundBlendMode: BlendMode.difference,
                  ),
                  alignment: Alignment.center,
                  child: AnimatedOpacity(
                    opacity: inverting ? 1 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(color: SuperColors.darkBackground),
                  ),
                ),
              ),
            ),
          ),
          exists
              ? AnimatedOpacity(
                  duration: const Duration(milliseconds: 600),
                  opacity: opacity,
                  curve: Curves.easeInOutQuad,
                  child: Container(
                    constraints: const BoxConstraints.expand(),
                    color: SuperColors.lightBackground,
                  ),
                )
              : empty,
        ],
      ),
    );
  }
}
