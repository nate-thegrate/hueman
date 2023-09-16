import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:super_hueman/data/structs.dart';
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
    _Page2(nextPage),
    _Page3(nextPage),
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
  final controllers = [
    OneShotAnimation('combine', autoplay: false),
    SimpleAnimation('spin'),
  ];

  bool get stagnant => !controllers[0].isActive;
  void weBallin() => controllers[0].isActive = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MyRive(name: 'color_truth', controllers: controllers),
        Fader(
          stagnant,
          child: Center(
            child: Column(
              children: [
                const Spacer(),
                const EasyText("Let's combine the primary colors,\nfor real this time."),
                const Spacer(flex: 4),
                ContinueButton(onPressed: () {
                  setState(weBallin);
                  sleep(4.5, then: widget.nextPage);
                }),
                const Spacer(),
              ],
            ),
          ),
        ),
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
