import 'dart:math';

import 'package:flutter/material.dart';
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

void quickly(Function() function) => sleep(0.001, then: function);

const halfSec = Duration(milliseconds: 500);
const oneSec = Duration(seconds: 1);
const Curve curve = Curves.easeOutCubic;

final rng = Random();

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
  tenseVolatile(TenseMode('volatile')),
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
        tenseVolatile => 'Tense (volatile!)',
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

void addListener(ValueChanged<RawKeyEvent> func) => RawKeyboard.instance.addListener(func);
void yeetListener(ValueChanged<RawKeyEvent> func) => RawKeyboard.instance.removeListener(func);

class HueQueue {
  HueQueue(this.choices, {int? maxRecentChoices})
      : numColors = choices.length,
        recentChoices = [],
        maxRecent = maxRecentChoices ?? choices.length ~/ 2;

  final List<int> choices, recentChoices;
  final int numColors;
  late final int maxRecent;

  /// grabs the next hue to use and updates the queue.
  int get queuedHue {
    final hue = choices.removeAt(rng.nextInt(choices.length));
    if (recentChoices.length >= maxRecent) choices.add(recentChoices.removeAt(0));
    recentChoices.add(hue);
    return hue;
  }
}

extension ToInt on TextEditingValue {
  int toInt() => text.isEmpty ? 0 : int.parse(text);
}

extension NumStuff<T extends num> on T {
  T get squared => this * this as T;
  T stayInRange(T lower, T upper) => min(max(this, lower), upper);
}

T diff<T extends num>(T a, T b) => (a - b).abs() as T;
