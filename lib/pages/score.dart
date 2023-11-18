import 'package:flutter/material.dart';
import 'package:hueman/data/page_data.dart';
import 'package:hueman/data/save_data.dart';
import 'package:hueman/data/structs.dart';
import 'package:hueman/data/super_color.dart';
import 'package:hueman/data/super_container.dart';
import 'package:hueman/data/super_state.dart';
import 'package:hueman/data/super_text.dart';
import 'package:hueman/data/widgets.dart';
import 'package:hueman/pages/intro.dart';

class ScoreScreen extends StatefulWidget {
  const ScoreScreen(this.scoreKeeper, {super.key});
  final ScoreKeeper scoreKeeper;

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends DynamicState<ScoreScreen> {
  @override
  void initState() {
    super.initState();
    final ScoreKeeper sk = widget.scoreKeeper;
    final Score? mode = Score.fromScoreKeeper(sk);
    if (mode != null) mode.set(sk.scoreVal);
  }

  @override
  void animate() async {
    if (widget.scoreKeeper case final TutorialScoreKeeper sk) {
      if (sk.numColors != 6) return;
      await sleep(0.5);
      final bool lovinTheCircle = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          Widget circleLoveButton(bool lovinIt) => SizedBox(
                height: 33,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0x10FFFFFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                  ),
                  onPressed: () => Navigator.pop(context, lovinIt),
                  child: Text(lovinIt ? 'yes' : 'no', style: const SuperStyle.sans(size: 16)),
                ),
              );
          return AlertDialog(
            title: const Text('How was that?', style: SuperStyle.sans()),
            content: const Text(
              'Did you like the circle better than typing?',
              style: SuperStyle.sans(),
            ),
            actions: [circleLoveButton(true), circleLoveButton(false)],
            actionsAlignment: MainAxisAlignment.spaceEvenly,
          );
        },
      );
      hueTyping = !lovinTheCircle;
      saveData('hueTyping', hueTyping);

      final soundsGood = hueTyping ? 'You can type out the hues' : "We'll keep the circle going";
      showDialog(
        context: context,
        builder: (context) => DismissibleDialog(
          title: const Text('Sounds good!', style: SuperStyle.sans()),
          content: Text(
            '$soundsGood from now on.\n\n'
            'If you change your mind, you can switch back in the game settings.',
            style: const SuperStyle.sans(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ScoreKeeper sk = widget.scoreKeeper;
    final Pages page = sk.page;
    final bool tutorial = sk is TutorialScoreKeeper;
    final SuperColor color = inverted ? inverseColor : epicColor;

    return Theme(
      data: ThemeData(
        useMaterial3: true,
        fontFamily: 'nunito sans',
        colorScheme: inverted ? null : const ColorScheme.dark(primary: Colors.white),
      ),
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              children: [
                const Expanded(flex: 4, child: empty),
                SuperContainer(
                  decoration: BoxDecoration(
                      border: Border.all(color: color, width: 2),
                      borderRadius: BorderRadius.circular(25)),
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 36),
                  child: Text('Finished!', style: SuperStyle.sans(size: 54, color: color)),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Game mode:  ', style: SuperStyle.sans(size: 22, color: color)),
                    Text(
                      page.gameMode,
                      style: const SuperStyle.sans(size: 21, weight: 200),
                    ),
                  ],
                ),
                const Spacer(flex: 3),
                if (tutorial) ...[
                  if (page == Pages.introC) ...[
                    BrandNew(
                      color: color,
                      text: 'casual\nmode',
                      child: SuperButton(
                        'play again',
                        color: color,
                        onPressed: () => context.goto(page),
                      ),
                    ),
                  ] else ...[
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
                    SuperButton(
                      'play again',
                      color: color,
                      onPressed: () => context.goto(page),
                    ),
                  ],
                  const FixedSpacer(33),
                  SuperButton(
                    'main menu',
                    color: color,
                    onPressed: context.menu,
                  ),
                ] else ...[
                  SuperRichText(
                    style: const SuperStyle.sans(size: 32),
                    [
                      TextSpan(text: 'Score:  ', style: TextStyle(color: color)),
                      TextSpan(text: sk.scoreVal.toString())
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
                const Expanded(flex: 3, child: empty),
              ],
            ),
          ),
        ),
        backgroundColor: inverted ? SuperColors.lightBackground : null,
      ),
    );
  }
}
