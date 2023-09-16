import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:super_hueman/data/color_lists.dart';
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
import 'package:super_hueman/tutorial_pages/intro3.dart';
import 'package:super_hueman/tutorial_pages/intro6.dart';
import 'package:super_hueman/tutorial_pages/start.dart';
import 'package:super_hueman/data/save_data.dart';
import 'package:url_launcher/url_launcher.dart';

/// ```dart
///
/// await sleep(3); // in an async function
/// sleep(3, then: do_something()); // anywhere
/// ```
/// Just like `time.sleep(3)` in Python.
Future<void> sleep(double seconds, {Function()? then}) =>
    Future.delayed(Duration(milliseconds: (seconds * 1000).toInt()), then);

const halfSec = Duration(milliseconds: 500);
const oneSec = Duration(seconds: 1);
const Curve curve = Curves.easeOutCubic;

enum Pages {
  start(StartScreen()),
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

  const Pages(this._widget);
  final Widget _widget;

  Widget get widget => switch (this) {
        intro3 when !Tutorials.intro3 => const Intro3Tutorial(),
        intro6 when !Tutorials.intro6 => const Intro6Tutorial(),
        _ => _widget,
      };

  String call() => switch (this) {
        inverseMenu => 'invert!',
        inverseSandbox => 'sandbox',
        trueMastery => 'true\nmastery',
        _ when name.contains('intro') => '${name.substring(5)} colors',
        _ when name.startsWith('tense') => name.substring(5).toLowerCase(),
        _ => name,
      };

  static Map<String, WidgetBuilder> routes = {
    for (final page in values) page.name: (context) => page.widget
  };

  static String get initialRoute {
    final route = !Tutorials.intro
        ? start
        : inverted
            ? inverseMenu
            : mainMenu;
    return route.name;
  }

  String get gameMode => switch (this) {
        intro3 => 'intro  (3 colors)',
        intro6 => 'intro  (6 colors)',
        intro12 => 'intro  (12 colors)',
        intense => 'Intense',
        master => 'Master',
        tenseVibrant => 'Tense (vibrant)',
        tenseMixed => 'Tense (mixed!)',
        trueMastery => 'True Mastery',
        _ => "lol this shouldn't pop up",
      };
}

abstract interface class ScoreKeeper {
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

  void noTransition(Widget screen) => Navigator.pushReplacement<void, void>(
        this,
        PageRouteBuilder<void>(
          pageBuilder: (context, animation1, animation2) => screen,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );

  void invert() => noTransition(inverted ? const MainMenu() : const InverseMenu());

  Size get _size => MediaQuery.of(this).size;
  double get screenWidth => _size.width;
  double get screenHeight => _size.height;

  bool get squished => screenHeight < 1040;
}

void Function() gotoWebsite(String url) => () => launchUrl(Uri.parse(url));

T diff<T extends num>(T a, T b) => (a - b).abs() as T;
T stayInRange<T extends num>(T value, T lower, T upper) => min(max(value, lower), upper);

void addListener(ValueChanged<RawKeyEvent> func) => RawKeyboard.instance.addListener(func);
void yeetListener(ValueChanged<RawKeyEvent> func) => RawKeyboard.instance.removeListener(func);

Color contrastWith(Color c, {double threshold = .2}) =>
    (c.computeLuminance() > threshold) ? Colors.black : Colors.white;

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

  factory SuperColor.hue(num h) => SuperColor.hsv(h % 360, 1, 1);

  factory SuperColor.hsl(num h, double s, double l) => switch ((h, s, l)) {
        (_, _, 0) => SuperColors.black,
        (_, _, 1) => SuperColors.white,
        (_, 0, 0.5) => SuperColors.gray,
        (_, 1, 0.5) when h % 30 == 0 => SuperColors.twelveHues[h ~/ 30],
        _ => SuperColor(HSLColor.fromAHSL(0, h.toDouble(), s, l).toColor().value),
      };
  final int colorCode;

  final String name;
  static const opaque = 0xFF000000;

  num get hue {
    final int i = SuperColors.twelveHues.indexOf(this);
    return i != -1 ? i * 30 : HSVColor.fromColor(this).hue;
  }

  /// The hexadecimal color code (doesn't include alpha).
  String get hexCode => '#${colorCode.toRadixString(16).padLeft(6, "0").toUpperCase()}';

  SuperColor get rounded {
    const easterEgg = SuperColor.named('Kali 🙂', 0x8080FF);
    if (colorCode == 0x8080FF) return easterEgg;

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

  static const darkBackground = SuperColor(0x121212);
  static const lightBackground = SuperColor(0xffeef3f8);
  static const bsBackground = SuperColor(0xfff2d6);
  static const inverting = SuperColor(0xf5faff);

  static const black80 = Color(0xCC000000);
  static const white80 = Color(0xCCFFFFFF);

  static const primaries = [red, green, blue];
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
}

int epicHue = 0, inverseHue = 0;

/// a [Color] with [epicHue] as its hue.
///
/// The color is retrieved from [epicColors],
/// where all colors have the same luminosity.
SuperColor get epicColor => epicColors[epicHue];

/// oscillates between 0 and 2 based on [epicHue].
///
/// Each peak is a tertiary color,
/// and each 0-value is the hue of an additive/subtractive primary :)
double get epicSine => sin(6 * 2 * pi * (epicHue) / 360) + 1;

/// similar to [epicColor], but the color is darker.
///
/// It also cycles the reverse way through the hues.
SuperColor get inverseColor => inverseColors[inverseHue];

Ticker epicSetup(StateSetter setState) {
  int lastEpicChange = 0;
  const int hueChangeDelay = 60;
  void epicCycle(Duration elapsed) {
    if (elapsed.inMilliseconds >= lastEpicChange + hueChangeDelay) {
      lastEpicChange += hueChangeDelay;
      setState(() => epicHue = ++epicHue % 360);
    }
  }

  epicHue = rng.nextInt(360);
  lastEpicChange = 0;
  final Ticker epicHues = Ticker(epicCycle)..start();

  return epicHues;
}

Ticker inverseSetup(StateSetter setState) {
  void inverseCycle(Duration elapsed) => setState(() => inverseHue = --inverseHue % 360);

  inverseHue = rng.nextInt(360);
  final Ticker inverseHues = Ticker(inverseCycle)..start();

  return inverseHues;
}

extension ToInt on TextEditingValue {
  int toInt() => text.isEmpty ? 0 : int.parse(text);
}

extension TwoDecimalPlaces on double {
  double get twoDecimalPlaces => double.parse((this).toStringAsFixed(2)).abs();
}

final rng = Random();
