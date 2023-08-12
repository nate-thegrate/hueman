import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:super_hueman/pages/intense.dart';
import 'package:super_hueman/pages/intro.dart';
import 'package:super_hueman/pages/main_menu.dart';
import 'package:super_hueman/pages/sandbox.dart';

/// ```dart
///
/// await sleep(3);
/// ```
/// is just like `time.sleep(3)` in Python.
///
/// Must be called in an `async` function.
Future<void> sleep(double seconds) =>
    Future.delayed(Duration(milliseconds: (seconds * 1000).toInt()));

enum Pages {
  mainMenu(MainMenu()),
  intro3(IntroMode(3)),
  intro6(IntroMode(6)),
  intro12(IntroMode(12)),
  intense(IntenseMode()),
  master(IntenseMode('master')),
  sandbox(Sandbox()),
  ;

  final Widget widget;
  const Pages(this.widget);

  String call() {
    if (name.contains('intro')) {
      return '${name.substring(5)} colors';
    }
    return name;
  }

  static Map<String, WidgetBuilder> routes = {
    for (final page in values) page(): (context) => page.widget
  };
}

enum KeepScore {
  none,
  accuracy,
  time;

  bool get active => this != KeepScore.none;
  String call() => name == 'time' ? 'accuracy + time' : name;

  static List<Widget> radioList({required void Function(KeepScore?) onChanged}) => [
        for (final value in values)
          RadioListTile<KeepScore>(
            title: Text(value()),
            value: value,
            groupValue: keepScore,
            onChanged: onChanged,
          ),
      ];
}

KeepScore keepScore = KeepScore.none;
bool autoSubmit = false;

extension ContextStuff on BuildContext {
  /// less stuff to type now :)
  void goto(Pages page) => Navigator.pushReplacementNamed(this, page());
}

void addListener(ValueChanged<RawKeyEvent> func) => RawKeyboard.instance.addListener(func);
void yeetListener(ValueChanged<RawKeyEvent> func) => RawKeyboard.instance.removeListener(func);

Color hsv(int h, double s, double v) => HSVColor.fromAHSV(1, h.toDouble(), s, v).toColor();

Color contrastWith(Color c) => (c.computeLuminance() > .2) ? Colors.black : Colors.white;

const List<int> _epicColors = [
  0xffffa3a3,
  0xffffa3a1,
  0xffffa39f,
  0xffffa49f,
  0xffffa49d,
  0xffffa49b,
  0xffffa499,
  0xffffa497,
  0xffffa597,
  0xffffa493,
  0xffffa593,
  0xffffa48f,
  0xffffa48d,
  0xffffa48b,
  0xffffa68b,
  0xffffa587,
  0xffffa685,
  0xffffa683,
  0xffffa680,
  0xffffa57c,
  0xffffa578,
  0xffffa778,
  0xffffa774,
  0xffffa770,
  0xffffa76c,
  0xffffa768,
  0xffffa764,
  0xffffa760,
  0xffffa85c,
  0xffffa958,
  0xffffa954,
  0xffffa84c,
  0xffffa948,
  0xffffa940,
  0xffffa938,
  0xffffa930,
  0xffffa928,
  0xffffa920,
  0xffffaa18,
  0xffffab10,
  0xffffaa00,
  0xfffbac00,
  0xfff7ad00,
  0xfff5b000,
  0xfff1b100,
  0xffedb200,
  0xffebb400,
  0xffe7b500,
  0xffe3b600,
  0xffe1b800,
  0xffddb800,
  0xffdbba00,
  0xffd7ba00,
  0xffd5bc00,
  0xffd1bc00,
  0xffcfbe00,
  0xffcbbe00,
  0xffc9bf00,
  0xffc7c100,
  0xffc5c200,
  0xffc2c200,
  0xffc0c300,
  0xffbdc300,
  0xffbbc500,
  0xffb8c500,
  0xffb5c500,
  0xffb3c700,
  0xffb0c700,
  0xffadc700,
  0xffabc900,
  0xffa8c900,
  0xffa4c900,
  0xffa3cb00,
  0xff9fcb00,
  0xff9ccb00,
  0xff99cc00,
  0xff96cd00,
  0xff93cd00,
  0xff90cd00,
  0xff8ecf00,
  0xff8acf00,
  0xff87cf00,
  0xff84d000,
  0xff81d100,
  0xff7ed100,
  0xff7ad100,
  0xff77d100,
  0xff74d300,
  0xff71d300,
  0xff6dd300,
  0xff6ad300,
  0xff67d500,
  0xff63d500,
  0xff60d500,
  0xff5cd500,
  0xff59d500,
  0xff55d500,
  0xff52d700,
  0xff4fd700,
  0xff4bd700,
  0xff48d700,
  0xff44d700,
  0xff41d700,
  0xff3dd700,
  0xff3ad800,
  0xff36d900,
  0xff33d900,
  0xff2fd900,
  0xff2bd900,
  0xff28d900,
  0xff24d900,
  0xff21d900,
  0xff1dd900,
  0xff19d900,
  0xff16d900,
  0xff12d900,
  0xff0ed900,
  0xff0bd900,
  0xff07d900,
  0xff04d900,
  0xff00d900,
  0xff00d904,
  0xff00d907,
  0xff00d90b,
  0xff00d90e,
  0xff00d912,
  0xff00d916,
  0xff00d919,
  0xff00d91d,
  0xff00d921,
  0xff00d924,
  0xff00d928,
  0xff00d92b,
  0xff00d92f,
  0xff00d933,
  0xff00d936,
  0xff00d93a,
  0xff00d93e,
  0xff00d941,
  0xff00d945,
  0xff00d948,
  0xff00d94c,
  0xff00d950,
  0xff00d953,
  0xff00d957,
  0xff00d95a,
  0xff00d95e,
  0xff00d861,
  0xff00d764,
  0xff00d768,
  0xff00d76c,
  0xff00d76f,
  0xff00d773,
  0xff00d776,
  0xff00d77a,
  0xff00d77e,
  0xff00d781,
  0xff00d785,
  0xff00d788,
  0xff00d78c,
  0xff00d58e,
  0xff00d592,
  0xff00d595,
  0xff00d599,
  0xff00d59c,
  0xff00d5a0,
  0xff00d5a3,
  0xff00d5a7,
  0xff00d4aa,
  0xff00d3ac,
  0xff00d3b0,
  0xff00d3b4,
  0xff00d3b7,
  0xff00d3bb,
  0xff00d3be,
  0xff00d3c2,
  0xff00d1c3,
  0xff00d1c7,
  0xff00d1ca,
  0xff00d1ce,
  0xff00d1d1,
  0xff00d0d3,
  0xff00d0d7,
  0xff00d0db,
  0xff00d0df,
  0xff00cee1,
  0xff00cee5,
  0xff00cee9,
  0xff00cded,
  0xff00cdf1,
  0xff00ccf5,
  0xff00cbf9,
  0xff00ccff,
  0xff10cbff,
  0xff20cbff,
  0xff2ccaff,
  0xff38caff,
  0xff40c9ff,
  0xff48c8ff,
  0xff50c7ff,
  0xff58c7ff,
  0xff5cc6ff,
  0xff60c5ff,
  0xff68c5ff,
  0xff6cc4ff,
  0xff70c3ff,
  0xff74c3ff,
  0xff78c2ff,
  0xff7cc2ff,
  0xff80c1ff,
  0xff83c1ff,
  0xff85c0ff,
  0xff87bfff,
  0xff8bbfff,
  0xff8bbeff,
  0xff8fbeff,
  0xff93beff,
  0xff93bdff,
  0xff97bdff,
  0xff97bcff,
  0xff99bbff,
  0xff9bbbff,
  0xff9dbbff,
  0xff9fbaff,
  0xffa1baff,
  0xffa3baff,
  0xffa3b9ff,
  0xffa5b9ff,
  0xffa7b9ff,
  0xffa9b9ff,
  0xffa9b8ff,
  0xffabb8ff,
  0xffadb8ff,
  0xffadb7ff,
  0xffafb7ff,
  0xffafb6ff,
  0xffb1b7ff,
  0xffb1b5ff,
  0xffb3b6ff,
  0xffb3b5ff,
  0xffb5b5ff,
  0xffb7b5ff,
  0xffb8b5ff,
  0xffb7b3ff,
  0xffb8b3ff,
  0xffbab3ff,
  0xffbbb3ff,
  0xffbcb3ff,
  0xffbdb3ff,
  0xffbeb2ff,
  0xffbeb1ff,
  0xffc0b1ff,
  0xffc1b1ff,
  0xffc2b1ff,
  0xffc3b1ff,
  0xffc4b0ff,
  0xffc5afff,
  0xffc6afff,
  0xffc7afff,
  0xffc9afff,
  0xffcaafff,
  0xffcaadff,
  0xffcbadff,
  0xffcdadff,
  0xffceadff,
  0xffcfadff,
  0xffd0abff,
  0xffd1abff,
  0xffd2abff,
  0xffd4abff,
  0xffd5abff,
  0xffd6a9ff,
  0xffd7a9ff,
  0xffd8a9ff,
  0xffd9a7ff,
  0xffdaa7ff,
  0xffdca7ff,
  0xffdda7ff,
  0xffdea5ff,
  0xffe0a5ff,
  0xffe1a5ff,
  0xffe2a3ff,
  0xffe4a3ff,
  0xffe5a3ff,
  0xffe7a3ff,
  0xffe8a1ff,
  0xffe9a1ff,
  0xffea9fff,
  0xffec9fff,
  0xffed9fff,
  0xffef9fff,
  0xfff09dff,
  0xfff29bff,
  0xfff39bff,
  0xfff59bff,
  0xfff79bff,
  0xfff899ff,
  0xfffa97ff,
  0xfffc97ff,
  0xfffd97ff,
  0xffff95ff,
  0xffff97fd,
  0xffff97fc,
  0xffff97fa,
  0xffff97f8,
  0xffff97f6,
  0xffff97f5,
  0xffff97f3,
  0xffff97f1,
  0xffff97ef,
  0xffff97ee,
  0xffff99ec,
  0xffff99eb,
  0xffff99e9,
  0xffff99e7,
  0xffff9be6,
  0xffff9be4,
  0xffff9be3,
  0xffff9be1,
  0xffff9bdf,
  0xffff9bde,
  0xffff9bdc,
  0xffff9bda,
  0xffff9bd9,
  0xffff9bd7,
  0xffff9bd5,
  0xffff9dd5,
  0xffff9dd3,
  0xffff9dd1,
  0xffff9dd0,
  0xffff9dce,
  0xffff9dcd,
  0xffff9fcc,
  0xffff9fca,
  0xffff9fc9,
  0xffff9fc7,
  0xffff9fc6,
  0xffff9fc4,
  0xffff9fc2,
  0xffff9fc1,
  0xffff9fbf,
  0xffff9fbe,
  0xffff9fbc,
  0xffff9fba,
  0xffff9fb9,
  0xffffa1b9,
  0xffffa1b7,
  0xffffa1b6,
  0xffffa1b4,
  0xffffa1b3,
  0xffffa1b1,
  0xffffa1af,
  0xffffa1ae,
  0xffffa1ac,
  0xffffa3ad,
  0xffffa3ab,
  0xffffa3a9,
  0xffffa3a8,
  0xffffa3a6,
  0xffffa3a5,
];

const int _epicStepSize = 50;
int epicHue = 0;
late int _lastEpicChange;

/// a [Color] with [epicHue] as its hue.
///
/// The color is retrieved from [_epicColors],
/// where all colors have the same luminosity.
Color get epicColor => Color(_epicColors[epicHue]);

Ticker epicSetup(StateSetter setState) {
  void epicCycle(Duration elapsed) {
    if (elapsed.inMilliseconds >= _lastEpicChange + _epicStepSize) {
      _lastEpicChange += _epicStepSize;
      setState(() => epicHue = ++epicHue % 360);
    }
  }

  epicHue = rng.nextInt(360);
  _lastEpicChange = 0;
  final Ticker ticker = Ticker(epicCycle)..start();

  return ticker;
}

const Widget empty = SizedBox.shrink();
const Widget filler = Expanded(child: empty);
Widget vspace(double h) => SizedBox(height: h);
Widget hspace(double w) => SizedBox(width: w);

extension ToInt on TextEditingValue {
  int toInt() => text.isEmpty ? 0 : int.parse(text);
}

extension HexCode on Color {
  /// The hexadecimal color code (doesn't include alpha).
  String get hexCode => '0x${toString().substring(10, 16)}';
}

final rng = Random();
