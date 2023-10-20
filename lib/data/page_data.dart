import 'package:flutter/material.dart';
import 'package:hueman/data/save_data.dart';
import 'package:hueman/inverse_pages/menu.dart';
import 'package:hueman/inverse_pages/sandbox.dart';
import 'package:hueman/inverse_pages/tense.dart';
import 'package:hueman/inverse_pages/trivial.dart';
import 'package:hueman/inverse_pages/true_mastery.dart';
import 'package:hueman/pages/intense_master.dart';
import 'package:hueman/pages/intro.dart';
import 'package:hueman/pages/menu.dart';
import 'package:hueman/pages/sandbox.dart';
import 'package:hueman/tutorial_pages/intense.dart';
import 'package:hueman/tutorial_pages/intro_3.dart';
import 'package:hueman/tutorial_pages/intro_6.dart';
import 'package:hueman/tutorial_pages/intro_c.dart';
import 'package:hueman/tutorial_pages/master.dart';
import 'package:hueman/tutorial_pages/sandbox.dart';
import 'package:hueman/tutorial_pages/start.dart';

enum Pages {
  start(StartScreen()),
  menu(MainMenu()),
  intro3(IntroMode(3)),
  intro6(IntroMode(6)),
  introC(IntroMode(12)),
  intense(IntenseMode()),
  master(IntenseMode('master')),
  sandbox(Sandbox()),

  trivial(TriviaMode()),
  tenseVibrant(TenseMode('vibrant')),
  tenseVolatile(TenseMode('volatile')),
  trueMastery(TrueMastery()),
  ;

  const Pages(this._widget);
  final Widget _widget;

  Widget get widget => switch (this) {
        intro3 when !tutorialIntro3 => const Intro3Tutorial(),
        intro6 when !tutorialIntro6 => const Intro6Tutorial(),
        introC when !tutorialIntroC => const IntroCTutorial(),
        intense when !tutorialIntense => const IntenseTutorial(),
        master when !tutorialMaster => const MasterTutorial(),
        sandbox when !tutorialSandbox => const SandboxTutorial(),
        sandbox when inverted => const InverseSandbox(),
        menu when inverted => const InverseMenu(),
        _ => _widget,
      };

  /// button text
  String call() => switch (this) {
        trueMastery => 'true\nmastery',
        intro3 => '3 colors',
        intro6 => '6 colors',
        introC => '12 colors',
        _ when name.startsWith('tense') => name.substring(5).toLowerCase(),
        _ => name,
      };

  String get gameMode => switch (this) {
        intro3 => 'intro  (3 colors)',
        intro6 => 'intro  (6 colors)',
        introC => 'intro  (12 colors)',
        intense => 'Intense',
        master => 'Master',
        tenseVibrant => 'Tense (vibrant)',
        tenseVolatile => 'Tense (volatile!)',
        trueMastery => 'True Mastery',
        _ => throw Error(),
      };

  static Map<String, WidgetBuilder> routes = {
    for (final page in values) page.name: (context) => page.widget
  };

  static String get initialRoute => (started ? menu : start).name;
}
