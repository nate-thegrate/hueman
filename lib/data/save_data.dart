import 'package:shared_preferences/shared_preferences.dart';

/// do an animation on boot :)
bool booted = false;

// settings
late bool casualMode;
late bool autoSubmit;
late bool externalKeyboard;
late bool inverted;
late bool music;
late bool sounds;

// game progress
late bool tutorialIntro3;
late bool tutorialIntro6;
late bool tutorialIntroC;
late bool tutorialCasual;
late bool tutorialIntense;
late bool tutorialMaster;
late bool tutorialTrivial;
late bool tutorialTense;
late bool tutorialSandbox;
late bool tutorialTrueMastery;

late bool started;
late bool sawInversion;
late int superHue;
bool get hueMaster => superHue != -1;

Future<void> saveData(String key, Object value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (key == 'superHue') {
    await prefs.setInt(key, value as int);
    return;
  }
  await prefs.setBool(key, value as bool);
}

/// using an enum probably would have been better haha
Future<void> loadData() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  casualMode = prefs.getBool('casualMode') ?? true;
  autoSubmit = prefs.getBool('autoSubmit') ?? false;
  externalKeyboard = prefs.getBool('externalKeyboard') ?? false;
  inverted = prefs.getBool('inverted') ?? false;
  music = prefs.getBool('music') ?? true;
  sounds = prefs.getBool('sounds') ?? true;

  tutorialIntro3 = prefs.getBool('tutorialIntro3') ?? false;
  tutorialIntro6 = prefs.getBool('tutorialIntro6') ?? false;
  tutorialIntroC = prefs.getBool('tutorialIntroC') ?? false;
  tutorialCasual = prefs.getBool('tutorialCasual') ?? false;
  tutorialIntense = prefs.getBool('tutorialIntense') ?? false;
  tutorialMaster = prefs.getBool('tutorialMaster') ?? false;
  tutorialTrivial = prefs.getBool('tutorialTrivial') ?? false;
  tutorialTense = prefs.getBool('tutorialTense') ?? false;
  tutorialSandbox = prefs.getBool('tutorialSandbox') ?? false;
  tutorialTrueMastery = prefs.getBool('tutorialTrueMastery') ?? false;
  started = prefs.getBool('started') ?? false;
  sawInversion = prefs.getBool('sawInversion') ?? false;

  superHue = prefs.getInt('superHue') ?? -1;
}
