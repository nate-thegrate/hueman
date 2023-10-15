import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:super_hueman/data/page_data.dart';
import 'package:super_hueman/data/save_data.dart';
import 'package:super_hueman/data/structs.dart';
import 'package:super_hueman/data/super_color.dart';
import 'package:super_hueman/data/super_container.dart';
import 'package:super_hueman/data/widgets.dart';
import 'package:super_hueman/pages/intro.dart';

class ScoreScreen extends StatefulWidget {
  const ScoreScreen(this.scoreKeeper, {super.key});
  final ScoreKeeper scoreKeeper;

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
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
    final bool tutorial = sk is TutorialScoreKeeper;
    final Color color = inverted ? inverseColor : epicColor;

    return Theme(
      data: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: inverted ? null : const ColorScheme.dark(primary: Colors.white),
      ),
      child: Scaffold(
        body: Center(
          child: Column(
            children: [
              const Expanded(flex: 4, child: empty),
              SuperContainer(
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
              if (tutorial) ...[
                if (page != Pages.introC)
                  SuperButton(
                    'continue',
                    color: color,
                    onPressed: () => context.goto(switch (page) {
                      Pages.intro3 => Pages.intro6,
                      Pages.intro6 => Pages.introC,
                      _ => throw Error(),
                    }),
                  ),
                const FixedSpacer(33),
                SuperButton('play again', color: color, onPressed: () => context.goto(page)),
                const FixedSpacer(33),
                SuperButton(
                  'main menu',
                  color: color,
                  onPressed: context.menu,
                ),
              ] else ...[
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
                  'main menu',
                  color: color,
                  onPressed: context.menu,
                ),
              ],
              const Expanded(flex: 4, child: empty),
            ],
          ),
        ),
        backgroundColor: inverted ? SuperColors.lightBackground : null,
      ),
    );
  }
}
