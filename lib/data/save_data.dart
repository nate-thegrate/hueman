// import 'package:super_hueman/data/structs.dart';

/// do an animation on boot :)
bool booted = false;

// settings
bool casualMode = true;
bool autoSubmit = true;
bool externalKeyboard = false;
bool inverted = true;
bool music = true;
bool sounds = true;

// game progress
int superHue = -1;
// int superHue = rng.nextInt(360);
bool get hueMaster => superHue != -1;

abstract final class Tutorials {
  static bool started = true;
  static bool intro3 = false;
  static bool intro6 = false;
  static bool introC = true;
  static bool casual = false;
  static bool intense = false;
  static bool master = false;
  static bool trivial = true;
  static bool tense = true;
  static bool sandbox = true;
  static bool trueMastery = false;

  static bool sawInversion = false;
}
