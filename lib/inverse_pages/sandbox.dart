import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:super_hueman/data/structs.dart';
import 'package:super_hueman/data/widgets.dart';

int _r = 0x80, _g = 0x80, _b = 0x80;
int _cyan = 0, _magenta = 0, _yellow = 0, _black = 0x7f;
double _h = 0, _s = 0, _l = 0;

void updateCMYK() {
  final brightest = [_r, _g, _b].max;
  _black = 0xFF - brightest;

  int value(int rgb) => brightest == 0 ? 0 : (0xFF * (1 - rgb / brightest)).round();

  _cyan = value(_r);
  _magenta = value(_g);
  _yellow = value(_b);
}

void updateHSL() {
  HSLColor hslColor = HSLColor.fromColor(SuperColor.rgb(_r, _g, _b));
  _h = hslColor.hue;
  _l = hslColor.lightness;
  _s = (_l == 0 || _l == 1) ? 0 : hslColor.saturation;
}

void updateRGB() {
  int value(int cmy) => ((0xFF - cmy) * (1 - _black / 0xFF)).round();

  _r = value(_cyan);
  _g = value(_magenta);
  _b = value(_yellow);
}

double get _c => _cyan / 0xFF;
double get _m => _magenta / 0xFF;
double get _y => _yellow / 0xFF;
double get _k => _black / 0xFF;

set _c(double val) => _cmyk(val, (c) => _cyan = c);
set _m(double val) => _cmyk(val, (m) => _magenta = m);
set _y(double val) => _cmyk(val, (y) => _yellow = y);
set _k(double val) => _cmyk(val, (k) => _black = k);

void _cmyk(double val, ValueChanged<int> update) {
  update((val * 0xFF).round());
  updateRGB();
}

enum _ColorPicker {
  cmyk(Icons.tune, 'sliders'),
  hsl(Icons.gradient, 'plane'),
  select(Icons.motion_photos_on, 'from color wheel');

  final IconData icon;
  final String tag;
  const _ColorPicker(this.icon, this.tag);
  String get upperName => name == 'select' ? 'Select' : name.toUpperCase();

  static List<BottomNavigationBarItem> get navBarItems => [
        for (final value in values)
          BottomNavigationBarItem(
            icon: Transform.flip(flipX: value == cmyk, child: Icon(value.icon, size: 50)),
            label: value.upperName,
            tooltip: value.desc,
            backgroundColor: contrastWith(_color, threshold: 0.8).withAlpha(64),
          )
      ];

  String get desc => '$upperName $tag';
}

_ColorPicker _colorPicker = _ColorPicker.cmyk;
SuperColor get _color => switch (_colorPicker) {
      _ColorPicker.cmyk || _ColorPicker.select => SuperColor.rgb(_r, _g, _b),
      _ColorPicker.hsl => SuperColor.hsl(_h, _s, _l),
    };

class _CMYScreen extends StatelessWidget {
  final ValueChanged<double> updateC, updateM, updateY, updateK;
  const _CMYScreen({
    required this.updateC,
    required this.updateM,
    required this.updateY,
    required this.updateK,
  });

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 300, height: 300, color: _color),
          const FixedSpacer(30),
          Flex(
            direction: context.squished ? Axis.vertical : Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _CMYKSlider('cyan', _c, onChanged: updateC),
              _CMYKSlider('magenta', _m, onChanged: updateM),
              _CMYKSlider('yellow', _y, onChanged: updateY),
              _CMYKSlider('black', _k, onChanged: updateK),
            ],
          ),
        ],
      );
}

class _CMYKSlider extends StatelessWidget {
  final String name;
  final double value;
  final ValueChanged<double> onChanged;
  const _CMYKSlider(this.name, this.value, {required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final int byte = (0xFF * (1 - value)).toInt();
    final SuperColor color = switch (name) {
      'cyan' => SuperColor.rgb(byte, 0xFF, 0xFF),
      'magenta' => SuperColor.rgb(0xFF, byte, 0xFF),
      'yellow' => SuperColor.rgb(0xFF, 0xFF, byte),
      'black' => SuperColor.rgb(byte, byte, byte),
      _ => null,
    }!;
    final bool enabled = switch (name) {
      'cyan' => (_magenta == 0 || _yellow == 0) && _black < 0xFF,
      'magenta' => (_cyan == 0 || _yellow == 0) && _black < 0xFF,
      'yellow' => (_cyan == 0 || _magenta == 0) && _black < 0xFF,
      'black' => true,
      _ => null,
    }!;
    final bool horizontal = context.squished;

    return Flex(
      direction: horizontal ? Axis.horizontal : Axis.vertical,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RotatedBox(
          quarterTurns: horizontal ? 0 : 3,
          child: SizedBox(
            width: 384,
            child: SliderTheme(
              data: const SliderThemeData(
                trackHeight: 15,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 15),
              ),
              child: Slider(
                thumbColor: color,
                activeColor: color.withAlpha(0x80),
                inactiveColor: Colors.white24,
                value: value.toDouble(),
                onChanged: enabled ? onChanged : null,
              ),
            ),
          ),
        ),
        Container(
          width: 125,
          alignment: Alignment.center,
          child: Text(
            '$name:  ${(value * 100).toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}

class _HSLScreen extends StatelessWidget {
  final double hue, saturation, lightness;
  final ValueChanged<double> updateH, updateS, updateL;
  const _HSLScreen(this.hue, this.saturation, this.lightness,
      {required this.updateH, required this.updateS, required this.updateL});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 400,
            height: 400,
            alignment: Alignment.center,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(0.5),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [SuperColors.gray, SuperColor.hue(hue)],
                          ),
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.white, Color(0x00FFFFFF), Color(0x00FFFFFF)],
                          ),
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.transparent, Colors.black],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment(2 * saturation - 1, 1 - 2 * lightness),
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
            hue,
            color: SuperColor.hue(hue),
            onChanged: updateH,
          ),
          _HSLSlider(
            'saturation',
            saturation,
            color: SuperColor.hsl(hue, saturation, 0.5),
            onChanged: updateS,
          ),
          _HSLSlider(
            'lightness',
            lightness,
            color: SuperColor.hsl(hue, saturation, lightness),
            onChanged: updateL,
          ),
          const FixedSpacer(25),
          Container(width: 500, height: 100, color: _color),
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

class _ColorWheel extends StatefulWidget {
  final void Function(Color) updateColor;
  const _ColorWheel(this.updateColor);

  @override
  State<_ColorWheel> createState() => _ColorWheelState();
}

class _ColorWheelState extends State<_ColorWheel> {
  double sliderValue = 0;
  int get _sliderIndex => sliderValue.toInt();
  SuperColor get centerColor => [
        SuperColors.lightBackground,
        SuperColors.black,
        SuperColors.gray,
        SuperColors.white,
      ][_sliderIndex];
  String get label => [
        '[none]',
        'black',
        'gray',
        'white',
      ][_sliderIndex];

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: _color, width: 5),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(10),
            child: Container(
              width: 400,
              height: 400,
              padding: const EdgeInsets.all(16),
              decoration: SuperColors.colorWheel,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  centerColor == SuperColors.lightBackground
                      ? empty
                      : Container(
                          margin: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient:
                                RadialGradient(colors: [centerColor, centerColor.withAlpha(0)]),
                          ),
                          child: Center(
                            child: IconButton(
                              icon: Icon(
                                _color.rounded == centerColor
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: centerColor == SuperColors.black
                                    ? Colors.white70
                                    : Colors.black,
                                size: 32,
                              ),
                              onPressed: () => widget.updateColor(centerColor),
                            ),
                          ),
                        ),
                  for (int hue = 0; hue < 360; hue += 30)
                    RotationTransition(
                      turns: AlwaysStoppedAnimation(-hue / 360),
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: Icon(
                            _color.rounded == SuperColor.hue(hue)
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: Colors.black,
                            size: 32,
                          ),
                          onPressed: () => widget.updateColor(SuperColor.hue(hue)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const FixedSpacer(10),
          _ColorWheelSlider(
            label: label,
            index: _sliderIndex,
            centerColor: centerColor,
            value: sliderValue,
            updateValue: (value) => setState(() => sliderValue = value),
          ),
        ],
      );
}

class _ColorWheelSlider extends StatelessWidget {
  final String label;
  final int index;
  final SuperColor centerColor;
  final double value;
  final ValueChanged<double> updateValue;
  const _ColorWheelSlider({
    required this.label,
    required this.index,
    required this.centerColor,
    required this.value,
    required this.updateValue,
  });

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('center:  ', style: TextStyle(fontSize: 16)),
          SizedBox(
            width: 66,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: index == 0 ? Colors.black38 : centerColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                shadows: index == 3 ? [const Shadow(blurRadius: 1)] : [],
              ),
            ),
          ),
          SizedBox(
            width: 240,
            child: SliderTheme(
              data: const SliderThemeData(
                trackHeight: 12,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12),
              ),
              child: Slider(
                value: value,
                onChanged: updateValue,
                max: 3,
                divisions: 3,
                thumbColor: centerColor,
                activeColor: centerColor.withAlpha(0xcc),
              ),
            ),
          ),
        ],
      );
}

class InverseSandbox extends StatefulWidget {
  const InverseSandbox({super.key});

  @override
  State<InverseSandbox> createState() => _InverseSandboxState();
}

class _InverseSandboxState extends State<InverseSandbox> {
  void colorPickerPicker(int index) => setState(() {
        switch (_colorPicker) {
          case _ColorPicker.cmyk:
            updateHSL();
          case _ColorPicker.hsl:
            _r = _color.red;
            _g = _color.green;
            _b = _color.blue;
            updateCMYK();
          default:
            updateHSL();
            updateCMYK();
        }
        _colorPicker = _ColorPicker.values[index];
      });

  void updateColorCode(SuperColor color) => setState(() {
        _r = color.red;
        _g = color.green;
        _b = color.blue;
        updateCMYK();
        updateHSL();
      });

  static const titleStyle = TextStyle(fontSize: 28.0, letterSpacing: 0.0, height: 1.3);
  TextStyle get colorNameStyle => TextStyle(
        color: _color,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(color: contrastWith(_color, threshold: 0.8).withAlpha(128), blurRadius: 3)
        ],
      );
  String get hue => HSLColor.fromColor(_color).hue.round().toString();

  @override
  Widget build(BuildContext context) => Theme(
        data: ThemeData(useMaterial3: true),
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Spacer(),
                const GoBack(),
                const Spacer(),
                Text(_colorPicker.desc, style: titleStyle),
                const Spacer(),
                AnimatedSize(
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeInOutCubic,
                  child: {
                    _ColorPicker.cmyk: _CMYScreen(
                      updateC: (value) => setState(() => _c = value),
                      updateM: (value) => setState(() => _m = value),
                      updateY: (value) => setState(() => _y = value),
                      updateK: (value) => setState(() => _k = value),
                    ),
                    _ColorPicker.hsl: _HSLScreen(
                      _h,
                      _s,
                      _l,
                      updateH: (value) => setState(() => _h = value),
                      updateS: (value) => setState(() => _s = value),
                      updateL: (value) => setState(() => _l = value),
                    ),
                    _ColorPicker.select: _ColorWheel(
                      (rgb) => setState(() {
                        _r = rgb.red;
                        _g = rgb.green;
                        _b = rgb.blue;

                        final hsl = HSLColor.fromColor(rgb);
                        _h = hsl.hue;
                        _s = hsl.saturation;
                        _l = hsl.lightness;
                      }),
                    ),
                  }[_colorPicker]!,
                ),
                const Spacer(flex: 2),
                ColorLabel('hue', hue),
                ColorLabel('color name', _color.rounded.name, textStyle: colorNameStyle),
                ColorLabel.colorCode('color code', _color.hexCode,
                    updateColorCode: updateColorCode),
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
