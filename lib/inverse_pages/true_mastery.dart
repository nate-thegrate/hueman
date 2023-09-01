import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:super_hueman/pages/thanks_for_playing.dart';
import 'package:super_hueman/save_data.dart';
import 'package:super_hueman/structs.dart';
import 'package:super_hueman/widgets.dart';

class TrueMastery extends StatefulWidget {
  const TrueMastery({super.key});

  @override
  State<TrueMastery> createState() => _TrueMasteryState();
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

class _TrueMasteryState extends State<TrueMastery> {
  late int r, g, b, colorCode;

  SuperColor get color => SuperColor.noName(colorCode);

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

  @override
  void initState() {
    super.initState();
    inverted = true;
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
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                TrueMasteryScore(guess: userColor, actual: color),
                            barrierDismissible: userColor.colorCode != color.colorCode,
                          ).then((_) => setState(nextColor));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: contrastWith(color),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Text('submit', style: TextStyle(fontSize: 24)),
                        ),
                      ),
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

class TrueMasteryScore extends StatefulWidget {
  final SuperColor guess, actual;
  const TrueMasteryScore({required this.guess, required this.actual, super.key});

  @override
  State<TrueMasteryScore> createState() => _TrueMasteryScoreState();
}

const errorRecoveryText = '''\
DIV_0 ERROR


rebuilding window

(_) => Navigator.pushReplacement<void, void>(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const ThanksForPlaying(),
        ),
      );''';

class _TrueMasteryScoreState extends State<TrueMasteryScore> {
  late final guess = widget.guess, actual = widget.actual;

  int diff(int a, int b) => (a - b).abs();

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
            // letterSpacing: 0.5,
            // height: 1.5,
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
    setState(() => perfectScoreOverlay = const _ErrorScreen(errorRecoveryText));
    await sleep(6);
  }

  @override
  void initState() {
    super.initState();
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
      const DataCell(Center(child: Text('guess', style: TextStyle(fontWeight: FontWeight.bold)))),
      DataCell(_Base10PlusHex(guess.red)),
      DataCell(_Base10PlusHex(guess.green)),
      DataCell(_Base10PlusHex(guess.blue)),
    ]),
    DataRow(cells: [
      const DataCell(
          Center(child: Text('actual', style: TextStyle(fontWeight: FontWeight.bold)))),
      DataCell(_Base10PlusHex(actual.red)),
      DataCell(_Base10PlusHex(actual.green)),
      DataCell(_Base10PlusHex(actual.blue)),
    ]),
    DataRow(cells: [
      const DataCell(
          Center(child: Text('difference', style: TextStyle(fontWeight: FontWeight.bold)))),
      DataCell(Text(redOffBy.toString())),
      DataCell(Text(greenOffBy.toString())),
      DataCell(Text(blueOffBy.toString())),
    ]),
  ];

  static const List<DataColumn> columns = [
    DataColumn(label: empty),
    DataColumn(label: Text('red')),
    DataColumn(label: Text('green')),
    DataColumn(label: Text('blue')),
  ];

  Widget title(bool isGuess) {
    final String text =
        isGuess ? 'your guess: ${widget.guess.hexCode}' : 'actual: ${widget.actual.hexCode}';
    return Container(
      margin: const EdgeInsets.only(right: 50),
      width: 210,
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: const TextStyle(fontFamily: 'Consolas', fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );
  }

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

  @override
  Widget build(BuildContext context) => Theme(
        data: ThemeData(useMaterial3: true),
        child: Stack(
          children: [
            AlertDialog(
              surfaceTintColor: Colors.transparent,
              backgroundColor: SuperColors.lightBackground,
              title: Column(children: [title(true), title(false)]),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DataTable(columns: columns, rows: [
                    ...rows,
                    DataRow(cells: [
                      const DataCell(Center(
                          child: Text('match %', style: TextStyle(fontWeight: FontWeight.bold)))),
                      matchPercent(redOffBy),
                      matchPercent(greenOffBy),
                      matchPercent(blueOffBy),
                    ]),
                  ]),
                  const FixedSpacer(30),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('score:', style: TextStyle(fontSize: 18)),
                      const FixedSpacer.horizontal(10),
                      const Column(
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
                            style: TextStyle(
                              // fontFamily: 'Consolas',
                              height: 0.5,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      const Text(' = ', style: TextStyle(fontSize: 18, height: -0.2)),
                      Column(
                        children: [
                          const Text('765'),
                          Container(
                            decoration: const BoxDecoration(border: Border(top: BorderSide())),
                            padding: const EdgeInsets.fromLTRB(5, 3, 5, 0),
                            margin: const EdgeInsets.only(top: 3),
                            child: Text(
                              '$redOffBy + $blueOffBy + $greenOffBy',
                            ),
                          ),
                        ],
                      ),
                      const Text(' = ', style: TextStyle(fontSize: 18, height: -0.2)),
                      offBy == 0
                          ? empty
                          : Text(
                              (765 / offBy).toStringAsFixed(1),
                              style: const TextStyle(fontSize: 18, height: -0.15),
                            ),
                    ],
                  ),
                  const FixedSpacer(10),
                ],
              ),
            ),
            perfectScoreOverlay,
            showFlicker
                ? Align(
                    alignment: const Alignment(1, -.4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(width: context.screenWidth, height: 1, color: actual),
                        Container(width: context.screenWidth * .75, height: 2, color: actual),
                        const FixedSpacer(4),
                        Container(
                          width: context.screenWidth * 2 / 3,
                          height: 2,
                          color: flickerValue ? actual : Colors.transparent,
                        ),
                        const FixedSpacer(4),
                        Container(width: context.screenWidth / 2, height: 2, color: actual),
                        const FixedSpacer(10),
                        Container(
                          height: 5,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: const BoxDecoration(
                            border: Border.symmetric(
                              vertical: BorderSide(
                                color: SuperColors.lightBackground,
                                width: 300,
                              ),
                            ),
                          ),
                          child: empty,
                        ),
                        Container(
                            width: context.screenWidth / 2,
                            height: 3,
                            color: SuperColors.lightBackground),
                        const FixedSpacer(10),
                        Container(
                          height: 3,
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          decoration: const BoxDecoration(
                              border: Border.symmetric(
                                  vertical: BorderSide(
                                      color: SuperColors.lightBackground, width: 250))),
                          child: empty,
                        ),
                      ],
                    ),
                  )
                : empty,
          ],
        ),
      );
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
