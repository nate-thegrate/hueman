import 'package:flutter/material.dart';
import 'package:hueman/data/structs.dart';

class SuperColor extends Color {
  const SuperColor(this.colorCode)
      : name = '[none]',
        super(colorCode + opaque);

  const SuperColor.named(this.name, this.colorCode) : super(colorCode + opaque);

  factory SuperColor.rgb(int r, int g, int b) {
    final int colorCode = (r << 16) + (g << 8) + b;
    for (final superColor in SuperColors.fullList) {
      if (colorCode == superColor.colorCode) return superColor;
    }

    return SuperColor(colorCode);
  }

  factory SuperColor.hsv(num h, double s, double v) => switch ((h, s, v)) {
        (_, _, 0) => SuperColors.black,
        (_, 0, 1) => SuperColors.white,
        (_, 0, 0.5) => SuperColors.gray,
        (_, 1, 1) when h % 30 == 0 => SuperColors.twelveHues[h ~/ 30],
        _ => SuperColor(HSVColor.fromAHSV(0, h.toDouble(), s, v).toColor().value),
      };

  factory SuperColor.hsl(num h, double s, double l) => switch ((h, s, l)) {
        (_, _, 0) => SuperColors.black,
        (_, _, 1) => SuperColors.white,
        (_, 0, 0.5) => SuperColors.gray,
        (_, 1, 0.5) when h % 30 == 0 => SuperColors.twelveHues[h ~/ 30],
        _ => SuperColor(HSLColor.fromAHSL(0, h.toDouble(), s, l).toColor().value),
      };

  /// Creates a color with the given hue.
  ///
  /// if a value is passed for [luminance],
  /// the color's lightness will be adjusted to achieve the target luminance.
  factory SuperColor.hue(num hue, [double? luminance]) {
    if (luminance == null) return SuperColor.hsv(hue % 360, 1, 1);

    double max = 1, min = 0;
    double mid() => (max + min) / 2;
    SuperColor color() => SuperColor.hsl(hue, 1, mid());
    for (int i = 0; i < 10; i++) {
      final double currentLuminance = color().computeLuminance();
      if (currentLuminance > luminance) {
        max = mid();
      } else {
        min = mid();
      }
    }
    return color();
  }

  final int colorCode;

  final String name;
  static const opaque = 0xFF000000;

  num get hue {
    final int i = SuperColors.twelveHues.indexOf(this);
    return i == -1 ? HSVColor.fromColor(this).hue : i * 30;
  }

  /// The hexadecimal color code (doesn't include alpha).
  String get hexCode => '#${colorCode.toRadixString(16).padLeft(6, "0").toUpperCase()}';

  @override
  String toString() => switch (name) { '[none]' => hexCode, _ => 'SuperColors.$name ($hexCode)' };

  SuperColor get complement => SuperColor.rgb(0xFF - red, 0xFF - green, 0xFF - blue).rounded;
  SuperColor get rounded {
    // const easterEgg = SuperColor.named('Kali 🙂', 0x8080FF);
    // if (colorCode == 0x8080FF) return easterEgg;

    int snapToVals(int rgbVal) {
      const int tolerance = 0x0F;
      for (final int snappable in [0x00, 0x80, 0xFF]) {
        if (diff(rgbVal, snappable) <= tolerance) return snappable;
      }
      return rgbVal;
    }

    return SuperColor.rgb(snapToVals(red), snapToVals(green), snapToVals(blue));
  }
}

abstract final class SuperColors {
  static const red = SuperColor.named('red', 0xFF0000);
  static const orange = SuperColor.named('orange', 0xFF8000);
  static const yellow = SuperColor.named('yellow', 0xFFFF00);
  static const chartreuse = SuperColor.named('chartreuse', 0x80FF00);
  static const green = SuperColor.named('green', 0x00FF00);
  static const spring = SuperColor.named('spring', 0x00FF80);
  static const cyan = SuperColor.named('cyan', 0x00FFFF);
  static const azure = SuperColor.named('azure', 0x0080FF);
  static const blue = SuperColor.named('blue', 0x0000FF);
  static const violet = SuperColor.named('violet', 0x8000FF);
  static const magenta = SuperColor.named('magenta', 0xFF00FF);
  static const rose = SuperColor.named('rose', 0xFF0080);

  static const white = SuperColor.named('white', 0xFFFFFF);
  static const gray = SuperColor.named('gray', 0x808080);
  static const black = SuperColor.named('black', 0x000000);

  static const lightBackground = SuperColor(0xEEF3F8);
  static const darkBackground = SuperColor(0x121212);
  static const tintedDarkBackground = SuperColor(0x2C2C2C);
  static const bsBackground = SuperColor(0xFFF2D6);
  static const bsBrown = SuperColor(0x6C4B00);
  static const inverting = SuperColor(0xF5FAFF);

  // blue is struggling to be seen, #relatable
  static const visibleBlue = SuperColor.named('blue', 0x1212FF);
  static const visibleYellow = SuperColor.named('yellow', 0xF0F000);

  static const black80 = Color(0xCC000000);
  static const white80 = Color(0xCCFFFFFF);

  static const primaries = [red, green, blue];
  static const subtractivePrimaries = [cyan, magenta, yellow];
  static const allPrimaries = [red, yellow, green, cyan, blue, magenta];
  static const twelveHues = [
    red,
    orange,
    yellow,
    chartreuse,
    green,
    spring,
    cyan,
    azure,
    blue,
    violet,
    magenta,
    rose,
  ];
  static const fullList = [...twelveHues, white, gray, black];

  static const colorWheel = BoxDecoration(
    gradient: SweepGradient(colors: [red, magenta, blue, cyan, green, yellow, red]),
    shape: BoxShape.circle,
  );

  static const epic = [
    SuperColor(0xffa3a3),
    SuperColor(0xffa3a1),
    SuperColor(0xffa39f),
    SuperColor(0xffa49f),
    SuperColor(0xffa49d),
    SuperColor(0xffa49b),
    SuperColor(0xffa499),
    SuperColor(0xffa497),
    SuperColor(0xffa597),
    SuperColor(0xffa493),
    SuperColor(0xffa593),
    SuperColor(0xffa48f),
    SuperColor(0xffa48d),
    SuperColor(0xffa48b),
    SuperColor(0xffa68b),
    SuperColor(0xffa587),
    SuperColor(0xffa685),
    SuperColor(0xffa683),
    SuperColor(0xffa680),
    SuperColor(0xffa57c),
    SuperColor(0xffa578),
    SuperColor(0xffa778),
    SuperColor(0xffa774),
    SuperColor(0xffa770),
    SuperColor(0xffa76c),
    SuperColor(0xffa768),
    SuperColor(0xffa764),
    SuperColor(0xffa760),
    SuperColor(0xffa85c),
    SuperColor(0xffa958),
    SuperColor(0xffa954),
    SuperColor(0xffa84c),
    SuperColor(0xffa948),
    SuperColor(0xffa940),
    SuperColor(0xffa938),
    SuperColor(0xffa930),
    SuperColor(0xffa928),
    SuperColor(0xffa920),
    SuperColor(0xffaa18),
    SuperColor(0xffab10),
    SuperColor(0xffaa00),
    SuperColor(0xfbac00),
    SuperColor(0xf7ad00),
    SuperColor(0xf5b000),
    SuperColor(0xf1b100),
    SuperColor(0xedb200),
    SuperColor(0xebb400),
    SuperColor(0xe7b500),
    SuperColor(0xe3b600),
    SuperColor(0xe1b800),
    SuperColor(0xddb800),
    SuperColor(0xdbba00),
    SuperColor(0xd7ba00),
    SuperColor(0xd5bc00),
    SuperColor(0xd1bc00),
    SuperColor(0xcfbe00),
    SuperColor(0xcbbe00),
    SuperColor(0xc9bf00),
    SuperColor(0xc7c100),
    SuperColor(0xc5c200),
    SuperColor(0xc2c200),
    SuperColor(0xc0c300),
    SuperColor(0xbdc300),
    SuperColor(0xbbc500),
    SuperColor(0xb8c500),
    SuperColor(0xb5c500),
    SuperColor(0xb3c700),
    SuperColor(0xb0c700),
    SuperColor(0xadc700),
    SuperColor(0xabc900),
    SuperColor(0xa8c900),
    SuperColor(0xa4c900),
    SuperColor(0xa3cb00),
    SuperColor(0x9fcb00),
    SuperColor(0x9ccb00),
    SuperColor(0x99cc00),
    SuperColor(0x96cd00),
    SuperColor(0x93cd00),
    SuperColor(0x90cd00),
    SuperColor(0x8ecf00),
    SuperColor(0x8acf00),
    SuperColor(0x87cf00),
    SuperColor(0x84d000),
    SuperColor(0x81d100),
    SuperColor(0x7ed100),
    SuperColor(0x7ad100),
    SuperColor(0x77d100),
    SuperColor(0x74d300),
    SuperColor(0x71d300),
    SuperColor(0x6dd300),
    SuperColor(0x6ad300),
    SuperColor(0x67d500),
    SuperColor(0x63d500),
    SuperColor(0x60d500),
    SuperColor(0x5cd500),
    SuperColor(0x59d500),
    SuperColor(0x55d500),
    SuperColor(0x52d700),
    SuperColor(0x4fd700),
    SuperColor(0x4bd700),
    SuperColor(0x48d700),
    SuperColor(0x44d700),
    SuperColor(0x41d700),
    SuperColor(0x3dd700),
    SuperColor(0x3ad800),
    SuperColor(0x36d900),
    SuperColor(0x33d900),
    SuperColor(0x2fd900),
    SuperColor(0x2bd900),
    SuperColor(0x28d900),
    SuperColor(0x24d900),
    SuperColor(0x21d900),
    SuperColor(0x1dd900),
    SuperColor(0x19d900),
    SuperColor(0x16d900),
    SuperColor(0x12d900),
    SuperColor(0x0ed900),
    SuperColor(0x0bd900),
    SuperColor(0x07d900),
    SuperColor(0x04d900),
    SuperColor(0x00d900),
    SuperColor(0x00d904),
    SuperColor(0x00d907),
    SuperColor(0x00d90b),
    SuperColor(0x00d90e),
    SuperColor(0x00d912),
    SuperColor(0x00d916),
    SuperColor(0x00d919),
    SuperColor(0x00d91d),
    SuperColor(0x00d921),
    SuperColor(0x00d924),
    SuperColor(0x00d928),
    SuperColor(0x00d92b),
    SuperColor(0x00d92f),
    SuperColor(0x00d933),
    SuperColor(0x00d936),
    SuperColor(0x00d93a),
    SuperColor(0x00d93e),
    SuperColor(0x00d941),
    SuperColor(0x00d945),
    SuperColor(0x00d948),
    SuperColor(0x00d94c),
    SuperColor(0x00d950),
    SuperColor(0x00d953),
    SuperColor(0x00d957),
    SuperColor(0x00d95a),
    SuperColor(0x00d95e),
    SuperColor(0x00d861),
    SuperColor(0x00d764),
    SuperColor(0x00d768),
    SuperColor(0x00d76c),
    SuperColor(0x00d76f),
    SuperColor(0x00d773),
    SuperColor(0x00d776),
    SuperColor(0x00d77a),
    SuperColor(0x00d77e),
    SuperColor(0x00d781),
    SuperColor(0x00d785),
    SuperColor(0x00d788),
    SuperColor(0x00d78c),
    SuperColor(0x00d58e),
    SuperColor(0x00d592),
    SuperColor(0x00d595),
    SuperColor(0x00d599),
    SuperColor(0x00d59c),
    SuperColor(0x00d5a0),
    SuperColor(0x00d5a3),
    SuperColor(0x00d5a7),
    SuperColor(0x00d4aa),
    SuperColor(0x00d3ac),
    SuperColor(0x00d3b0),
    SuperColor(0x00d3b4),
    SuperColor(0x00d3b7),
    SuperColor(0x00d3bb),
    SuperColor(0x00d3be),
    SuperColor(0x00d3c2),
    SuperColor(0x00d1c3),
    SuperColor(0x00d1c7),
    SuperColor(0x00d1ca),
    SuperColor(0x00d1ce),
    SuperColor(0x00d1d1),
    SuperColor(0x00d0d3),
    SuperColor(0x00d0d7),
    SuperColor(0x00d0db),
    SuperColor(0x00d0df),
    SuperColor(0x00cee1),
    SuperColor(0x00cee5),
    SuperColor(0x00cee9),
    SuperColor(0x00cded),
    SuperColor(0x00cdf1),
    SuperColor(0x00ccf5),
    SuperColor(0x00cbf9),
    SuperColor(0x00ccff),
    SuperColor(0x10cbff),
    SuperColor(0x20cbff),
    SuperColor(0x2ccaff),
    SuperColor(0x38caff),
    SuperColor(0x40c9ff),
    SuperColor(0x48c8ff),
    SuperColor(0x50c7ff),
    SuperColor(0x58c7ff),
    SuperColor(0x5cc6ff),
    SuperColor(0x60c5ff),
    SuperColor(0x68c5ff),
    SuperColor(0x6cc4ff),
    SuperColor(0x70c3ff),
    SuperColor(0x74c3ff),
    SuperColor(0x78c2ff),
    SuperColor(0x7cc2ff),
    SuperColor(0x80c1ff),
    SuperColor(0x83c1ff),
    SuperColor(0x85c0ff),
    SuperColor(0x87bfff),
    SuperColor(0x8bbfff),
    SuperColor(0x8bbeff),
    SuperColor(0x8fbeff),
    SuperColor(0x93beff),
    SuperColor(0x93bdff),
    SuperColor(0x97bdff),
    SuperColor(0x97bcff),
    SuperColor(0x99bbff),
    SuperColor(0x9bbbff),
    SuperColor(0x9dbbff),
    SuperColor(0x9fbaff),
    SuperColor(0xa1baff),
    SuperColor(0xa3baff),
    SuperColor(0xa3b9ff),
    SuperColor(0xa5b9ff),
    SuperColor(0xa7b9ff),
    SuperColor(0xa9b9ff),
    SuperColor(0xa9b8ff),
    SuperColor(0xabb8ff),
    SuperColor(0xadb8ff),
    SuperColor(0xadb7ff),
    SuperColor(0xafb7ff),
    SuperColor(0xafb6ff),
    SuperColor(0xb1b7ff),
    SuperColor(0xb1b5ff),
    SuperColor(0xb3b6ff),
    SuperColor(0xb3b5ff),
    SuperColor(0xb5b5ff),
    SuperColor(0xb7b5ff),
    SuperColor(0xb8b5ff),
    SuperColor(0xb7b3ff),
    SuperColor(0xb8b3ff),
    SuperColor(0xbab3ff),
    SuperColor(0xbbb3ff),
    SuperColor(0xbcb3ff),
    SuperColor(0xbdb3ff),
    SuperColor(0xbeb2ff),
    SuperColor(0xbeb1ff),
    SuperColor(0xc0b1ff),
    SuperColor(0xc1b1ff),
    SuperColor(0xc2b1ff),
    SuperColor(0xc3b1ff),
    SuperColor(0xc4b0ff),
    SuperColor(0xc5afff),
    SuperColor(0xc6afff),
    SuperColor(0xc7afff),
    SuperColor(0xc9afff),
    SuperColor(0xcaafff),
    SuperColor(0xcaadff),
    SuperColor(0xcbadff),
    SuperColor(0xcdadff),
    SuperColor(0xceadff),
    SuperColor(0xcfadff),
    SuperColor(0xd0abff),
    SuperColor(0xd1abff),
    SuperColor(0xd2abff),
    SuperColor(0xd4abff),
    SuperColor(0xd5abff),
    SuperColor(0xd6a9ff),
    SuperColor(0xd7a9ff),
    SuperColor(0xd8a9ff),
    SuperColor(0xd9a7ff),
    SuperColor(0xdaa7ff),
    SuperColor(0xdca7ff),
    SuperColor(0xdda7ff),
    SuperColor(0xdea5ff),
    SuperColor(0xe0a5ff),
    SuperColor(0xe1a5ff),
    SuperColor(0xe2a3ff),
    SuperColor(0xe4a3ff),
    SuperColor(0xe5a3ff),
    SuperColor(0xe7a3ff),
    SuperColor(0xe8a1ff),
    SuperColor(0xe9a1ff),
    SuperColor(0xea9fff),
    SuperColor(0xec9fff),
    SuperColor(0xed9fff),
    SuperColor(0xef9fff),
    SuperColor(0xf09dff),
    SuperColor(0xf29bff),
    SuperColor(0xf39bff),
    SuperColor(0xf59bff),
    SuperColor(0xf79bff),
    SuperColor(0xf899ff),
    SuperColor(0xfa97ff),
    SuperColor(0xfc97ff),
    SuperColor(0xfd97ff),
    SuperColor(0xff95ff),
    SuperColor(0xff97fd),
    SuperColor(0xff97fc),
    SuperColor(0xff97fa),
    SuperColor(0xff97f8),
    SuperColor(0xff97f6),
    SuperColor(0xff97f5),
    SuperColor(0xff97f3),
    SuperColor(0xff97f1),
    SuperColor(0xff97ef),
    SuperColor(0xff97ee),
    SuperColor(0xff99ec),
    SuperColor(0xff99eb),
    SuperColor(0xff99e9),
    SuperColor(0xff99e7),
    SuperColor(0xff9be6),
    SuperColor(0xff9be4),
    SuperColor(0xff9be3),
    SuperColor(0xff9be1),
    SuperColor(0xff9bdf),
    SuperColor(0xff9bde),
    SuperColor(0xff9bdc),
    SuperColor(0xff9bda),
    SuperColor(0xff9bd9),
    SuperColor(0xff9bd7),
    SuperColor(0xff9bd5),
    SuperColor(0xff9dd5),
    SuperColor(0xff9dd3),
    SuperColor(0xff9dd1),
    SuperColor(0xff9dd0),
    SuperColor(0xff9dce),
    SuperColor(0xff9dcd),
    SuperColor(0xff9fcc),
    SuperColor(0xff9fca),
    SuperColor(0xff9fc9),
    SuperColor(0xff9fc7),
    SuperColor(0xff9fc6),
    SuperColor(0xff9fc4),
    SuperColor(0xff9fc2),
    SuperColor(0xff9fc1),
    SuperColor(0xff9fbf),
    SuperColor(0xff9fbe),
    SuperColor(0xff9fbc),
    SuperColor(0xff9fba),
    SuperColor(0xff9fb9),
    SuperColor(0xffa1b9),
    SuperColor(0xffa1b7),
    SuperColor(0xffa1b6),
    SuperColor(0xffa1b4),
    SuperColor(0xffa1b3),
    SuperColor(0xffa1b1),
    SuperColor(0xffa1af),
    SuperColor(0xffa1ae),
    SuperColor(0xffa1ac),
    SuperColor(0xffa3ad),
    SuperColor(0xffa3ab),
    SuperColor(0xffa3a9),
    SuperColor(0xffa3a8),
    SuperColor(0xffa3a6),
    SuperColor(0xffa3a5),
  ];
  static const inverse = [
    SuperColor(0x9e0000),
    SuperColor(0x9d0300),
    SuperColor(0x9c0500),
    SuperColor(0x9c0800),
    SuperColor(0x9b0a00),
    SuperColor(0x9b0d00),
    SuperColor(0x9a0f00),
    SuperColor(0x991200),
    SuperColor(0x981400),
    SuperColor(0x971700),
    SuperColor(0x961900),
    SuperColor(0x951b00),
    SuperColor(0x941e00),
    SuperColor(0x932000),
    SuperColor(0x922200),
    SuperColor(0x902400),
    SuperColor(0x8f2600),
    SuperColor(0x8d2800),
    SuperColor(0x8c2a00),
    SuperColor(0x8a2c00),
    SuperColor(0x892e00),
    SuperColor(0x872f00),
    SuperColor(0x863100),
    SuperColor(0x843300),
    SuperColor(0x823400),
    SuperColor(0x803600),
    SuperColor(0x7f3700),
    SuperColor(0x7d3800),
    SuperColor(0x7b3a00),
    SuperColor(0x7a3b00),
    SuperColor(0x783c00),
    SuperColor(0x763d00),
    SuperColor(0x753e00),
    SuperColor(0x733f00),
    SuperColor(0x714000),
    SuperColor(0x704100),
    SuperColor(0x6e4200),
    SuperColor(0x6c4300),
    SuperColor(0x6b4400),
    SuperColor(0x694400),
    SuperColor(0x684500),
    SuperColor(0x664600),
    SuperColor(0x654700),
    SuperColor(0x634700),
    SuperColor(0x624800),
    SuperColor(0x614800),
    SuperColor(0x5f4900),
    SuperColor(0x5e4a00),
    SuperColor(0x5d4a00),
    SuperColor(0x5b4b00),
    SuperColor(0x5a4b00),
    SuperColor(0x594c00),
    SuperColor(0x584c00),
    SuperColor(0x564c00),
    SuperColor(0x554d00),
    SuperColor(0x544d00),
    SuperColor(0x534e00),
    SuperColor(0x524e00),
    SuperColor(0x514e00),
    SuperColor(0x504f00),
    SuperColor(0x4f4f00),
    SuperColor(0x4e4f00),
    SuperColor(0x4d4f00),
    SuperColor(0x4c5000),
    SuperColor(0x4b5000),
    SuperColor(0x4a5000),
    SuperColor(0x495100),
    SuperColor(0x475100),
    SuperColor(0x465100),
    SuperColor(0x455100),
    SuperColor(0x445200),
    SuperColor(0x435200),
    SuperColor(0x425200),
    SuperColor(0x415200),
    SuperColor(0x3f5300),
    SuperColor(0x3e5300),
    SuperColor(0x3d5300),
    SuperColor(0x3c5400),
    SuperColor(0x3b5400),
    SuperColor(0x395400),
    SuperColor(0x385400),
    SuperColor(0x375400),
    SuperColor(0x365500),
    SuperColor(0x345500),
    SuperColor(0x335500),
    SuperColor(0x325500),
    SuperColor(0x305600),
    SuperColor(0x2f5600),
    SuperColor(0x2e5600),
    SuperColor(0x2c5600),
    SuperColor(0x2b5600),
    SuperColor(0x2a5600),
    SuperColor(0x285700),
    SuperColor(0x275700),
    SuperColor(0x265700),
    SuperColor(0x245700),
    SuperColor(0x235700),
    SuperColor(0x225700),
    SuperColor(0x205800),
    SuperColor(0x1f5800),
    SuperColor(0x1d5800),
    SuperColor(0x1c5800),
    SuperColor(0x1a5800),
    SuperColor(0x195800),
    SuperColor(0x185800),
    SuperColor(0x165800),
    SuperColor(0x155900),
    SuperColor(0x135900),
    SuperColor(0x125900),
    SuperColor(0x105900),
    SuperColor(0x0f5900),
    SuperColor(0x0d5900),
    SuperColor(0x0c5900),
    SuperColor(0x0a5900),
    SuperColor(0x095900),
    SuperColor(0x075900),
    SuperColor(0x065900),
    SuperColor(0x045900),
    SuperColor(0x035900),
    SuperColor(0x015900),
    SuperColor(0x005900),
    SuperColor(0x005901),
    SuperColor(0x005903),
    SuperColor(0x005904),
    SuperColor(0x005906),
    SuperColor(0x005907),
    SuperColor(0x005909),
    SuperColor(0x00590a),
    SuperColor(0x00590c),
    SuperColor(0x00590d),
    SuperColor(0x00590f),
    SuperColor(0x005910),
    SuperColor(0x005912),
    SuperColor(0x005913),
    SuperColor(0x005915),
    SuperColor(0x005916),
    SuperColor(0x005918),
    SuperColor(0x005919),
    SuperColor(0x00591b),
    SuperColor(0x00591c),
    SuperColor(0x00591e),
    SuperColor(0x00591f),
    SuperColor(0x005921),
    SuperColor(0x005922),
    SuperColor(0x005923),
    SuperColor(0x005925),
    SuperColor(0x005926),
    SuperColor(0x005928),
    SuperColor(0x005829),
    SuperColor(0x00582b),
    SuperColor(0x00582c),
    SuperColor(0x00582e),
    SuperColor(0x00582f),
    SuperColor(0x005830),
    SuperColor(0x005832),
    SuperColor(0x005833),
    SuperColor(0x005835),
    SuperColor(0x005836),
    SuperColor(0x005838),
    SuperColor(0x005839),
    SuperColor(0x00583a),
    SuperColor(0x00573c),
    SuperColor(0x00573d),
    SuperColor(0x00573f),
    SuperColor(0x005740),
    SuperColor(0x005741),
    SuperColor(0x005743),
    SuperColor(0x005744),
    SuperColor(0x005745),
    SuperColor(0x005747),
    SuperColor(0x005748),
    SuperColor(0x00564a),
    SuperColor(0x00564b),
    SuperColor(0x00564c),
    SuperColor(0x00564e),
    SuperColor(0x00564f),
    SuperColor(0x005650),
    SuperColor(0x005651),
    SuperColor(0x005653),
    SuperColor(0x005654),
    SuperColor(0x005555),
    SuperColor(0x005557),
    SuperColor(0x005558),
    SuperColor(0x005559),
    SuperColor(0x00555b),
    SuperColor(0x00555c),
    SuperColor(0x00545e),
    SuperColor(0x00545f),
    SuperColor(0x005461),
    SuperColor(0x005463),
    SuperColor(0x005464),
    SuperColor(0x005366),
    SuperColor(0x005368),
    SuperColor(0x00536a),
    SuperColor(0x00536c),
    SuperColor(0x00526e),
    SuperColor(0x005270),
    SuperColor(0x005272),
    SuperColor(0x005174),
    SuperColor(0x005177),
    SuperColor(0x005179),
    SuperColor(0x00507b),
    SuperColor(0x00507e),
    SuperColor(0x004f81),
    SuperColor(0x004f83),
    SuperColor(0x004e86),
    SuperColor(0x004e89),
    SuperColor(0x004d8c),
    SuperColor(0x004c8f),
    SuperColor(0x004c93),
    SuperColor(0x004b96),
    SuperColor(0x004a99),
    SuperColor(0x00499d),
    SuperColor(0x0048a1),
    SuperColor(0x0047a4),
    SuperColor(0x0046a8),
    SuperColor(0x0045ac),
    SuperColor(0x0044b0),
    SuperColor(0x0042b4),
    SuperColor(0x0041b9),
    SuperColor(0x003fbd),
    SuperColor(0x003dc1),
    SuperColor(0x003bc6),
    SuperColor(0x0039ca),
    SuperColor(0x0037cf),
    SuperColor(0x0035d3),
    SuperColor(0x0032d7),
    SuperColor(0x0030dc),
    SuperColor(0x002de0),
    SuperColor(0x002ae4),
    SuperColor(0x0027e7),
    SuperColor(0x0023eb),
    SuperColor(0x0020ee),
    SuperColor(0x001cf2),
    SuperColor(0x0018f4),
    SuperColor(0x0015f7),
    SuperColor(0x0011f9),
    SuperColor(0x000dfb),
    SuperColor(0x0008fc),
    SuperColor(0x0004fe),
    SuperColor(0x0000ff),
    SuperColor(0x0400ff),
    SuperColor(0x0800fe),
    SuperColor(0x0d00fe),
    SuperColor(0x1100fd),
    SuperColor(0x1500fd),
    SuperColor(0x1900fc),
    SuperColor(0x1d00fb),
    SuperColor(0x2100fa),
    SuperColor(0x2500f9),
    SuperColor(0x2900f7),
    SuperColor(0x2d00f6),
    SuperColor(0x3100f5),
    SuperColor(0x3500f3),
    SuperColor(0x3800f1),
    SuperColor(0x3c00f0),
    SuperColor(0x3f00ee),
    SuperColor(0x4300ec),
    SuperColor(0x4600ea),
    SuperColor(0x4900e7),
    SuperColor(0x4c00e5),
    SuperColor(0x4f00e3),
    SuperColor(0x5200e1),
    SuperColor(0x5500de),
    SuperColor(0x5800dc),
    SuperColor(0x5b00d9),
    SuperColor(0x5d00d7),
    SuperColor(0x5f00d4),
    SuperColor(0x6200d2),
    SuperColor(0x6400cf),
    SuperColor(0x6600cc),
    SuperColor(0x6800ca),
    SuperColor(0x6a00c7),
    SuperColor(0x6c00c5),
    SuperColor(0x6e00c2),
    SuperColor(0x7000c0),
    SuperColor(0x7100bd),
    SuperColor(0x7300bb),
    SuperColor(0x7500b8),
    SuperColor(0x7600b6),
    SuperColor(0x7700b3),
    SuperColor(0x7900b1),
    SuperColor(0x7a00ae),
    SuperColor(0x7b00ac),
    SuperColor(0x7d00aa),
    SuperColor(0x7e00a8),
    SuperColor(0x7f00a5),
    SuperColor(0x8000a3),
    SuperColor(0x8100a1),
    SuperColor(0x82009f),
    SuperColor(0x83009d),
    SuperColor(0x83009b),
    SuperColor(0x840099),
    SuperColor(0x850097),
    SuperColor(0x860095),
    SuperColor(0x870093),
    SuperColor(0x870091),
    SuperColor(0x88008f),
    SuperColor(0x89008d),
    SuperColor(0x89008c),
    SuperColor(0x8a008a),
    SuperColor(0x8a0088),
    SuperColor(0x8b0086),
    SuperColor(0x8c0085),
    SuperColor(0x8c0083),
    SuperColor(0x8d0081),
    SuperColor(0x8d007f),
    SuperColor(0x8e007d),
    SuperColor(0x8e007b),
    SuperColor(0x8f0079),
    SuperColor(0x8f0078),
    SuperColor(0x900076),
    SuperColor(0x900074),
    SuperColor(0x910072),
    SuperColor(0x910070),
    SuperColor(0x92006d),
    SuperColor(0x92006b),
    SuperColor(0x930069),
    SuperColor(0x930067),
    SuperColor(0x940065),
    SuperColor(0x940063),
    SuperColor(0x950061),
    SuperColor(0x95005e),
    SuperColor(0x96005c),
    SuperColor(0x96005a),
    SuperColor(0x960058),
    SuperColor(0x970055),
    SuperColor(0x970053),
    SuperColor(0x980051),
    SuperColor(0x98004e),
    SuperColor(0x98004c),
    SuperColor(0x99004a),
    SuperColor(0x990047),
    SuperColor(0x990045),
    SuperColor(0x990043),
    SuperColor(0x9a0040),
    SuperColor(0x9a003e),
    SuperColor(0x9a003b),
    SuperColor(0x9b0039),
    SuperColor(0x9b0036),
    SuperColor(0x9b0034),
    SuperColor(0x9b0031),
    SuperColor(0x9b002f),
    SuperColor(0x9c002c),
    SuperColor(0x9c002a),
    SuperColor(0x9c0027),
    SuperColor(0x9c0024),
    SuperColor(0x9c0022),
    SuperColor(0x9d001f),
    SuperColor(0x9d001d),
    SuperColor(0x9d001a),
    SuperColor(0x9d0018),
    SuperColor(0x9d0015),
    SuperColor(0x9d0012),
    SuperColor(0x9d0010),
    SuperColor(0x9d000d),
    SuperColor(0x9d000a),
    SuperColor(0x9d0008),
    SuperColor(0x9d0005),
    SuperColor(0x9d0003),
  ];
  static const orb = [
    SuperColor(0xff2e2e),
    SuperColor(0xff2e40),
    SuperColor(0xff2d51),
    SuperColor(0xff2d62),
    SuperColor(0xff2c72),
    SuperColor(0xff2c83),
    SuperColor(0xff2a95),
    SuperColor(0xff29a6),
    SuperColor(0xff28b7),
    SuperColor(0xff26c8),
    SuperColor(0xff24da),
    SuperColor(0xff22ec),
    SuperColor(0xff20ff),
    SuperColor(0xed27ff),
    SuperColor(0xdb2dff),
    SuperColor(0xcb33ff),
    SuperColor(0xbc38ff),
    SuperColor(0xae3cff),
    SuperColor(0xa041ff),
    SuperColor(0x9244ff),
    SuperColor(0x8447ff),
    SuperColor(0x7749ff),
    SuperColor(0x694aff),
    SuperColor(0x5b4cff),
    SuperColor(0x4d4dff),
    SuperColor(0x4959ff),
    SuperColor(0x4564ff),
    SuperColor(0x3f6fff),
    SuperColor(0x377aff),
    SuperColor(0x2e85ff),
    SuperColor(0x2391ff),
    SuperColor(0x179eff),
    SuperColor(0x0caeff),
    SuperColor(0x02bfff),
    SuperColor(0x00d4fe),
    SuperColor(0x00e5fa),
    SuperColor(0x00f1f1),
    SuperColor(0x00f2df),
    SuperColor(0x00f3cb),
    SuperColor(0x00f4b7),
    SuperColor(0x00f4a3),
    SuperColor(0x00f58f),
    SuperColor(0x00f57b),
    SuperColor(0x00f666),
    SuperColor(0x00f652),
    SuperColor(0x00f63d),
    SuperColor(0x00f628),
    SuperColor(0x00f614),
    SuperColor(0x00f600),
    SuperColor(0x14f600),
    SuperColor(0x29f600),
    SuperColor(0x3df600),
    SuperColor(0x51f500),
    SuperColor(0x65f400),
    SuperColor(0x7af300),
    SuperColor(0x8df200),
    SuperColor(0xa0f000),
    SuperColor(0xb2ee00),
    SuperColor(0xc4eb00),
    SuperColor(0xd5e800),
    SuperColor(0xe4e400),
    SuperColor(0xf0dc00),
    SuperColor(0xf8cf00),
    SuperColor(0xfdbd00),
    SuperColor(0xffaa00),
    SuperColor(0xff9603),
    SuperColor(0xff850b),
    SuperColor(0xff7513),
    SuperColor(0xff661a),
    SuperColor(0xff5921),
    SuperColor(0xff4b27),
    SuperColor(0xff3d2b),
    SuperColor(0xff2e2e),
  ];
  static const blobs = [
    SuperColor(0x3E0000),
    SuperColor(0x3D0100),
    SuperColor(0x3C0200),
    SuperColor(0x3C0300),
    SuperColor(0x3B0400),
    SuperColor(0x3A0500),
    SuperColor(0x390600),
    SuperColor(0x390700),
    SuperColor(0x380700),
    SuperColor(0x380800),
    SuperColor(0x370900),
    SuperColor(0x360A00),
    SuperColor(0x360B00),
    SuperColor(0x350B00),
    SuperColor(0x350C00),
    SuperColor(0x340D00),
    SuperColor(0x330D00),
    SuperColor(0x330E00),
    SuperColor(0x320F00),
    SuperColor(0x311000),
    SuperColor(0x311000),
    SuperColor(0x2F1000),
    SuperColor(0x2F1100),
    SuperColor(0x2E1100),
    SuperColor(0x2E1200),
    SuperColor(0x2D1300),
    SuperColor(0x2C1300),
    SuperColor(0x2C1400),
    SuperColor(0x2B1400),
    SuperColor(0x2B1500),
    SuperColor(0x291500),
    SuperColor(0x291500),
    SuperColor(0x281500),
    SuperColor(0x271600),
    SuperColor(0x271600),
    SuperColor(0x271700),
    SuperColor(0x261700),
    SuperColor(0x251700),
    SuperColor(0x251700),
    SuperColor(0x241700),
    SuperColor(0x231700),
    SuperColor(0x231800),
    SuperColor(0x231800),
    SuperColor(0x221800),
    SuperColor(0x221900),
    SuperColor(0x211800),
    SuperColor(0x201900),
    SuperColor(0x201900),
    SuperColor(0x201900),
    SuperColor(0x1F1900),
    SuperColor(0x1F1A00),
    SuperColor(0x1E1A00),
    SuperColor(0x1E1A00),
    SuperColor(0x1E1A00),
    SuperColor(0x1E1B00),
    SuperColor(0x1D1B00),
    SuperColor(0x1D1B00),
    SuperColor(0x1C1B00),
    SuperColor(0x1C1B00),
    SuperColor(0x1B1B00),
    SuperColor(0x1B1B00),
    SuperColor(0x1A1B00),
    SuperColor(0x1A1B00),
    SuperColor(0x191B00),
    SuperColor(0x191B00),
    SuperColor(0x191C00),
    SuperColor(0x191C00),
    SuperColor(0x181C00),
    SuperColor(0x181C00),
    SuperColor(0x171C00),
    SuperColor(0x171C00),
    SuperColor(0x171C00),
    SuperColor(0x161C00),
    SuperColor(0x161C00),
    SuperColor(0x161C00),
    SuperColor(0x151D00),
    SuperColor(0x151D00),
    SuperColor(0x151D00),
    SuperColor(0x141D00),
    SuperColor(0x141D00),
    SuperColor(0x131D00),
    SuperColor(0x131D00),
    SuperColor(0x121D00),
    SuperColor(0x121D00),
    SuperColor(0x111D00),
    SuperColor(0x111E00),
    SuperColor(0x111E00),
    SuperColor(0x101E00),
    SuperColor(0x101E00),
    SuperColor(0x0F1E00),
    SuperColor(0x0F1E00),
    SuperColor(0x0E1E00),
    SuperColor(0x0E1E00),
    SuperColor(0x0D1E00),
    SuperColor(0x0D1E00),
    SuperColor(0x0C1E00),
    SuperColor(0x0C1E00),
    SuperColor(0x0C1E00),
    SuperColor(0x0B1F00),
    SuperColor(0x0B1F00),
    SuperColor(0x0A1F00),
    SuperColor(0x0A1F00),
    SuperColor(0x091F00),
    SuperColor(0x091F00),
    SuperColor(0x081F00),
    SuperColor(0x081F00),
    SuperColor(0x071F00),
    SuperColor(0x071F00),
    SuperColor(0x061F00),
    SuperColor(0x061F00),
    SuperColor(0x051F00),
    SuperColor(0x051F00),
    SuperColor(0x041F00),
    SuperColor(0x041F00),
    SuperColor(0x032000),
    SuperColor(0x032000),
    SuperColor(0x022000),
    SuperColor(0x022000),
    SuperColor(0x012000),
    SuperColor(0x012000),
    SuperColor(0x002000),
    SuperColor(0x002001),
    SuperColor(0x002001),
    SuperColor(0x002002),
    SuperColor(0x002002),
    SuperColor(0x002003),
    SuperColor(0x002003),
    SuperColor(0x002004),
    SuperColor(0x002004),
    SuperColor(0x002005),
    SuperColor(0x002005),
    SuperColor(0x002006),
    SuperColor(0x002006),
    SuperColor(0x002007),
    SuperColor(0x002007),
    SuperColor(0x002008),
    SuperColor(0x002008),
    SuperColor(0x002009),
    SuperColor(0x002009),
    SuperColor(0x001F0A),
    SuperColor(0x001F0A),
    SuperColor(0x001F0B),
    SuperColor(0x001F0B),
    SuperColor(0x001F0C),
    SuperColor(0x001F0C),
    SuperColor(0x001F0D),
    SuperColor(0x001F0D),
    SuperColor(0x001F0E),
    SuperColor(0x001F0E),
    SuperColor(0x001F0F),
    SuperColor(0x001F0F),
    SuperColor(0x001F10),
    SuperColor(0x001F10),
    SuperColor(0x001F11),
    SuperColor(0x001F11),
    SuperColor(0x001F12),
    SuperColor(0x001F12),
    SuperColor(0x001F13),
    SuperColor(0x001F13),
    SuperColor(0x001F14),
    SuperColor(0x001F14),
    SuperColor(0x001F15),
    SuperColor(0x001F15),
    SuperColor(0x001F16),
    SuperColor(0x001F16),
    SuperColor(0x001F17),
    SuperColor(0x001F17),
    SuperColor(0x001F18),
    SuperColor(0x001F19),
    SuperColor(0x001F19),
    SuperColor(0x001F1A),
    SuperColor(0x001E1A),
    SuperColor(0x001E1A),
    SuperColor(0x001E1A),
    SuperColor(0x001E1B),
    SuperColor(0x001E1B),
    SuperColor(0x001E1C),
    SuperColor(0x001E1C),
    SuperColor(0x001E1D),
    SuperColor(0x001E1D),
    SuperColor(0x001E1E),
    SuperColor(0x001E1E),
    SuperColor(0x001E1F),
    SuperColor(0x001E1F),
    SuperColor(0x001E20),
    SuperColor(0x001D20),
    SuperColor(0x001D21),
    SuperColor(0x001E22),
    SuperColor(0x001E22),
    SuperColor(0x001D23),
    SuperColor(0x001D23),
    SuperColor(0x001D23),
    SuperColor(0x001C24),
    SuperColor(0x001D25),
    SuperColor(0x001C25),
    SuperColor(0x001D26),
    SuperColor(0x001D27),
    SuperColor(0x001C28),
    SuperColor(0x001C29),
    SuperColor(0x001C2A),
    SuperColor(0x001C2B),
    SuperColor(0x001C2B),
    SuperColor(0x001C2C),
    SuperColor(0x001B2D),
    SuperColor(0x001C2E),
    SuperColor(0x001B2F),
    SuperColor(0x001C31),
    SuperColor(0x001B31),
    SuperColor(0x001A32),
    SuperColor(0x001A33),
    SuperColor(0x001B35),
    SuperColor(0x001A36),
    SuperColor(0x001937),
    SuperColor(0x001939),
    SuperColor(0x00193A),
    SuperColor(0x00193B),
    SuperColor(0x00183D),
    SuperColor(0x00183E),
    SuperColor(0x001740),
    SuperColor(0x001741),
    SuperColor(0x001643),
    SuperColor(0x001644),
    SuperColor(0x001547),
    SuperColor(0x001548),
    SuperColor(0x00144A),
    SuperColor(0x00134C),
    SuperColor(0x00134F),
    SuperColor(0x001251),
    SuperColor(0x001052),
    SuperColor(0x000F54),
    SuperColor(0x000E56),
    SuperColor(0x000D58),
    SuperColor(0x000C59),
    SuperColor(0x000B5B),
    SuperColor(0x00095D),
    SuperColor(0x00085F),
    SuperColor(0x000661),
    SuperColor(0x000562),
    SuperColor(0x000364),
    SuperColor(0x000265),
    SuperColor(0x000068),
    SuperColor(0x020067),
    SuperColor(0x030067),
    SuperColor(0x050066),
    SuperColor(0x070065),
    SuperColor(0x080065),
    SuperColor(0x0A0064),
    SuperColor(0x0C0064),
    SuperColor(0x0D0063),
    SuperColor(0x0F0062),
    SuperColor(0x100062),
    SuperColor(0x120061),
    SuperColor(0x130060),
    SuperColor(0x15005F),
    SuperColor(0x16005F),
    SuperColor(0x17005E),
    SuperColor(0x19005D),
    SuperColor(0x1A005C),
    SuperColor(0x1B005B),
    SuperColor(0x1D005A),
    SuperColor(0x1E0059),
    SuperColor(0x1F0058),
    SuperColor(0x200057),
    SuperColor(0x210056),
    SuperColor(0x220055),
    SuperColor(0x230054),
    SuperColor(0x240053),
    SuperColor(0x250051),
    SuperColor(0x260050),
    SuperColor(0x26004F),
    SuperColor(0x27004F),
    SuperColor(0x28004D),
    SuperColor(0x29004C),
    SuperColor(0x29004B),
    SuperColor(0x2A004A),
    SuperColor(0x2B0049),
    SuperColor(0x2B0048),
    SuperColor(0x2C0047),
    SuperColor(0x2D0046),
    SuperColor(0x2D0045),
    SuperColor(0x2E0044),
    SuperColor(0x2E0044),
    SuperColor(0x2F0042),
    SuperColor(0x300042),
    SuperColor(0x300041),
    SuperColor(0x300040),
    SuperColor(0x310040),
    SuperColor(0x31003E),
    SuperColor(0x31003E),
    SuperColor(0x31003D),
    SuperColor(0x32003C),
    SuperColor(0x33003C),
    SuperColor(0x32003A),
    SuperColor(0x33003A),
    SuperColor(0x330039),
    SuperColor(0x330038),
    SuperColor(0x330037),
    SuperColor(0x340037),
    SuperColor(0x350037),
    SuperColor(0x350036),
    SuperColor(0x350035),
    SuperColor(0x350034),
    SuperColor(0x350033),
    SuperColor(0x360033),
    SuperColor(0x360032),
    SuperColor(0x360031),
    SuperColor(0x360031),
    SuperColor(0x370030),
    SuperColor(0x37002F),
    SuperColor(0x37002E),
    SuperColor(0x37002D),
    SuperColor(0x37002D),
    SuperColor(0x38002C),
    SuperColor(0x38002C),
    SuperColor(0x38002B),
    SuperColor(0x38002A),
    SuperColor(0x380029),
    SuperColor(0x390029),
    SuperColor(0x390028),
    SuperColor(0x390027),
    SuperColor(0x390026),
    SuperColor(0x390025),
    SuperColor(0x3A0024),
    SuperColor(0x3A0023),
    SuperColor(0x3A0023),
    SuperColor(0x3A0022),
    SuperColor(0x3A0021),
    SuperColor(0x3A0020),
    SuperColor(0x3B001F),
    SuperColor(0x3B001E),
    SuperColor(0x3B001D),
    SuperColor(0x3B001C),
    SuperColor(0x3B001B),
    SuperColor(0x3B001A),
    SuperColor(0x3B001A),
    SuperColor(0x3C0019),
    SuperColor(0x3C0018),
    SuperColor(0x3C0017),
    SuperColor(0x3C0016),
    SuperColor(0x3C0015),
    SuperColor(0x3C0014),
    SuperColor(0x3C0013),
    SuperColor(0x3C0012),
    SuperColor(0x3C0011),
    SuperColor(0x3D0010),
    SuperColor(0x3D000F),
    SuperColor(0x3D000E),
    SuperColor(0x3D000D),
    SuperColor(0x3D000C),
    SuperColor(0x3D000B),
    SuperColor(0x3D000A),
    SuperColor(0x3D0009),
    SuperColor(0x3D0008),
    SuperColor(0x3D0007),
    SuperColor(0x3D0006),
    SuperColor(0x3D0005),
    SuperColor(0x3D0004),
    SuperColor(0x3E0003),
    SuperColor(0x3E0002),
    SuperColor(0x3E0001),
  ];
}
