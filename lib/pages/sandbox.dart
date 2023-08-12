import 'package:flutter/material.dart';
import 'package:super_hueman/reference.dart';

int _r = 255, _g = 255, _b = 255;
double _h = 0, _s = 0, _v = 0;

ColorPicker _colorPicker = ColorPicker.rgb;
Color get color {
  switch (_colorPicker) {
    case ColorPicker.rgb:
    case ColorPicker.select:
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
            width: 384,
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
            name == 'hue' ? value.round().toString() : value.toStringAsFixed(2),
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
  hsv(icon: Icons.gradient, tag: 'plane'),
  select(icon: Icons.list, tag: 'a color');

  final IconData icon;
  // final String desc;
  final String tag;
  const ColorPicker({required this.icon, required this.tag});
  String get upperName => name == 'select' ? 'Select' : name.toUpperCase();

  static List<BottomNavigationBarItem> get navBarItems => [
        for (final value in values)
          BottomNavigationBarItem(
            icon: RotatedBox(quarterTurns: value == hsv ? 2 : 0, child: Icon(value.icon, size: 50)),
            label: value.upperName,
            tooltip: value.desc,
            backgroundColor: contrastWith(color, threshold: 0.01).withAlpha(64),
          )
      ];

  String get desc => '$upperName $tag';
}

class ColorSelection extends StatelessWidget {
  final List<String> colorNames;
  final void Function(Color, HSVColor) updateColor;
  const ColorSelection(this.colorNames, {required this.updateColor, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: color, width: 2)),
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Column(
        children: [
          for (final colorName in colorNames)
            SizedBox(
              width: 500,
              child: TextButton(
                style: TextButton.styleFrom(
                    shape: const BeveledRectangleBorder(),
                    backgroundColor: color.roundedHexCode == colorFromName(colorName).hexCode
                        ? Colors.black45
                        : null),
                onPressed: () {
                  final Color rgb = colorFromName(colorName);
                  final HSVColor hsv = HSVColor.fromColor(rgb);

                  updateColor(rgb, hsv);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: 150,
                        child: Text(colorName, style: Theme.of(context).textTheme.headlineSmall)),
                    Container(
                      width: 150,
                      height: 40,
                      margin: const EdgeInsets.fromLTRB(0, 8, 20, 8),
                      color: colorFromName(colorName),
                    ),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}

class ColorLabel extends StatelessWidget {
  final String property, value;
  final TextStyle? textStyle;
  const ColorLabel(this.property, this.value, {this.textStyle, super.key});

  @override
  Widget build(BuildContext context) {
    final TextStyle? defaultStyle = Theme.of(context).textTheme.bodyLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
              width: 200,
              child: Text(
                '$property:',
                style: defaultStyle,
                textAlign: TextAlign.right,
              )),
          hspace(10),
          SizedBox(width: 200, child: Text(value, style: textStyle ?? defaultStyle)),
        ],
      ),
    );
  }
}

class Sandbox extends StatefulWidget {
  const Sandbox({super.key});

  @override
  State<Sandbox> createState() => _SandboxState();
}

class _SandboxState extends State<Sandbox> {
  void colorPickerPicker(int index) {
    setState(() {
      switch (_colorPicker) {
        case ColorPicker.rgb:
          HSVColor hsvColor = HSVColor.fromColor(color);
          _h = hsvColor.hue;
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

  Widget get title => Text(_colorPicker.desc, style: Theme.of(context).textTheme.headlineMedium);
  Widget get colorName => ColorLabel(
        'color name',
        colorNames[color.roundedHexCode] ?? '[none]',
        textStyle: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold, shadows: [
          Shadow(color: contrastWith(color, threshold: 0.01).withAlpha(64), blurRadius: 3)
        ]),
      );
  Widget get hue => ColorLabel('hue', HSLColor.fromColor(color).hue.round().toString());
  Widget get colorCode => ColorLabel('color code', color.hexCode);

  @override
  Widget build(BuildContext context) {
    final Widget colorPicker = {
      ColorPicker.rgb: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 300, height: 300, color: color),
          vspace(30),
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
        ],
      ),
      ColorPicker.hsv: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 400,
            height: 400,
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
          HSVSlider(
            'hue',
            _h,
            color: hsv(_h, 1, 1),
            onChanged: (value) => setState(() => _h = value),
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
          vspace(25),
          Container(width: 500, height: 100, color: color),
        ],
      ),
      ColorPicker.select: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ColorSelection(
            const [
              'red',
              'orange',
              'yellow',
              'lime',
              'green',
              'jade',
              'cyan',
              'azure',
              'blue',
              'violet',
              'magenta',
              'rose',
              'white',
              'gray',
              'black',
            ],
            updateColor: (rgb, hsv) => setState(() {
              _r = rgb.red;
              _g = rgb.green;
              _b = rgb.blue;

              _h = hsv.hue;
              _s = hsv.saturation;
              _v = hsv.value;
            }),
          ),
        ],
      ),
    }[_colorPicker]!;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            filler,
            backButton,
            filler,
            title,
            filler,
            AnimatedSize(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeInOutCubic,
              child: colorPicker,
            ),
            filler,
            filler,
            hue,
            colorName,
            colorCode,
            filler,
            filler,
          ],
        ),
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
