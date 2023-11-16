import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hueman/data/page_data.dart';
import 'package:hueman/inverse_pages/menu.dart';
import 'package:hueman/pages/menu.dart';
import 'package:hueman/data/save_data.dart';
import 'package:url_launcher/url_launcher.dart';

/// ```dart
///
/// await sleep(3); // in an async function
/// sleep(3, then: do_something()); // anywhere
/// ```
/// Just like `time.sleep(3)` in Python.
Future<void> sleep(double seconds, {Function()? then}) =>
    Future.delayed(Duration(milliseconds: (seconds * 1000).toInt()), then);

void quickly(Function() function) => sleep(0.001, then: function);

const oneSec = Duration(seconds: 1);
const halfSec = Duration(milliseconds: 500);
const quarterSec = Duration(milliseconds: 250);
const Curve curve = Curves.easeOutCubic;

final rng = Random();

Color contrastWith(Color c, {double threshold = .2}) =>
    (c.computeLuminance() > threshold) ? Colors.black : Colors.white;

abstract interface class ScoreKeeper {
  Pages get page;
  Widget get midRoundDisplay;
  Widget get finalDetails;
  int get scoreVal;
  void scoreTheRound();
  void roundCheck(BuildContext context);
}

extension ContextStuff on BuildContext {
  void goto(Pages page) => Navigator.pushReplacementNamed(this, page.name);
  void menu() => goto(Pages.menu);

  void noTransition(Widget screen) => Navigator.pushReplacement<void, void>(
        this,
        PageRouteBuilder<void>(
          pageBuilder: (context, animation1, animation2) => screen,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );

  void invert() => noTransition(inverted ? const MainMenu() : const InverseMenu());

  EdgeInsets get iOSpadding =>
      Platform.isIOS ? EdgeInsets.zero : const EdgeInsets.symmetric(vertical: 5);

  double get _safePadding {
    final padding = View.of(this).padding;
    return min(padding.top + padding.bottom, 110);
  }

  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  double get safeHeight => screenHeight - _safePadding;
  bool get squished => safeHeight < 1080;

  /// calculates the ideal size (a [double]) based on the viewport width & height.
  double calcSize(double Function(double w, double h) widthHeight) {
    final size = screenSize;
    return widthHeight(size.width, size.height - _safePadding);
  }
}

void gotoWebsite(String url) => launchUrl(Uri.parse(url));

typedef KeyFunc = ValueChanged<RawKeyEvent>;
void addListener(KeyFunc func) => RawKeyboard.instance.addListener(func);
void yeetListener(KeyFunc func) => RawKeyboard.instance.removeListener(func);

class HueQueue {
  HueQueue(this.numColors) {
    choices = [for (int hue = 0; hue < 360; hue += 360 ~/ numColors) hue];
    recentChoices = [];
    minChoices = numColors == 3 ? 2 : 3;
  }
  final int numColors;
  late final List<int> choices, recentChoices;
  late final int minChoices;

  /// grabs the next hue to use and updates the queue.
  int get queuedHue {
    final hue = choices.removeAt(rng.nextInt(choices.length));
    if (choices.length < minChoices) choices.add(recentChoices.removeAt(0));
    recentChoices.add(hue);
    return hue;
  }
}

extension ToInt on TextEditingValue {
  int toInt() => text.isEmpty ? 0 : int.parse(text);
}

extension HexByte on int {
  String get hexByte => '0x${toRadixString(16).padLeft(2, '0').toUpperCase()}';
}

extension NumStuff<T extends num> on T {
  T get squared => this * this as T;
  T stayInRange(T lower, T upper) => min(max(this, lower), upper);

  int roundToNearest(int roundTo) => ((this / roundTo).round() * roundTo) % 360;
}

extension Average<T extends num> on List<T> {
  /// it better not be an empty list :)
  double get average => reduce((total, val) => total + val as T) / length;
}

T diff<T extends num>(T a, T b) => (a - b).abs() as T;
