import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
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
              width: MediaQuery.of(context).size.height - 600,
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
  late int r, g, b;
  late int colorCode;
  SuperColor get color => SuperColor.noName(colorCode);
  void nextColor() => setState(() {
        colorCode = rng.nextInt(0xFFFFFF + 1);
        r = 0;
        g = 0;
        b = 0;
      });

  String get userColorCode => SuperColor.rgb(r, g, b).hexCode;
  String get matchPercent {
    double singleColorMatch(int a, int b) => (256 - (a - b).abs()) / 256;
    final match = [
          singleColorMatch(r, color.red),
          singleColorMatch(g, color.green),
          singleColorMatch(b, color.blue),
        ].average *
        100;
    return '${match.toStringAsFixed(2)}%';
  }

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
                        builder: (context) => AlertDialog(
                          title: Text(matchPercent),
                        ),
                      ).then((_) => setState(nextColor));
                    }),
                    // const FixedSpacer(20),
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
