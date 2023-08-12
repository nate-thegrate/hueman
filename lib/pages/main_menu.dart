import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:super_hueman/reference.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  late final Ticker ticker;
  List<Widget> children = [];
  bool introSelect = false;

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
    children = introSelect
        ? [
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
          ]
        : [
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
              onPressed: () => setState(() => introSelect = true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: epicColor, foregroundColor: Colors.black),
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
          ];

    scoreKeeping() => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('keep score?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...KeepScore.radioList(
                  onChanged: (value) {
                    setState(() => keepScore = value!);
                    Navigator.pop(context);
                  },
                ),
                vspace(50),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('auto-submit\nwhen 3 digits are entered'),
                    hspace(20),
                    Checkbox(
                        value: autoSubmit,
                        onChanged: (value) {
                          setState(() => autoSubmit = value!);
                          Navigator.pop(context);
                        }),
                  ],
                ),
              ],
            ),
          ),
        );

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
              opacity: introSelect ? 1 : 0,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white70,
                    backgroundColor: Colors.black12,
                  ),
                  onPressed: () {
                    if (introSelect) setState(() => introSelect = false);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'back',
                      style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(border: Border.all(color: epicColor, width: 2)),
              width: 300,
              padding: const EdgeInsets.all(50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: children,
              ),
            ),
          ],
        ),
      ),
      bottomSheet: GestureDetector(
        onTap: scoreKeeping,
        child: Container(
          alignment: Alignment.center,
          height: 50,
          width: 200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('keep score', style: Theme.of(context).textTheme.bodyLarge),
              ),
              hspace(4),
              Checkbox(value: keepScore.active, onChanged: (_) => scoreKeeping()),
            ],
          ),
        ),
      ),
    );
  }
}
