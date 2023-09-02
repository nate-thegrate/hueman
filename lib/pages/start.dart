import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:super_hueman/structs.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  late RiveAnimationController controller, controller2;

  late final Widget startButton = OutlinedButton(
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.black,
      side: const BorderSide(width: 2),
    ),
    onPressed: () => setState(() => controller.isActive = !controller.isActive),
    child: const Padding(
      padding: EdgeInsets.fromLTRB(0, 5, 0, 10),
      child: Text(
        'start',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.5,
        ),
      ),
    ),
  );
  late final Widget startButton2 = OutlinedButton(
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.black,
      side: const BorderSide(width: 2),
    ),
    onPressed: () => setState(() => controller2.isActive = true),
    child: const Padding(
      padding: EdgeInsets.fromLTRB(0, 5, 0, 10),
      child: Text(
        'start2',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.5,
        ),
      ),
    ),
  );

  void Function() transition(Widget newContent) => () async {
        setState(() => visible = false);
        await sleep(2);
        setState(() {
          content = newContent;
          visible = true;
        });
      };

  late Widget content = startButton;
  bool visible = false;

  @override
  void initState() {
    super.initState();
    controller = SimpleAnimation('colorChange');
    controller2 = OneShotAnimation('spin');
    sleep(2 / 3).then((_) => setState(() => visible = true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 750),
            opacity: visible ? 1 : 0,
            child: Center(child: content),
          ),
          startButton2,
          SizedBox(
            width: context.screenWidth,
            height: context.screenWidth,
            child: RiveAnimation.asset(
              'assets/animations/lucidium.riv',
              fit: BoxFit.contain,
              controllers: [controller, controller2],
            ),
          ),
        ],
      ),
      backgroundColor: SuperColors.lightBackground,
    );
  }
}
