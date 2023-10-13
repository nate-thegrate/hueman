import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:super_hueman/data/page_data.dart';
import 'package:super_hueman/data/save_data.dart';
import 'package:super_hueman/data/structs.dart';
import 'package:super_hueman/data/super_color.dart';
import 'package:super_hueman/data/super_container.dart';
import 'package:super_hueman/data/widgets.dart';

extension _BallSpacing on BuildContext {
  double get ballSpacing => (screenHeight - 150) / 30;
}

class IntenseTutorial extends StatefulWidget {
  const IntenseTutorial({super.key});

  @override
  State<IntenseTutorial> createState() => _IntenseTutorialState();
}

class _IntenseTutorialState extends SuperState<IntenseTutorial> {
  int textVisible = 0;
  bool showAllRows = false, justKidding = false, makingTheJump = false, madeTheJump = false;
  late final Ticker epicHues;

  void animate() async {
    await sleepState(3, () => textVisible++);
    await sleepState(2, () => textVisible++);
    await sleepState(4, () => textVisible++);
    await sleepState(1, () => showAllRows = true);
    await sleepState(1, () => textVisible++);
  }

  void ready() => () async {
        setState(() => textVisible = 0);

        await sleepState(1, () {
          showAllRows = false;
          justKidding = true;
          textVisible = 2;
        });
        await sleepState(2, () {
          showAllRows = true;
          textVisible = 3;
        });
        await sleepState(3, () => textVisible = 0);
        await sleepState(1, () {
          textVisible = 2;
          makingTheJump = true;
        });
        await sleepState(2, () => madeTheJump = true);
        await sleepState(4 / 3, () => textVisible = 3);
        await sleep(3);
        Tutorials.intense = true;
      }()
          .then((_) => context.goto(Pages.intense));

  @override
  void initState() {
    super.initState();
    epicHues = epicSetup(setState);
    animate();
  }

  @override
  Widget build(BuildContext context) {
    final color = epicColor;
    final double padMultiplier = showAllRows
        ? justKidding
            ? context.ballSpacing
            : context.screenWidth / 12
        : 0;
    return Scaffold(
      body: FadeIn(
        child: Center(
          child: Column(
            children: [
              const Spacer(flex: 4),
              Stack(
                children: [
                  if (justKidding)
                    for (int startHue = 29; startHue >= 0; startHue -= 1)
                      _ColorRow(startHue, topPadding: startHue * padMultiplier)
                  else
                    for (int startHue = 20; startHue >= 0; startHue -= 10)
                      _ColorRow(startHue, topPadding: startHue * padMultiplier / 10),
                ],
              ),
              const Spacer(flex: 2),
              SexyBox(
                child: justKidding
                    ? empty
                    : Fader(
                        textVisible >= 1,
                        child: const EasyText(
                            'To identify and keep track of twelve different hues,'),
                      ),
              ),
              Fader(
                textVisible >= 2,
                child: makingTheJump
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          EasyRichText([
                            const TextSpan(text: 'this is the jump from '),
                            TextSpan(
                              text: 'sharp',
                              style: TextStyle(fontWeight: FontWeight.w100, color: color),
                            ),
                          ]),
                          AnimatedSlide(
                            offset: Offset(madeTheJump ? 0 : 3, 0),
                            duration: halfSec,
                            curve: Curves.easeOutExpo,
                            child: EasyRichText([
                              const TextSpan(text: ' to '),
                              TextSpan(text: 'superʜᴜᴇman', style: TextStyle(color: color)),
                              const TextSpan(text: '.'),
                            ]),
                          ),
                        ],
                      )
                    : justKidding
                        ? const EasyText('Sorry, did I say 36?')
                        : EasyRichText([
                            const TextSpan(text: 'you have to be '),
                            TextSpan(
                              text: 'sharp',
                              style: TextStyle(fontWeight: FontWeight.w100, color: color),
                            ),
                            const TextSpan(text: '.'),
                          ]),
              ),
              const Spacer(),
              Fader(
                textVisible >= 3,
                child: justKidding
                    ? makingTheJump
                        ? const EasyText("Let's see if you got what it takes.")
                        : const EasyText('I meant 360.')
                    : const EasyText("But now it's time to try 36."),
              ),
              const Spacer(flex: 3),
              SexyBox(
                child: Fader(
                  textVisible >= 4,
                  child: justKidding ? empty : ContinueButton(onPressed: ready),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot(this.hue);
  final int hue;

  @override
  Widget build(BuildContext context) {
    final width = context.ballSpacing * 3 / 4;
    return Center(
      child: SuperContainer(
        width: width,
        height: width,
        decoration: BoxDecoration(
          color: SuperColor.hue(hue),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// TODO: class _ColorWave

class _ColorRow extends StatelessWidget {
  // ignore: unused_element
  const _ColorRow(this.startHue, {this.topPadding = 0});
  final int startHue;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: oneSec,
      curve: Curves.easeInOutQuart,
      padding: EdgeInsets.only(top: topPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [for (int hue = startHue; hue < 360; hue += 30) _ColorDot(hue)],
      ),
    );
  }
}
