import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:super_hueman/reference.dart';

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

  menuButton(Pages page) {
    return ElevatedButton(
      onPressed: () => context.goto(page),
      style: ElevatedButton.styleFrom(backgroundColor: epicColor, foregroundColor: Colors.black),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(page(), style: const TextStyle(fontSize: 24)),
      ),
    );
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
        vspace(67),
        ElevatedButton(
          onPressed: () => setState(() => menuPage = MenuPage.introSelect),
          style:
              ElevatedButton.styleFrom(backgroundColor: epicColor, foregroundColor: Colors.black),
          child: const Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Text('intro', style: TextStyle(fontSize: 24)),
          ),
        ),
        vspace(33),
        menuButton(Pages.intense),
        vspace(33),
        menuButton(Pages.master),
        vspace(67),
        menuButton(Pages.sandbox),
      ],
      MenuPage.settings: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Checkbox(
              value: casualMode,
              onChanged: (value) {
                setState(() => casualMode = value!);
              },
            ),
            hspace(10),
            const Text(
              'casual mode',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
        Text(
          casualMode ? 'play without keeping score' : 'keep score when you play',
          style: Theme.of(context).textTheme.labelSmall,
        ),
        vspace(50),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Checkbox(
                value: autoSubmit,
                onChanged: (value) {
                  setState(() => autoSubmit = value!);
                }),
            hspace(10),
            const Text(
              'auto-submit',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
        Text(
          autoSubmit ? "'submit' when 3 digits are entered" : "submit with the 'submit' button",
          style: Theme.of(context).textTheme.labelSmall,
        ),
        ...showDonation
            ? [
                vspace(50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => {},
                      style: ElevatedButton.styleFrom(
                          backgroundColor: epicColor, foregroundColor: Colors.black),
                      child: const Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Text('ads', style: TextStyle(fontSize: 24)),
                      ),
                    ),
                  ],
                ),
              ]
            : [],
        vspace(50),
        const SizedBox(
          width: double.infinity,
          child: Text(
            '(Tip: long-press a button\nto replay the tutorial!)',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60),
          ),
        ),
      ],
      MenuPage.introSelect: [
        Text(
          'intro',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        vspace(55),
        menuButton(Pages.intro3),
        vspace(33),
        menuButton(Pages.intro6),
        vspace(33),
        menuButton(Pages.intro12),
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
                curve: Curves.easeOutCubic,
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
