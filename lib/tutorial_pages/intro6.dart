import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;
import 'package:super_hueman/data/structs.dart';
import 'package:super_hueman/data/super_color.dart';
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
    _Page2(nextPage),
    _Page3(nextPage),
    _Page4(nextPage),
    _Page5(nextPage),
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
    rive.SimpleAnimation('spin'),
    rive.OneShotAnimation('combine', autoplay: false),
    rive.OneShotAnimation('2 at a time', autoplay: false),
  ];

  bool get stagnant => !controllers[1].isActive;
  void weBallin() => controllers[1].isActive = true;
  void bestPart() => controllers[2].isActive = true;
  void noSpins() => controllers[0].isActive = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Rive(name: 'color_truth', controllers: controllers),
        Fader(
          stagnant,
          child: Center(
            child: Column(
              children: [
                const Spacer(),
                const EasyText("Let's combine the primary colors,\nfor real this time."),
                const Spacer(flex: 4),
                ContinueButton(onPressed: () async {
                  setState(weBallin);
                  await sleep(5);
                  setState(noSpins);
                  setState(bestPart);
                  await sleep(8);
                  widget.nextPage();
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

class _Page2State extends State<_Page2> with DelayedPress {
  static const colorText = Text.rich(
    textAlign: TextAlign.center,
    TextSpan(
      style: TextStyle(fontSize: 24),
      children: [
        TextSpan(
          text: 'cyan',
          style: TextStyle(color: SuperColors.cyan, fontWeight: FontWeight.bold),
        ),
        TextSpan(text: ', '),
        TextSpan(
          text: 'magenta',
          style: TextStyle(color: SuperColors.magenta, fontWeight: FontWeight.bold),
        ),
        TextSpan(text: ', and '),
        TextSpan(
          text: 'yellow',
          style: TextStyle(color: SuperColors.yellow, fontWeight: FontWeight.bold),
        ),
        TextSpan(text: '.'),
      ],
    ),
  );

  static const shouldntPrintersUse = Text.rich(
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: 24),
    TextSpan(
      children: [
        TextSpan(text: "That's kinda weird though…\nshouldn't printers use "),
        TextSpan(
          text: 'red',
          style: TextStyle(color: SuperColors.red, fontWeight: FontWeight.bold),
        ),
        TextSpan(text: '/'),
        TextSpan(
          text: 'green',
          style: TextStyle(color: SuperColors.green, fontWeight: FontWeight.bold),
        ),
        TextSpan(text: '/'),
        TextSpan(
          text: 'blue',
          style: TextStyle(color: SuperColors.blue, fontWeight: FontWeight.bold),
        ),
        TextSpan(text: " ink\n if that's what our eyes are built for?"),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 4),
        colorText,
        const Spacer(),
        const Text(
          'Those are the colors that printers use!',
          style: TextStyle(fontSize: 20),
        ),
        const Spacer(),
        SizedBox(
          width: context.screenWidth * .8,
          height: context.screenWidth * .8,
          child: const Image(image: AssetImage('assets/ink_cartridge.png')),
        ),
        const Spacer(flex: 2),
        shouldntPrintersUse,
        const Spacer(flex: 2),
        OutlinedButton(
            onPressed: delayed(widget.nextPage),
            child: const Padding(
              padding: EdgeInsets.only(top: 10, bottom: 13),
              child: Text(
                'wow, good question!',
                style: TextStyle(fontSize: 18),
              ),
            )),
        const Spacer(flex: 2),
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

class _Page3State extends State<_Page3> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Spacer(),
        Text('Thanks!'),
        FixedSpacer(10),
        Text("Here's the answer:"),
        Spacer(),
        Text('A screen starts as black, and then adds red/green/blue light.'),
        Spacer(),
        _AddSubtract(color: SuperColors.red),
        Spacer(),
        Text(
          'But printers work the opposite way—\n'
          'they start with a white piece of paper,\n'
          'and then add pigments that absorb red/green/blue wavelengths.',
          textAlign: TextAlign.center,
        ),
        Spacer(),
        _AddSubtract(color: SuperColors.cyan, subtract: SuperColors.red),
        Spacer(),
      ],
    );
  }
}

class _AddSubtract extends StatelessWidget {
  const _AddSubtract({required this.color, this.subtract}) : subtractive = (subtract != null);
  final SuperColor color;
  final SuperColor? subtract;
  final bool subtractive;

  List<Color> get colors => subtractive ? [subtract!, Colors.black] : [Colors.black, color];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SuperContainer(
          color: subtractive ? Colors.white : Colors.black,
          width: 100,
          height: 100,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Stack(
            children: [
              SuperContainer(
                width: 125,
                height: 25,
                alignment: const Alignment(0, 0),
                child: Text(subtractive ? 'absorb ${subtract!.name}' : 'add ${color.name}'),
              ),
              const Icon(
                Icons.trending_flat,
                size: 125,
                color: Colors.black,
                shadows: [Shadow(blurRadius: 4)],
              ),
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => LinearGradient(colors: colors).createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                ),
                child: const Icon(Icons.trending_flat, size: 125),
              ),
            ],
          ),
        ),
        SuperContainer(
          color: color,
          width: 100,
          height: 100,
        ),
      ],
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

class _Page5 extends StatefulWidget {
  const _Page5(this.nextPage);
  final void Function() nextPage;

  @override
  State<_Page5> createState() => _Page5State();
}

class _Page5State extends State<_Page5> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [],
    );
  }
}
