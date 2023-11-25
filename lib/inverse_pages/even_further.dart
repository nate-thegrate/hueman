import 'dart:math';

import 'package:flutter/gestures.dart';
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
                    ? Alignment.topCenter
                    : Alignment(iAlign % 2 - .5, (iAlign + .6) / (topics.length - 1) * 2 - 1),
                child: Padding(
                  padding: selected()
                      ? const EdgeInsets.only(top: 20)
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
        onTap: selectedTopic == 6 ? null : () => setState(deselect),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeLayout((context, constraints) {
            return Center(
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
                        height: constraints.maxHeight - 190,
                        child: topics[topic].details,
                      ),
                    )
                ],
              ),
            );
          }),
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
    details: FittedBox(
      fit: BoxFit.scaleDown,
      child: SuperContainer(
        margin: EdgeInsets.symmetric(horizontal: 33),
        width: 1080,
        height: 1500,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 100),
              child: Image(image: AssetImage('assets/black_light.jpg')),
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
                  style: SuperStyle.sans(color: SuperColor(0xA080C0), size: 50),
                ),
                Text(
                  'So if a material is glowing under a black light, '
                  "that means it's somehow able to collect the energy from ultraviolet radiation "
                  'and then re-emit it as light we can see.',
                  style: SuperStyle.sans(color: SuperColor(0xA080C0), size: 50),
                ),
                Text(
                  'I have no idea how any of that works, '
                  "but someone who's into chemical engineering might understand what's going on.",
                  style: SuperStyle.sans(color: SuperColor(0xA080C0), size: 50),
                ),
                Text.rich(
                  style: SuperStyle.sans(color: SuperColor(0xA080C0), size: 50),
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Maybe one day, we'll have a ",
                      ),
                      ColorTextSpan.red,
                      TextSpan(
                        text: " pigment that doesn't absorb/reflect different frequencies, "
                            'but instead captures the energy from all electro-magnetic radiation '
                            'and releases it as red light: ',
                      ),
                      TextSpan(
                        text: 'the brightest red imaginable!',
                        style: SuperStyle.sans(
                          size: 50,
                          weight: 800,
                          color: SuperColor(0xFF2020),
                        ),
                      ),
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
  Topic(
    name: 'chartreuse',
    defaultColor: SuperColors.chartreuse,
    details: _ChartreuseSucks(),
  ),
  Topic(
    name: 'color\nspaces',
    defaultColor: Colors.white54,
    accentColor: Colors.black54,
    details: _ColorSpaceInfo(),
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
              width: 1060,
              height: 975,
              child: Text.rich(
                style: SuperStyle.sans(size: 36, color: Colors.black),
                TextSpan(children: [
                  TextSpan(
                    text: 'Flutter is an open-source app framework made by Google.\n\n',
                  ),
                  TextSpan(
                    text: "I really like Flutter's flexibility—it lets you make a game "
                        '(or any other type of application) and then publish it to any platform.\n'
                        "And it's open-source, so you never have to pay for it!\n\n",
                  ),
                  TextSpan(
                    text: 'I animated this game using Rive '
                        "(plus Flutter's built-in animated widgets). "
                        'If you want to focus on making games, '
                        'Rive works with lots of great open-source options, including '
                        "Defold, Bevy, and Flutter's Flame engine.\n\n",
                  ),
                  TextSpan(
                    text: "I'm excited to see all the cool stuff people make in the future "
                        '(even if this game ends up feeling not-so-cool by comparison).\n\n',
                  ),
                  TextSpan(text: 'Oh, and '),
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
                        'for getting started as a cross-platform game dev.',
                  ),
                ]),
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
    details: Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
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
            TextSpan(text: '".\n'),
            TextSpan(text: "There's an option to "),
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
  ),
  Topic(
    name: 'end of\nthe world',
    defaultColor: SuperColors.k,
    details: K_glitch.destroyer(),
  ),
];

class _HighScores extends StatelessWidget {
  const _HighScores();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        const SuperText(
          "HUEman doesn't have any public leaderboards, "
          "since it's super easy to cheat if you take screenshots.",
          style: SuperStyle.gaegu(size: 18, height: 0),
        ),
        const Spacer(),
        SuperText(
          'But your scores are saved in this app!\n'
          'Go back to the main menu and find the "high scores" button in the settings'
          '${Score.noneSet ? '.' : ', or compare with my high scores here:'}',
          style: const SuperStyle.gaegu(size: 18, height: 0),
        ),
        const Spacer(),
        if (Score.noneSet)
          const SuperText(
            'In order to set high scores, turn off "casual mode" before starting a game!',
            style: SuperStyle.gaegu(size: 18, height: 0),
          )
        else
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Theme(
              data: ThemeData(dividerColor: Colors.black),
              child: DataTable(
                columnSpacing: 30,
                columns: const [
                  DataColumn(
                    label: Text(
                      'game mode',
                      style: SuperStyle.gaegu(size: 20, weight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'my score',
                      style: SuperStyle.gaegu(size: 20, weight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'your score',
                      style: SuperStyle.gaegu(size: 20, weight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'comparison',
                      style: SuperStyle.gaegu(size: 20, weight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: [
                  for (final score in Score.allScores)
                    if (score())
                      DataRow(cells: [
                        DataCell(Text(
                          score.label,
                          style: const SuperStyle.mono(),
                        )),
                        DataCell(Text(
                          '${score.mine}',
                          style: const SuperStyle.sans(size: 16, weight: 300),
                        )),
                        DataCell(Text(
                          '${score.value}',
                          style: const SuperStyle.sans(size: 16, weight: 300),
                        )),
                        DataCell(Text(
                          score.compare,
                          style: const SuperStyle.gaegu(size: 20),
                        )),
                      ])
                ],
              ),
            ),
          ),
        const Spacer(flex: 2),
      ],
    );
  }
}

class _ChartreuseSucks extends StatefulWidget {
  const _ChartreuseSucks();

  @override
  State<_ChartreuseSucks> createState() => _ChartreuseSucksState();
}

class _ChartreuseSucksState extends State<_ChartreuseSucks> {
  bool goodQuestion = false, tellMeMore = false;
  GestureRecognizer hyperlink(String url) =>
      TapGestureRecognizer()..onTap = () => gotoWebsite(url);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (tellMeMore)
          const Expanded(
              child: FittedBox(
            child: SuperContainer(
              margin: EdgeInsets.symmetric(horizontal: 10),
              width: 475,
              height: 550,
              child: SuperRichText(align: TextAlign.left, [
                TextSpan(
                  text: 'A color really should just have a single color code\nthat we ',
                ),
                TextSpan(
                  text: 'chart',
                  style: SuperStyle.sans(size: 11, width: 87.5, weight: 500, extraBold: true),
                ),
                TextSpan(text: 'reuse everywhere.\n\n'),
                TextSpan(
                  text: 'And terrible puns aside, '
                      "there's still more I don't like about chartreuse:\n\n",
                ),
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
                TextSpan(text: ", it's easy for me\nto tell that it's "),
                TextSpan(
                  text: 'spring',
                  style: SuperStyle.sans(color: SuperColors.spring, weight: 600, shadows: [
                    Shadow(blurRadius: 1),
                    Shadow(blurRadius: 1),
                    Shadow(blurRadius: 2),
                  ]),
                ),
                TextSpan(text: '.\nAnd '),
                ColorTextSpan.red,
                TextSpan(text: " is brighter than blue, so you'd think I'd be\nable to tell "),
                TextSpan(
                  text: 'chartreuse',
                  style: SuperStyle.sans(color: SuperColors.chartreuse, weight: 600, shadows: [
                    Shadow(blurRadius: 1),
                    Shadow(blurRadius: 1),
                    Shadow(blurRadius: 2),
                  ]),
                ),
                TextSpan(text: ' apart from '),
                TextSpan(
                  text: 'green',
                  style: SuperStyle.sans(color: SuperColors.green, weight: 600, shadows: [
                    Shadow(blurRadius: 1),
                    Shadow(blurRadius: 1),
                    Shadow(blurRadius: 2),
                  ]),
                ),
                TextSpan(text: ' just as easily, if not even more so.\n\n'),
                TextSpan(
                  text: 'But no.\n'
                      "I've had so much difficulty with chartreuse, and I\nhave no idea why.\n\n",
                ),
                TextSpan(
                  text: 'If you know why this is, '
                      "or if you're able to easily differentiate these colors, "
                      "that's very impressive.",
                ),
              ]),
            ),
          ))
        else if (goodQuestion)
          Expanded(
            child: FittedBox(
              child: SuperContainer(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 600,
                height: 640,
                child: SuperRichText(align: TextAlign.left, [
                  const TextSpan(text: 'Thanks! I wish I had a good answer.\n\n\n'),
                  const TextSpan(
                    text: 'While I was doing color theory research,\t'
                        "I realized there isn't even a clear consensus "
                        'regarding what "chartreuse" is, at least not on Wikipedia.\n\n',
                  ),
                  const TextSpan(text: 'This game sets "chartreuse" as '),
                  const TextSpan(
                    text: '#80FF00',
                    style: SuperStyle.mono(weight: 550, size: 18),
                  ),
                  const TextSpan(text: ', which comes from the Wikipedia articles for '),
                  TextSpan(
                    text: 'shades of chartreuse',
                    style: const SuperStyle.sans(
                      extraBold: true,
                      color: SuperColors.azure,
                      decoration: TextDecoration.underline,
                      decorationColor: SuperColors.azure,
                    ),
                    recognizer: hyperlink(
                      'https://en.wikipedia.org/w/index.php?title=Shades_of_chartreuse&oldid=1184863956',
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'tertiary color',
                    style: const SuperStyle.sans(
                      extraBold: true,
                      color: SuperColors.azure,
                      decoration: TextDecoration.underline,
                      decorationColor: SuperColors.azure,
                    ),
                    recognizer: hyperlink(
                      'https://en.wikipedia.org/w/index.php?title=Tertiary_color&oldid=1182085196#RGB_or_CMYK_primary,_secondary,_and_tertiary_colors',
                    ),
                  ),
                  const TextSpan(text: '.\n\n'),
                  const TextSpan(text: 'But the main '),
                  TextSpan(
                    text: 'chartreuse',
                    style: const SuperStyle.sans(
                      extraBold: true,
                      color: SuperColors.azure,
                      decoration: TextDecoration.underline,
                      decorationColor: SuperColors.azure,
                    ),
                    recognizer: hyperlink(
                      'https://en.wikipedia.org/w/index.php?title=Chartreuse_(color)&oldid=1184724573',
                    ),
                  ),
                  const TextSpan(text: ' page defines it as '),
                  const TextSpan(text: '#B2D63F', style: SuperStyle.mono(weight: 550, size: 18)),
                  const TextSpan(text: ', which looks '),
                  const TextSpan(
                    text: 'really dull and gross',
                    style: SuperStyle.sans(
                      weight: 800,
                      color: SuperColor(0xB2D63F),
                      shadows: [Shadow(color: Colors.white54, blurRadius: 2)],
                    ),
                  ),
                  const TextSpan(text: " (but apparently it's based on the color of a "),
                  TextSpan(
                    text: 'liqueur',
                    style: const SuperStyle.sans(
                      extraBold: true,
                      color: SuperColors.azure,
                      decoration: TextDecoration.underline,
                      decorationColor: SuperColors.azure,
                    ),
                    recognizer: hyperlink(
                      'https://en.wikipedia.org/wiki/Chartreuse_(liqueur)',
                    ),
                  ),
                  const TextSpan(text: ' with the same name).\n\n'),
                  const TextSpan(text: 'And on the '),
                  TextSpan(
                    text: 'color term',
                    style: const SuperStyle.sans(
                      extraBold: true,
                      color: SuperColors.azure,
                      decoration: TextDecoration.underline,
                      decorationColor: SuperColors.azure,
                    ),
                    recognizer: hyperlink(
                      'https://en.wikipedia.org/w/index.php?title=Color_term&oldid=1182771422',
                    ),
                  ),
                  const TextSpan(text: " page, it's shown as "),
                  const TextSpan(
                    text: 'another gross color',
                    style: SuperStyle.sans(
                      weight: 800,
                      width: 96,
                      color: SuperColor(0xD0EA2B),
                      shadows: [Shadow(color: SuperColor(0x9080FF), blurRadius: 1)],
                    ),
                  ),
                  const TextSpan(
                    text: ', and they put it inside the red/yellow/blue color wheel. '
                        'The more vibrant chartreuse is shown in the ',
                  ),
                  TextSpan(
                    text: 'RGB color wheel',
                    style: const SuperStyle.sans(
                      extraBold: true,
                      color: SuperColors.azure,
                      decoration: TextDecoration.underline,
                      decorationColor: SuperColors.azure,
                    ),
                    recognizer:
                        hyperlink('https://en.wikipedia.org/wiki/File:RGB_color_wheel.svg'),
                  ),
                  const TextSpan(text: ' on that page, but its name is "chartreuse green".\n\n'),
                  const TextSpan(text: 'That color wheel is also shown on the '),
                  TextSpan(
                    text: 'tertiary color',
                    style: const SuperStyle.sans(
                      extraBold: true,
                      color: SuperColors.azure,
                      decoration: TextDecoration.underline,
                      decorationColor: SuperColors.azure,
                    ),
                    recognizer: hyperlink(
                      'https://en.wikipedia.org/w/index.php?title=Tertiary_color&oldid=1182085196#RGB_or_CMYK_primary,_secondary,_and_tertiary_colors',
                    ),
                  ),
                  const TextSpan(
                    text: ' page, which means that the exact same color is being called '
                        'both "chartreuse" and "chartreuse green" in the same article!',
                  ),
                ]),
              ),
            ),
          )
        else ...[
          const SuperText('Why is "chartreuse" so awful?'),
        ],
        if (!goodQuestion)
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              side: const BorderSide(width: 2, color: Colors.black),
            ),
            onPressed: () =>
                setState(goodQuestion ? () => tellMeMore = true : () => goodQuestion = true),
            child: const Padding(
              padding: EdgeInsets.fromLTRB(6, 6, 6, 7),
              child: Text(
                'wow, good question!',
                style: SuperStyle.sans(size: 20, weight: 400, extraBold: true),
              ),
            ),
          )
        else if (!tellMeMore)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: SizedBox(
              height: 42,
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: SuperColors.chartreuse,
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                ),
                onPressed: () =>
                    setState(goodQuestion ? () => tellMeMore = true : () => goodQuestion = true),
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(6, 6, 6, 7),
                  child: Text(
                    'please, tell me more!',
                    style: SuperStyle.sans(size: 20, weight: 300, extraBold: true),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ColorSpaceInfo extends StatefulWidget {
  const _ColorSpaceInfo();

  @override
  State<_ColorSpaceInfo> createState() => _ColorSpaceInfoState();
}

class _ColorSpaceInfoState extends State<_ColorSpaceInfo> {
  bool mindBlown = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (!mindBlown)
          SuperRichText(
            pad: false,
            style: SuperStyle.sans(size: min(20, context.screenWidth / 24)),
            const [
              TextSpan(text: 'In an ideal world, '),
              TextSpan(
                text: 'cyan',
                style: SuperStyle.sans(
                  weight: 600,
                  color: SuperColors.cyan,
                  shadows: [
                    Shadow(color: Colors.black38, blurRadius: 2),
                  ],
                ),
              ),
              TextSpan(text: ' ink would absorb all '),
              ColorTextSpan.red,
              TextSpan(text: ' light and reflect all '),
              TextSpan(
                text: 'green',
                style: SuperStyle.sans(
                  weight: 600,
                  color: SuperColors.green,
                  shadows: [
                    Shadow(color: Colors.black38, blurRadius: 2),
                  ],
                ),
              ),
              TextSpan(text: ' & '),
              ColorTextSpan.blue,
              TextSpan(text: ' light.'),
            ],
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: SuperText(
            mindBlown
                ? 'And I don\'t fully understand this, '
                    'but there are other color spaces '
                    'that claim to be even more vibrant than standard RGB:'
                : "But ink isn't 100% perfect, "
                    'so there are some colors in the standard RGB color space '
                    "that printers can't quite replicate.",
            style: SuperStyle.sans(size: min(20, context.screenWidth / 24)),
          ),
        ),
        if (mindBlown)
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(mindBlown ? 20 : 0),
              child: const Image(image: AssetImage('assets/color_spaces.png')),
            ),
          )
        else
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: SuperContainer(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [...SuperColors.allPrimaries, SuperColors.red],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: SuperText(
                      'RGB',
                      style: SuperStyle.sans(weight: 800, size: context.screenWidth / 10),
                    ),
                  ),
                ),
                Expanded(
                  child: SuperContainer(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          SuperColor(0xEC1C24),
                          SuperColor(0xFFF100),
                          SuperColor(0x00A550),
                          SuperColor(0x00ADEE),
                          SuperColor(0x2E3092),
                          SuperColor(0xEB008B),
                          SuperColor(0xEC1C24),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: SuperText(
                      'CMYK',
                      style: SuperStyle.sans(weight: 800, size: context.screenWidth / 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (mindBlown)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: SizedBox(
              height: 30,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black54,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                ),
                onPressed: () => gotoWebsite(
                  'https://en.wikipedia.org/wiki/File:CIE1931xy_gamut_comparison_of_sRGB_P3_Rec2020.svg',
                ),
                child: SuperText(
                  'tap here for image source',
                  style: SuperStyle.sans(
                    size: min(20, context.screenWidth / 32),
                    width: 96,
                    extraBold: true,
                    weight: 300,
                    height: 2,
                  ),
                ),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ContinueButton(onPressed: () => setState(() => mindBlown = true)),
          ),
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
      'Flutter': 'https://flutter.dev/games',
      'Defold': 'https://defold.com/',
      'Bevy': 'https://bevyengine.org/',
      'Rive': 'https://rive.app/',
    };
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final MapEntry(key: name, value: url) in links.entries)
              SuperContainer(
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: const SuperColor(0x20FFF0),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  onPressed: () => gotoWebsite(url),
                  child: name == 'hueman'
                      ? const Text.rich(TextSpan(children: [
                          TextSpan(
                            text: 'HUE',
                            style: SuperStyle.sans(
                              size: 10,
                              weight: 800,
                              extraBold: true,
                              height: 2,
                            ),
                          ),
                          TextSpan(text: 'man', style: SuperStyle.sans(size: 14)),
                        ]))
                      : Text(name, style: const SuperStyle.sans(height: 2)),
                ),
              )
          ],
        ),
      ),
    );
  }
}
