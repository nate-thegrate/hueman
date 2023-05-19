import 'dart:math';

import 'package:flutter/material.dart';

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
  mainMenu,
  easy,
  intense,
  master,
  ;

  String call() => name;
}

extension ContextStuff on BuildContext {
  /// less stuff to type now :)
  void goto(Pages page) => Navigator.pushReplacementNamed(this, page());
}

Color contrastWith(Color c) => (c.computeLuminance() > .2) ? Colors.black : Colors.white;

String? colorName(Color c) => {
      "Color(0xffff0000)": "red",
      "Color(0xffffff00)": "yellow",
      "Color(0xff00ff00)": "green",
      "Color(0xff00ffff)": "cyan",
      "Color(0xff0000ff)": "blue",
      "Color(0xffff00ff)": "magenta",
    }[c.toString()];

const Widget empty = SizedBox.shrink();
const Widget filler = Expanded(child: empty);
Widget vspace(double h) => SizedBox(height: h);
Widget hspace(double w) => SizedBox(width: w);

extension ToInt on TextEditingValue {
  int toInt() => text.isEmpty ? 0 : int.parse(text);
}

final rng = Random();
