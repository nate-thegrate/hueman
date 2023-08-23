import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:super_hueman/save_data.dart';
import 'package:super_hueman/structs.dart';
import 'package:super_hueman/widgets.dart';

class GameEnd extends StatefulWidget {
  final ScoreKeeper scoreKeeper;
  const GameEnd(this.scoreKeeper, {super.key});

  @override
  State<GameEnd> createState() => _GameEndState();
}

class _GameEndState extends State<GameEnd> {
  late final Ticker ticker;

  @override
  void initState() {
    super.initState();
    ticker = inverted ? inverseSetup(setState) : epicSetup(setState);
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ScoreKeeper sk = widget.scoreKeeper;
    final Pages page = sk.page;
    final Color color = inverted ? inverseColor : epicColor;

    return Theme(
      data: inverted
          ? ThemeData(useMaterial3: true)
          : ThemeData(
              useMaterial3: true,
              colorScheme: const ColorScheme.dark(primary: Colors.white),
            ),
      child: Scaffold(
        body: Center(
          child: Column(
            children: [
              const Expanded(flex: 4, child: empty),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: color, width: 2),
                    borderRadius: BorderRadius.circular(25)),
                padding: const EdgeInsets.all(50),
                child: Text('Finished!', style: TextStyle(fontSize: 54, color: color)),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Game mode:  ', style: TextStyle(fontSize: 24, color: color)),
                  Text(page.gameMode, style: const TextStyle(fontSize: 24)),
                ],
              ),
              const Spacer(flex: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Score:  ', style: TextStyle(fontSize: 32, color: color)),
                  sk.finalScore,
                ],
              ),
              const FixedSpacer(10),
              sk.finalDetails,
              const Spacer(flex: 3),
              SuperButton('play again', color: color, onPressed: () => context.goto(page)),
              const FixedSpacer(33),
              SuperButton(
                'play in casual mode',
                color: color,
                onPressed: () {
                  casualMode = true;
                  context.goto(page);
                },
              ),
              const FixedSpacer(33),
              SuperButton(
                'back to menu',
                color: color,
                onPressed: () => context.goto(inverted ? Pages.inverseMenu : Pages.mainMenu),
              ),
              const Expanded(flex: 4, child: empty),
            ],
          ),
        ),
        backgroundColor: inverted ? SuperColors.lightBackground : null,
      ),
    );
  }
}
