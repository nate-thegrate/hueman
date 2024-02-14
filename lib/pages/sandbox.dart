/// Warning: messy code; view at your own risk.
library;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hueman/data/structs.dart';
import 'package:hueman/data/super_color.dart';
import 'package:hueman/data/super_container.dart';
import 'package:hueman/data/super_text.dart';
import 'package:hueman/data/widgets.dart';

int _r = 0xFF, _g = 0xFF, _b = 0xFF;
double _h = 0, _s = 0, _v = 0;

_ColorPicker _colorPicker = _ColorPicker.rgb;

SuperColor get _color => switch (_colorPicker) {
      _ColorPicker.rgb || _ColorPicker.select => SuperColor.rgb(_r, _g, _b),
      _ColorPicker.hsv => SuperColor.hsv(_h, _s, _v),
    };

class _RGBSlider extends StatelessWidget {
  const _RGBSlider(this.name, this.value, this.onChanged);
  final String name;
  final int value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final SuperColor color = switch (name) {
      'red' => SuperColor.rgb(value, 0, 0),
      'green' => SuperColor.rgb(0, value, 0),
      'blue' => SuperColor.rgb(0, 0, value),
      _ => throw Error(),
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: min(384, context.screenWidth - 65),
          child: SliderTheme(
            data: const SliderThemeData(
              trackHeight: 15,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 15),
            ),
            child: Slider(
              thumbColor: color,
              activeColor: color.withAlpha(0x80),
              inactiveColor: Colors.white24,
              max: 255,
              value: value.toDouble(),
              onChanged: onChanged,
            ),
          ),
        ),
        SuperContainer(
          width: 50,
          margin: const EdgeInsets.only(right: 15),
          alignment: Alignment.centerRight,
          child: Text(
            value.hexByte,
            style: const SuperStyle.mono(size: 18, weight: 500),
          ),
        ),
      ],
    );
  }
}

class _HSVSlider extends StatelessWidget {
  const _HSVSlider(this.hsv, this.onChanged);
  final _HSV hsv;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final SuperColor color = hsv.color;
    final bool isHue = hsv == _HSV.hue;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            hsv.name,
            textAlign: TextAlign.right,
            style: const SuperStyle.sans(size: 14),
          ),
        ),
        SizedBox(
          width: min(context.screenWidth - 160, 720),
          child: SliderTheme(
            data: const SliderThemeData(
              trackHeight: 10,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(
              thumbColor: color,
              activeColor: color.withAlpha(128),
              inactiveColor: Colors.white24,
              max: isHue ? 359 : 1,
              value: hsv.val.toDouble(),
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 50,
          child: Text(
            isHue ? hsv.val.round().toString() : hsv.val.toStringAsFixed(2),
            textAlign: TextAlign.center,
            style: const SuperStyle.sans(size: 16),
          ),
        ),
      ],
    );
  }
}

enum _ColorPicker {
  rgb(Icons.tune),
  hsv(Icons.gradient),
  select(Icons.list);

  const _ColorPicker(this.icon);
  final IconData icon;
  String get upperName => name == 'select' ? 'Select' : name.toUpperCase();

  static List<BottomNavigationBarItem> get navBarItems => [
        for (final value in values)
          BottomNavigationBarItem(
            icon: RotatedBox(
              quarterTurns: value == hsv ? 2 : 0,
              child: Icon(value.icon, size: 50),
            ),
            label: value.upperName,
            tooltip: value.upperName,
            backgroundColor: contrastWith(_color, threshold: 0.01).withAlpha(64),
          ),
      ];
}

class _ColorSelection extends StatelessWidget {
  const _ColorSelection({required this.constraints, required this.updateColor});
  final BoxConstraints constraints;
  final void Function(Color rgb, HSVColor hsv) updateColor;

  @override
  Widget build(BuildContext context) {
    return SuperContainer(
      decoration: BoxDecoration(border: Border.all(color: _color, width: 2)),
      padding: const EdgeInsets.symmetric(vertical: 25),
      constraints: BoxConstraints.loose(Size.fromHeight(constraints.maxHeight - 300)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final color in SuperColors.fullList)
              SizedBox(
                width: 500,
                child: TextButton(
                  style: TextButton.styleFrom(
                    shape: const BeveledRectangleBorder(),
                    foregroundColor: color,
                    backgroundColor: _color == color ? Colors.black45 : null,
                  ),
                  onPressed: () => updateColor(color, HSVColor.fromColor(color)),
                  child: ConstrainedBox(
                    constraints: BoxConstraints.loose(const Size.fromWidth(400)),
                    child: Row(
                      children: [
                        const FixedSpacer.horizontal(12),
                        Text(
                          color.name,
                          style: const SuperStyle.sans(
                            weight: 100,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        SuperContainer(
                          width: 150,
                          height: 40,
                          margin: const EdgeInsets.fromLTRB(0, 8, 20, 8),
                          color: color,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class Sandbox extends StatefulWidget {
  const Sandbox({super.key});

  @override
  State<Sandbox> createState() => _SandboxState();
}

void updateHSV() {
  final hsvColor = HSVColor.fromColor(SuperColor.rgb(_r, _g, _b));
  _h = hsvColor.hue;
  _s = hsvColor.saturation;
  _v = hsvColor.value;
}

void updateColor(SuperColor color) {
  _r = color.red;
  _g = color.green;
  _b = color.blue;

  final hsv = HSVColor.fromColor(color);
  _h = hsv.hue;
  _s = hsv.saturation;
  _v = hsv.value;
}

enum _HSV {
  hue,
  saturation,
  value;

  double get val => switch (this) { hue => _h, saturation => _s, value => _v };
  SuperColor get color => switch (this) {
        hue => SuperColor.hue(_h),
        saturation => SuperColor.hsv(_h, _s, 1),
        value => SuperColor.hsv(_h, _s, _v),
      };
}

class _SandboxState extends State<Sandbox> {
  void colorPickerPicker(int index) => setState(() {
        switch (_colorPicker) {
          case _ColorPicker.rgb:
            updateHSV();
          case _ColorPicker.hsv:
            updateColor(_color);
          default:
            break;
        }
        _colorPicker = _ColorPicker.values[index];
      });

  @override
  void initState() {
    super.initState();
    musicPlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeLayout((context, constraints) {
        final horizontal = constraints.maxHeight < 1000;
        final double width = min(constraints.maxWidth - 50, 500);
        final double height =
            constraints.calcSize((w, h) => min(h - (horizontal ? 420 : 720), 500));
        final double colorBarHeight = constraints.maxHeight < 800 ? 0 : 100;
        final double planeSize =
            constraints.calcSize((w, h) => min(w - 50, h - 420 - colorBarHeight));
        void touchRecognition(details) {
          final Offset offset = details.localPosition;
          double val(double position) => (position / (planeSize - 40)).clamp(0, 1);
          setState(() => _s = val(offset.dx));
          setState(() => _v = 1 - val(offset.dy));
        }

        final bool isK = _color.colorCode == 0x8080FF;

        final colorPicker = switch (_colorPicker) {
          _ColorPicker.rgb => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SuperContainer(
                  width: width,
                  height: height,
                  color: _color,
                  alignment: Alignment.center,
                  child: isK ? const K_glitch() : null,
                ),
                const FixedSpacer(30),
                Flex(
                  direction: horizontal ? Axis.vertical : Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _RGBSlider('red', _r, (value) => setState(() => _r = value.round())),
                    _RGBSlider('green', _g, (value) => setState(() => _g = value.round())),
                    _RGBSlider('blue', _b, (value) => setState(() => _b = value.round())),
                  ],
                ),
              ],
            ),
          _ColorPicker.hsv => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: planeSize,
                  height: planeSize,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Stack(
                          children: [
                            SuperContainer(
                              margin: const EdgeInsets.all(0.5),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [Colors.white, SuperColor.hue(_h)],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onPanStart: touchRecognition,
                              onPanUpdate: touchRecognition,
                              child: const SuperContainer(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, Colors.black],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SuperContainer(
                        margin: const EdgeInsets.fromLTRB(1, 0, 0, 1),
                        alignment: Alignment(2 * _s - 1, 1 - 2 * _v),
                        child: Icon(
                          Icons.add,
                          color: contrastWith(_color),
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ),
                _HSVSlider(_HSV.hue, (value) => setState(() => _h = value)),
                _HSVSlider(_HSV.saturation, (value) => setState(() => _s = value)),
                _HSVSlider(_HSV.value, (value) => setState(() => _v = value)),
                if (colorBarHeight > 0) SuperContainer(width: 500, height: 100, color: _color),
              ],
            ),
          _ColorPicker.select => _ColorSelection(
              constraints: constraints,
              updateColor: (rgb, hsv) => setState(() {
                _r = rgb.red;
                _g = rgb.green;
                _b = rgb.blue;

                _h = hsv.hue;
                _s = hsv.saturation;
                _v = hsv.value;
              }),
            ),
        };
        return Center(
          child: Column(
            children: [
              const Spacer(),
              const GoBack(),
              const Spacer(),
              if (_colorPicker != _ColorPicker.select)
                Text(_colorPicker.upperName, style: const SuperStyle.sans(size: 24)),
              const Spacer(),
              AnimatedSize(
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeInOutCubic,
                child: colorPicker,
              ),
              const Spacer(flex: 2),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ColorLabel('hue', _color.hue.round().toString()),
                  ColorLabel(
                    'color name',
                    _color.rounded.name,
                    style: SuperStyle.sans(
                      color: _color,
                      size: 20,
                      weight: 900,
                      shadows: [
                        Shadow(
                          color: contrastWith(_color, threshold: 0.01).withAlpha(64),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                  ColorLabel.colorCode(
                    'color code',
                    _color.hexCode,
                    (color) => setState(() => updateColor(color)),
                  ),
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
    );
  }
}
