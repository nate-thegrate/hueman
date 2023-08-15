import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:super_hueman/pages/main_menu.dart';
import 'package:super_hueman/structs.dart';
import 'package:super_hueman/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class InverseMenu extends StatefulWidget {
  const InverseMenu({super.key});

  @override
  State<InverseMenu> createState() => _InverseMenuState();
}

class _InverseMenuState extends State<InverseMenu> {
  late final Ticker ticker;
  List<Widget> children = [];
  MenuPage menuPage = MenuPage.main;
  bool get mainMenu => menuPage == MenuPage.main;

  @override
  void initState() {
    super.initState();
    ticker = inverseSetup(setState);
  }

  @override
  void dispose() {
    ticker.dispose();
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
        MenuButton('intro',
            color: inverseColor, onPressed: () => setState(() => menuPage = MenuPage.introSelect)),
        const FixedSpacer(33),
        NavigateButton(Pages.intense, color: inverseColor),
        const FixedSpacer(33),
        NavigateButton(Pages.master, color: inverseColor),
        const FixedSpacer(67),
        NavigateButton(Pages.sandbox, color: inverseColor),
      ],
      MenuPage.settings: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Checkbox(
                value: autoSubmit,
                onChanged: (value) {
                  setState(() => autoSubmit = value!);
                }),
            const FixedSpacer.horizontal(10),
            const Text(
              'auto-submit',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
        Text(
          autoSubmit ? "'submit' when 3 digits are entered" : "submit with the 'submit' button",
          style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Colors.black45),
        ),
        const FixedSpacer(50),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Checkbox(
              value: casualMode,
              onChanged: (value) {
                setState(() => casualMode = value!);
              },
            ),
            const FixedSpacer.horizontal(10),
            const Text(
              'casual mode',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
        Text(
          casualMode ? 'play without keeping score' : 'keep score when you play',
          style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Colors.black45),
        ),
        const FixedSpacer(50),
        Center(
          child: OutlinedButton(
            onPressed: () => launchUrl(Uri.parse('https://google.com/')),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: inverseColor, width: 2),
              foregroundColor: inverseColor,
              backgroundColor: const Color(0xffeef3f8),
              shadowColor: inverseColor,
            ),
            child: const Padding(
              padding: EdgeInsets.only(top: 4, bottom: 10),
              child: Text('report a bug',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal)),
            ),
          ),
        ),
        const FixedSpacer(25),
        Center(
          child: OutlinedButton(
            onPressed: () {
              setState(() => inverted = false);
              context.goto(Pages.mainMenu);
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: inverseColor, width: 2),
              foregroundColor: inverseColor,
              backgroundColor: const Color(0xffeef3f8),
              shadowColor: inverseColor,
            ),
            child: const Padding(
              padding: EdgeInsets.fromLTRB(23, 10, 23, 16),
              child: Text('revert', style: TextStyle(fontSize: 24)),
            ),
          ),
        ),
      ],
      MenuPage.introSelect: [
        const Text(
          'intro',
          textAlign: TextAlign.center,
          style: superStyle,
        ),
        const FixedSpacer(55),
        NavigateButton(Pages.intro3, color: inverseColor),
        const FixedSpacer(33),
        NavigateButton(Pages.intro6, color: inverseColor),
        const FixedSpacer(33),
        NavigateButton(Pages.intro12, color: inverseColor),
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

    return Theme(
      data: ThemeData(
        useMaterial3: true,
        checkboxTheme: CheckboxThemeData(fillColor: MaterialStatePropertyAll(inverseColor)),
      ),
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: TextButton(
                  style: mainMenu
                      ? TextButton.styleFrom(
                          foregroundColor: inverseColor,
                          backgroundColor: Colors.white,
                        )
                      : TextButton.styleFrom(
                          foregroundColor: inverseColor,
                          backgroundColor: Colors.white54,
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
                decoration: BoxDecoration(
                  border: Border.all(color: inverseColor, width: 2),
                ),
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
        backgroundColor: const Color(0xffeef3f8),
        // backgroundColor: const Color(0xffe1e8ee),
        // backgroundColor: const Color(0xfff0f8ff),
      ),
    );
  }
}
