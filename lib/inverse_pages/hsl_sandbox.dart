import 'package:flutter/material.dart';
import 'package:super_hueman/structs.dart';
import 'package:super_hueman/widgets.dart';

int _r = 0, _g = 0, _b = 0;
double _h = 0, _s = 0, _l = 0;

_ColorPicker _colorPicker = _ColorPicker.rgb;
SuperColor get _color {
  switch (_colorPicker) {
    case _ColorPicker.rgb:
    case _ColorPicker.select:
      return SuperColor.rgb(_r, _g, _b);
    case _ColorPicker.hsl:
      return SuperColor.hsl(_h, _s, _l);
    default:
      return SuperColors.black;
  }
}

class _RGBSlider extends StatelessWidget {
  final String name;
  final int value, multiplier;
  final ValueChanged<double> onChanged;
  const _RGBSlider(this.name, this.value, {required this.multiplier, required this.onChanged});

  @override
  Widget build(BuildContext context) => Column(
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

class _HSLSlider extends StatelessWidget {
  final String name;
  final num value;
  final Color color;
  final ValueChanged<double> onChanged;
  const _HSLSlider(this.name, this.value, {required this.color, required this.onChanged});

  @override
  Widget build(BuildContext context) => Row(
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

enum _ColorPicker {
  rgb(icon: Icons.tune, tag: 'sliders'),
  hsl(icon: Icons.gradient, tag: 'plane'),
  select(icon: Icons.list, tag: 'a color');

  final IconData icon;
  // final String desc;
  final String tag;
  const _ColorPicker({required this.icon, required this.tag});
  String get upperName => name == 'select' ? 'Select' : name.toUpperCase();

  static List<BottomNavigationBarItem> get navBarItems => [
        for (final value in values)
          BottomNavigationBarItem(
            icon: Icon(value.icon, size: 50),
            label: value.upperName,
            tooltip: value.desc,
            backgroundColor: contrastWith(_color, threshold: 0.8).withAlpha(64),
          )
      ];

  String get desc => '$upperName $tag';
}

class _ColorSelection extends StatelessWidget {
  final void Function(Color, HSLColor) updateColor;
  const _ColorSelection(this.updateColor);

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(border: Border.all(color: _color, width: 2)),
        padding: const EdgeInsets.symmetric(vertical: 50),
        child: Column(
          children: [
            for (final color in SuperColors.fullList)
              SizedBox(
                width: 500,
                child: TextButton(
                  style: TextButton.styleFrom(
                      shape: const BeveledRectangleBorder(),
                      backgroundColor:
                          _color.rounded.hexCode == color.hexCode ? Colors.black45 : null),
                  onPressed: () => updateColor(color, HSLColor.fromColor(color)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          width: 150,
                          child:
                              Text(color.name, style: Theme.of(context).textTheme.headlineSmall)),
                      Container(
                        width: 150,
                        height: 40,
                        margin: const EdgeInsets.fromLTRB(0, 8, 20, 8),
                        color: color,
                      ),
                    ],
                  ),
                ),
              )
          ],
        ),
      );
}

class _ColorLabel extends StatelessWidget {
  final String property, value;
  final TextStyle? textStyle;
  const _ColorLabel(this.property, this.value, {this.textStyle});

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
          const FixedSpacer.horizontal(10),
          SizedBox(width: 200, child: Text(value, style: textStyle ?? defaultStyle)),
        ],
      ),
    );
  }
}

class HslSandbox extends StatefulWidget {
  const HslSandbox({super.key});

  @override
  State<HslSandbox> createState() => _HslSandboxState();
}

class _HslSandboxState extends State<HslSandbox> {
  void colorPickerPicker(int index) {
    setState(() {
      switch (_colorPicker) {
        case _ColorPicker.rgb:
          HSLColor hslColor = HSLColor.fromColor(_color);
          _h = hslColor.hue;
          _s = hslColor.saturation;
          _l = hslColor.lightness;
          break;
        case _ColorPicker.hsl:
          _r = _color.red;
          _g = _color.green;
          _b = _color.blue;
          break;
        default:
      }
      _colorPicker = _ColorPicker.values[index];
    });
  }

  Widget get title => Text(_colorPicker.desc,
      style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.black));
  Widget get colorName => _ColorLabel(
        'color name',
        _color.name,
        textStyle: TextStyle(color: _color, fontSize: 20, fontWeight: FontWeight.bold, shadows: [
          Shadow(color: contrastWith(_color, threshold: 0.8).withAlpha(64), blurRadius: 3)
        ]),
      );
  Widget get hue => _ColorLabel('hue', HSLColor.fromColor(_color).hue.round().toString());
  Widget get colorCode => _ColorLabel(
        'color code',
        _color.hexCode,
        textStyle: const TextStyle(fontFamily: 'Consolas', fontSize: 18),
      );

  void updateColor(Color rgb, HSLColor hsl) => setState(() {
        _r = rgb.red;
        _g = rgb.green;
        _b = rgb.blue;

        _h = hsl.hue;
        _s = hsl.saturation;
        _l = hsl.lightness;
      });

  @override
  Widget build(BuildContext context) {
    final Widget colorPicker = {
      _ColorPicker.rgb: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 300, height: 300, color: _color),
          const FixedSpacer(30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _RGBSlider(
                'red',
                _r,
                multiplier: 0x010000,
                onChanged: (value) => setState(() => _r = value.round()),
              ),
              _RGBSlider(
                'green',
                _g,
                multiplier: 0x000100,
                onChanged: (value) => setState(() => _g = value.round()),
              ),
              _RGBSlider(
                'blue',
                _b,
                multiplier: 0x000001,
                onChanged: (value) => setState(() => _b = value.round()),
              ),
            ],
          ),
        ],
      ),
      _ColorPicker.hsl: Column(
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
                            colors: [SuperColors.gray, SuperColor.hsl(_h, 1, 0.5)],
                          ),
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.white, Colors.transparent, Colors.black],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment(2 * _s - 1, 1 - 2 * _l),
                  child: Icon(
                    Icons.add,
                    color: contrastWith(_color),
                    size: 40,
                  ),
                ),
              ],
            ),
          ),
          _HSLSlider(
            'hue',
            _h,
            color: SuperColor.hsl(_h, 1, 0.5),
            onChanged: (value) => setState(() => _h = value),
          ),
          _HSLSlider(
            'saturation',
            _s,
            color: SuperColor.hsl(_h, _s, 0.5),
            onChanged: (value) => setState(() => _s = value),
          ),
          _HSLSlider(
            'lightness',
            _l,
            color: SuperColor.hsl(_h, _s, _l),
            onChanged: (value) => setState(() => _l = value),
          ),
          const FixedSpacer(25),
          Container(width: 500, height: 100, color: _color),
        ],
      ),
      _ColorPicker.select: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ColorSelection(updateColor),
        ],
      ),
    }[_colorPicker]!;

    return Theme(
      data: ThemeData(useMaterial3: true),
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Spacer(),
              const GoBack(),
              const Spacer(),
              title,
              const Spacer(),
              AnimatedSize(
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeInOutCubic,
                child: colorPicker,
              ),
              const Spacer(flex: 2),
              hue,
              colorName,
              colorCode,
              const Spacer(flex: 2),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          elevation: 0,
          type: BottomNavigationBarType.shifting,
          items: _ColorPicker.navBarItems,
          currentIndex: _colorPicker.index,
          selectedItemColor: _color,
          unselectedItemColor: _color.withAlpha(128),
          onTap: colorPickerPicker,
        ),
        backgroundColor: SuperColors.lightBackground,
      ),
    );
  }
}
