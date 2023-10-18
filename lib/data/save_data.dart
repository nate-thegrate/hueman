import 'package:super_hueman/data/structs.dart';

/// do an animation on boot :)
bool booted = false;

// settings
bool casualMode = true;
bool autoSubmit = true;
bool externalKeyboard = true;
bool inverted = true;
bool music = true;
bool sounds = true;

// game progress
int? superHue = rng.nextInt(360);
bool get hueMaster => superHue != null;

abstract final class Tutorials {
  static bool started = true;
  static bool intro3 = false;
  static bool intro6 = false;
  static bool introC = false;
  static bool casual = false;
  static bool intense = false;
  static bool master = false;
  static bool trivial = false;
  static bool tense = false;
  static bool compSci = false;
  static bool trueMastery = true;

  static bool ads = false;
}
