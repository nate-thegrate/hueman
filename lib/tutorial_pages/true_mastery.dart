import 'package:flutter/material.dart';
import 'package:hueman/data/big_balls.dart';
import 'package:hueman/data/page_data.dart';
import 'package:hueman/data/save_data.dart';
import 'package:hueman/data/structs.dart';
import 'package:hueman/data/super_state.dart';
import 'package:hueman/data/super_text.dart';
import 'package:hueman/data/widgets.dart';

class TrueMasteryTutorial extends StatefulWidget {
  const TrueMasteryTutorial({super.key});

  @override
  State<TrueMasteryTutorial> createState() => _TrueMasteryTutorialState();
}

class _TrueMasteryTutorialState extends SuperState<TrueMasteryTutorial> {
  @override
  void animate() async {
    musicPlayer.stop();
    for (final (readTime, sentence) in dialogue) {
      await sleepState(readTime, () => visible = false);
      await sleepState(1, () {
        visible = true;
        text = sentence;
      });
    }
    await sleep(10);
    Tutorial.trueMastery.complete();
    playMusic(once: 'invert_1', loop: 'invert_2');
    context.goto(Pages.trueMastery);
  }

  static const List<(double, String)> dialogue = [
    (
      5,
      'In order to have made it this far,\n'
          'you had to identify a hue\n'
          'out of 360 possibilities.'
    ),
    (8, "But now you've arrived at the final challenge:\nidentifying a full color code."),
    (6, '3 channels, 256 possible values each.'),
    (5, '360 hue options is a lot:\n\na random guess is correct\nonly 0.3% of the time.'),
    (7, 'But 256³ is much, much worse:\n\n0.000006%.'),
    (8, 'Honestly, this is more of a joke\nthan an actual challenge.'),
    (6, 'But if you get creative and pay attention,\nyou might be able to figure something out.'),
  ];
  String text = 'Congratulations.';
  bool visible = true;

  @override
  Widget build(BuildContext context) {
    const shadows = [
      Shadow(blurRadius: 5),
      Shadow(blurRadius: 5),
      Shadow(blurRadius: 5),
      Shadow(blurRadius: 5),
      Shadow(blurRadius: 5),
    ];

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const Balls.bigAndBlack(),
            Center(
              child: Column(
                children: [
                  const Spacer(),
                  Fader(
                    visible,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        text,
                        textAlign: TextAlign.center,
                        style: const SuperStyle.sans(size: 24, shadows: shadows),
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
