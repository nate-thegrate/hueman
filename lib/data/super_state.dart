import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hueman/data/save_data.dart';
import 'package:hueman/data/structs.dart';
import 'package:hueman/data/super_color.dart';

/// Auto-runs [animate] when initialized,
/// and prevents [setState] from running when disposed.
///
/// Also adds a handy [sleepState] function.
abstract class SuperState<T extends StatefulWidget> extends State<T> {
  @override
  void setState(VoidCallback fn) => mounted ? super.setState(fn) : null;

  void animate() {}

  @override
  void initState() {
    super.initState();
    animate();
  }

  /// [sleep], then [setState].
  Future<void> sleepState(double seconds, VoidCallback fn) =>
      sleep(seconds, then: () => setState(fn));
}

int epicHue = rng.nextInt(360), inverseHue = rng.nextInt(360);

/// a [Color] with [epicHue] as its hue.
///
/// The color is retrieved from [epicColors],
/// where all colors have the same luminosity.
SuperColor get epicColor => SuperColors.epic[epicHue];

/// oscillates between 0 and 2 based on [epicHue].
///
/// Each peak is a tertiary color,
/// and each 0-value is the hue of an additive/subtractive primary :)
double get epicSine => sin(2 * pi * epicHue * 6 / 360) + 1;

/// similar to [epicColor], but the color is darker.
///
/// It also cycles the reverse way through the hues.
SuperColor get inverseColor => SuperColors.inverse[inverseHue];

/// Sets up the fancy colors!
///
/// Increments the hue every 4 frames.
Ticker epicSetup(StateSetter setState) {
  int cycle = 0;
  void epicCycle(_) {
    cycle = ++cycle % 4;
    if (cycle == 0) setState(() => epicHue = ++epicHue % 360);
  }

  return Ticker(epicCycle)..start();
}

/// Just like epicSetup, but goes in reverse, and twice as fast.
Ticker inverseSetup(StateSetter setState) {
  bool cycle = false;
  void inverseCycle(_) {
    cycle = !cycle;
    if (cycle) setState(() => inverseHue = --inverseHue % 360);
  }

  return Ticker(inverseCycle)..start();
}

abstract class EpicState<T extends StatefulWidget> extends SuperState<T> {
  late final Ticker epicHues;

  @override
  void initState() {
    super.initState();
    epicHues = epicSetup(setState);
  }

  @override
  void dispose() {
    epicHues.dispose();
    super.dispose();
  }
}

abstract class InverseState<T extends StatefulWidget> extends SuperState<T> {
  late final Ticker inverseHues;

  @override
  void initState() {
    super.initState();
    inverseHues = inverseSetup(setState);
  }

  @override
  void dispose() {
    inverseHues.dispose();
    super.dispose();
  }
}

abstract class DynamicState<T extends StatefulWidget> extends SuperState<T> {
  late final Ticker hues;

  @override
  void initState() {
    super.initState();
    hues = inverted ? inverseSetup(setState) : epicSetup(setState);
  }

  @override
  void dispose() {
    hues.dispose();
    super.dispose();
  }
}
