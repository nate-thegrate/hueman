import 'package:flutter/material.dart';
import 'package:super_hueman/reference.dart';

class Sandbox extends StatefulWidget {
  const Sandbox({super.key});

  @override
  State<Sandbox> createState() => _SandboxState();
}

int _r = 255, _g = 255, _b = 255;
int _h = 0;
double _s = 0, _v = 0;
String upperHex(int i) => i.toRadixString(16).toUpperCase().padLeft(2, '0');

ColorPicker _colorPicker = ColorPicker.rgb;
Color get color {
  switch (_colorPicker) {
    case ColorPicker.rgb:
      return Color.fromARGB(255, _r, _g, _b);
    case ColorPicker.hsv:
      return hsv(_h, _s, _v);
    default:
      return Colors.black;
  }
}

class RGBSlider extends StatelessWidget {
  final String name;
  final int value, multiplier;
  final ValueChanged<double> onChanged;
  const RGBSlider(this.name, this.value,
      {required this.multiplier, required this.onChanged, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RotatedBox(
          quarterTurns: 3,
          child: SizedBox(
            width: 512,
            child: SliderTheme(
              data: const SliderThemeData(
                trackHeight: 15,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 15),
              ),
              child: Slider(
                thumbColor: Color(0xFF000000 + value * multiplier),
                activeColor: Color(0x80000000 + value * multiplier),
                inactiveColor: Colors.white24,
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

class HSVSlider extends StatelessWidget {
  final String name;
  final num value;
  final Color color;
  final ValueChanged<double> onChanged;
  const HSVSlider(this.name, this.value, {required this.color, required this.onChanged, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
            width: 80,
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            )),
        SizedBox(
          width: 370,
          child: SliderTheme(
            data: const SliderThemeData(
              trackHeight: 10,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(
              thumbColor: color,
              activeColor: color.withAlpha(128),
              inactiveColor: Colors.white24,
              max: name == 'hue' ? 359 : 1,
              value: value.toDouble(),
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 50,
          child: Text(
            name == 'hue' ? value.toString() : value.toStringAsFixed(2),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}

enum ColorPicker {
  rgb(icon: Icons.tune, tag: 'sliders'),
  hsv(icon: Icons.gradient, tag: 'plane');

  final IconData icon;
  // final String desc;
  final String tag;
  const ColorPicker({required this.icon, required this.tag});
  String get upperName => name.toUpperCase();

  static List<BottomNavigationBarItem> get navBarItems => [
        for (final value in values)
          BottomNavigationBarItem(
            icon: Icon(value.icon, size: 50),
            label: value.upperName,
            tooltip: value.desc,
            backgroundColor: color.computeLuminance() > 0.05 ? Colors.black26 : Colors.white24,
          )
      ];

  String get desc => '$upperName $tag';
}

class _SandboxState extends State<Sandbox> {
  void colorPickerPicker(int index) {
    setState(() {
      switch (_colorPicker) {
        case ColorPicker.rgb:
          HSVColor hsvColor = HSVColor.fromColor(color);
          _h = hsvColor.hue.toInt();
          _s = hsvColor.saturation;
          _v = hsvColor.value;
        case ColorPicker.hsv:
          _r = color.red;
          _g = color.green;
          _b = color.blue;
        default:
      }
      _colorPicker = ColorPicker.values[index];
    });
  }

  Widget get backButton => TextButton(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white70,
          backgroundColor: Colors.black12,
        ),
        onPressed: () => context.goto(Pages.mainMenu),
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Text(
            'back',
            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: {
          ColorPicker.rgb: Column(
            children: [
              filler,
              backButton,
              filler,
              Text(ColorPicker.rgb.desc, style: Theme.of(context).textTheme.headlineMedium),
              filler,
              filler,
              Container(width: 300, height: 300, color: color),
              filler,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RGBSlider(
                    'red',
                    _r,
                    multiplier: 0x010000,
                    onChanged: (value) => setState(() => _r = value.round()),
                  ),
                  RGBSlider(
                    'green',
                    _g,
                    multiplier: 0x000100,
                    onChanged: (value) => setState(() => _g = value.round()),
                  ),
                  RGBSlider(
                    'blue',
                    _b,
                    multiplier: 0x000001,
                    onChanged: (value) => setState(() => _b = value.round()),
                  ),
                ],
              ),
              filler,
              filler,
              Text('hue:  ${HSVColor.fromColor(color).hue.round()}',
                  style: Theme.of(context).textTheme.bodyLarge),
              vspace(25),
              Text('hexadecimal color code:  #${upperHex(_r)}${upperHex(_g)}${upperHex(_b)}',
                  style: Theme.of(context).textTheme.bodyLarge),
              filler,
              filler,
            ],
          ),
          ColorPicker.hsv: Center(
            child: Column(
              children: [
                filler,
                backButton,
                filler,
                Text(ColorPicker.hsv.desc, style: Theme.of(context).textTheme.headlineMedium),
                filler,
                Container(
                  width: 540,
                  height: 540,
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      Padding(
                        // color: Colors.amber,
                        padding: const EdgeInsets.all(20),
                        child: Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.all(0.5),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [Colors.white, hsv(_h, 1, 1)],
                                ),
                              ),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment(2 * _s - 1, 1 - 2 * _v),
                        child: Icon(
                          Icons.add,
                          color: contrastWith(color),
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ),
                filler,
                HSVSlider(
                  'hue',
                  _h,
                  color: hsv(_h, 1, 1),
                  onChanged: (value) => setState(() => _h = value.toInt()),
                ),
                HSVSlider(
                  'saturation',
                  _s,
                  color: hsv(_h, _s, 1),
                  onChanged: (value) => setState(() => _s = value),
                ),
                HSVSlider(
                  'value',
                  _v,
                  color: hsv(_h, _s, _v),
                  onChanged: (value) => setState(() => _v = value),
                ),
                filler,
                Container(width: 500, height: 50, color: color),
                filler,
                Text(
                    'hexadecimal color code:  '
                    '#${upperHex(color.red)}${upperHex(color.green)}${upperHex(color.blue)}',
                    style: Theme.of(context).textTheme.bodyLarge),
                filler,
                filler,
                filler,
              ],
            ),
          ),
        }[_colorPicker],
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        type: BottomNavigationBarType.shifting,
        items: ColorPicker.navBarItems,
        currentIndex: _colorPicker.index,
        selectedItemColor: color,
        unselectedItemColor: color.withAlpha(128),
        onTap: colorPickerPicker,
      ),
    );
  }
}
