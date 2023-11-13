import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hueman/data/big_balls.dart';
import 'package:hueman/data/save_data.dart';
import 'package:hueman/data/structs.dart';
import 'package:hueman/data/super_color.dart';
import 'package:hueman/data/super_container.dart';
import 'package:hueman/data/super_state.dart';
import 'package:hueman/data/super_text.dart';
import 'package:hueman/data/widgets.dart';

class EvenFurther extends StatefulWidget {
  const EvenFurther({super.key});

  @override
  State<EvenFurther> createState() => _EvenFurtherState();
}

class _EvenFurtherState extends SuperState<EvenFurther> {
  int? selectedTopic;
  void deselect() => selectedTopic = null;

  late final bool showK;
  late final Ticker ticker;
  int counter = 0;
  static const cycleLength = 0x80;
  void cycle(_) => setState(() => counter = ++counter % cycleLength);
  double funSine(int i) => (sin((counter - i * 15) / cycleLength * 2 * pi) + 1) * 5;

  @override
  void initState() {
    super.initState();
    showK = theEndApproaches;
    if (!theEndApproaches && !Tutorial.worldEnd()) theEndApproaches = true;
    ticker = Ticker(cycle)..start();
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  int buttonsInPlace = 0;
  @override
  void animate() async {
    for (int i = 0; i < 6; i++) {
      await sleepState(0.2, () => buttonsInPlace++);
    }
  }

  List<Widget> get _buttons {
    final List<Widget> buttons = [];
    final buttonToYeet = showK ? 2 : 1;
    for (final (i, Topic(:name, :defaultColor, :accentColor)) in topics.indexed) {
      bool selected() => i == selectedTopic;
      bool somethingElseSelected() => selectedTopic != null && !selected();
      void select() => setState(selected() ? deselect : () => selectedTopic = i);
      final accent = accentColor ?? contrastWith(defaultColor);
      final sine = funSine(i);
      if (i != topics.length - buttonToYeet) {
        final iAlign = min(i, topics.length - 2);
        buttons.add(
          Fader(
            !somethingElseSelected(),
            duration: quarterSec,
            child: SlideItIn(
              buttonsInPlace > iAlign,
              direction: iAlign % 2 == 0 ? AxisDirection.right : AxisDirection.left,
              duration: const Duration(seconds: 2),
              child: AnimatedAlign(
                duration: quarterSec,
                curve: Curves.easeOutQuart,
                alignment: selected()
                    ? const Alignment(0, -.8)
                    : Alignment(iAlign % 2 - .5, (iAlign + .6) / (topics.length - 1) * 2 - 1),
                child: Padding(
                  padding: selected()
                      ? EdgeInsets.zero
                      : EdgeInsets.only(top: sine, bottom: 10 - sine),
                  child: SizedBox.fromSize(
                    size: const Size.square(150),
                    child: Stack(
                      children: [
                        AnimatedScale(
                          scale: selected() ? 50 : 0.99,
                          duration: quarterSec,
                          curve: selected() ? Curves.easeInExpo : Curves.easeOutExpo,
                          child: DecoratedBox(
                            decoration:
                                BoxDecoration(shape: BoxShape.circle, color: defaultColor),
                            child: const SizedBox.expand(),
                          ),
                        ),
                        SizedBox.expand(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: selected() ? accent : defaultColor,
                              foregroundColor: selected() ? defaultColor.withAlpha(0xFF) : accent,
                              surfaceTintColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 36),
                            ),
                            onPressed: somethingElseSelected() ? null : select,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                name,
                                textAlign: TextAlign.center,
                                style: const SuperStyle.sans(size: 100, extraBold: true),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(brightness: Brightness.light, useMaterial3: true),
      child: GestureDetector(
        onTap: () => setState(deselect),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                const Balls(),
                ConstrainedBox(
                  constraints: BoxConstraints.loose(const Size.fromWidth(550)),
                  child: Stack(children: _buttons),
                ),
                if (selectedTopic case final int topic)
                  FadeIn(
                    duration: quarterSec,
                    curve: Curves.easeInExpo,
                    child: SizedBox(
                      height: context.safeHeight * .85 - 150,
                      child: topics[topic].details,
                    ),
                  )
              ],
            ),
          ),
          floatingActionButton: selectedTopic == null
              ? const Padding(
                  padding: EdgeInsets.only(top: 25),
                  child: GoBack(),
                )
              : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
        ),
      ),
    );
  }
}

class Topic {
  const Topic({
    required this.name,
    required this.defaultColor,
    this.accentColor,
    required this.details,
  });
  final String name;
  final Color defaultColor;
  final Color? accentColor;
  final Widget details;
}

const topics = [
  Topic(
    name: 'high\nscores',
    defaultColor: SuperColor(0xFFAAFF),
    details: _HighScores(),
  ),
  Topic(
    name: 'black\nlight',
    defaultColor: SuperColors.black,
    accentColor: SuperColors.violet,
    details: Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: 1080,
          height: 1500,
          child: Stack(
            children: [
              AnimatedSlide(
                offset: Offset(0, -0.2),
                duration: oneSec,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 66),
                  child: Image(
                    image: AssetImage('assets/black_light.jpg'),
                    colorBlendMode: BlendMode.screen,
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  empty,
                  empty,
                  empty,
                  Text(
                    '"Black lights" mostly give off ultraviolet radiation, '
                    'which is outside the visible spectrum.',
                    style: SuperStyle.sans(color: SuperColors.gray, size: 50),
                  ),
                  Text(
                    'So if a material is glowing under a black light, '
                    "that means it's somehow able to collect the energy from ultraviolet radiation "
                    'and then emit it as light we can see.',
                    style: SuperStyle.sans(color: SuperColors.gray, size: 50),
                  ),
                  Text(
                    'I have no idea how any of that works, '
                    "but someone who's into chemical engineering might understand what's going on.",
                    style: SuperStyle.sans(color: SuperColors.gray, size: 50),
                  ),
                  Text.rich(
                    style: SuperStyle.sans(color: SuperColors.gray, size: 50),
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "Maybe one day, we'll have a ",
                        ),
                        ColorTextSpan.red,
                        TextSpan(
                          text: " pigment that doesn't absorb/reflect different frequencies, "
                              'but instead captures the energy from all electromagnetic radiation '
                              'and releases it as red light: ',
                        ),
                        TextSpan(
                          text: 'the brightest red imaginable',
                          style:
                              SuperStyle.sans(size: 50, weight: 800, color: SuperColor(0xFF2020)),
                        ),
                        TextSpan(text: '.'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  ),
  Topic(
    name: 'chartreuse',
    defaultColor: SuperColors.chartreuse,
    details: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // TODO: Wikipedia contradictions
        // GestureRecognizer hyperlink(String url) =>
        //   TapGestureRecognizer()..onTap = () => gotoWebsite(url);
        SuperText('I don\'t understand why "chartreuse" is so awful, '
            'both its name and the fact that I always have trouble telling it apart from green.'),
        SuperRichText([
          TextSpan(text: 'When I add a bit of '),
          ColorTextSpan.blue,
          TextSpan(text: ' to '),
          TextSpan(
            text: 'green',
            style: SuperStyle.sans(color: SuperColors.green, weight: 600, shadows: [
              Shadow(blurRadius: 1),
              Shadow(blurRadius: 1),
              Shadow(blurRadius: 2),
            ]),
          ),
          TextSpan(text: ", it's easy for me to tell that it's "),
          TextSpan(
            text: 'spring',
            style: SuperStyle.sans(color: SuperColors.spring, weight: 600, shadows: [
              Shadow(blurRadius: 1),
              Shadow(blurRadius: 1),
              Shadow(blurRadius: 2),
            ]),
          ),
          TextSpan(text: '.'),
        ]),
        SuperRichText([
          TextSpan(text: 'And '),
          ColorTextSpan.red,
          TextSpan(
            text: ' is brighter than blue, '
                "so you'd think I'd be able to notice it just as easily, "
                'if not more so.',
          ),
        ]),
        SuperRichText([
          TextSpan(text: 'So why is it remarkably difficult to tell '),
          TextSpan(
            text: 'chartreuse',
            style: SuperStyle.sans(color: SuperColors.chartreuse, weight: 600, shadows: [
              Shadow(blurRadius: 1),
              Shadow(blurRadius: 1),
              Shadow(blurRadius: 2),
            ]),
          ),
          TextSpan(text: ' and '),
          TextSpan(
            text: 'green',
            style: SuperStyle.sans(color: SuperColors.green, weight: 600, shadows: [
              Shadow(blurRadius: 1),
              Shadow(blurRadius: 1),
              Shadow(blurRadius: 2),
            ]),
          ),
          TextSpan(text: ' apart?'),
        ]),
        SuperText(
          'If you know why this is, '
          "or if you're able to easily differentiate these colors, "
          "that's very impressive.",
        ),
        empty,
      ],
    ),
  ),
  Topic(
    name: 'color\nspaces',
    defaultColor: Colors.white54,
    accentColor: Colors.black54,
    details: Text('lorem ipsum'),
  ),
  Topic(
    name: 'your own\ngame',
    defaultColor: SuperColor(0x20FFF0),
    details: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SuperContainer(
              margin: EdgeInsets.symmetric(horizontal: 33),
              width: 1080,
              height: 1450,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text.rich(
                    style: SuperStyle.sans(size: 42, color: Colors.black),
                    TextSpan(children: [
                      TextSpan(
                        text: 'Flutter is an open-source app-building framework\n'
                            'made by Google.\n\n',
                      ),
                      TextSpan(
                        text: "It wasn't originally designed for video games, "
                            'but Flutter game development '
                            'has been gaining traction over the past few years, '
                            "and that's how this game was made.\n\n",
                      ),
                      TextSpan(
                        text: 'Unity, a 3D game engine, charges over ',
                      ),
                      TextSpan(text: '\$2000', style: SuperStyle.mono(size: 42, weight: 500)),
                      TextSpan(
                        text: ' a year for a "pro" subscription.\n'
                            "Flutter isn't built for 3D graphics, "
                            "but since it's an open-source framework, "
                            'you never have to pay for it!\n\n',
                      ),
                      TextSpan(
                        text: 'I animated this game using Rive '
                            "(along with Flutter's built-in animated widgets), "
                            'and if you want to make a 2D game with more action, '
                            "there's the Flame engine.\n\n",
                      ),
                      TextSpan(
                        text: "I'm excited to see all the cool stuff "
                            'people make with Flutter in the future '
                            '(even if this game ends up feeling '
                            'not quite as cool by comparison).\n\n'
                            'Oh, and ',
                      ),
                      TextSpan(
                        text: 'HUEman',
                        style: SuperStyle.gaegu(
                          size: 48,
                          weight: FontWeight.bold,
                          letterSpacing: -1 / 3,
                          height: 0,
                        ),
                      ),
                      TextSpan(
                        text: " is open-source too! This game's source code "
                            'is linked below, along with some other resources '
                            'for getting started as a Flutter game dev.',
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ),
        _GameDevButtons(),
      ],
    ),
  ),
  Topic(
    name: 'be a\nteacher',
    defaultColor: SuperColors.azure,
    accentColor: SuperColor(0xFFCC99),
    details: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SuperText(
          "I don't usually interact with groups of kids, but if you do then this'll be easy.",
        ),
        SuperRichText([
          TextSpan(text: 'Go back to the main menu and tap on "'),
          TextSpan(
              text: 'settings',
              style: TextStyle(
                color: SuperColor(0xFFCC99),
                shadows: [Shadow(color: Colors.black38, blurRadius: 3)],
              )),
          TextSpan(text: '".\nThere\'s an option to '),
          TextSpan(
              text: 'reset',
              style: TextStyle(
                color: SuperColor(0xFFCC99),
                shadows: [Shadow(color: Colors.black38, blurRadius: 3)],
              )),
          TextSpan(text: ' all your progress, so you can play through the tutorials again.'),
        ]),
        SuperText(
          'The next time a kid asks "you got games on your phone?",\nyou know what to do.',
        ),
        empty,
        empty,
      ],
    ),
  ),
  Topic(
    name: 'end of\nthe world',
    defaultColor: SuperColors.k,
    details: K_crash.padded(),
  ),
];

class _HighScores extends StatelessWidget {
  const _HighScores();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Spacer(),
        SuperText(
          "HUEman doesn't have any public leaderboards, "
          "since it's super easy to cheat if you take screenshots.",
          style: SuperStyle.gaegu(height: 0),
        ),
        Spacer(),
        SuperText(
          'But just for fun, your high scores are saved here, '
          'and you can compare them to what I got.',
          style: SuperStyle.gaegu(height: 0),
        ),
        Spacer(flex: 2),
      ],
    );
  }
}

class _GameDevButtons extends StatelessWidget {
  const _GameDevButtons();

  @override
  Widget build(BuildContext context) {
    const Map<String, String> links = {
      'hueman': 'https://github.com/nate-thegrate/hueman',
      'Flutter': 'https://flutter.dev/',
      'Flame': 'https://flame-engine.org/',
      'Rive': 'https://rive.app/',
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final MapEntry(key: name, value: url) in links.entries)
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: const SuperColor(0x20FFF0),
              ),
              onPressed: () => gotoWebsite(url),
              child: Padding(
                padding: EdgeInsets.fromLTRB(5, name == 'hueman' ? 8 : 10, 5, 10),
                child: name == 'hueman'
                    ? const Text.rich(TextSpan(children: [
                        TextSpan(
                          text: 'HUE',
                          style: SuperStyle.sans(size: 10, weight: 800, extraBold: true),
                        ),
                        TextSpan(text: 'man', style: SuperStyle.sans(size: 14)),
                      ]))
                    : Text(name, style: const SuperStyle.sans()),
              ),
            )
        ],
      ),
    );
  }
}
