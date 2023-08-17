import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
    ticker = epicSetup(setState);
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  ScoreKeeper get sk => widget.scoreKeeper;
  Pages get page => sk.page;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(
            children: [
              const Expanded(flex: 4, child: empty),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: epicColor, width: 2),
                    borderRadius: BorderRadius.circular(25)),
                padding: const EdgeInsets.all(50),
                child: Text('Finished!', style: TextStyle(fontSize: 54, color: epicColor)),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Game mode:  ', style: TextStyle(fontSize: 24, color: epicColor)),
                  Text(page.gameMode, style: const TextStyle(fontSize: 24)),
                ],
              ),
              const Spacer(flex: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Score:  ', style: TextStyle(fontSize: 32, color: epicColor)),
                  sk.finalScore,
                ],
              ),
              const FixedSpacer(10),
              sk.finalDetails,
              const Spacer(flex: 3),
              ElevatedButton(
                onPressed: () => context.goto(page),
                style: ElevatedButton.styleFrom(
                    backgroundColor: epicColor, foregroundColor: Colors.black),
                child: const Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Text('play again', style: TextStyle(fontSize: 24)),
                ),
              ),
              const FixedSpacer(33),
              ElevatedButton(
                onPressed: () {
                  casualMode = true;
                  context.goto(page);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: epicColor, foregroundColor: Colors.black),
                child: const Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Text('play in casual mode', style: TextStyle(fontSize: 24)),
                ),
              ),
              const FixedSpacer(33),
              ElevatedButton(
                onPressed: () => context.goto(Pages.mainMenu),
                style: ElevatedButton.styleFrom(
                    backgroundColor: epicColor, foregroundColor: Colors.black),
                child: const Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Text('back to menu', style: TextStyle(fontSize: 24)),
                ),
              ),
              const Expanded(flex: 4, child: empty),
            ],
          ),
        ),
      );
}
