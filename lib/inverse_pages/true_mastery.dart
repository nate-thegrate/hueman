import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hueman/data/page_data.dart';
import 'package:hueman/data/super_color.dart';
import 'package:hueman/data/super_container.dart';
import 'package:hueman/data/super_state.dart';
import 'package:hueman/data/super_text.dart';
import 'package:hueman/pages/score.dart';
import 'package:hueman/tutorial_pages/game_end.dart';
import 'package:hueman/data/save_data.dart';
import 'package:hueman/data/structs.dart';
import 'package:hueman/data/widgets.dart';

class TrueMasteryScoreKeeper implements ScoreKeeper {
  TrueMasteryScoreKeeper();

  int round = 0;
  static const int _maxRounds = 10;
  double score = 0;
  int superCount = 0;

  @override
  void roundCheck(BuildContext context) => (round == _maxRounds - 1)
      ? Navigator.pushReplacement(
          context, MaterialPageRoute<void>(builder: (context) => ScoreScreen(this)))
      : round++;

  @override
  void scoreTheRound() {
    score += thisRoundScore;
    superCount += thisRoundSuperCount;
  }

  @override
  String get finalDetails {
    final String scoreDesc = '$_maxRounds rounds, total score = ${score.toStringAsFixed(1)}';
    if (superCount == 0) return scoreDesc;
    return '$scoreDesc\n'
        '\u00d7${superCount + 1} bonus! '
        '($superCount superscore${superCount > 1 ? "s" : ""})';
  }

  @override
  int get scoreVal => (score * (superCount + 1)).round();

  @override
  Widget get midRoundDisplay {
    String text = 'round ${round + 1}/$_maxRounds\nscore: ${score.toStringAsFixed(1)}';
    if (superCount > 0) text += ', $superCount superscore${superCount > 1 ? 's' : ''}!';

    return SuperContainer(
      width: 150,
      height: 75,
      alignment: Alignment.bottomCenter,
      child: SuperText(text, pad: false, style: const SuperStyle.sans()),
    );
  }

  @override
  final Pages page = Pages.trueMastery;
}

late double thisRoundScore;
late int thisRoundSuperCount;

class TrueMastery extends StatefulWidget {
  const TrueMastery({super.key});

  @override
  State<TrueMastery> createState() => _TrueMasteryState();
}

class _TrueMasteryState extends State<TrueMastery> {
  late int r, g, b, colorCode;

  SuperColor get color => SuperColor(colorCode);

  void updateUserColor(SuperColor colorFromHex) => setState(() {
        r = colorFromHex.red;
        g = colorFromHex.green;
        b = colorFromHex.blue;
      });
  void nextColor() {
    setState(() => colorCode = rng.nextInt(0xFFFFFF + 1));
    updateUserColor(SuperColors.black);
  }

  SuperColor get userColor => SuperColor.rgb(r, g, b);
  String get userColorCode => userColor.hexCode;

  late final TrueMasteryScoreKeeper? scoreKeeper;

  @override
  void initState() {
    super.initState();
    inverted = true;

    scoreKeeper = casualMode ? null : TrueMasteryScoreKeeper();
    nextColor();
  }

  bool giveHint = false;

  @override
  Widget build(BuildContext context) {
    // ignore: avoid_print
    if (casualMode) print(color);

    return Theme(
      data: ThemeData(useMaterial3: true, fontFamily: 'nunito sans'),
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: LayoutBuilder(builder: (context, constraints) {
            return Center(
              child: Column(
                children: [
                  const Spacer(),
                  const GoBack(),
                  const Spacer(),
                  SuperContainer(
                    decoration: const BoxDecoration(
                        color: SuperColors.lightBackground,
                        borderRadius: BorderRadiusDirectional.only(
                            topStart: Radius.circular(64), topEnd: Radius.circular(64))),
                    padding: const EdgeInsets.fromLTRB(30, 45, 30, 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _RGBSlider(
                              'red',
                              r,
                              constraints: constraints,
                              giveHint ? '${color.red}' : r.hexByte,
                              onChanged: (value) => setState(() => r = value.toInt()),
                            ),
                            _RGBSlider(
                              'green',
                              g,
                              constraints: constraints,
                              giveHint ? '${color.green}' : g.hexByte,
                              onChanged: (value) => setState(() => g = value.toInt()),
                            ),
                            _RGBSlider(
                              'blue',
                              b,
                              constraints: constraints,
                              giveHint ? '${color.blue}' : b.hexByte,
                              onChanged: (value) => setState(() => b = value.toInt()),
                            ),
                          ],
                        ),
                        const FixedSpacer(50),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'color code:',
                              style: SuperStyle.mono(size: 20),
                            ),
                            SizedBox(
                              height: 33,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                ),
                                onPressed: () {
                                  if (casualMode) setState(() => giveHint = true);
                                  ManualColorCode.run(
                                    context,
                                    color: color,
                                    updateColor: updateUserColor,
                                  ).then((_) {
                                    if (casualMode) setState(() => giveHint = false);
                                  });
                                },
                                child: Text(
                                  userColorCode,
                                  style: const SuperStyle.mono(size: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const FixedSpacer(30),
                        ElevatedButton(
                          onPressed: () => showDialog(
                            context: context,
                            builder: (context) =>
                                TrueMasteryScore(guess: userColor, actual: color),
                            barrierDismissible: userColor.colorCode != color.colorCode,
                          ).then((_) {
                            scoreKeeper?.scoreTheRound();
                            scoreKeeper?.roundCheck(context);
                            setState(nextColor);
                          }),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            foregroundColor: contrastWith(color),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.only(bottom: 1),
                            child: Text('submit', style: SuperStyle.sans(size: 24)),
                          ),
                        ),
                        scoreKeeper == null ? empty : scoreKeeper!.midRoundDisplay,
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        backgroundColor: color,
      ),
    );
  }
}

extension _Scale on BuildContext {
  double get scale => min((screenWidth - 100) / 350, 1);
}

class TrueMasteryScore extends StatefulWidget {
  const TrueMasteryScore({required this.guess, required this.actual, super.key});
  final SuperColor guess, actual;

  @override
  State<TrueMasteryScore> createState() => _TrueMasteryScoreState();
}

class _TrueMasteryScoreState extends SuperState<TrueMasteryScore> {
  late final guess = widget.guess, actual = widget.actual;

  late final redOffBy = diff(guess.red, actual.red);
  late final greenOffBy = diff(guess.green, actual.green);
  late final blueOffBy = diff(guess.blue, actual.blue);
  late final offBy = redOffBy + greenOffBy + blueOffBy;

  late final Ticker? ticker;

  Widget perfectScoreOverlay = empty;

  bool showFlicker = false;

  /// alternates between `true` and `false` to make a rapid glitchy flicker :)
  bool flickerValue = false;

  Future<void> perfectScore() async {
    await sleepState(0.5, () => showFlicker = true);
    ticker!.start();
    await sleep(1.5);
    ticker!.stop();
    context.noTransition(const _ErrorScreen());
  }

  @override
  void initState() {
    super.initState();

    thisRoundScore = 765 / offBy;
    thisRoundSuperCount = 0;
    for (final perfecto in [
      guess.red == actual.red,
      guess.green == actual.green,
      guess.blue == actual.blue,
    ]) {
      if (perfecto) thisRoundSuperCount++;
    }

    if (offBy == 0) {
      ticker = Ticker((_) => setState(() => flickerValue = !flickerValue));
      perfectScore();
    } else {
      ticker = guess.red == actual.red || guess.green == actual.green || guess.blue == actual.blue
          ? inverseSetup(setState)
          : null;
    }
  }

  @override
  void dispose() {
    ticker?.dispose();
    super.dispose();
  }

  static const List<DataColumn> columns = [
    DataColumn(label: empty),
    DataColumn(label: _TableHeader('red')),
    DataColumn(label: _TableHeader('green')),
    DataColumn(label: _TableHeader('blue')),
  ];

  DataCell matchPercent(int offBy, double scale) => DataCell(
        Center(
          child: offBy == 0
              ? Text(
                  '100%',
                  style: SuperStyle.sans(
                    weight: 800,
                    color: inverseColor,
                    size: 18 * scale,
                    shadows: [
                      for (double i = 0.5; i <= 3; i += 0.5)
                        Shadow(blurRadius: i, color: Colors.white),
                    ],
                  ),
                )
              : Text(
                  (100 * (1 - offBy / 256)).toStringAsFixed(1),
                  style: SuperStyle.sans(size: 14 * scale),
                ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final double scale = context.scale;

    final equals = Text(' = ', style: SuperStyle.sans(size: 18 * scale, height: -0.2));
    final List<DataRow> rows = [
      DataRow(cells: [
        DataCell(
          Center(
            child: Text(
              'guess',
              style: SuperStyle.sans(size: 14 * scale, weight: 600),
            ),
          ),
        ),
        DataCell(_HexText(guess.red)),
        DataCell(_HexText(guess.green)),
        DataCell(_HexText(guess.blue)),
      ]),
      DataRow(cells: [
        DataCell(
          Center(
            child: Text(
              'true',
              style: SuperStyle.sans(size: 14 * scale, weight: 600),
            ),
          ),
        ),
        DataCell(_HexText(actual.red)),
        DataCell(_HexText(actual.green)),
        DataCell(_HexText(actual.blue)),
      ]),
      DataRow(cells: [
        DataCell(
          Center(
            child: Text(
              'diff',
              style: SuperStyle.sans(size: 14 * scale, weight: 600),
            ),
          ),
        ),
        DataCell(Center(
          child: Text(redOffBy.toString(), style: SuperStyle.sans(size: 14 * scale)),
        )),
        DataCell(Center(
          child: Text(greenOffBy.toString(), style: SuperStyle.sans(size: 14 * scale)),
        )),
        DataCell(Center(
          child: Text(blueOffBy.toString(), style: SuperStyle.sans(size: 14 * scale)),
        )),
      ]),
    ];

    return Theme(
      data: ThemeData(useMaterial3: true, fontFamily: 'nunito sans'),
      child: Stack(
        children: [
          DismissibleDialog(
            surfaceTintColor: Colors.transparent,
            backgroundColor: SuperColors.lightBackground,
            title: Column(children: [
              _ScoreTitle.guess(widget.guess),
              _ScoreTitle.actual(widget.actual),
            ]),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DataTable(
                  columnSpacing: 10 * scale.squared,
                  horizontalMargin: 24 * scale.squared,
                  columns: columns,
                  rows: [
                    ...rows,
                    DataRow(cells: [
                      DataCell(
                        Center(
                          child: Text(
                            'match %',
                            textAlign: TextAlign.center,
                            style: SuperStyle.sans(size: 14 * scale, weight: 600),
                          ),
                        ),
                      ),
                      matchPercent(redOffBy, scale),
                      matchPercent(greenOffBy, scale),
                      matchPercent(blueOffBy, scale),
                    ]),
                  ],
                ),
                const FixedSpacer(30),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('score:', style: SuperStyle.sans(size: 16, width: 87.5)),
                    const FixedSpacer.horizontal(10),
                    Column(
                      children: [
                        const Text(
                          '0xFF \u00d7 3',
                          style: SuperStyle.mono(size: 16, weight: 600),
                        ),
                        SuperContainer(
                          decoration: const BoxDecoration(border: Border(top: BorderSide())),
                          padding: const EdgeInsets.fromLTRB(5, 3, 5, 0),
                          margin: const EdgeInsets.only(top: 3),
                          child: Text(
                            '$redOffBy + $greenOffBy + $blueOffBy',
                            style: const SuperStyle.sans(),
                          ),
                        ),
                      ],
                    ),
                    equals,
                    if (offBy != 0)
                      Text(
                        thisRoundScore.toStringAsFixed(1),
                        style: const SuperStyle.sans(size: 18, height: -0.15),
                      ),
                  ],
                ),
                const FixedSpacer(10),
              ],
            ),
          ),
          perfectScoreOverlay,
          showFlicker ? _Flicker(flickerValue, actual) : empty,
        ],
      ),
    );
  }
}

class _ScoreTitle extends StatefulWidget {
  const _ScoreTitle.guess(this.color) : isGuess = true;
  const _ScoreTitle.actual(this.color) : isGuess = false;
  final bool isGuess;
  final SuperColor color;

  @override
  State<_ScoreTitle> createState() => _ScoreTitleState();
}

class _ScoreTitleState extends State<_ScoreTitle> {
  String get label => widget.isGuess ? 'your guess' : 'actual';
  bool expanded = false;

  late final BoxDecoration decoration;

  @override
  void initState() {
    super.initState();

    bool opaque(int i) => widget.isGuess ? i != 0 : i != 10;
    final Color c = widget.color, clear = c.withAlpha(0);
    const r = Radius.circular(25);
    decoration = BoxDecoration(
      gradient: LinearGradient(colors: [for (int i = 0; i <= 10; i++) opaque(i) ? c : clear]),
      borderRadius: widget.isGuess
          ? const BorderRadius.only(topRight: r, bottomRight: r)
          : const BorderRadius.only(topLeft: r, bottomLeft: r),
    );

    quickly(() => setState(() => expanded = true));
  }

  @override
  Widget build(BuildContext context) {
    final Widget text = Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.only(left: 28),
          child: Text(
            '$label: ${widget.color.hexCode}',
            textAlign: TextAlign.center,
            style: SuperStyle.mono(
              weight: 700,
              size: 16,
              color: contrastWith(widget.color).withAlpha(0xCC),
            ),
          ),
        ),
      ),
    );

    final width = 308 * context.scale;
    return SuperContainer(
      width: width,
      alignment: widget.isGuess ? Alignment.centerLeft : Alignment.centerRight,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: curve,
        width: expanded ? min(width, 271.5) : 0,
        height: 50,
        decoration: decoration,
        child: text,
      ),
    );
  }
}

class _Flicker extends StatelessWidget {
  const _Flicker(this.flickerValue, this.color);
  final bool flickerValue;
  final SuperColor color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(1, -0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Spacer(flex: 2),
          SuperContainer(width: context.screenWidth, height: 1, color: color),
          SuperContainer(width: context.screenWidth * .75, height: 2, color: color),
          const FixedSpacer(4),
          SuperContainer(
            width: double.infinity,
            height: 25,
            color: flickerValue ? color : null,
          ),
          const FixedSpacer(3),
          SuperContainer(width: context.screenWidth / 2, height: 2, color: color),
          const FixedSpacer(10),
          const SuperContainer(
            height: 5,
            padding: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(color: SuperColors.lightBackground, width: 300),
              ),
            ),
            child: empty,
          ),
          SuperContainer(
            width: context.screenWidth / 2,
            height: 3,
            color: SuperColors.lightBackground,
          ),
          const FixedSpacer(10),
          const SuperContainer(
            height: 3,
            padding: EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(color: SuperColors.lightBackground, width: 250),
              ),
            ),
            child: empty,
          ),
          Expanded(
            flex: 3,
            child: FittedBox(
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (int row = 0; row < 15; row++)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int i = 0; i < 33; i++)
                          SuperContainer(
                            width: 10,
                            height: 10,
                            color: switch ((i + row) % 2) {
                              _ when i < row - 5 => null,
                              0 when rng.nextBool() && rng.nextBool() =>
                                SuperColors.darkBackground,
                              1 when rng.nextBool() && rng.nextBool() =>
                                SuperColors.lightBackground,
                              0 => color,
                              _ => null,
                            },
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final scale = context.scale;
    return SizedBox(
      width: 60 * scale,
      child: Center(
        child: Text(text, style: SuperStyle.sans(size: 16 * scale)),
      ),
    );
  }
}

class _ErrorScreen extends StatefulWidget {
  const _ErrorScreen();

  @override
  State<_ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends SuperState<_ErrorScreen> {
  static const errorRecoveryText = ''
      'DIV_0 ERROR\n\n\n'
      'rebuilding window\n\n'
      '(_) => Navigator.pushReplacement<void, void>(\n'
      '        context,\n'
      '        MaterialPageRoute<void>(\n'
      '          builder: (BuildContext context) => const ThanksForPlaying(),\n'
      '        ),\n'
      '      );';

  String text = 'DIV_0 ERROR';

  @override
  void animate() async {
    await sleepState(4, () => text = errorRecoveryText);
    await sleep(6, then: () => context.noTransition(const ThanksForPlaying()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SuperColors.blue,
      body: SafeArea(
        child: SizedBox.expand(
          child: FittedBox(
            alignment: Alignment.topCenter,
            child: SuperContainer(
              margin: const EdgeInsets.all(50),
              width: 500,
              height: 260,
              child: Text(
                text,
                softWrap: false,
                style: const SuperStyle.sans(color: Colors.white, size: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HexText extends StatelessWidget {
  const _HexText(this.value);
  final int value;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        value.hexByte,
        style: SuperStyle.mono(size: 16 * context.scale, weight: 600),
      ),
    );
  }
}

class _RGBSlider extends StatelessWidget {
  const _RGBSlider(
    this.name,
    this.value,
    this.displayValue, {
    required this.constraints,
    required this.onChanged,
  });
  final BoxConstraints constraints;
  final String name, displayValue;
  final int value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final SuperColor color = switch (name) {
      'red' => SuperColor.rgb(value, 0, 0),
      'green' => SuperColor.rgb(0, value, 0),
      'blue' => SuperColor.rgb(0, 0, value),
      _ => throw Error(),
    };

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RotatedBox(
          quarterTurns: 3,
          child: SizedBox(
            width: constraints.maxHeight - (casualMode ? 325 : 400),
            child: SliderTheme(
              data: const SliderThemeData(
                trackHeight: 15,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 15),
              ),
              child: Slider(
                thumbColor: color,
                activeColor: color.withAlpha(0x80),
                inactiveColor: Colors.black12,
                max: 255,
                value: value.toDouble(),
                onChanged: onChanged,
              ),
            ),
          ),
        ),
        SuperContainer(
          width: 80,
          alignment: Alignment.center,
          child: Text(
            displayValue,
            textAlign: TextAlign.center,
            style: const SuperStyle.mono(size: 16, weight: 600),
          ),
        ),
      ],
    );
  }
}
