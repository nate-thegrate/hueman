import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:super_hueman/data/save_data.dart';
import 'package:super_hueman/data/structs.dart';
import 'package:super_hueman/data/widgets.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

enum MenuPage { main, settings, introSelect }

class _MainMenuState extends State<MainMenu> with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Ticker epicHues;
  List<Widget> children = [];
  MenuPage menuPage = MenuPage.main;
  bool get mainMenu => menuPage == MenuPage.main;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: oneSec, vsync: this);
    epicHues = epicSetup(setState);
    if (inverted) {
      inverted = false;
      sleep(0.01, then: () => setState(() => visible = false));
      sleep(0.5, then: () => setState(() => darkBackground = null));
    } else {
      visible = false;
      darkBackground = null;
    }
  }

  @override
  void dispose() {
    epicHues.dispose();
    super.dispose();
  }

  bool done = false;
  List<String> calculateColors(double targetLuminance) {
    List<String> colors = [];
    for (double hue = 0; hue < 360; hue++) {
      double max = 1, min = 0;
      double mid() => (max + min) / 2;
      SuperColor color() => SuperColor.hsl(hue, 1, mid());
      for (int i = 0; i < 15; i++) {
        double luminance = color().computeLuminance();
        if (luminance > targetLuminance) {
          max = mid();
        } else {
          min = mid();
        }
      }
      colors.add(color().hexCode);
    }
    return colors;
  }

  bool showMasteryText = false;
  bool inverting = false;
  bool visible = true;
  bool? darkBackground = true;

  @override
  Widget build(BuildContext context) {
    children = <MenuPage, List<Widget>>{
      MenuPage.main: [
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
        const FixedSpacer(67),
        ElevatedButton(
          onPressed: () => setState(() => menuPage = MenuPage.introSelect),
          style:
              ElevatedButton.styleFrom(backgroundColor: epicColor, foregroundColor: Colors.black),
          child: const Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Text('intro', style: TextStyle(fontSize: 24)),
          ),
        ),
        const FixedSpacer(33),
        NavigateButton(Pages.intense, color: epicColor),
        ...hueMaster
            ? [
                const FixedSpacer(33),
                NavigateButton(Pages.master, color: epicColor),
              ]
            : [],
        const FixedSpacer(67),
        NavigateButton(Pages.sandbox, color: epicColor),
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
          'auto-submit',
          value: autoSubmit,
          description: ("'submit' when 3 digits are entered", "submit with the 'submit' button"),
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
        ...hueMaster
            ? [
                MenuCheckbox(
                  'casual mode',
                  value: casualMode,
                  description: ('play without keeping score', 'keep score when you play'),
                  toggle: (value) => setState(() => casualMode = value),
                ),
                const FixedSpacer(50),
                Center(
                  child: OutlinedButton(
                    onPressed: gotoWebsite('https://google.com/'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: epicColor, width: 2),
                      foregroundColor: epicColor,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.only(top: 4, bottom: 10),
                      child: Text('report a bug',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal)),
                    ),
                  ),
                ),
                const FixedSpacer(33),
                Center(
                  child: OutlinedButton(
                    onPressed: () {
                      Future animate() async {
                        setState(() => inverting = true);
                        controller.forward();
                        await sleep(0.7);
                        setState(() => darkBackground = false);
                        await sleep(0.1);
                        setState(() => visible = true);
                        await sleep(0.5);
                      }

                      animate().then((_) => context.invert());
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: epicColor, width: 2),
                      foregroundColor: epicColor,
                      backgroundColor: SuperColors.darkBackground,
                      shadowColor: epicColor,
                      elevation: epicSine * 5,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
                      child: Text(Pages.inverseMenu(), style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                ),
              ]
            : [
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
                  duration: const Duration(milliseconds: 250),
                  curve: curve,
                  child: Container(
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
              ],
      ],
      MenuPage.introSelect: [
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
        NavigateButton(Pages.intro12, color: epicColor),
        ...casualMode
            ? []
            : [
                const FixedSpacer(33),
                const Text(
                  "during 'intro' games,\nquick answers score higher!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60),
                )
              ]
      ],
    }[menuPage]!;

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
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
                Container(
                  decoration: BoxDecoration(border: Border.all(color: epicColor, width: 2)),
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
          ...inverting
              ? [
                  Container(
                    constraints: const BoxConstraints.expand(),
                    decoration: const BoxDecoration(
                      backgroundBlendMode: BlendMode.difference,
                      color: SuperColors.inverting,
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(top: 400),
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 12, end: 0).animate(controller),
                      child: Container(
                        height: context.screenWidth / 4,
                        decoration: const BoxDecoration(
                          backgroundBlendMode: BlendMode.difference,
                          color: SuperColors.inverting,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ]
              : [],
          darkBackground == null
              ? empty
              : Fader(
                  visible,
                  duration: halfSec,
                  curve: Curves.easeInOutQuad,
                  child: Container(
                    constraints: const BoxConstraints.expand(),
                    color: darkBackground!
                        ? SuperColors.darkBackground
                        : SuperColors.lightBackground,
                  ),
                ),
        ],
      ),
    );
  }
}
