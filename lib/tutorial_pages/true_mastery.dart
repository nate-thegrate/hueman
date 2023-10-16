import 'dart:math';

import 'package:flutter/material.dart';
import 'package:super_hueman/data/page_data.dart';
import 'package:super_hueman/data/save_data.dart';
import 'package:super_hueman/data/structs.dart';
import 'package:super_hueman/data/super_color.dart';
import 'package:super_hueman/data/super_container.dart';
import 'package:super_hueman/data/super_state.dart';
import 'package:super_hueman/data/widgets.dart';

const _balls = 75;
const _cycleSeconds = 10;

class TrueMasteryTutorial extends StatefulWidget {
  const TrueMasteryTutorial({super.key});

  @override
  State<TrueMasteryTutorial> createState() => _TrueMasteryTutorialState();
}

class _TrueMasteryTutorialState extends SuperState<TrueMasteryTutorial> {
  final List<Widget> balls = [];

  @override
  void animate() {
    () async {
      for (int i = 0; i < _balls; i++) {
        setState(() {
          balls.insert(
            rng.nextInt(balls.length + 1),
            _ColorBall((360 * i) ~/ _balls, key: ObjectKey(i)),
          );
        });
        await sleep(_cycleSeconds / _balls);
      }
    }();
    () async {
      for (final (readTime, sentence) in dialogue) {
        await sleepState(readTime, () => visible = false);
        await sleepState(1, () {
          visible = true;
          text = sentence;
        });
      }
      await sleep(10);
      Tutorials.trueMastery = true;
    }()
        .then((_) => context.goto(Pages.trueMastery));
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
      body: Stack(
        children: [
          Stack(children: balls),
          Center(
            child: Column(
              children: [
                const Spacer(),
                Fader(
                  visible,
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 32, shadows: shadows),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}

class _ColorBall extends StatefulWidget {
  const _ColorBall(this.hue, {super.key});
  final int hue;

  @override
  State<_ColorBall> createState() => _ColorBallState();
}

extension _RandAlign on Random {
  Alignment get randAlign => Alignment(nextDouble() * 2 - 1, nextDouble() * 2 - 1);
}

class _ColorBallState extends SuperState<_ColorBall> {
  bool visible = false;
  Alignment alignment = rng.randAlign;

  @override
  void animate() async {
    while (mounted) {
      const startupTime = 2.0;
      quickly(
        () => setState(() {
          alignment = rng.randAlign;
          visible = true;
        }),
      );
      await sleepState(_cycleSeconds - startupTime, () => visible = false);
      await sleep(startupTime);
    }
  }

  late final color = SuperColor.hue(widget.hue, 0.01);
  late final blob = Transform.scale(
    scale: 250,
    child: SuperContainer(
      width: 1,
      height: 1,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withAlpha(0)]),
      ),
    ),
  );
  late final child = Stack(children: [blob, blob]);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Fader(
        visible,
        duration: const Duration(seconds: 2),
        child: child,
      ),
    );
  }
}
