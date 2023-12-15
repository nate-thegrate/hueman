import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hueman/data/page_data.dart';
import 'package:hueman/data/save_data.dart';
import 'package:hueman/data/structs.dart';
import 'package:hueman/data/super_color.dart';
import 'package:hueman/data/super_container.dart';
import 'package:hueman/data/super_state.dart';
import 'package:hueman/data/super_text.dart';
import 'package:hueman/data/widgets.dart';

class MasterTutorial extends StatefulWidget {
  const MasterTutorial({super.key});

  @override
  State<MasterTutorial> createState() => _MasterTutorialState();
}

class _MasterTutorialState extends SuperState<MasterTutorial> {
  bool visible = false;
  late final pages = [
    _Page1(nextPage),
    _Page2(nextPage),
    _Page3(nextPage),
  ];
  int page = 1;

  Duration duration = oneSec;

  void nextPage() {
    setState(() {
      duration = halfSec;
      visible = false;
    });
    sleepState(1, () {
      page++;
      visible = true;
      duration = oneSec;
    });
  }

  @override
  void animate() {
    musicPlayer.stop();
    sleepState(1, () => visible = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Fader(
            visible,
            duration: duration,
            child: pages[page - 1],
          ),
        ),
      ),
    );
  }
}

class _Page1 extends StatefulWidget {
  const _Page1(this.nextPage);
  final void Function() nextPage;

  @override
  State<_Page1> createState() => _Page1State();
}

class _Page1State extends EpicState<_Page1> {
  bool showQuestion = false, showSkills = false, showTheBestOne = false, buttonVisible = false;
  int skill = 0;

  @override
  void animate() async {
    await sleepState(6, () => showQuestion = true);
    await sleepState(2, () => showSkills = true);
    for (int i = 1; i < skills.length; i++) {
      await sleepState(1 - i / 20, () => skill = i);
    }
    await sleepState(1 - skills.length / 20, () => showTheBestOne = true);
    await sleepState(3, () => buttonVisible = true);
  }

  static const skills = [
    'cooking',
    'cleaning',
    'carpentry',
    'communication',
    'kung fu',
    'football',
    'american football :(',
    'dart language programming',
    'swing dancing',
    'financial literacy',
    'distance running',
    'time management',
    'public speaking',
    'piano',
    'singing',
    'cycling',
    'leadership',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 2),
        const SuperText("There's a lot of great skills that a human can learn and master."),
        const Spacer(),
        Fader(
          showQuestion,
          child: SuperText(showTheBestOne ? 'the best one:' : "But what's the best one?"),
        ),
        Expanded(
          flex: 4,
          child: Fader(
            showSkills,
            child: FittedBox(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SuperContainer(
                  width: 250,
                  height: 75,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                  alignment: Alignment.center,
                  child: showTheBestOne
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SuperText(
                              'vision',
                              style: SuperStyle.sans(size: 32, color: epicColor),
                            ),
                            Fader(
                              buttonVisible,
                              child: const SuperText(
                                '(I might be a little biased)',
                                style: SuperStyle.sans(size: 8, color: Colors.white54),
                              ),
                            ),
                          ],
                        )
                      : SuperText(skills[skill]),
                ),
              ),
            ),
          ),
        ),
        Fader(buttonVisible, child: ContinueButton(onPressed: widget.nextPage)),
        const Spacer(),
      ],
    );
  }
}

class _Page2 extends StatefulWidget {
  const _Page2(this.nextPage);
  final void Function() nextPage;

  @override
  State<_Page2> createState() => _Page2State();
}

class _Page2State extends SuperState<_Page2> {
  bool buttonVisible = false, showK = false;

  @override
  void animate() async {
    await sleepState(5, () {
      buttonVisible = true;
      yellow = const SuperColor(0x404000);
      blue = const SuperColor(0x8080FF);
    });
    await sleepState(5, () => showK = true);
    if (mounted) playSound('k_color');
  }

  SuperColor yellow = SuperColors.yellow;
  SuperColor blue = SuperColors.blue;
  static const duration = Duration(seconds: 5);

  @override
  Widget build(BuildContext context) {
    final double size = min(context.screenWidth / 20, 20);
    return Column(
      children: [
        const Spacer(flex: 2),
        SuperText(
          "Thus far, we've only worked with vibrant,\nfully saturated colors.",
          pad: false,
          style: SuperStyle.sans(size: size),
        ),
        const Spacer(),
        Expanded(
          flex: 4,
          child: Row(
            children: [
              const Spacer(),
              Expanded(
                flex: 8,
                child: AnimatedContainer(
                  duration: duration,
                  curve: Curves.easeOutSine,
                  color: yellow,
                ),
              ),
              const Spacer(),
              Expanded(
                flex: 8,
                child: AnimatedContainer(
                  duration: duration,
                  curve: Curves.easeOutSine,
                  color: blue,
                  alignment: Alignment.center,
                  child: showK ? const K_glitch() : null,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
        const Spacer(),
        Fader(
          buttonVisible,
          child: SuperText(
            "It's time to change that.",
            style: SuperStyle.sans(size: size),
          ),
        ),
        const Spacer(flex: 2),
        Fader(buttonVisible, child: ContinueButton(onPressed: widget.nextPage)),
        const Spacer(),
      ],
    );
  }
}

class _Page3 extends StatefulWidget {
  const _Page3(this.nextPage);
  final void Function() nextPage;

  @override
  State<_Page3> createState() => _Page3State();
}

class _Page3State extends EpicState<_Page3> {
  bool finalMessage = false, fadeAway = false;

  @override
  void animate() async {
    await sleepState(6, () => finalMessage = true);
    await sleepState(8, () => fadeAway = true);
    await Tutorial.master.complete();
    await sleep(1.5);
    if (casualMode) playMusic(once: 'verity_1', loop: 'verity_2');
    context.goto(Pages.master);
  }

  @override
  Widget build(BuildContext context) {
    final color = epicColor;
    return Center(
      child: Fader(
        !fadeAway,
        child: Column(
          children: [
            const Spacer(flex: 5),
            SuperRichText([
              const TextSpan(text: 'To '),
              TextSpan(
                  text: 'have',
                  style: SuperStyle.sans(
                    color: color,
                    weight: 250,
                    shadows: const [Shadow(blurRadius: 2)],
                  )),
              const TextSpan(text: ' a conscious experience is '),
              TextSpan(
                  text: 'amazing',
                  style: SuperStyle.sans(
                    color: color,
                    weight: 600,
                    shadows: const [Shadow(blurRadius: 2)],
                  )),
              const TextSpan(text: ','),
            ]),
            const Spacer(),
            Fader(
              finalMessage,
              child: SuperRichText([
                const TextSpan(text: 'but to '),
                TextSpan(
                    text: 'understand',
                    style: SuperStyle.sans(
                      color: color,
                      weight: 250,
                      shadows: const [Shadow(blurRadius: 2)],
                    )),
                const TextSpan(text: ' a conscious experience is '),
                TextSpan(
                    text: 'incredible',
                    style: SuperStyle.sans(
                      color: color,
                      weight: 600,
                      shadows: const [Shadow(blurRadius: 2)],
                    )),
                const TextSpan(text: '.'),
              ]),
            ),
            const Spacer(flex: 6),
          ],
        ),
      ),
    );
  }
}
