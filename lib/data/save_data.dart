import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hueman/data/page_data.dart';
import 'package:hueman/data/structs.dart';
import 'package:hueman/inverse_pages/tense.dart';
import 'package:hueman/inverse_pages/true_mastery.dart';
import 'package:hueman/pages/intense_master.dart';
import 'package:hueman/pages/intro.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// do a menu animation on boot
bool booted = false;

/// K
bool theEndApproaches = false;

// settings
late bool hueTyping;
late bool externalKeyboard;
late bool hueRuler;
late bool casualMode;
late bool inverted;
late bool evenFurther;
late bool music;
late bool sounds;

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
  final prefs = await SharedPreferences.getInstance();
  casualMode = prefs.getBool('casualMode') ?? true;
  hueTyping = prefs.getBool('hueTyping') ?? true;
  externalKeyboard = prefs.getBool('externalKeyboard') ?? false;
  hueRuler = prefs.getBool('hueRuler') ?? true;
  inverted = prefs.getBool('inverted') ?? false;
  evenFurther = prefs.getBool('evenFurther') ?? false;
  music = prefs.getBool('music') ?? true;
  sounds = prefs.getBool('sounds') ?? true;

  Tutorial.init(prefs);
  Score.init(prefs);
}

Future<void> reset() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  exit(0);
}

enum Tutorial {
  started,
  intro3,
  intro6,
  introC,
  casual,
  intense,
  master,
  mastered,
  sandbox,
  aiCertificate,
  sawInversion,
  trivial,
  tense,
  trueMastery,
  gameEnd,
  evenFurther,
  worldEnd,
  ;

  bool call() => data[this]!;

  Future<void> complete() async {
    final prefs = await SharedPreferences.getInstance();
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
          mastered: false,
          sandbox: false,
          aiCertificate: false,
          sawInversion: false,
          trivial: false,
          tense: false,
          trueMastery: false,
          gameEnd: false,
          evenFurther: false,
          worldEnd: false,
        },
    };
    // ignore: dead_code
    if (!localStorage) {
      casualMode = true;
      hueRuler = true;
      inverted = false;
      music = true;
      sounds = true;
    }
  }
}

/// stores the player's superHUE and high scores.
enum Score {
  superHue,
  introC,
  intro18,
  intense,
  master,
  tenseVibrant,
  tenseVolatile,
  trueMastery,
  ;

  int? get value => highScores[this];
  int get mine => myScores[this]!;
  String get compare => '${(value! * 100) ~/ mine}%';
  bool call() => value != null;
  String get scoreKey => this == superHue ? name : '${name}Score';
  String get label => switch (this) {
        superHue => throw Error(),
        introC => 'intro_0x0C',
        intro18 => 'intro_0x18',
        intense => 'intense_mode',
        master => 'master_mode',
        tenseVibrant => 'tense_vibrant',
        tenseVolatile => 'tense_volatile',
        trueMastery => 'true_mastery',
      };

  Future<void> set(int score) async {
    if (score < (value ?? 0)) return;
    highScores[this] = score;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(scoreKey, score);
  }

  static Iterable<Score> get allScores => values.skip(1);
  static bool get noneSet {
    for (final score in allScores) {
      if (score()) return false;
    }
    return true;
  }

  static late final Map<Score, int?> highScores;
  static const Map<Score, int> myScores = {
    introC: 3774,
    intro18: 1944,
    intense: 14280,
    master: 162,
    tenseVibrant: 23940,
    tenseVolatile: 7740,
    trueMastery: 140,
  };

  static void init(SharedPreferences prefs) {
    highScores = {for (final value in values) value: prefs.getInt(value.scoreKey)};
  }

  static Score? fromScoreKeeper(ScoreKeeper scoreKeeper) => switch (scoreKeeper) {
        final IntroScoreKeeper sk when sk.numColors == 0xC => introC,
        final IntroScoreKeeper sk when sk.numColors == 0x18 => intro18,
        final TenseScoreKeeper sk when sk.page == Pages.tenseVibrant => tenseVibrant,
        TenseScoreKeeper() => tenseVolatile,
        MasterScoreKeeper() => master,
        IntenseScoreKeeper() => intense,
        TrueMasteryScoreKeeper() => trueMastery,
        _ => null,
      };
}
