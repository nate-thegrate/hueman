import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:super_hueman/structs.dart';
import 'package:super_hueman/widgets.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

enum MenuPage { main, settings, introSelect }

class _MainMenuState extends State<MainMenu> {
  late final Ticker ticker;
  List<Widget> children = [];
  MenuPage menuPage = MenuPage.main;
  bool get mainMenu => menuPage == MenuPage.main;

  @override
  void initState() {
    super.initState();
    ticker = epicSetup(setState);
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  bool done = false;
  List<String> calculateColors(double targetLuminance) {
    List<String> colors = [];
    for (double hue = 0; hue < 360; hue++) {
      double max = 1, min = 0;
      double mid() => (max + min) / 2;
      Color color() => HSLColor.fromAHSL(1, hue, 1, mid()).toColor();
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
        ...mastery
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
          'auto-submit',
          value: autoSubmit,
          description: ("'submit' when 3 digits are entered", "submit with the 'submit' button"),
          toggle: (value) => setState(() => autoSubmit = value),
        ),
        const FixedSpacer(33),
        ...mastery
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
                      backgroundColor: const Color(0xff121212),
                      shadowColor: epicColor,
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
                      setState(() => inverted = true);
                      context.goto(Pages.inverseMenu);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: epicColor, width: 2),
                      foregroundColor: epicColor,
                      backgroundColor: const Color(0xff121212),
                      shadowColor: epicColor,
                      elevation: (sin(epicHue / 360 * 2 * pi * 6) + 1) * 6,
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
                    backgroundColor: const Color(0xff121212),
                    shadowColor: epicColor,
                  ),
                  onPressed: () => {
                    showDialog(
                      context: context,
                      builder: (context) => const AlertDialog(
                        content: Text(
                          'unlock more options\nby playing "intense" mode!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Colors.white70),
                        ),
                      ),
                    ),
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(top: 5, bottom: 10),
                    child: Text('more options', style: TextStyle(fontSize: 18)),
                  ),
                )),
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
      body: Center(
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
    );
  }
}
