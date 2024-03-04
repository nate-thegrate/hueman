import 'package:flutter/material.dart';
import 'package:hueman/data/page_data.dart';
import 'package:hueman/data/save_data.dart';
import 'package:hueman/data/structs.dart';
import 'package:hueman/data/super_color.dart';
import 'package:hueman/data/super_container.dart';
import 'package:hueman/data/super_state.dart';
import 'package:hueman/data/super_text.dart';
import 'package:hueman/data/widgets.dart';

extension _BallSpacing on BoxConstraints {
  double get ballSpacing => (maxHeight - 150) / 30;
}

class IntenseTutorial extends StatefulWidget {
  const IntenseTutorial({super.key});

  @override
  State<IntenseTutorial> createState() => _IntenseTutorialState();
}

class _IntenseTutorialState extends EpicState<IntenseTutorial> {
  int textVisible = 0;
  bool doTheWave = true,
      showAllRows = false,
      tellTheTruth = false,
      makingTheJump = false,
      madeTheJump = false;

  @override
  void animate() async {
    music.stop();
    await sleepState(2.3, () => textVisible++);
    await sleepState(2, () => textVisible++);
    await sleepState(3, () {
      doTheWave = false;
      textVisible++;
    });
    await sleepState(1, () => showAllRows = true);
    await sleepState(1, () => textVisible++);
  }

  void ready() async {
    setState(() => textVisible = 0);
    await sleepState(1, () {
      showAllRows = false;
      tellTheTruth = true;
      textVisible = 2;
    });
    await sleepState(2, () {
      showAllRows = true;
      textVisible = 3;
    });
    await sleepState(3, () => textVisible = 0);
    await sleepState(1.25, () {
      textVisible = 2;
      makingTheJump = true;
    });
    await sleepState(2, () => madeTheJump = true);
    await sleepState(4 / 3, () => textVisible = 3);
    await sleep(3);
    await Tutorial.intense.complete();
    context.goto(Pages.intense);
  }

  @override
  Widget build(BuildContext context) {
    final color = epicColor;

    final jumpTo = SuperRichText(pad: false, [
      const TextSpan(text: ' to '),
      TextSpan(text: 'super', style: SuperStyle.sans(color: color)),
      TextSpan(
        text: 'HUE',
        style: SuperStyle.sans(color: color, weight: 900, size: 14.5),
      ),
      TextSpan(text: 'man', style: SuperStyle.sans(color: color)),
      const TextSpan(text: '.'),
    ]);

    return Scaffold(
      body: SafeLayout((context, constraints) {
        return FadeIn(
          child: Center(
            child: Column(
              children: [
                const Spacer(flex: 4),
                Stack(
                  children: [
                    if (doTheWave)
                      _ColorWave(constraints)
                    else if (tellTheTruth)
                      for (int startHue = 29; startHue >= 0; startHue -= 1)
                        _ColorRow(
                          startHue,
                          showAllRows ? constraints.ballSpacing : 0,
                          constraints: constraints,
                        )
                    else
                      for (int startHue = 20; startHue >= 0; startHue -= 10)
                        _ColorRow(
                          startHue,
                          showAllRows ? constraints.maxWidth / 120 : 0,
                          constraints: constraints,
                        ),
                  ],
                ),
                const Spacer(flex: 2),
                SexyBox(
                  child: tellTheTruth
                      ? empty
                      : Fader(
                          textVisible >= 1,
                          child: const SuperText(
                            'To identify and keep track of twelve different hues,',
                          ),
                        ),
                ),
                Fader(
                  textVisible >= 2,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: switch (tellTheTruth) {
                      _ when makingTheJump => Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SuperRichText(pad: false, [
                              const TextSpan(text: 'this is the jump from '),
                              TextSpan(
                                text: 'sharp',
                                style: SuperStyle.sans(
                                  color: color,
                                  weight: 100,
                                  width: 87.5,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ]),
                            SlideItIn(
                              madeTheJump,
                              duration: Durations.extralong1,
                              direction: AxisDirection.right,
                              child: jumpTo,
                            ),
                          ],
                        ),
                      true => const SuperText('Sorry, did I say 36?'),
                      false => SuperRichText([
                          const TextSpan(text: 'you have to be '),
                          TextSpan(
                            text: 'sharp',
                            style: SuperStyle.sans(
                              color: color,
                              weight: 100,
                              width: 87.5,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const TextSpan(text: '.'),
                        ]),
                    },
                  ),
                ),
                const Spacer(),
                Fader(textVisible >= 3,
                    child: SuperText(
                      switch (makingTheJump) {
                        _ when !tellTheTruth => "But now it's time to try 36.",
                        true => "Let's see if you got what it takes.",
                        false => 'I meant 360.',
                      },
                    )),
                const Spacer(flex: 3),
                SexyBox(
                  child: Fader(
                    textVisible >= 4,
                    child: tellTheTruth ? empty : ContinueButton(onPressed: ready),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot(this.hue, {required this.constraints});
  final BoxConstraints constraints;
  final int hue;

  @override
  Widget build(BuildContext context) {
    final width = constraints.ballSpacing * 3 / 4;
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

class _ColorWave extends StatefulWidget {
  const _ColorWave(this.constraints);
  final BoxConstraints constraints;

  @override
  State<_ColorWave> createState() => _ColorWaveState();
}

class _ColorWaveState extends SuperState<_ColorWave> {
  final List<_ColorDotData> colorWaveData = [
    for (int hue = 0; hue < 360; hue += 30) _ColorDotData(hue)
  ];

  void doTheWave(_ColorDotData dotData) async {
    final List<VoidCallback> actions = [
      () => dotData.dy = -1.5,
      () => dotData
        ..curve = Curves.easeInOutQuad
        ..dy = 1,
      () => dotData.dy = -0.5,
      () => dotData
        ..curve = Curves.easeInQuad
        ..dy = 0,
    ];

    for (final action in actions) {
      await Future.delayed(quarterSec);
      setState(action);
    }
  }

  @override
  void animate() async {
    await sleep(1);
    for (final dotData in colorWaveData) {
      await sleep(0.08);
      doTheWave(dotData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (final _ColorDotData(:hue, :dy, :curve) in colorWaveData)
          AnimatedSlide(
            offset: Offset(0, dy),
            duration: quarterSec,
            curve: curve,
            child: _ColorDot(hue, constraints: widget.constraints),
          ),
      ],
    );
  }
}

class _ColorDotData {
  _ColorDotData(this.hue);
  final int hue;
  double dy = 0;
  Curve curve = Curves.easeOutQuad;
}

class _ColorRow extends StatelessWidget {
  const _ColorRow(this.startHue, this.topPadding, {required this.constraints});
  final BoxConstraints constraints;
  final int startHue;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: oneSec,
      curve: Curves.easeInOutQuart,
      padding: EdgeInsets.only(top: topPadding * startHue),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (int hue = startHue; hue < 360; hue += 30) _ColorDot(hue, constraints: constraints),
        ],
      ),
    );
  }
}
