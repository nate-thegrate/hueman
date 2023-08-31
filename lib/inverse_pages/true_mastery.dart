import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
  final int value, multiplier;
  final ValueChanged<double> onChanged;
  const RGBSlider(this.name, this.value,
      {required this.multiplier, required this.onChanged, super.key});

  @override
  Widget build(BuildContext context) => Column(
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
                  thumbColor: Color(0xFF000000 + value * multiplier),
                  activeColor: Color(0x80000000 + value * multiplier),
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

class _TrueMasteryState extends State<TrueMastery> {
  late int r, g, b, colorCode;
  SuperColor get color => SuperColor.noName(colorCode);
  void nextColor() => setState(() {
        colorCode = rng.nextInt(0xFFFFFF + 1);
        r = 0;
        g = 0;
        b = 0;
      });

  SuperColor get userColor => SuperColor.rgb(r, g, b);
  String get userColorCode => userColor.hexCode;

  @override
  void initState() {
    super.initState();
    inverted = true;
    nextColor();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
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
                          multiplier: 0x010000,
                          onChanged: (value) => setState(() => r = value.toInt()),
                        ),
                        RGBSlider(
                          'green',
                          g,
                          multiplier: 0x000100,
                          onChanged: (value) => setState(() => g = value.toInt()),
                        ),
                        RGBSlider(
                          'blue',
                          b,
                          multiplier: 1,
                          onChanged: (value) => setState(() => b = value.toInt()),
                        ),
                      ],
                    ),
                    const FixedSpacer(50),
                    Text(
                      'color code: $userColorCode',
                      style: const TextStyle(fontFamily: 'Consolas', fontSize: 20),
                    ),
                    const FixedSpacer(30),
                    SuperButton('submit', color: color, onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => TrueMasteryScore(guess: userColor, actual: color),
                      ).then((_) => setState(nextColor));
                    }),
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

  @override
  void initState() {
    super.initState();

    inverseHues =
        (guess.red == actual.red) || (guess.green == actual.green) || (guess.blue == actual.blue)
            ? inverseSetup(setState)
            : null;
  }

  @override
  void dispose() {
    inverseHues?.dispose();
    super.dispose();
  }

  late final Ticker? inverseHues;

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

  int diff(int a, int b) => (a - b).abs();

  String _matchPercent(num difference) =>
      difference == 0 ? '100%' : '${(100 * (1 - difference / 256)).toStringAsFixed(2)}%';

  static const List<DataColumn> columns = [
    DataColumn(label: empty),
    DataColumn(label: Text('red')),
    DataColumn(label: Text('green')),
    DataColumn(label: Text('blue')),
  ];

  TextStyle get superStyle => TextStyle(
        fontWeight: FontWeight.bold,
        color: inverseColor,
        fontSize: 18,
        shadows: [
          for (double i = 0; i <= 3; i += 0.5) Shadow(blurRadius: i, color: Colors.white),
        ],
      );

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

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(useMaterial3: true),
      child: AlertDialog(
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
                DataCell(Text(_matchPercent(redOffBy), style: redOffBy == 0 ? superStyle : null)),
                DataCell(
                    Text(_matchPercent(greenOffBy), style: greenOffBy == 0 ? superStyle : null)),
                DataCell(
                    Text(_matchPercent(blueOffBy), style: blueOffBy == 0 ? superStyle : null)),
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
                    // const FixedSpacer(2),
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
    );
  }
}

class _Base10PlusHex extends StatelessWidget {
  final int value;
  const _Base10PlusHex(this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
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
}
