// settings
bool casualMode = true;
bool autoSubmit = true;
bool externalKeyboard = true;
bool inverted = false;
bool music = true;
bool sounds = true;

// game progress
int? superHue;
bool get hueMaster => superHue != null;

abstract class Tutorials {
  static bool intro = false;
  static bool intro3 = false;
  static bool intro6 = false;
  static bool intro12 = false;
  static bool intense = false;
  static bool master = false;

  static bool compSci = false;
  static bool trueMastery = false;

  static bool ads = false;
}
