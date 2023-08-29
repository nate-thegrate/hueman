import 'package:flutter/material.dart';
import 'package:super_hueman/structs.dart';
import 'package:super_hueman/widgets.dart';

int _r = 0, _g = 0, _b = 0;
double _h = 0, _s = 0, _l = 0;

_ColorPicker _colorPicker = _ColorPicker.cmy;
SuperColor get _color {
  switch (_colorPicker) {
    case _ColorPicker.cmy:
    case _ColorPicker.select:
      return SuperColor.rgb(_r, _g, _b);
    case _ColorPicker.hsl:
      return SuperColor.hsl(_h, _s, _l);
    default:
      return SuperColors.black;
  }
}

class _CMYSlider extends StatelessWidget {
  final String name;
  final int rgbValue, multiplier;
  final ValueChanged<double> onChanged;
  const _CMYSlider(this.name, this.rgbValue, {required this.multiplier, required this.onChanged});

  int get cmyValue => 255 - rgbValue;

  @override
  Widget build(BuildContext context) {
    final bool horizontal = context.squished;
    return Flex(
      direction: horizontal ? Axis.horizontal : Axis.vertical,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RotatedBox(
          quarterTurns: horizontal ? 2 : 1,
          child: SizedBox(
            width: 384,
            child: SliderTheme(
              data: const SliderThemeData(
                trackHeight: 15,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 15),
              ),
              child: Slider(
                thumbColor: Color(0xFFFFFFFF - cmyValue * multiplier),
                activeColor: Colors.black12,
                inactiveColor: Color(0x80FFFFFF - cmyValue * multiplier),
                max: 255,
                value: rgbValue.toDouble(),
                onChanged: onChanged,
              ),
            ),
          ),
        ),
        Container(
          width: 125,
          alignment: Alignment.center,
          child: Text('$name:  ${(100 - rgbValue / 256 * 100).round()}%',
              style: Theme.of(context).textTheme.titleMedium),
        ),
      ],
    );
  }
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
  cmy(icon: Icons.tune, tag: 'sliders'),
  hsl(icon: Icons.gradient, tag: 'plane'),
  select(icon: Icons.motion_photos_on, tag: 'a color');

  final IconData icon;
  final String tag;
  const _ColorPicker({required this.icon, required this.tag});
  String get upperName => name == 'select' ? 'Select' : name.toUpperCase();

  static List<BottomNavigationBarItem> get navBarItems => [
        for (final value in values)
          BottomNavigationBarItem(
            icon: Transform.flip(flipX: value == cmy, child: Icon(value.icon, size: 50)),
            label: value.upperName,
            tooltip: value.desc,
            backgroundColor: contrastWith(_color, threshold: 0.8).withAlpha(64),
          )
      ];

  String get desc => '$upperName $tag';
}

class _ColorSelection extends StatelessWidget {
  final void Function(Color, HSLColor) updateColor;
  final Color centerColor;
  const _ColorSelection(this.updateColor, {required this.centerColor});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          border: Border.all(color: _color, width: 5),
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(10),
        child: Container(
          width: 400,
          height: 400,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: SweepGradient(
              colors: [for (int hue = 360; hue >= 0; hue -= 60) SuperColor.hue(hue)],
            ),
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              centerColor == SuperColors.lightBackground
                  ? empty
                  : Container(
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [centerColor, centerColor.withAlpha(0)]),
                      ),
                      child: Center(
                        child: IconButton(
                          icon: Icon(
                            _color.rounded == centerColor
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color:
                                centerColor == SuperColors.black ? Colors.white70 : Colors.black,
                            size: 32,
                          ),
                          onPressed: () {
                            updateColor(centerColor, HSLColor.fromColor(centerColor));
                          },
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
                      onPressed: () {
                        final SuperColor c = SuperColor.hue(hue);
                        updateColor(c, HSLColor.fromColor(c));
                      },
                    ),
                  ),
                ),
            ],
          ),
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
        case _ColorPicker.cmy:
          HSLColor hslColor = HSLColor.fromColor(_color);
          _h = hslColor.hue;
          _l = hslColor.lightness;
          _s = (_l == 0) ? 0 : hslColor.saturation;
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
        _color.rounded.name,
        textStyle: TextStyle(color: _color, fontSize: 20, fontWeight: FontWeight.bold, shadows: [
          Shadow(color: contrastWith(_color, threshold: 0.8).withAlpha(128), blurRadius: 3)
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

  double colorWheelValue = 0;
  int get colorWheelIndex => colorWheelValue.toInt();
  SuperColor get colorWheelCenter => [
        SuperColors.lightBackground,
        SuperColors.black,
        SuperColors.gray,
        SuperColors.white,
      ][colorWheelIndex];
  String get colorWheelLabel => [
        '[none]',
        'black',
        'gray',
        'white',
      ][colorWheelIndex];

  @override
  Widget build(BuildContext context) {
    final bool horizontal = context.squished;
    final Widget colorPicker = {
      _ColorPicker.cmy: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 300, height: 300, color: _color),
          const FixedSpacer(30),
          Flex(
            direction: horizontal ? Axis.vertical : Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _CMYSlider(
                'cyan',
                _r,
                multiplier: 0x010000,
                onChanged: (value) => setState(() => _r = value.round()),
              ),
              _CMYSlider(
                'magenta',
                _g,
                multiplier: 0x000100,
                onChanged: (value) => setState(() => _g = value.round()),
              ),
              _CMYSlider(
                'yellow',
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
            color: SuperColor.hue(_h),
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
        children: [
          _ColorSelection(updateColor, centerColor: colorWheelCenter),
          const FixedSpacer(10),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('center:  ', style: TextStyle(fontSize: 16)),
              SizedBox(
                width: 66,
                child: Text(
                  colorWheelLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorWheelIndex == 0 ? Colors.black38 : colorWheelCenter,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    shadows: colorWheelIndex == 3 ? [const Shadow(blurRadius: 1)] : [],
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
                    value: colorWheelValue,
                    onChanged: (value) => setState(() => colorWheelValue = value),
                    max: 3,
                    divisions: 3,
                    thumbColor: colorWheelCenter,
                    activeColor: colorWheelCenter.withAlpha(0xcc),
                  ),
                ),
              ),
            ],
          ),
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
