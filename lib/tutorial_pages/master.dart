import 'package:flutter/material.dart';
import 'package:super_hueman/data/page_data.dart';
import 'package:super_hueman/data/save_data.dart';
import 'package:super_hueman/data/structs.dart';
import 'package:super_hueman/data/super_color.dart';
import 'package:super_hueman/data/super_state.dart';
import 'package:super_hueman/data/widgets.dart';

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
  void animate() => sleepState(1, () => visible = true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Fader(
          visible,
          duration: duration,
          child: pages[page - 1],
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

class _Page1State extends SuperState<_Page1> {
  bool finalStep = false, buttonVisible = false;

  @override
  void animate() async {
    await sleepState(5, () => finalStep = true);
    await sleepState(3, () => buttonVisible = true);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 2),
        const EasyText(
          "By finding the right hue out of 360,\nyou've proven your mettle.",
        ),
        const Spacer(),
        Fader(
          finalStep,
          child: const EasyText(
            "But there's one final step on the path\nto fully unlocking this superpower.",
          ),
        ),
        const Spacer(flex: 2),
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
  bool timeToChange = false, buttonVisible = false;

  @override
  void animate() async {
    await sleepState(5, () {
      timeToChange = true;
      buttonVisible = true;
      yellow = const SuperColor(0x404000);
      blue = const SuperColor(0xA0A0F0);
    });
  }

  SuperColor yellow = SuperColors.yellow;
  SuperColor blue = SuperColors.blue;
  static const duration = Duration(seconds: 5);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 2),
        const EasyText("Thus far, we've only worked with vibrant,\nfully saturated colors."),
        const Spacer(),
        Expanded(
          flex: 4,
          child: Row(
            children: [
              const Spacer(),
              Expanded(
                flex: 8,
                child: AnimatedContainer(duration: duration, color: yellow),
              ),
              const Spacer(),
              Expanded(
                flex: 8,
                child: AnimatedContainer(duration: duration, color: blue),
              ),
              const Spacer(),
            ],
          ),
        ),
        const Spacer(),
        Fader(
          timeToChange,
          child: const EasyText("It's time to change that."),
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

class _Page3State extends SuperState<_Page3> {
  bool finalMessage = false, fadeAway = false;

  @override
  void animate() {
    sleepState(4, () => finalMessage = true);
    sleepState(8, () => fadeAway = true).then((_) {
      Tutorials.master = true;
      sleep(1.5, then: () => context.goto(Pages.master));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Fader(
        !fadeAway,
        child: Column(
          children: [
            const Spacer(flex: 5),
            const EasyText(
              "Master this skill, and you'll have full dominion\n"
              'over your visual experience.',
            ),
            const Spacer(),
            Fader(
              finalMessage,
              child: const EasyText("You'll see every color for what it is."),
            ),
            const Spacer(flex: 6),
          ],
        ),
      ),
    );
  }
}
