import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hueman/data/structs.dart';
import 'package:hueman/data/super_color.dart';
import 'package:hueman/data/super_text.dart';
import 'package:hueman/data/widgets.dart';

int _r = 0x80, _g = 0x80, _b = 0x80;
int _cyan = 0, _magenta = 0, _yellow = 0, _black = 0x7f;
double _h = 0, _s = 0, _l = 0;

void updateCMYK() {
  final brightest = max(_r, max(_g, _b));
  _black = 0xFF - brightest;

  int value(int rgb) => brightest == 0 ? 0 : (0xFF * (1 - rgb / brightest)).round();

  _cyan = value(_r);
  _magenta = value(_g);
  _yellow = value(_b);
}

void updateHSL() {
  final hslColor = HSLColor.fromColor(SuperColor.rgb(_r, _g, _b));
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

enum _ColorPicker {
  cmyk(Icons.tune),
  hsl(Icons.gradient),
  select(Icons.motion_photos_on);

  const _ColorPicker(this.icon);
  final IconData icon;

  String get upperName => name == 'select' ? 'Select' : name.toUpperCase();

  static List<BottomNavigationBarItem> get navBarItems => [
        for (final value in values)
          BottomNavigationBarItem(
            icon: Transform.flip(flipX: value == cmyk, child: Icon(value.icon, size: 50)),
            label: value.upperName,
            tooltip: value.upperName,
            backgroundColor: contrastWith(_color, threshold: 0.8).withAlpha(64),
          ),
      ];
}

_ColorPicker _colorPicker = _ColorPicker.cmyk;
SuperColor get _color => switch (_colorPicker) {
      _ColorPicker.cmyk || _ColorPicker.select => SuperColor.rgb(_r, _g, _b),
      _ColorPicker.hsl => SuperColor.hsl(_h, _s, _l),
    };

class _CMYKScreen extends StatelessWidget {
  const _CMYKScreen(this.update, this.constraints);
  final StateSetter update;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    final double width = min(constraints.maxWidth - 50, 500);
    final double height = min(constraints.maxHeight - 500, 500);
    final bool isK = _color.colorCode == 0x8080FF;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ColoredBox(
          color: _color,
          child: SizedBox(
            width: width,
            height: height,
            child: Center(child: isK ? const K_glitch() : null),
          ),
        ),
        const FixedSpacer(30),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _CMYKSlider(
              'cyan',
              _cyan / 0xFF,
              onChanged: (value) => update(() => _cyan = (value * 0xFF).round()),
            ),
            _CMYKSlider(
              'magenta',
              _magenta / 0xFF,
              onChanged: (value) => update(() => _magenta = (value * 0xFF).round()),
            ),
            _CMYKSlider(
              'yellow',
              _yellow / 0xFF,
              onChanged: (value) => update(() => _yellow = (value * 0xFF).round()),
            ),
            _CMYKSlider(
              'key',
              _black / 0xFF,
              onChanged: (value) => update(() => _black = (value * 0xFF).round()),
            ),
          ],
        ),
      ],
    );
  }
}

class _CMYKSlider extends StatelessWidget {
  const _CMYKSlider(this.name, this.value, {required this.onChanged});
  final String name;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final int byte = (0xFF * (1 - value)).toInt();
    final SuperColor color = switch (name) {
      'cyan' => SuperColor.rgb(byte, 0xFF, 0xFF),
      'magenta' => SuperColor.rgb(0xFF, byte, 0xFF),
      'yellow' => SuperColor.rgb(0xFF, 0xFF, byte),
      'key' => SuperColor.rgb(byte, byte, byte),
      _ => throw Error(),
    };
    final bool enabled = switch (name) {
      'cyan' => (_magenta == 0 || _yellow == 0) && _black < 0xFF,
      'magenta' => (_cyan == 0 || _yellow == 0) && _black < 0xFF,
      'yellow' => (_cyan == 0 || _magenta == 0) && _black < 0xFF,
      'key' => true,
      _ => throw Error(),
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: min(384, context.screenWidth - 80),
          child: SliderTheme(
            data: const SliderThemeData(
              trackHeight: 15,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 15),
            ),
            child: Slider(
              thumbColor: color,
              activeColor: color.withAlpha(0x80),
              inactiveColor: Colors.white24,
              value: value,
              onChanged: enabled ? onChanged : null,
            ),
          ),
        ),
        SizedBox(
          width: 50,
          child: Center(
            child: Text(
              '${(value * 100).toStringAsFixed(0).padLeft(3)}%',
              style: const SuperStyle.mono(size: 16),
            ),
          ),
        ),
      ],
    );
  }
}

class _HSLScreen extends StatefulWidget {
  const _HSLScreen(this.onChanged, this.constraints);
  final ValueChanged<double> Function(int) onChanged;
  final BoxConstraints constraints;

  @override
  State<_HSLScreen> createState() => _HSLScreenState();
}

class _HSLScreenState extends State<_HSLScreen> {
  @override
  Widget build(BuildContext context) {
    final constraints = widget.constraints;
    final double colorBarHeight = constraints.maxHeight < 800 ? 0 : 100;
    final double planeSize =
        constraints.calcSize((w, h) => min(w - 50, h - 420 - colorBarHeight));

    // ignore: avoid_annotating_with_dynamic, would be fixed by https://github.com/flutter/flutter/pull/160714
    void touchRecognition(dynamic details) {
      // ignore: avoid_dynamic_calls, same here
      final Offset offset = details.localPosition;
      double val(double position) => (position / (planeSize - 40)).clamp(0.0, 1.0);
      widget.onChanged(1)(val(offset.dx));
      widget.onChanged(2)(1 - val(offset.dy));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: planeSize,
          child: Center(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(0.5),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [SuperColors.gray, SuperColor.hue(_h)],
                            ),
                          ),
                          child: emptyContainer,
                        ),
                      ),
                      GestureDetector(
                        onPanStart: touchRecognition,
                        onPanUpdate: touchRecognition,
                        child: const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white,
                                Color(0x00FFFFFF),
                                Colors.transparent,
                                Colors.black,
                              ],
                              stops: [0, 0.5, 0.5, 1],
                            ),
                          ),
                          child: emptyContainer,
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
        ),
        _HSLSlider(
          'hue',
          _h,
          color: SuperColor.hue(_h),
          onChanged: widget.onChanged(0),
        ),
        _HSLSlider(
          'saturation',
          _s,
          color: SuperColor.hsl(_h, _s, 0.5),
          onChanged: widget.onChanged(1),
        ),
        _HSLSlider(
          'lightness',
          _l,
          color: SuperColor.hsl(_h, _s, _l),
          onChanged: widget.onChanged(2),
        ),
        const FixedSpacer(25),
        if (colorBarHeight > 0)
          SizedBox(
            width: 500,
            height: colorBarHeight,
            child: ColoredBox(color: _color),
          ),
      ],
    );
  }
}

class _HSLSlider extends StatelessWidget {
  const _HSLSlider(this.name, this.value, {required this.color, required this.onChanged});
  final String name;
  final num value;
  final Color color;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            name,
            textAlign: TextAlign.right,
            style: const SuperStyle.sans(size: 14),
          ),
        ),
        SizedBox(
          width: min(context.screenWidth - 150, 720),
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
          width: 33,
          child: Text(
            name == 'hue' ? value.round().toString() : value.toStringAsFixed(2),
            textAlign: TextAlign.center,
            style: const SuperStyle.sans(),
          ),
        ),
      ],
    );
  }
}

class _ColorWheel extends StatefulWidget {
  const _ColorWheel(this.updateColor, this.constraints);
  final void Function(Color) updateColor;
  final BoxConstraints constraints;

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
  Widget build(BuildContext context) {
    final double width = widget.constraints.calcSize((w, h) => min(w - 50, h - 333));
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: _color, width: 5),
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: SizedBox(
              width: width,
              height: width,
              child: DecoratedBox(
                decoration: SuperColors.colorWheel,
                child: Padding(
                  padding: EdgeInsets.all(width / 32),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (centerColor != SuperColors.lightBackground)
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: DecoratedBox(
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
                        ),
                      for (int hue = 0; hue < 360; hue += 30)
                        RotationTransition(
                          turns: AlwaysStoppedAnimation(-hue / 360),
                          child: Align(
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
}

class _ColorWheelSlider extends StatelessWidget {
  const _ColorWheelSlider({
    required this.label,
    required this.index,
    required this.centerColor,
    required this.value,
    required this.updateValue,
  });
  final String label;
  final int index;
  final SuperColor centerColor;
  final double value;
  final ValueChanged<double> updateValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('center:  ', style: SuperStyle.sans(size: 16)),
        SizedBox(
          width: 66,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: SuperStyle.sans(
              color: index == 0 ? Colors.black38 : centerColor,
              weight: 800,
              size: 18,
              shadows: index == 3 ? [const Shadow(blurRadius: 1)] : [],
            ),
          ),
        ),
        SizedBox(
          width: min(240, context.screenWidth - 175),
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
              inactiveColor: Colors.black12,
              activeColor: centerColor.withAlpha(0xcc),
            ),
          ),
        ),
      ],
    );
  }
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
            _r = (_color.r * 0xFF).round();
            _g = (_color.g * 0xFF).round();
            _b = (_color.b * 0xFF).round();
            updateCMYK();
          case _ColorPicker.select:
            updateHSL();
            updateCMYK();
        }
        _colorPicker = _ColorPicker.values[index];
      });

  void updateColorCode(SuperColor color) => setState(() {
        _r = (_color.r * 0xFF).round();
        _g = (_color.g * 0xFF).round();
        _b = (_color.b * 0xFF).round();
        updateCMYK();
        updateHSL();
      });

  static const titleStyle = SuperStyle.sans(size: 28.0, letterSpacing: 0.0, height: 1.3);
  SuperStyle get colorNameStyle => SuperStyle.sans(
        color: _color,
        size: 20,
        weight: 800,
        shadows: [
          Shadow(color: contrastWith(_color, threshold: 0.8).withAlpha(128), blurRadius: 3)
        ],
      );
  String get hue => HSLColor.fromColor(_color).hue.round().toString();

  void updateCMYKval(void Function() updateVal) => setState(() {
        updateVal();
        updateRGB();
      });

  void updateFromWheel(Color rgb) => setState(() {
        _r = (_color.r * 0xFF).round();
        _g = (_color.g * 0xFF).round();
        _b = (_color.b * 0xFF).round();

        final hsl = HSLColor.fromColor(rgb);
        _h = hsl.hue;
        _s = hsl.saturation;
        _l = hsl.lightness;
      });

  final hslUpdateFuncs = <ValueChanged<double>>[
    (value) => _h = value,
    (value) => _s = value,
    (value) => _l = value,
  ];

  void Function(double) onChangedHSL(int updateFunc) => (value) => setState(() {
        hslUpdateFuncs[updateFunc](value);
        final c = _color;
        _r = (c.r * 0xFF).round();
        _g = (c.g * 0xFF).round();
        _b = (c.b * 0xFF).round();
      });

  @override
  void initState() {
    super.initState();
    music.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(useMaterial3: true, fontFamily: 'nunito sans'),
      child: Scaffold(
        body: SafeLayout((context, constraints) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Spacer(),
                const GoBack(),
                const Spacer(),
                if (_colorPicker != _ColorPicker.select)
                  Text(_colorPicker.upperName, style: titleStyle),
                const Spacer(),
                AnimatedSize(
                  duration: Durations.short2,
                  curve: Curves.easeInOutCubic,
                  child: switch (_colorPicker) {
                    _ColorPicker.cmyk => _CMYKScreen(updateCMYKval, constraints),
                    _ColorPicker.hsl => _HSLScreen(onChangedHSL, constraints),
                    _ColorPicker.select => _ColorWheel(updateFromWheel, constraints),
                  },
                ),
                const Spacer(flex: 2),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ColorLabel('hue', hue),
                    ColorLabel('color name', _color.rounded.name, style: colorNameStyle),
                    ColorLabel.colorCode('color code', _color.hexCode, updateColorCode),
                  ],
                ),
                const Spacer(flex: 2),
              ],
            ),
          );
        }),
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
