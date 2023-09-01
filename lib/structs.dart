import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:super_hueman/inverse_pages/tense.dart';
import 'package:super_hueman/inverse_pages/trivial.dart';
import 'package:super_hueman/inverse_pages/ads.dart';
import 'package:super_hueman/inverse_pages/true_mastery.dart';
import 'package:super_hueman/pages/intense_master.dart';
import 'package:super_hueman/pages/intro.dart';
import 'package:super_hueman/inverse_pages/menu.dart';
import 'package:super_hueman/inverse_pages/sandbox.dart';
import 'package:super_hueman/pages/menu.dart';
import 'package:super_hueman/pages/sandbox.dart';
import 'package:super_hueman/save_data.dart';
import 'package:url_launcher/url_launcher.dart';

/// ```dart
///
/// await sleep(3); // in an async function
/// sleep(3).then((_) => do_something()); // use anywhere
/// ```
/// Just like `time.sleep(3)` in Python.
Future<void> sleep(double seconds) =>
    Future.delayed(Duration(milliseconds: (seconds * 1000).toInt()));

const Curve curve = Curves.easeOutCubic;

enum Pages {
  mainMenu(MainMenu()),
  intro3(IntroMode(3)),
  intro6(IntroMode(6)),
  intro12(IntroMode(12)),
  intense(IntenseMode()),
  master(IntenseMode('master')),
  sandbox(Sandbox()),
  ads(Ads()),

  inverseMenu(InverseMenu()),
  trivial(TriviaMode()),
  tenseVibrant(TenseMode('vibrant')),
  tenseMixed(TenseMode('mixed')),
  trueMastery(TrueMastery()),
  inverseSandbox(InverseSandbox()),
  ;

  final Widget widget;
  const Pages(this.widget);

  String call() {
    if (name.contains('intro')) return '${name.substring(5)} colors';
    if (name.startsWith('tense')) return name.substring(5).toLowerCase();

    return {
          'inverseMenu': 'invert!',
          'inverseSandbox': 'sandbox',
          'trueMastery': 'true\nmastery',
        }[name] ??
        name;
  }

  static Map<String, WidgetBuilder> routes = {
    for (final page in values) page.name: (context) => page.widget
  };

  String get gameMode {
    switch (this) {
      case intro3:
        return 'intro  (3 colors)';
      case intro6:
        return 'intro  (6 colors)';
      case intro12:
        return 'intro  (12 colors)';
      case intense:
        return 'Intense';
      case master:
        return 'Master';
      case tenseVibrant:
        return 'Tense (vibrant)';
      case tenseMixed:
        return 'Tense (mixed!)';
      default:
        return "lol this shouldn't pop up";
    }
  }
}

abstract class ScoreKeeper {
  Pages get page;
  Widget get midRoundDisplay;
  Widget get finalDetails;
  Widget get finalScore;
  void scoreTheRound();
  void roundCheck(BuildContext context);
}

/// less stuff to type now :)
extension ContextStuff on BuildContext {
  void goto(Pages page) => Navigator.pushReplacementNamed(this, page.name);

  void invert() => Navigator.pushReplacement(
        this,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) =>
              inverted ? const MainMenu() : const InverseMenu(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );

  Size get _size => MediaQuery.of(this).size;
  double get screenWidth => _size.width;
  double get screenHeight => _size.height;

  bool get squished => screenHeight < 1040;
}

void Function() gotoWebsite(String url) => () => launchUrl(Uri.parse(url));

void addListener(ValueChanged<RawKeyEvent> func) => RawKeyboard.instance.addListener(func);
void yeetListener(ValueChanged<RawKeyEvent> func) => RawKeyboard.instance.removeListener(func);

Color contrastWith(Color c, {double threshold = .2}) =>
    (c.computeLuminance() > threshold) ? Colors.black : Colors.white;

class SuperColor extends Color {
  final int colorCode;

  final String name;
  static const opaque = 0xFF000000;

  const SuperColor(this.name, this.colorCode) : super(colorCode + opaque);

  const SuperColor.noName(this.colorCode)
      : name = '[none]',
        super(colorCode + opaque);

  factory SuperColor.rgb(int r, int g, int b) {
    final int colorCode = (r << 16) + (g << 8) + b;
    for (final superColor in SuperColors.fullList) {
      if (colorCode == superColor.colorCode) return superColor;
    }

    return SuperColor.noName(colorCode);
  }

  factory SuperColor.hsv(num h, double s, double v) {
    if (s == 1 && v == 1 && h % 30 == 0) return SuperColors.twelveHues[h ~/ 30];
    if (v == 0) return SuperColors.black;
    if (s == 0) {
      if (v == 1) return SuperColors.white;
      if (v == 0.5) return SuperColors.gray;
    }

    final int colorCode = HSVColor.fromAHSV(0, h.toDouble(), s, v).toColor().value;
    return SuperColor.noName(colorCode);
  }

  factory SuperColor.hue(num h) => SuperColor.hsv(h % 360, 1, 1);

  factory SuperColor.hsl(num h, double s, double l) {
    if (l == 0) return SuperColors.black;
    if (l == 1) return SuperColors.white;
    if (s == 0 && l == 0.5) return SuperColors.gray;
    if (s == 1 && l == 0.5 && h % 30 == 0) return SuperColors.twelveHues[h ~/ 30];

    final int colorCode = HSLColor.fromAHSL(0, h.toDouble(), s, l).toColor().value;
    return SuperColor.noName(colorCode);
  }

  num get hue {
    final int i = SuperColors.twelveHues.indexOf(this);
    return i == -1 ? HSVColor.fromColor(this).hue : i * 30;
  }

  /// The hexadecimal color code (doesn't include alpha).
  String get hexCode => '#${colorCode.toRadixString(16).padLeft(6, "0").toUpperCase()}';

  SuperColor get rounded {
    int snapToVals(int rgbVal) {
      const int tolerance = 0x0F;
      for (final int snappable in [0x00, 0x80, 0xFF]) {
        if ((rgbVal - snappable).abs() <= tolerance) return snappable;
      }
      return rgbVal;
    }

    return SuperColor.rgb(snapToVals(red), snapToVals(green), snapToVals(blue));
  }
}

abstract class SuperColors {
  static const red = SuperColor('red', 0xFF0000);
  static const orange = SuperColor('orange', 0xFF8000);
  static const yellow = SuperColor('yellow', 0xFFFF00);
  static const lime = SuperColor('lime', 0x80FF00);
  static const green = SuperColor('green', 0x00FF00);
  static const spring = SuperColor('spring', 0x00FF80);
  static const cyan = SuperColor('cyan', 0x00FFFF);
  static const azure = SuperColor('azure', 0x0080FF);
  static const blue = SuperColor('blue', 0x0000FF);
  static const violet = SuperColor('violet', 0x8000FF);
  static const magenta = SuperColor('magenta', 0xFF00FF);
  static const rose = SuperColor('rose', 0xFF0080);

  static const white = SuperColor('white', 0xFFFFFF);
  static const gray = SuperColor('gray', 0x808080);
  static const black = SuperColor('black', 0x000000);

  static const darkBackground = SuperColor.noName(0x121212);
  static const lightBackground = SuperColor.noName(0xffeef3f8);
  static const inverting = SuperColor.noName(0xf5faff);

  static const black80 = Color(0xCC000000);
  static const white80 = Color(0xCCFFFFFF);

  static const primaries = [red, green, blue];
  static const allPrimaries = [red, yellow, green, cyan, blue, magenta];
  static const twelveHues = [
    red,
    orange,
    yellow,
    lime,
    green,
    spring,
    cyan,
    azure,
    blue,
    violet,
    magenta,
    rose,
  ];
  static const fullList = [
    red,
    orange,
    yellow,
    lime,
    green,
    spring,
    cyan,
    azure,
    blue,
    violet,
    magenta,
    rose,
    white,
    gray,
    black,
  ];
}

const List<SuperColor> epicColors = [
  SuperColor.noName(0xffa3a3),
  SuperColor.noName(0xffa3a1),
  SuperColor.noName(0xffa39f),
  SuperColor.noName(0xffa49f),
  SuperColor.noName(0xffa49d),
  SuperColor.noName(0xffa49b),
  SuperColor.noName(0xffa499),
  SuperColor.noName(0xffa497),
  SuperColor.noName(0xffa597),
  SuperColor.noName(0xffa493),
  SuperColor.noName(0xffa593),
  SuperColor.noName(0xffa48f),
  SuperColor.noName(0xffa48d),
  SuperColor.noName(0xffa48b),
  SuperColor.noName(0xffa68b),
  SuperColor.noName(0xffa587),
  SuperColor.noName(0xffa685),
  SuperColor.noName(0xffa683),
  SuperColor.noName(0xffa680),
  SuperColor.noName(0xffa57c),
  SuperColor.noName(0xffa578),
  SuperColor.noName(0xffa778),
  SuperColor.noName(0xffa774),
  SuperColor.noName(0xffa770),
  SuperColor.noName(0xffa76c),
  SuperColor.noName(0xffa768),
  SuperColor.noName(0xffa764),
  SuperColor.noName(0xffa760),
  SuperColor.noName(0xffa85c),
  SuperColor.noName(0xffa958),
  SuperColor.noName(0xffa954),
  SuperColor.noName(0xffa84c),
  SuperColor.noName(0xffa948),
  SuperColor.noName(0xffa940),
  SuperColor.noName(0xffa938),
  SuperColor.noName(0xffa930),
  SuperColor.noName(0xffa928),
  SuperColor.noName(0xffa920),
  SuperColor.noName(0xffaa18),
  SuperColor.noName(0xffab10),
  SuperColor.noName(0xffaa00),
  SuperColor.noName(0xfbac00),
  SuperColor.noName(0xf7ad00),
  SuperColor.noName(0xf5b000),
  SuperColor.noName(0xf1b100),
  SuperColor.noName(0xedb200),
  SuperColor.noName(0xebb400),
  SuperColor.noName(0xe7b500),
  SuperColor.noName(0xe3b600),
  SuperColor.noName(0xe1b800),
  SuperColor.noName(0xddb800),
  SuperColor.noName(0xdbba00),
  SuperColor.noName(0xd7ba00),
  SuperColor.noName(0xd5bc00),
  SuperColor.noName(0xd1bc00),
  SuperColor.noName(0xcfbe00),
  SuperColor.noName(0xcbbe00),
  SuperColor.noName(0xc9bf00),
  SuperColor.noName(0xc7c100),
  SuperColor.noName(0xc5c200),
  SuperColor.noName(0xc2c200),
  SuperColor.noName(0xc0c300),
  SuperColor.noName(0xbdc300),
  SuperColor.noName(0xbbc500),
  SuperColor.noName(0xb8c500),
  SuperColor.noName(0xb5c500),
  SuperColor.noName(0xb3c700),
  SuperColor.noName(0xb0c700),
  SuperColor.noName(0xadc700),
  SuperColor.noName(0xabc900),
  SuperColor.noName(0xa8c900),
  SuperColor.noName(0xa4c900),
  SuperColor.noName(0xa3cb00),
  SuperColor.noName(0x9fcb00),
  SuperColor.noName(0x9ccb00),
  SuperColor.noName(0x99cc00),
  SuperColor.noName(0x96cd00),
  SuperColor.noName(0x93cd00),
  SuperColor.noName(0x90cd00),
  SuperColor.noName(0x8ecf00),
  SuperColor.noName(0x8acf00),
  SuperColor.noName(0x87cf00),
  SuperColor.noName(0x84d000),
  SuperColor.noName(0x81d100),
  SuperColor.noName(0x7ed100),
  SuperColor.noName(0x7ad100),
  SuperColor.noName(0x77d100),
  SuperColor.noName(0x74d300),
  SuperColor.noName(0x71d300),
  SuperColor.noName(0x6dd300),
  SuperColor.noName(0x6ad300),
  SuperColor.noName(0x67d500),
  SuperColor.noName(0x63d500),
  SuperColor.noName(0x60d500),
  SuperColor.noName(0x5cd500),
  SuperColor.noName(0x59d500),
  SuperColor.noName(0x55d500),
  SuperColor.noName(0x52d700),
  SuperColor.noName(0x4fd700),
  SuperColor.noName(0x4bd700),
  SuperColor.noName(0x48d700),
  SuperColor.noName(0x44d700),
  SuperColor.noName(0x41d700),
  SuperColor.noName(0x3dd700),
  SuperColor.noName(0x3ad800),
  SuperColor.noName(0x36d900),
  SuperColor.noName(0x33d900),
  SuperColor.noName(0x2fd900),
  SuperColor.noName(0x2bd900),
  SuperColor.noName(0x28d900),
  SuperColor.noName(0x24d900),
  SuperColor.noName(0x21d900),
  SuperColor.noName(0x1dd900),
  SuperColor.noName(0x19d900),
  SuperColor.noName(0x16d900),
  SuperColor.noName(0x12d900),
  SuperColor.noName(0x0ed900),
  SuperColor.noName(0x0bd900),
  SuperColor.noName(0x07d900),
  SuperColor.noName(0x04d900),
  SuperColor.noName(0x00d900),
  SuperColor.noName(0x00d904),
  SuperColor.noName(0x00d907),
  SuperColor.noName(0x00d90b),
  SuperColor.noName(0x00d90e),
  SuperColor.noName(0x00d912),
  SuperColor.noName(0x00d916),
  SuperColor.noName(0x00d919),
  SuperColor.noName(0x00d91d),
  SuperColor.noName(0x00d921),
  SuperColor.noName(0x00d924),
  SuperColor.noName(0x00d928),
  SuperColor.noName(0x00d92b),
  SuperColor.noName(0x00d92f),
  SuperColor.noName(0x00d933),
  SuperColor.noName(0x00d936),
  SuperColor.noName(0x00d93a),
  SuperColor.noName(0x00d93e),
  SuperColor.noName(0x00d941),
  SuperColor.noName(0x00d945),
  SuperColor.noName(0x00d948),
  SuperColor.noName(0x00d94c),
  SuperColor.noName(0x00d950),
  SuperColor.noName(0x00d953),
  SuperColor.noName(0x00d957),
  SuperColor.noName(0x00d95a),
  SuperColor.noName(0x00d95e),
  SuperColor.noName(0x00d861),
  SuperColor.noName(0x00d764),
  SuperColor.noName(0x00d768),
  SuperColor.noName(0x00d76c),
  SuperColor.noName(0x00d76f),
  SuperColor.noName(0x00d773),
  SuperColor.noName(0x00d776),
  SuperColor.noName(0x00d77a),
  SuperColor.noName(0x00d77e),
  SuperColor.noName(0x00d781),
  SuperColor.noName(0x00d785),
  SuperColor.noName(0x00d788),
  SuperColor.noName(0x00d78c),
  SuperColor.noName(0x00d58e),
  SuperColor.noName(0x00d592),
  SuperColor.noName(0x00d595),
  SuperColor.noName(0x00d599),
  SuperColor.noName(0x00d59c),
  SuperColor.noName(0x00d5a0),
  SuperColor.noName(0x00d5a3),
  SuperColor.noName(0x00d5a7),
  SuperColor.noName(0x00d4aa),
  SuperColor.noName(0x00d3ac),
  SuperColor.noName(0x00d3b0),
  SuperColor.noName(0x00d3b4),
  SuperColor.noName(0x00d3b7),
  SuperColor.noName(0x00d3bb),
  SuperColor.noName(0x00d3be),
  SuperColor.noName(0x00d3c2),
  SuperColor.noName(0x00d1c3),
  SuperColor.noName(0x00d1c7),
  SuperColor.noName(0x00d1ca),
  SuperColor.noName(0x00d1ce),
  SuperColor.noName(0x00d1d1),
  SuperColor.noName(0x00d0d3),
  SuperColor.noName(0x00d0d7),
  SuperColor.noName(0x00d0db),
  SuperColor.noName(0x00d0df),
  SuperColor.noName(0x00cee1),
  SuperColor.noName(0x00cee5),
  SuperColor.noName(0x00cee9),
  SuperColor.noName(0x00cded),
  SuperColor.noName(0x00cdf1),
  SuperColor.noName(0x00ccf5),
  SuperColor.noName(0x00cbf9),
  SuperColor.noName(0x00ccff),
  SuperColor.noName(0x10cbff),
  SuperColor.noName(0x20cbff),
  SuperColor.noName(0x2ccaff),
  SuperColor.noName(0x38caff),
  SuperColor.noName(0x40c9ff),
  SuperColor.noName(0x48c8ff),
  SuperColor.noName(0x50c7ff),
  SuperColor.noName(0x58c7ff),
  SuperColor.noName(0x5cc6ff),
  SuperColor.noName(0x60c5ff),
  SuperColor.noName(0x68c5ff),
  SuperColor.noName(0x6cc4ff),
  SuperColor.noName(0x70c3ff),
  SuperColor.noName(0x74c3ff),
  SuperColor.noName(0x78c2ff),
  SuperColor.noName(0x7cc2ff),
  SuperColor.noName(0x80c1ff),
  SuperColor.noName(0x83c1ff),
  SuperColor.noName(0x85c0ff),
  SuperColor.noName(0x87bfff),
  SuperColor.noName(0x8bbfff),
  SuperColor.noName(0x8bbeff),
  SuperColor.noName(0x8fbeff),
  SuperColor.noName(0x93beff),
  SuperColor.noName(0x93bdff),
  SuperColor.noName(0x97bdff),
  SuperColor.noName(0x97bcff),
  SuperColor.noName(0x99bbff),
  SuperColor.noName(0x9bbbff),
  SuperColor.noName(0x9dbbff),
  SuperColor.noName(0x9fbaff),
  SuperColor.noName(0xa1baff),
  SuperColor.noName(0xa3baff),
  SuperColor.noName(0xa3b9ff),
  SuperColor.noName(0xa5b9ff),
  SuperColor.noName(0xa7b9ff),
  SuperColor.noName(0xa9b9ff),
  SuperColor.noName(0xa9b8ff),
  SuperColor.noName(0xabb8ff),
  SuperColor.noName(0xadb8ff),
  SuperColor.noName(0xadb7ff),
  SuperColor.noName(0xafb7ff),
  SuperColor.noName(0xafb6ff),
  SuperColor.noName(0xb1b7ff),
  SuperColor.noName(0xb1b5ff),
  SuperColor.noName(0xb3b6ff),
  SuperColor.noName(0xb3b5ff),
  SuperColor.noName(0xb5b5ff),
  SuperColor.noName(0xb7b5ff),
  SuperColor.noName(0xb8b5ff),
  SuperColor.noName(0xb7b3ff),
  SuperColor.noName(0xb8b3ff),
  SuperColor.noName(0xbab3ff),
  SuperColor.noName(0xbbb3ff),
  SuperColor.noName(0xbcb3ff),
  SuperColor.noName(0xbdb3ff),
  SuperColor.noName(0xbeb2ff),
  SuperColor.noName(0xbeb1ff),
  SuperColor.noName(0xc0b1ff),
  SuperColor.noName(0xc1b1ff),
  SuperColor.noName(0xc2b1ff),
  SuperColor.noName(0xc3b1ff),
  SuperColor.noName(0xc4b0ff),
  SuperColor.noName(0xc5afff),
  SuperColor.noName(0xc6afff),
  SuperColor.noName(0xc7afff),
  SuperColor.noName(0xc9afff),
  SuperColor.noName(0xcaafff),
  SuperColor.noName(0xcaadff),
  SuperColor.noName(0xcbadff),
  SuperColor.noName(0xcdadff),
  SuperColor.noName(0xceadff),
  SuperColor.noName(0xcfadff),
  SuperColor.noName(0xd0abff),
  SuperColor.noName(0xd1abff),
  SuperColor.noName(0xd2abff),
  SuperColor.noName(0xd4abff),
  SuperColor.noName(0xd5abff),
  SuperColor.noName(0xd6a9ff),
  SuperColor.noName(0xd7a9ff),
  SuperColor.noName(0xd8a9ff),
  SuperColor.noName(0xd9a7ff),
  SuperColor.noName(0xdaa7ff),
  SuperColor.noName(0xdca7ff),
  SuperColor.noName(0xdda7ff),
  SuperColor.noName(0xdea5ff),
  SuperColor.noName(0xe0a5ff),
  SuperColor.noName(0xe1a5ff),
  SuperColor.noName(0xe2a3ff),
  SuperColor.noName(0xe4a3ff),
  SuperColor.noName(0xe5a3ff),
  SuperColor.noName(0xe7a3ff),
  SuperColor.noName(0xe8a1ff),
  SuperColor.noName(0xe9a1ff),
  SuperColor.noName(0xea9fff),
  SuperColor.noName(0xec9fff),
  SuperColor.noName(0xed9fff),
  SuperColor.noName(0xef9fff),
  SuperColor.noName(0xf09dff),
  SuperColor.noName(0xf29bff),
  SuperColor.noName(0xf39bff),
  SuperColor.noName(0xf59bff),
  SuperColor.noName(0xf79bff),
  SuperColor.noName(0xf899ff),
  SuperColor.noName(0xfa97ff),
  SuperColor.noName(0xfc97ff),
  SuperColor.noName(0xfd97ff),
  SuperColor.noName(0xff95ff),
  SuperColor.noName(0xff97fd),
  SuperColor.noName(0xff97fc),
  SuperColor.noName(0xff97fa),
  SuperColor.noName(0xff97f8),
  SuperColor.noName(0xff97f6),
  SuperColor.noName(0xff97f5),
  SuperColor.noName(0xff97f3),
  SuperColor.noName(0xff97f1),
  SuperColor.noName(0xff97ef),
  SuperColor.noName(0xff97ee),
  SuperColor.noName(0xff99ec),
  SuperColor.noName(0xff99eb),
  SuperColor.noName(0xff99e9),
  SuperColor.noName(0xff99e7),
  SuperColor.noName(0xff9be6),
  SuperColor.noName(0xff9be4),
  SuperColor.noName(0xff9be3),
  SuperColor.noName(0xff9be1),
  SuperColor.noName(0xff9bdf),
  SuperColor.noName(0xff9bde),
  SuperColor.noName(0xff9bdc),
  SuperColor.noName(0xff9bda),
  SuperColor.noName(0xff9bd9),
  SuperColor.noName(0xff9bd7),
  SuperColor.noName(0xff9bd5),
  SuperColor.noName(0xff9dd5),
  SuperColor.noName(0xff9dd3),
  SuperColor.noName(0xff9dd1),
  SuperColor.noName(0xff9dd0),
  SuperColor.noName(0xff9dce),
  SuperColor.noName(0xff9dcd),
  SuperColor.noName(0xff9fcc),
  SuperColor.noName(0xff9fca),
  SuperColor.noName(0xff9fc9),
  SuperColor.noName(0xff9fc7),
  SuperColor.noName(0xff9fc6),
  SuperColor.noName(0xff9fc4),
  SuperColor.noName(0xff9fc2),
  SuperColor.noName(0xff9fc1),
  SuperColor.noName(0xff9fbf),
  SuperColor.noName(0xff9fbe),
  SuperColor.noName(0xff9fbc),
  SuperColor.noName(0xff9fba),
  SuperColor.noName(0xff9fb9),
  SuperColor.noName(0xffa1b9),
  SuperColor.noName(0xffa1b7),
  SuperColor.noName(0xffa1b6),
  SuperColor.noName(0xffa1b4),
  SuperColor.noName(0xffa1b3),
  SuperColor.noName(0xffa1b1),
  SuperColor.noName(0xffa1af),
  SuperColor.noName(0xffa1ae),
  SuperColor.noName(0xffa1ac),
  SuperColor.noName(0xffa3ad),
  SuperColor.noName(0xffa3ab),
  SuperColor.noName(0xffa3a9),
  SuperColor.noName(0xffa3a8),
  SuperColor.noName(0xffa3a6),
  SuperColor.noName(0xffa3a5),
];
const List<SuperColor> inverseColors = [
  SuperColor.noName(0x9e0000),
  SuperColor.noName(0x9d0300),
  SuperColor.noName(0x9c0500),
  SuperColor.noName(0x9c0800),
  SuperColor.noName(0x9b0a00),
  SuperColor.noName(0x9b0d00),
  SuperColor.noName(0x9a0f00),
  SuperColor.noName(0x991200),
  SuperColor.noName(0x981400),
  SuperColor.noName(0x971700),
  SuperColor.noName(0x961900),
  SuperColor.noName(0x951b00),
  SuperColor.noName(0x941e00),
  SuperColor.noName(0x932000),
  SuperColor.noName(0x922200),
  SuperColor.noName(0x902400),
  SuperColor.noName(0x8f2600),
  SuperColor.noName(0x8d2800),
  SuperColor.noName(0x8c2a00),
  SuperColor.noName(0x8a2c00),
  SuperColor.noName(0x892e00),
  SuperColor.noName(0x872f00),
  SuperColor.noName(0x863100),
  SuperColor.noName(0x843300),
  SuperColor.noName(0x823400),
  SuperColor.noName(0x803600),
  SuperColor.noName(0x7f3700),
  SuperColor.noName(0x7d3800),
  SuperColor.noName(0x7b3a00),
  SuperColor.noName(0x7a3b00),
  SuperColor.noName(0x783c00),
  SuperColor.noName(0x763d00),
  SuperColor.noName(0x753e00),
  SuperColor.noName(0x733f00),
  SuperColor.noName(0x714000),
  SuperColor.noName(0x704100),
  SuperColor.noName(0x6e4200),
  SuperColor.noName(0x6c4300),
  SuperColor.noName(0x6b4400),
  SuperColor.noName(0x694400),
  SuperColor.noName(0x684500),
  SuperColor.noName(0x664600),
  SuperColor.noName(0x654700),
  SuperColor.noName(0x634700),
  SuperColor.noName(0x624800),
  SuperColor.noName(0x614800),
  SuperColor.noName(0x5f4900),
  SuperColor.noName(0x5e4a00),
  SuperColor.noName(0x5d4a00),
  SuperColor.noName(0x5b4b00),
  SuperColor.noName(0x5a4b00),
  SuperColor.noName(0x594c00),
  SuperColor.noName(0x584c00),
  SuperColor.noName(0x564c00),
  SuperColor.noName(0x554d00),
  SuperColor.noName(0x544d00),
  SuperColor.noName(0x534e00),
  SuperColor.noName(0x524e00),
  SuperColor.noName(0x514e00),
  SuperColor.noName(0x504f00),
  SuperColor.noName(0x4f4f00),
  SuperColor.noName(0x4e4f00),
  SuperColor.noName(0x4d4f00),
  SuperColor.noName(0x4c5000),
  SuperColor.noName(0x4b5000),
  SuperColor.noName(0x4a5000),
  SuperColor.noName(0x495100),
  SuperColor.noName(0x475100),
  SuperColor.noName(0x465100),
  SuperColor.noName(0x455100),
  SuperColor.noName(0x445200),
  SuperColor.noName(0x435200),
  SuperColor.noName(0x425200),
  SuperColor.noName(0x415200),
  SuperColor.noName(0x3f5300),
  SuperColor.noName(0x3e5300),
  SuperColor.noName(0x3d5300),
  SuperColor.noName(0x3c5400),
  SuperColor.noName(0x3b5400),
  SuperColor.noName(0x395400),
  SuperColor.noName(0x385400),
  SuperColor.noName(0x375400),
  SuperColor.noName(0x365500),
  SuperColor.noName(0x345500),
  SuperColor.noName(0x335500),
  SuperColor.noName(0x325500),
  SuperColor.noName(0x305600),
  SuperColor.noName(0x2f5600),
  SuperColor.noName(0x2e5600),
  SuperColor.noName(0x2c5600),
  SuperColor.noName(0x2b5600),
  SuperColor.noName(0x2a5600),
  SuperColor.noName(0x285700),
  SuperColor.noName(0x275700),
  SuperColor.noName(0x265700),
  SuperColor.noName(0x245700),
  SuperColor.noName(0x235700),
  SuperColor.noName(0x225700),
  SuperColor.noName(0x205800),
  SuperColor.noName(0x1f5800),
  SuperColor.noName(0x1d5800),
  SuperColor.noName(0x1c5800),
  SuperColor.noName(0x1a5800),
  SuperColor.noName(0x195800),
  SuperColor.noName(0x185800),
  SuperColor.noName(0x165800),
  SuperColor.noName(0x155900),
  SuperColor.noName(0x135900),
  SuperColor.noName(0x125900),
  SuperColor.noName(0x105900),
  SuperColor.noName(0x0f5900),
  SuperColor.noName(0x0d5900),
  SuperColor.noName(0x0c5900),
  SuperColor.noName(0x0a5900),
  SuperColor.noName(0x095900),
  SuperColor.noName(0x075900),
  SuperColor.noName(0x065900),
  SuperColor.noName(0x045900),
  SuperColor.noName(0x035900),
  SuperColor.noName(0x015900),
  SuperColor.noName(0x005900),
  SuperColor.noName(0x005901),
  SuperColor.noName(0x005903),
  SuperColor.noName(0x005904),
  SuperColor.noName(0x005906),
  SuperColor.noName(0x005907),
  SuperColor.noName(0x005909),
  SuperColor.noName(0x00590a),
  SuperColor.noName(0x00590c),
  SuperColor.noName(0x00590d),
  SuperColor.noName(0x00590f),
  SuperColor.noName(0x005910),
  SuperColor.noName(0x005912),
  SuperColor.noName(0x005913),
  SuperColor.noName(0x005915),
  SuperColor.noName(0x005916),
  SuperColor.noName(0x005918),
  SuperColor.noName(0x005919),
  SuperColor.noName(0x00591b),
  SuperColor.noName(0x00591c),
  SuperColor.noName(0x00591e),
  SuperColor.noName(0x00591f),
  SuperColor.noName(0x005921),
  SuperColor.noName(0x005922),
  SuperColor.noName(0x005923),
  SuperColor.noName(0x005925),
  SuperColor.noName(0x005926),
  SuperColor.noName(0x005928),
  SuperColor.noName(0x005829),
  SuperColor.noName(0x00582b),
  SuperColor.noName(0x00582c),
  SuperColor.noName(0x00582e),
  SuperColor.noName(0x00582f),
  SuperColor.noName(0x005830),
  SuperColor.noName(0x005832),
  SuperColor.noName(0x005833),
  SuperColor.noName(0x005835),
  SuperColor.noName(0x005836),
  SuperColor.noName(0x005838),
  SuperColor.noName(0x005839),
  SuperColor.noName(0x00583a),
  SuperColor.noName(0x00573c),
  SuperColor.noName(0x00573d),
  SuperColor.noName(0x00573f),
  SuperColor.noName(0x005740),
  SuperColor.noName(0x005741),
  SuperColor.noName(0x005743),
  SuperColor.noName(0x005744),
  SuperColor.noName(0x005745),
  SuperColor.noName(0x005747),
  SuperColor.noName(0x005748),
  SuperColor.noName(0x00564a),
  SuperColor.noName(0x00564b),
  SuperColor.noName(0x00564c),
  SuperColor.noName(0x00564e),
  SuperColor.noName(0x00564f),
  SuperColor.noName(0x005650),
  SuperColor.noName(0x005651),
  SuperColor.noName(0x005653),
  SuperColor.noName(0x005654),
  SuperColor.noName(0x005555),
  SuperColor.noName(0x005557),
  SuperColor.noName(0x005558),
  SuperColor.noName(0x005559),
  SuperColor.noName(0x00555b),
  SuperColor.noName(0x00555c),
  SuperColor.noName(0x00545e),
  SuperColor.noName(0x00545f),
  SuperColor.noName(0x005461),
  SuperColor.noName(0x005463),
  SuperColor.noName(0x005464),
  SuperColor.noName(0x005366),
  SuperColor.noName(0x005368),
  SuperColor.noName(0x00536a),
  SuperColor.noName(0x00536c),
  SuperColor.noName(0x00526e),
  SuperColor.noName(0x005270),
  SuperColor.noName(0x005272),
  SuperColor.noName(0x005174),
  SuperColor.noName(0x005177),
  SuperColor.noName(0x005179),
  SuperColor.noName(0x00507b),
  SuperColor.noName(0x00507e),
  SuperColor.noName(0x004f81),
  SuperColor.noName(0x004f83),
  SuperColor.noName(0x004e86),
  SuperColor.noName(0x004e89),
  SuperColor.noName(0x004d8c),
  SuperColor.noName(0x004c8f),
  SuperColor.noName(0x004c93),
  SuperColor.noName(0x004b96),
  SuperColor.noName(0x004a99),
  SuperColor.noName(0x00499d),
  SuperColor.noName(0x0048a1),
  SuperColor.noName(0x0047a4),
  SuperColor.noName(0x0046a8),
  SuperColor.noName(0x0045ac),
  SuperColor.noName(0x0044b0),
  SuperColor.noName(0x0042b4),
  SuperColor.noName(0x0041b9),
  SuperColor.noName(0x003fbd),
  SuperColor.noName(0x003dc1),
  SuperColor.noName(0x003bc6),
  SuperColor.noName(0x0039ca),
  SuperColor.noName(0x0037cf),
  SuperColor.noName(0x0035d3),
  SuperColor.noName(0x0032d7),
  SuperColor.noName(0x0030dc),
  SuperColor.noName(0x002de0),
  SuperColor.noName(0x002ae4),
  SuperColor.noName(0x0027e7),
  SuperColor.noName(0x0023eb),
  SuperColor.noName(0x0020ee),
  SuperColor.noName(0x001cf2),
  SuperColor.noName(0x0018f4),
  SuperColor.noName(0x0015f7),
  SuperColor.noName(0x0011f9),
  SuperColor.noName(0x000dfb),
  SuperColor.noName(0x0008fc),
  SuperColor.noName(0x0004fe),
  SuperColor.noName(0x0000ff),
  SuperColor.noName(0x0400ff),
  SuperColor.noName(0x0800fe),
  SuperColor.noName(0x0d00fe),
  SuperColor.noName(0x1100fd),
  SuperColor.noName(0x1500fd),
  SuperColor.noName(0x1900fc),
  SuperColor.noName(0x1d00fb),
  SuperColor.noName(0x2100fa),
  SuperColor.noName(0x2500f9),
  SuperColor.noName(0x2900f7),
  SuperColor.noName(0x2d00f6),
  SuperColor.noName(0x3100f5),
  SuperColor.noName(0x3500f3),
  SuperColor.noName(0x3800f1),
  SuperColor.noName(0x3c00f0),
  SuperColor.noName(0x3f00ee),
  SuperColor.noName(0x4300ec),
  SuperColor.noName(0x4600ea),
  SuperColor.noName(0x4900e7),
  SuperColor.noName(0x4c00e5),
  SuperColor.noName(0x4f00e3),
  SuperColor.noName(0x5200e1),
  SuperColor.noName(0x5500de),
  SuperColor.noName(0x5800dc),
  SuperColor.noName(0x5b00d9),
  SuperColor.noName(0x5d00d7),
  SuperColor.noName(0x5f00d4),
  SuperColor.noName(0x6200d2),
  SuperColor.noName(0x6400cf),
  SuperColor.noName(0x6600cc),
  SuperColor.noName(0x6800ca),
  SuperColor.noName(0x6a00c7),
  SuperColor.noName(0x6c00c5),
  SuperColor.noName(0x6e00c2),
  SuperColor.noName(0x7000c0),
  SuperColor.noName(0x7100bd),
  SuperColor.noName(0x7300bb),
  SuperColor.noName(0x7500b8),
  SuperColor.noName(0x7600b6),
  SuperColor.noName(0x7700b3),
  SuperColor.noName(0x7900b1),
  SuperColor.noName(0x7a00ae),
  SuperColor.noName(0x7b00ac),
  SuperColor.noName(0x7d00aa),
  SuperColor.noName(0x7e00a8),
  SuperColor.noName(0x7f00a5),
  SuperColor.noName(0x8000a3),
  SuperColor.noName(0x8100a1),
  SuperColor.noName(0x82009f),
  SuperColor.noName(0x83009d),
  SuperColor.noName(0x83009b),
  SuperColor.noName(0x840099),
  SuperColor.noName(0x850097),
  SuperColor.noName(0x860095),
  SuperColor.noName(0x870093),
  SuperColor.noName(0x870091),
  SuperColor.noName(0x88008f),
  SuperColor.noName(0x89008d),
  SuperColor.noName(0x89008c),
  SuperColor.noName(0x8a008a),
  SuperColor.noName(0x8a0088),
  SuperColor.noName(0x8b0086),
  SuperColor.noName(0x8c0085),
  SuperColor.noName(0x8c0083),
  SuperColor.noName(0x8d0081),
  SuperColor.noName(0x8d007f),
  SuperColor.noName(0x8e007d),
  SuperColor.noName(0x8e007b),
  SuperColor.noName(0x8f0079),
  SuperColor.noName(0x8f0078),
  SuperColor.noName(0x900076),
  SuperColor.noName(0x900074),
  SuperColor.noName(0x910072),
  SuperColor.noName(0x910070),
  SuperColor.noName(0x92006d),
  SuperColor.noName(0x92006b),
  SuperColor.noName(0x930069),
  SuperColor.noName(0x930067),
  SuperColor.noName(0x940065),
  SuperColor.noName(0x940063),
  SuperColor.noName(0x950061),
  SuperColor.noName(0x95005e),
  SuperColor.noName(0x96005c),
  SuperColor.noName(0x96005a),
  SuperColor.noName(0x960058),
  SuperColor.noName(0x970055),
  SuperColor.noName(0x970053),
  SuperColor.noName(0x980051),
  SuperColor.noName(0x98004e),
  SuperColor.noName(0x98004c),
  SuperColor.noName(0x99004a),
  SuperColor.noName(0x990047),
  SuperColor.noName(0x990045),
  SuperColor.noName(0x990043),
  SuperColor.noName(0x9a0040),
  SuperColor.noName(0x9a003e),
  SuperColor.noName(0x9a003b),
  SuperColor.noName(0x9b0039),
  SuperColor.noName(0x9b0036),
  SuperColor.noName(0x9b0034),
  SuperColor.noName(0x9b0031),
  SuperColor.noName(0x9b002f),
  SuperColor.noName(0x9c002c),
  SuperColor.noName(0x9c002a),
  SuperColor.noName(0x9c0027),
  SuperColor.noName(0x9c0024),
  SuperColor.noName(0x9c0022),
  SuperColor.noName(0x9d001f),
  SuperColor.noName(0x9d001d),
  SuperColor.noName(0x9d001a),
  SuperColor.noName(0x9d0018),
  SuperColor.noName(0x9d0015),
  SuperColor.noName(0x9d0012),
  SuperColor.noName(0x9d0010),
  SuperColor.noName(0x9d000d),
  SuperColor.noName(0x9d000a),
  SuperColor.noName(0x9d0008),
  SuperColor.noName(0x9d0005),
  SuperColor.noName(0x9d0003),
];

const int _epicStepSize = 60;
int epicHue = 0, inverseHue = 0;
late int _lastEpicChange;

/// a [Color] with [epicHue] as its hue.
///
/// The color is retrieved from [epicColors],
/// where all colors have the same luminosity.
Color get epicColor => epicColors[epicHue];

/// similar to [epicColor], but the color is darker.
///
/// It also cycles the reverse way through the hues.
Color get inverseColor => inverseColors[inverseHue];
Ticker epicSetup(StateSetter setState) {
  void epicCycle(Duration elapsed) {
    if (elapsed.inMilliseconds >= _lastEpicChange + _epicStepSize) {
      _lastEpicChange += _epicStepSize;
      setState(() => epicHue = ++epicHue % 360);
    }
  }

  epicHue = rng.nextInt(360);
  _lastEpicChange = 0;
  final Ticker epicHues = Ticker(epicCycle)..start();

  return epicHues;
}

Ticker inverseSetup(StateSetter setState) {
  void inverseCycle(Duration elapsed) {
    setState(() => inverseHue = --inverseHue % 360);
  }

  inverseHue = rng.nextInt(360);
  final Ticker inverseHues = Ticker(inverseCycle)..start();

  return inverseHues;
}

extension ToInt on TextEditingValue {
  int toInt() => text.isEmpty ? 0 : int.parse(text);
}

final rng = Random();
