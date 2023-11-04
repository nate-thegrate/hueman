import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// do an animation on boot :)
bool booted = false;

// settings
late bool externalKeyboard;
late bool casualMode;
late bool inverted;
late bool music;
late bool sounds;

// game progress
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
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  casualMode = prefs.getBool('casualMode') ?? true;
  externalKeyboard = prefs.getBool('externalKeyboard') ?? false;
  inverted = prefs.getBool('inverted') ?? false;
  music = prefs.getBool('music') ?? true;
  sounds = prefs.getBool('sounds') ?? true;
  superHue = prefs.getInt('superHue') ?? -1;

  Tutorial.init(prefs);
}

enum Tutorial {
  started,
  intro3,
  intro6,
  introC,
  casual,
  intense,
  master,
  sandbox,
  aiCertificate,
  sawInversion,
  trivial,
  tense,
  trueMastery,
  ;

  bool call() => data[this]!;

  Future<void> complete() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    data[this] = true;
    await prefs.setBool(name, true);
  }

  static late final Map<Tutorial, bool> data;

  static void init(SharedPreferences prefs) {
    const bool localStorage = true;
    data = switch (localStorage) {
      true => {for (final tutorial in values) tutorial: prefs.getBool(tutorial.name) ?? false},
      false => {
          started: false,
          intro3: false,
          intro6: false,
          introC: false,
          casual: false,
          intense: false,
          master: false,
          sandbox: false,
          aiCertificate: false,
          sawInversion: false,
          trivial: false,
          tense: false,
          trueMastery: false,
        },
    };
    // ignore: dead_code
    if (!localStorage) {
      casualMode = true;
      inverted = false;
      music = true;
      sounds = true;
      superHue = -1;
    }
  }
}
