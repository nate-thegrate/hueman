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

  @override
  Widget build(BuildContext context) {
    menuButton(Pages page, [String? text]) {
      return ElevatedButton(
        onPressed: () => context.goto(page),
        style: ElevatedButton.styleFrom(backgroundColor: epicColor, foregroundColor: Colors.black),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(text ?? page(), style: const TextStyle(fontSize: 24)),
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(border: Border.all(color: epicColor, width: 2)),
          padding: const EdgeInsets.all(50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
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
              menuButton(Pages.intro),
              vspace(33),
              menuButton(Pages.intense),
              vspace(33),
              menuButton(Pages.master),
            ],
          ),
        ),
      ),
    );
  }
}
