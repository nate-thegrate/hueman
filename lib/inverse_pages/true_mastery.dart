import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:super_hueman/pages/score.dart';
import 'package:super_hueman/pages/thanks_for_playing.dart';
import 'package:super_hueman/save_data.dart';
import 'package:super_hueman/structs.dart';
import 'package:super_hueman/widgets.dart';

const _errorRecoveryText = '''\
DIV_0 ERROR


rebuilding window

(_) => Navigator.pushReplacement<void, void>(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const ThanksForPlaying(),
        ),
      );''';

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
  Widget get finalDetails {
    String scoreDesc = '$_maxRounds rounds, total score = ${score.toStringAsFixed(1)}';
    if (superCount > 0) {
      scoreDesc += '\n\u00d7${superCount + 1} bonus! '
          '($superCount s\u1d1cᴘᴇʀscore${superCount > 1 ? "s" : ""})';
    }
    return Text(
      scoreDesc,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 18, color: Colors.black54),
    );
  }

  @override
  Widget get finalScore => Text(
        (score * (superCount + 1)).toStringAsFixed(1),
        style: const TextStyle(fontSize: 32),
      );

  @override
  Widget get midRoundDisplay {
    String text = 'round ${round + 1}/$_maxRounds\nscore: ${score.toStringAsFixed(1)}';
    if (superCount > 0) text += ', $superCount sᴜᴘᴇʀscore${superCount > 1 ? 's' : ''}!';

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(text, textAlign: TextAlign.center),
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

  @override
  Widget build(BuildContext context) => Theme(
        data: ThemeData(useMaterial3: true),
        child: Scaffold(
          body: Center(
            child: Column(
              children: [
                const Spacer(),
                const GoBack(),
                const Spacer(flex: 3),
                Container(
                  decoration: const BoxDecoration(
                      color: SuperColors.lightBackground,
                      borderRadius: BorderRadiusDirectional.only(
                          topStart: Radius.circular(50), topEnd: Radius.circular(50))),
                  padding: const EdgeInsets.fromLTRB(30, 60, 30, 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RGBSlider(
                            'red',
                            r,
                            onChanged: (value) => setState(() => r = value.toInt()),
                          ),
                          RGBSlider(
                            'green',
                            g,
                            onChanged: (value) => setState(() => g = value.toInt()),
                          ),
                          RGBSlider(
                            'blue',
                            b,
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
                            style: TextStyle(fontFamily: 'Consolas', fontSize: 20),
                          ),
                          const FixedSpacer.horizontal(10),
                          TextButton(
                            style: TextButton.styleFrom(foregroundColor: Colors.black),
                            onPressed: ManualColorCode.run(
                              context,
                              color: color,
                              updateColor: updateUserColor,
                            ),
                            child: Text(
                              userColorCode,
                              style: const TextStyle(fontFamily: 'Consolas', fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                      const FixedSpacer(30),
                      ElevatedButton(
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) => TrueMasteryScore(guess: userColor, actual: color),
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
                          padding: EdgeInsets.only(bottom: 4),
                          child: Text('submit', style: TextStyle(fontSize: 24)),
                        ),
                      ),
                      scoreKeeper == null ? empty : scoreKeeper!.midRoundDisplay,
                    ],
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: color,
        ),
      );
}

class RGBSlider extends StatelessWidget {
  final String name;
  final int value;
  final ValueChanged<double> onChanged;
  const RGBSlider(this.name, this.value, {required this.onChanged, super.key});

  @override
  Widget build(BuildContext context) {
    final SuperColor color = {
      'red': SuperColor.rgb(value, 0, 0),
      'green': SuperColor.rgb(0, value, 0),
      'blue': SuperColor.rgb(0, 0, value),
    }[name]!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RotatedBox(
          quarterTurns: 3,
          child: SizedBox(
            width: context.screenHeight - 500,
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
        Container(
          width: 125,
          alignment: Alignment.center,
          child: Text('$name:  $value', style: Theme.of(context).textTheme.titleMedium),
        ),
      ],
    );
  }
}

class TrueMasteryScore extends StatefulWidget {
  final SuperColor guess, actual;
  const TrueMasteryScore({required this.guess, required this.actual, super.key});

  @override
  State<TrueMasteryScore> createState() => _TrueMasteryScoreState();
}

class _TrueMasteryScoreState extends State<TrueMasteryScore> {
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
    await sleep(4);
    setState(() => perfectScoreOverlay = Text(
          '9' * 10000,
          style: const TextStyle(
            color: Colors.black,
            fontFamily: 'Segoe UI',
            fontSize: 16.0,
            fontWeight: FontWeight.w400,
            decoration: TextDecoration.none,
          ),
        ));
    await sleep(2);
    setState(() => showFlicker = true);
    ticker!.start();
    await sleep(3);
    ticker!.stop();
    setState(() {
      showFlicker = false;
      perfectScoreOverlay = const _ErrorScreen('DIV_0 ERROR');
    });
    await sleep(4);
    setState(() => perfectScoreOverlay = const _ErrorScreen(_errorRecoveryText));
    await sleep(6);
  }

  @override
  void initState() {
    super.initState();

    thisRoundScore = 765 / offBy;
    thisRoundSuperCount = 0;
    for (final val in [
      guess.red == actual.red,
      guess.green == actual.green,
      guess.blue == actual.blue,
    ]) {
      if (val) thisRoundSuperCount++;
    }

    if (offBy == 0) {
      ticker = Ticker((_) => setState(() => flickerValue = !flickerValue));
      perfectScore().then((_) => Navigator.pushReplacement<void, void>(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const ThanksForPlaying(),
            ),
          ));
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

  late final List<DataRow> rows = [
    DataRow(cells: [
      const DataCell(Center(child: Text('guess', style: TextStyle(fontWeight: FontWeight.w600)))),
      DataCell(_Base10PlusHex(guess.red)),
      DataCell(_Base10PlusHex(guess.green)),
      DataCell(_Base10PlusHex(guess.blue)),
    ]),
    DataRow(cells: [
      const DataCell(
          Center(child: Text('actual', style: TextStyle(fontWeight: FontWeight.w600)))),
      DataCell(_Base10PlusHex(actual.red)),
      DataCell(_Base10PlusHex(actual.green)),
      DataCell(_Base10PlusHex(actual.blue)),
    ]),
    DataRow(cells: [
      const DataCell(
          Center(child: Text('difference', style: TextStyle(fontWeight: FontWeight.w600)))),
      DataCell(Text(redOffBy.toString())),
      DataCell(Text(greenOffBy.toString())),
      DataCell(Text(blueOffBy.toString())),
    ]),
  ];

  static const List<DataColumn> columns = [
    DataColumn(label: empty),
    DataColumn(label: _TableHeader('red')),
    DataColumn(label: _TableHeader('green')),
    DataColumn(label: _TableHeader('blue')),
  ];

  DataCell matchPercent(int offBy) => DataCell(
        offBy == 0
            ? Text(
                '100%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: inverseColor,
                  fontSize: 18,
                  shadows: [
                    for (double i = 0.5; i <= 3; i += 0.5)
                      Shadow(blurRadius: i, color: Colors.white),
                  ],
                ),
              )
            : Text('${(100 * (1 - offBy / 256)).toStringAsFixed(2)}%'),
      );

  static const scoreFormula = Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        '3 \u00d7 0xFF',
        style: TextStyle(fontFamily: 'Consolas', height: 0.5),
      ),
      SizedBox(
        width: 110,
        child: Divider(thickness: 1, color: Colors.black),
      ),
      Text(
        'total difference',
        style: TextStyle(height: 0.5, fontStyle: FontStyle.italic),
      ),
    ],
  );

  static const equals = Text(' = ', style: TextStyle(fontSize: 18, height: -0.2));

  @override
  Widget build(BuildContext context) => Theme(
        data: ThemeData(useMaterial3: true),
        child: Stack(
          children: [
            AlertDialog(
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
                    columnSpacing: 35,
                    columns: columns,
                    rows: [
                      ...rows,
                      DataRow(cells: [
                        const DataCell(Center(
                            child:
                                Text('match %', style: TextStyle(fontWeight: FontWeight.w600)))),
                        matchPercent(redOffBy),
                        matchPercent(greenOffBy),
                        matchPercent(blueOffBy),
                      ]),
                    ],
                  ),
                  const FixedSpacer(30),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('score:', style: TextStyle(fontSize: 18)),
                      const FixedSpacer.horizontal(10),
                      scoreFormula,
                      equals,
                      Column(
                        children: [
                          const Text('765'),
                          Container(
                            decoration: const BoxDecoration(border: Border(top: BorderSide())),
                            padding: const EdgeInsets.fromLTRB(5, 3, 5, 0),
                            margin: const EdgeInsets.only(top: 3),
                            child: Text('$redOffBy + $blueOffBy + $greenOffBy'),
                          ),
                        ],
                      ),
                      equals,
                      offBy == 0
                          ? empty
                          : Text(
                              thisRoundScore.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 18, height: -0.15),
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

class _ScoreTitle extends StatefulWidget {
  final bool isGuess;
  final SuperColor color;
  const _ScoreTitle.guess(this.color) : isGuess = true;
  const _ScoreTitle.actual(this.color) : isGuess = false;

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

    sleep(0.1).then((value) => setState(() => expanded = true));
  }

  late final Widget text = Align(
    alignment: Alignment.centerLeft,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.only(left: 50),
        child: Text(
          '$label: ${widget.color.hexCode}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Consolas',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: contrastWith(widget.color).withAlpha(0xCC),
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 450,
      child: Align(
        alignment: widget.isGuess ? Alignment.centerLeft : Alignment.centerRight,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: curve,
          width: expanded ? 407 : 0,
          height: 50,
          decoration: decoration,
          child: text,
        ),
      ),
    );
  }
}

class _Flicker extends StatelessWidget {
  final bool flickerValue;
  final SuperColor color;
  const _Flicker(this.flickerValue, this.color);

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints.expand(),
        alignment: const Alignment(1, -.4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(width: context.screenWidth, height: 1, color: color),
            Container(width: context.screenWidth * .75, height: 2, color: color),
            const FixedSpacer(4),
            Container(
              width: context.screenWidth * 2 / 3,
              height: 2,
              color: flickerValue ? color : null,
            ),
            const FixedSpacer(3),
            Container(width: context.screenWidth / 2, height: 2, color: color),
            const FixedSpacer(10),
            Container(
              height: 5,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                border: Border.symmetric(
                  vertical: BorderSide(color: SuperColors.lightBackground, width: 300),
                ),
              ),
              child: empty,
            ),
            Container(
              width: context.screenWidth / 2,
              height: 3,
              color: SuperColors.lightBackground,
            ),
            const FixedSpacer(10),
            Container(
              height: 3,
              padding: const EdgeInsets.symmetric(horizontal: 40),
              decoration: const BoxDecoration(
                border: Border.symmetric(
                  vertical: BorderSide(color: SuperColors.lightBackground, width: 250),
                ),
              ),
              child: empty,
            ),
          ],
        ),
      );
}

class _TableHeader extends StatelessWidget {
  final String text;
  const _TableHeader(this.text);

  @override
  Widget build(BuildContext context) => SizedBox(width: 60, child: Center(child: Text(text)));
}

class _ErrorScreen extends StatelessWidget {
  final String text;
  const _ErrorScreen(this.text);

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: SuperColors.blue,
        body: Padding(
          padding: EdgeInsets.all(context.screenWidth / 16),
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
}

class _Base10PlusHex extends StatelessWidget {
  final int value;
  const _Base10PlusHex(this.value);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(value.toString()),
          Text(
            ' (0x${value.toRadixString(16).padLeft(2, "0").toUpperCase()})',
            style: const TextStyle(fontFamily: 'Consolas', fontSize: 12),
          ),
        ],
      );
}
