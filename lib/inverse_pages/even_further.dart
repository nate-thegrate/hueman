import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
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
  late final List<Topic> topics;

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
    if (showK) {
      musicPlayer.play(AssetSource('audio/the_end_approaches.mp3'));
    } else if (!Tutorial.worldEnd()) {
      theEndApproaches = true;
    }
    topics = [
      const Topic(
        name: 'high\nscores',
        defaultColor: Color(0xCCFFAAFF),
        details: _HighScores(),
      ),
      const Topic(
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
      if (Tutorial.dawnOfSummer())
        const Topic(
          name: 'blend\nmodes',
          defaultColor: Color(0x80808080),
          accentColor: SuperColors.white80,
          details: _BlendModes(),
        )
      else
        const Topic(
          name: 'chartreuse',
          defaultColor: SuperColors.chartreuse,
          details: _ChartreuseSucks(),
        ),
      const Topic(
        name: 'color\nspaces',
        defaultColor: Colors.white54,
        accentColor: Colors.black54,
        details: _ColorSpaceInfo(),
      ),
      const Topic(
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
      if (showK)
        const Topic(
          name: 'the\nend',
          defaultColor: SuperColors.k,
          details: K_glitch.destroyer(),
        )
      else
        const Topic(
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
                  TextSpan(
                      text: ' all your progress, so you can play through the tutorials again.'),
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
    ];
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
    for (final (i, Topic(:name, :defaultColor, :accentColor)) in topics.indexed) {
      bool selected() => i == selectedTopic;
      bool somethingElseSelected() => selectedTopic != null && !selected();
      void select() {
        if (showK && i == 5) {
          if (selected()) return;
          playMusic(once: 'the_end_arrives');
        }
        setState(selected() ? deselect : () => selectedTopic = i);
      }

      final accent = accentColor ?? contrastWith(defaultColor);
      final sine = funSine(i);
      buttons.add(
        Fader(
          !somethingElseSelected(),
          duration: quarterSec,
          child: SlideItIn(
            buttonsInPlace > i,
            direction: i % 2 == 0 ? AxisDirection.right : AxisDirection.left,
            duration: const Duration(seconds: 2),
            child: AnimatedAlign(
              duration: quarterSec,
              curve: Curves.easeOutQuart,
              alignment: selected()
                  ? Alignment.topCenter
                  : Alignment(i % 2 - .5, (i + .6) / topics.length * 2 - 1),
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
                          decoration: BoxDecoration(shape: BoxShape.circle, color: defaultColor),
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
    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(brightness: Brightness.light, useMaterial3: true),
      child: GestureDetector(
        onTap: selectedTopic == 5 && showK ? null : () => setState(deselect),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeLayout((context, constraints) {
            return Center(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  const Balls(),
                  if (Tutorial.tensed() && !Tutorial.dawnOfSummer())
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          elevation: 0,
                        ),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('no more "chartreuse".'),
                            content: const Text(
                              "Take a look at the chartreuse bubble one last time, if you'd like.",
                            ),
                            actions: [
                              const WarnButton(),
                              WarnButton(
                                action: () => context.noTransition(const _DawnOfSummer()),
                              ),
                            ],
                            actionsAlignment: MainAxisAlignment.spaceEvenly,
                          ),
                        ),
                        child: const Text(
                          'no more chartreuse',
                          style: SuperStyle.sans(extraBold: true),
                        ),
                      ),
                    ),
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
                    style: linkStyle,
                    recognizer: hyperlink(
                      'https://en.wikipedia.org/w/index.php?title=Shades_of_chartreuse&oldid=1184863956',
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'tertiary color',
                    style: linkStyle,
                    recognizer: hyperlink(
                      'https://en.wikipedia.org/w/index.php?title=Tertiary_color&oldid=1182085196#RGB_or_CMYK_primary,_secondary,_and_tertiary_colors',
                    ),
                  ),
                  const TextSpan(text: '.\n\n'),
                  const TextSpan(text: 'But the main '),
                  TextSpan(
                    text: 'chartreuse',
                    style: linkStyle,
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
                    style: linkStyle,
                    recognizer: hyperlink(
                      'https://en.wikipedia.org/wiki/Chartreuse_(liqueur)',
                    ),
                  ),
                  const TextSpan(text: ' with the same name).\n\n'),
                  const TextSpan(text: 'And on the '),
                  TextSpan(
                    text: 'color term',
                    style: linkStyle,
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
                    style: linkStyle,
                    recognizer:
                        hyperlink('https://en.wikipedia.org/wiki/File:RGB_color_wheel.svg'),
                  ),
                  const TextSpan(text: ' on that page, but its name is "chartreuse green".\n\n'),
                  const TextSpan(text: 'That color wheel is also shown on the '),
                  TextSpan(
                    text: 'tertiary color',
                    style: linkStyle,
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

class _BlendModes extends StatelessWidget {
  const _BlendModes();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Image(image: AssetImage('assets/blend_modes.png')),
        Expanded(
          child: LayoutBuilder(builder: (context, constraints) {
            return SuperRichText(
              align: TextAlign.left,
              style: SuperStyle.sans(size: min(constraints.maxWidth / 16, 20)),
              [
                const TextSpan(text: 'If you open a picture in '),
                TextSpan(
                  text: 'Photoshop',
                  style: linkStyle,
                  recognizer: hyperlink('https://www.adobe.com/products/photoshop.html'),
                ),
                const TextSpan(text: ', '),
                TextSpan(
                  text: 'Photopea',
                  style: linkStyle,
                  recognizer: hyperlink('https://www.photopea.com/'),
                ),
                const TextSpan(text: ' (my favorite), or '),
                TextSpan(
                  text: 'GIMP',
                  style: linkStyle,
                  recognizer: hyperlink('https://www.gimp.org/'),
                ),
                const TextSpan(
                  text: ' (a great open-source option!), '
                      'you can find a bunch of different ways to blend layers together.\n\n'
                      'If you click ',
                ),
                const TextSpan(
                  text: 'Multiply',
                  style: SuperStyle.sans(
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 2)],
                  ),
                ),
                const TextSpan(text: ', you can do subtractive mixing, and '),
                const TextSpan(
                  text: 'Screen',
                  style: SuperStyle.sans(
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 2)],
                  ),
                ),
                const TextSpan(
                  text: ' will let you do additive mixing.\n\n'
                      "At some point, maybe I'll figure out what all those other options do too.",
                ),
              ],
            );
          }),
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

extension _ASCII on Random {
  String get nextAscii => String.fromCharCode(nextInt(94) + 33);
}

class _DawnOfSummer extends StatefulWidget {
  const _DawnOfSummer();

  @override
  State<_DawnOfSummer> createState() => _DawnOfSummerState();
}

class _DawnOfSummerState extends SuperState<_DawnOfSummer> {
  String name = '"chartreuse"';
  static const newName = '   summer   ';

  void updateName(int index, String value) =>
      setState(() => name = name.substring(0, index) + value + name.substring(index + 1));

  int textProgress = 0;

  @override
  void animate() async {
    musicPlayer.stop();
    for (final (_, sleepyTime) in text) {
      await sleepState(sleepyTime, () => textProgress++);
    }
    for (double sleepyTime = 2 / 3; sleepyTime > 0.01; sleepyTime *= 0.9) {
      await sleep(sleepyTime);
      updateName(rng.nextInt(12), rng.nextAscii);
    }
    for (int i = 0; i < 500; i++) {
      await sleep(0.01);
      updateName(rng.nextInt(12), rng.nextAscii);
    }
    final indices = List.generate(12, (index) => index)..shuffle();
    for (final i in indices) {
      await sleep(0.01);
      updateName(i, newName[i]);
    }
    await sleep(0.1);
    context.noTransition(const _ShowTheWheelAgain());
  }

  static const List<(Widget line, double timeToRead)> text = [
    (
      SuperRichText([
        TextSpan(text: "Let's take "),
        ColorTextSpan.green,
      ]),
      5
    ),
    (
      SuperRichText([
        TextSpan(text: 'and make it just a little bit '),
        ColorTextSpan.yellow,
        TextSpan(text: '.'),
      ]),
      2
    ),
    (Spacer(), 2),
    (SuperText('How do we describe this color?'), 2),
    (Spacer(), 2),
    (SuperText('We could use its color code'), 3.5),
    (SuperText('or its hue,'), 5),
    (SuperText('or we could make a new name for it.'), 1.5),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeIn(
        duration: const Duration(seconds: 2),
        child: Center(
          child: Column(
            children: [
              const Spacer(flex: 2),
              for (int i = 0; i < text.length; i++)
                switch (text[i].$1) {
                  final Spacer s => s,
                  _ => Fader(i <= textProgress, child: text[i].$1),
                },
              const Spacer(),
              Expanded(
                  flex: 4,
                  child: FittedBox(
                    child: SizedBox(
                      width: 500,
                      height: 300,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const SuperContainer(color: SuperColors.green),
                          Fader(
                            textProgress > 0,
                            curve: curve,
                            child: AnimatedSlide(
                              duration: halfSec,
                              offset: textProgress > 1 ? Offset.zero : const Offset(0, -1),
                              curve: Curves.easeInQuad,
                              child: Align(
                                alignment: Alignment.center,
                                child: AnimatedSize(
                                  duration: const Duration(seconds: 3),
                                  curve: curve,
                                  child: Opacity(
                                    opacity: 0.5,
                                    child: SuperContainer(
                                      width: textProgress > 2 ? 500 : 250,
                                      color: SuperColors.yellow,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Fader(
                                textProgress > 4,
                                child: const SuperRichText(
                                  style: SuperStyle.mono(size: 40, color: Colors.black),
                                  [
                                    TextSpan(
                                      text: '#',
                                      style: SuperStyle.mono(weight: 700),
                                    ),
                                    TextSpan(
                                      text: '80',
                                      style: SuperStyle.mono(
                                        weight: 500,
                                        color: SuperColor(0x800000),
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'FF',
                                      style: SuperStyle.mono(
                                        weight: 500,
                                        color: SuperColors.green,
                                        shadows: [
                                          Shadow(blurRadius: 1),
                                          Shadow(color: SuperColor(0x808000), blurRadius: 1),
                                        ],
                                      ),
                                    ),
                                    TextSpan(
                                      text: '00',
                                      style: SuperStyle.mono(weight: 500),
                                    ),
                                  ],
                                ),
                              ),
                              const FixedSpacer(15),
                              Fader(
                                textProgress > 5,
                                child: const SuperText(
                                  '90°',
                                  style: SuperStyle.sans(
                                    size: 45,
                                    color: Colors.black,
                                    extraBold: true,
                                  ),
                                ),
                              ),
                              Fader(
                                textProgress > 6,
                                child: Text(
                                  name,
                                  style: const SuperStyle.mono(
                                    size: 64,
                                    color: Colors.black,
                                    extraBold: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}

class _ShowTheWheelAgain extends StatefulWidget {
  const _ShowTheWheelAgain();

  @override
  State<_ShowTheWheelAgain> createState() => _ShowTheWheelAgainState();
}

class _ShowTheWheelAgainState extends SuperState<_ShowTheWheelAgain> {
  late final Ticker animateHue;
  int step = 0;
  double hue = 0;
  static const duration = Duration(seconds: 3);

  void smoothHue(Duration elapsed) {
    final double t, newHue;
    t = min(elapsed.inMilliseconds / duration.inMilliseconds, 1);
    newHue = 90 * curve.transform(t);
    setState(() => hue = newHue);

    if (t == 1) animateHue.dispose();
  }

  @override
  void animate() async {
    const List<double> sleepyTime = [3, 3, 1, 5, 3, 1, 2, 1];
    for (final time in sleepyTime) {
      await sleepState(time, () => step++);
      if (step == 4) animateHue = Ticker(smoothHue)..start();
    }

    await sleep(1.5);
    await Tutorial.dawnOfSummer.complete();
    inverted = false;
    context.invert();
  }

  static const step1 = 'Step 1: Find a color wheel.';
  static const step2 = 'Step 2: Measure the angle to your color, starting at red.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeLayout((context, constraints) {
        final width = constraints.calcSize((w, h) => min(w * 0.8, h * 0.8 - 250));
        return Column(
          children: [
            const Spacer(flex: 4),
            const SuperText(step1),
            const Spacer(),
            Fader(step >= 2, child: const SuperText(step2)),
            const Spacer(flex: 4),
            Stack(
              alignment: Alignment.center,
              children: [
                MeasuringOrb(
                  step: step,
                  width: width,
                  duration: duration,
                  hue: 90,
                  lineColor: Colors.black,
                ),
                Fader(
                  step >= 6,
                  duration: const Duration(seconds: 2),
                  child: AnimatedScale(
                    duration: const Duration(seconds: 2),
                    scale: step >= 7 ? 5 : 1,
                    curve: Curves.easeInExpo,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 1500),
                      width: width,
                      height: width,
                      decoration: BoxDecoration(
                        color: step >= 7 ? SuperColors.lightBackground : SuperColors.chartreuse,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(flex: 4),
            Fader(step < 7, child: _HueBox(step: step, width: width, hue: hue.ceil())),
            const Spacer(flex: 4),
          ],
        );
      }),
      backgroundColor: Colors.black,
    );
  }
}

class _HueBox extends StatelessWidget {
  const _HueBox({
    required this.step,
    required this.width,
    required this.hue,
  });
  final int step;
  final double width;
  final int hue;

  @override
  Widget build(BuildContext context) {
    final color = SuperColor.hue(hue);

    return SuperContainer(
      height: width / 4,
      alignment: Alignment.center,
      child: Fader(
        step >= 2,
        duration: const Duration(milliseconds: 400),
        child: SexyBox(
          child: SuperContainer(
            width: step < 2 ? 20 : width,
            color: color,
            padding: EdgeInsets.all(width / 48),
            child: SexyBox(
              child: step < 3
                  ? empty
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SexyBox(
                          child: step < 6
                              ? const SizedBox(height: 75)
                              : SizedBox(
                                  width: width / 2,
                                  child: Center(
                                    child: Text(
                                      'summer',
                                      style: SuperStyle.sans(
                                        color: Colors.black,
                                        size: width * 0.0667,
                                        weight: 800,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                        Expanded(
                          child: SuperContainer(
                            color: SuperColors.darkBackground,
                            alignment: Alignment.center,
                            child: Text(
                              'hue = $hue',
                              style: SuperStyle.sans(color: color, size: width * 0.06),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
