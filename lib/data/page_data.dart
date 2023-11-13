import 'package:flutter/material.dart';
import 'package:hueman/data/save_data.dart';
import 'package:hueman/inverse_pages/even_further.dart';
import 'package:hueman/inverse_pages/menu.dart';
import 'package:hueman/inverse_pages/sandbox.dart';
import 'package:hueman/inverse_pages/tense.dart';
import 'package:hueman/inverse_pages/trivial.dart';
import 'package:hueman/inverse_pages/true_mastery.dart';
import 'package:hueman/pages/intense_master.dart';
import 'package:hueman/pages/intro.dart';
import 'package:hueman/pages/menu.dart';
import 'package:hueman/pages/sandbox.dart';
import 'package:hueman/tutorial_pages/ai_certificate.dart';
import 'package:hueman/tutorial_pages/intense.dart';
import 'package:hueman/tutorial_pages/intro_3.dart';
import 'package:hueman/tutorial_pages/intro_6.dart';
import 'package:hueman/tutorial_pages/intro_c.dart';
import 'package:hueman/tutorial_pages/master.dart';
import 'package:hueman/tutorial_pages/sandbox.dart';
import 'package:hueman/tutorial_pages/start.dart';
import 'package:hueman/tutorial_pages/even_further.dart';
import 'package:hueman/tutorial_pages/true_mastery.dart';

enum Pages {
  start(StartScreen()),
  menu(MainMenu()),
  intro3(IntroMode(3)),
  intro6(IntroMode(6)),
  introC(IntroMode(0xC)),
  intro18(IntroMode(0x18)),
  intense(IntenseMode()),
  master(IntenseMode('master')),
  sandbox(Sandbox()),
  aiCertificate(AiCertificate()),

  trivial(TriviaMode()),
  tenseVibrant(TenseMode('vibrant')),
  tenseVolatile(TenseMode('volatile')),
  trueMastery(TrueMastery()),
  evenFurther(EvenFurther()),
  ;

  const Pages(this._widget);
  final Widget _widget;

  Widget get widget => switch (this) {
        intro3 when !Tutorial.intro3() => const Intro3Tutorial(),
        intro6 when !Tutorial.intro6() => const Intro6Tutorial(),
        introC when !Tutorial.introC() => const IntroCTutorial(),
        intense when !Tutorial.intense() => const IntenseTutorial(),
        master when !Tutorial.master() => const MasterTutorial(),
        sandbox when !Tutorial.sandbox() => const SandboxTutorial(),
        trueMastery when !Tutorial.trueMastery() => const TrueMasteryTutorial(),
        evenFurther when !Tutorial.evenFurther() => const EvenFurtherTutorial(),
        sandbox when inverted => const InverseSandbox(),
        menu when inverted => const InverseMenu(),
        _ => _widget,
      };

  /// button text
  String call() => switch (this) {
        intro3 => '3 colors',
        intro6 => '6 colors',
        introC => '12 colors',
        intro18 => '24 colors',
        _ when name.startsWith('tense') => name.substring(5).toLowerCase(),
        _ => name,
      };

  String get gameMode => switch (this) {
        intro3 => 'intro  (3 colors)',
        intro6 => 'intro  (6 colors)',
        introC => 'intro  (12 colors)',
        intro18 => 'intro  (24 colors)',
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

  static String get initialRoute => (Tutorial.started() ? menu : start).name;
}
