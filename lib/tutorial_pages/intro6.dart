import 'dart:math';

import 'package:flutter/material.dart';
import 'package:super_hueman/data/structs.dart';
import 'package:super_hueman/data/super_container.dart';
import 'package:super_hueman/data/widgets.dart';

class Intro6Tutorial extends StatefulWidget {
  const Intro6Tutorial({super.key});

  @override
  State<Intro6Tutorial> createState() => _Intro6TutorialState();
}

class _Intro6TutorialState extends State<Intro6Tutorial> {
  bool visible = false;
  late final pages = [
    _Page1(nextPage),
  ];
  int page = 1;

  Duration duration = oneSec;

  void nextPage() async {
    setState(() => duration = halfSec);
    setState(() => visible = false);
    await sleep(1);
    setState(() {
      page++;
      duration = oneSec;
    });
    setState(() => visible = true);
  }

  @override
  void initState() {
    super.initState();
    sleep(1, then: () => setState(() => visible = true));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Fader(
            visible,
            duration: duration,
            child: pages[page - 1],
          ),
        ),
      );
}

class _Page1 extends StatefulWidget {
  const _Page1(this.nextPage);
  final void Function() nextPage;

  @override
  State<_Page1> createState() => _Page1State();
}

class _Page1State extends State<_Page1> {
  int step = 0;

  void animate() async {
    setState(() => step++);

    await sleep(3);
    setState(() => step++);

    await sleep(2);
    setState(() => step++);
  }

  @override
  Widget build(BuildContext context) {
    final width = min(context.screenWidth, context.screenHeight - 200) / 3.5;
    return Column(
      children: [
        const Spacer(flex: 2),
        const EasyText("Let's combine the primary colors,\nfor real this time."),
        const Spacer(),
        SuperContainer(
          width: width * 3,
          height: width * 3,
          alignment: Alignment.center,
          child: Stack(
            children: [
              const SuperContainer(color: Colors.black),
              _ColorCoition(const [2, 5, 2, 3], step, width, SuperColors.red),
              _ColorCoition(const [2, 5, 2, 5], step, width, SuperColors.red),
              _ColorCoition(const [4, 5, 6, 3], step, width, SuperColors.green),
              _ColorCoition(const [4, 5, 8, 7], step, width, SuperColors.green),
              _ColorCoition(const [6, 5, 4, 5], step, width, SuperColors.blue),
              _ColorCoition(const [6, 5, 4, 7], step, width, SuperColors.blue),
              Center(
                child: Fader(
                  step != 2,
                  child: Text(
                    step > 2 ? 'red + blue\n= magenta' : 'R + G + B\n= white',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: SuperColors.darkBackground,
                      fontSize: width / 8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: SuperContainer(
                  width: width,
                  height: width,
                  alignment: Alignment.center,
                  child: Text(
                    'red + green\n= yellow',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: SuperColors.darkBackground,
                      fontSize: width / 8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: SuperContainer(
                  width: width,
                  height: width,
                  alignment: Alignment.center,
                  child: Text(
                    'green + blue\n= cyan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: SuperColors.darkBackground,
                      fontSize: width / 8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SuperContainer(
                decoration: BoxDecoration(
                  color: SuperColors.darkBackground,
                  backgroundBlendMode: BlendMode.lighten,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Fader(
          step == 0,
          child: ContinueButton(onPressed: animate),
        ),
        const Spacer(),
      ],
    );
  }
}

class _ColorCoition extends StatelessWidget {
  const _ColorCoition(this.alignSequence, this.progress, this.width, this.color);
  final List<int> alignSequence;
  final int progress;
  final double width;
  final SuperColor color;

  /// ```dart
  ///
  /// 1 2 3
  /// 4 5 6
  /// 7 8 9
  ///
  /// align[1] → Alignment.topLeft
  /// ```
  static const List<Alignment> align = [
    Alignment.topLeft, // index 0 don't matter
    Alignment.topLeft,
    Alignment.topCenter,
    Alignment.topRight,
    Alignment.centerLeft,
    Alignment.center,
    Alignment.centerRight,
    Alignment.bottomLeft,
    Alignment.bottomCenter,
    Alignment.bottomRight,
  ];

  Curve get _curve => switch (progress) {
        < 2 => Curves.easeInExpo,
        < 3 => Curves.easeOutExpo,
        _ => Curves.easeInCubic,
      };

  @override
  Widget build(BuildContext context) {
    return AnimatedAlign(
      duration: progress < 3 ? const Duration(milliseconds: 1500) : const Duration(seconds: 6),
      alignment: align[alignSequence[progress]],
      curve: _curve,
      child: SuperContainer(
        width: width,
        height: width,
        decoration: BoxDecoration(
          color: color,
          backgroundBlendMode: BlendMode.screen,
        ),
      ),
    );
  }
}

class _Page2 extends StatefulWidget {
  const _Page2(this.nextPage);
  final void Function() nextPage;

  @override
  State<_Page2> createState() => _Page2State();
}

class _Page2State extends State<_Page2> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [],
    );
  }
}

class _Page3 extends StatefulWidget {
  const _Page3(this.nextPage);
  final void Function() nextPage;

  @override
  State<_Page3> createState() => _Page3State();
}

class _Page3State extends State<_Page3> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [],
    );
  }
}

class _Page4 extends StatefulWidget {
  const _Page4(this.nextPage);
  final void Function() nextPage;

  @override
  State<_Page4> createState() => _Page4State();
}

class _Page4State extends State<_Page4> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [],
    );
  }
}
