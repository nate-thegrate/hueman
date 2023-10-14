import 'package:flutter/material.dart';
import 'package:super_hueman/data/structs.dart';

/// Auto-runs [animate] when initialized,
/// and prevents [setState] from running when disposed.
///
/// Also adds a handy [sleepState] function.
abstract class SuperState<T extends StatefulWidget> extends State<T> {
  @override
  void setState(fn) => mounted ? super.setState(fn) : null;

  void animate() async {}

  @override
  void initState() {
    super.initState();
    animate();
  }

  /// [sleep], then [setState].
  Future<void> sleepState(double seconds, VoidCallback fn) =>
      sleep(seconds, then: () => setState(fn));
}
