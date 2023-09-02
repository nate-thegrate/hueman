import 'package:flutter/material.dart';
import 'package:super_hueman/structs.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  late final Widget startButton = OutlinedButton(
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.black,
      side: const BorderSide(width: 2),
    ),
    onPressed: transition(const _ColorBullshit()),
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
    sleep(2 / 3).then((_) => setState(() => visible = true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedOpacity(
        duration: const Duration(milliseconds: 750),
        opacity: visible ? 1 : 0,
        child: Center(child: content),
      ),
      backgroundColor: SuperColors.lightBackground,
    );
  }
}

class _ColorBullshit extends StatefulWidget {
  const _ColorBullshit();

  @override
  State<_ColorBullshit> createState() => _ColorBullshitState();
}

class _ColorBullshitState extends State<_ColorBullshit> {
  static const title = Text(
    'There are 3 primary colors:',
    style: TextStyle(color: Colors.black, fontSize: 18),
  );

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Spacer(flex: 2),
        title,
        Spacer(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _BullshitBox(SuperColors.red),
            _BullshitBox(SuperColors.yellow),
            _BullshitBox(SuperColors.fakeBlue),
          ],
        ),
        Spacer(flex: 2),
      ],
    );
  }
}

class _BullshitBox extends StatelessWidget {
  final SuperColor color;
  const _BullshitBox(this.color);

  Widget get text => color.name == '[none]'
      ? Text(
          '${color.name},',
          style: const TextStyle(color: Colors.black, fontSize: 20),
        )
      : Text(
          '${color.name},',
          style: const TextStyle(color: Colors.black, fontSize: 20),
        );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        text,
        Container(
          width: 150,
          height: 75,
          margin: const EdgeInsets.fromLTRB(15, 10, 15, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: color,
          ),
          alignment: Alignment.center,
        ),
      ],
    );
  }
}
