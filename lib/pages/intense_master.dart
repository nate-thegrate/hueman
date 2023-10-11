import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:super_hueman/data/super_color.dart';
import 'package:super_hueman/data/photo_colors.dart';
import 'package:super_hueman/data/super_container.dart';
import 'package:super_hueman/pages/score.dart';
import 'package:super_hueman/pages/hue_typing_game.dart';
import 'package:super_hueman/data/save_data.dart';
import 'package:super_hueman/data/structs.dart';
import 'package:super_hueman/data/widgets.dart';
import 'package:collection/collection.dart';

import 'package:flutter/material.dart';

int hue = rng.nextInt(360);
SuperColor c = SuperColors.darkBackground;

class IntenseScoreKeeper implements ScoreKeeper {
  IntenseScoreKeeper({required this.scoring});
  int round = 0;
  final List<int> scores = [];
  int superCount = 0;

  /// ignore these, only used in [MasterScoreKeeper]
  late int rank, turnsAtRank100;

  final Function scoring;

  @override
  void scoreTheRound() => scoring();

  @override
  void roundCheck(BuildContext context) => (round == 30)
      ? Navigator.pushReplacement(
          context, MaterialPageRoute<void>(builder: (context) => ScoreScreen(this)))
      : ();

  @override
  Widget get midRoundDisplay {
    const TextStyle style = TextStyle(fontSize: 24);
    final Widget roundLabel = Text('round ${round + 1} / 30', style: style);
    if (round == 0) return roundLabel;

    final Widget accuracyDesc =
        Text('accuracy: ${scores.average.toStringAsFixed(1)}%', style: style);
    if (superCount == 0) return Column(children: [roundLabel, accuracyDesc]);

    final Widget superDesc = SuperContainer(
      margin: const EdgeInsets.only(top: 25),
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 15),
      decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(10)),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
                text: 's\u1d1cᴘᴇʀ',
                style: style.copyWith(color: SuperColors.epic[hue], fontWeight: FontWeight.w600)),
            const TextSpan(text: 'score ', style: style),
            TextSpan(
                text: 'count:   $superCount',
                style: style.copyWith(fontWeight: FontWeight.w100, fontSize: 22)),
          ],
        ),
      ),
    );
    return Column(children: [roundLabel, accuracyDesc, superDesc]);
  }

  @override
  Widget get finalScore => Text(
        (30 * scores.average * (superCount + 1)).round().toString(),
        style: const TextStyle(fontSize: 32),
      );

  @override
  Widget get finalDetails {
    String scoreDesc = '30 colors, ${scores.average.toStringAsFixed(2)}% accuracy';
    if (superCount > 0) {
      scoreDesc += '\n\u00d7${superCount + 1} bonus! '
          '($superCount s\u1d1cᴘᴇʀscore${superCount > 1 ? "s" : ""})';
    }
    return Text(
      scoreDesc,
      style: const TextStyle(fontSize: 18, color: Colors.white54),
    );
  }

  @override
  final Pages page = Pages.intense;
}

double screenHeight = 0;

class MasterScoreKeeper implements IntenseScoreKeeper {
  MasterScoreKeeper({required this.scoring});
  @override
  int superCount = 0;
  @override
  int round = 0;
  @override
  final List<int> scores = [];
  @override
  int rank = 0;

  @override
  int turnsAtRank100 = 0;

  @override
  final Function scoring;

  @override
  void scoreTheRound() => scoring();

  @override
  void roundCheck(BuildContext context) {
    if (round == 30) {
      Navigator.pushReplacement(
          context, MaterialPageRoute<void>(builder: (context) => ScoreScreen(this)));
    }
  }

  @override
  Widget get midRoundDisplay {
    const TextStyle style = TextStyle(fontSize: 24);
    final Color? cardColor = Color.lerp(c, Colors.white, pow(c.computeLuminance(), 2).toDouble());

    final Widget roundLabel = Text('round ${round + 1} / 30', style: style);
    final Widget rankDesc = Padding(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 15),
      child: Text(
        'rank: $rank',
        style: rank == 100
            ? const TextStyle(fontSize: 30, color: Colors.black, fontWeight: FontWeight.bold)
            : style,
      ),
    );
    final Widget rankLabel = rank == 100
        ? Card(color: cardColor, elevation: 8, shadowColor: cardColor, child: rankDesc)
        : Card(color: Colors.black38, elevation: 0, child: rankDesc);

    return Flex(
      direction: screenHeight < 1000 ? Axis.horizontal : Axis.vertical,
      children: [roundLabel, const SizedBox(width: 15, height: 15), rankLabel],
    );
  }

  @override
  Widget get finalScore => Text(
        (rank * max(1, turnsAtRank100) * (superCount + 1)).toString(),
        style: const TextStyle(fontSize: 32),
      );

  @override
  Widget get finalDetails {
    String finalDesc = 'final rank: $rank';
    if (turnsAtRank100 > 1) {
      finalDesc += '\n\u00d7$turnsAtRank100 ($turnsAtRank100 turns at rank 100)';
    }
    if (superCount > 0) {
      finalDesc +=
          '\n\u00d7${superCount + 1} ($superCount s\u1d1cᴘᴇʀscore${superCount > 1 ? "s" : ""}!)';
    }
    return Text(
      finalDesc,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 18, color: Colors.white54),
    );
  }

  @override
  final Pages page = Pages.master;
}

class SawEveryPic extends StatelessWidget {
  const SawEveryPic({super.key});

  GestureRecognizer hyperlink(String url) => TapGestureRecognizer()..onTap = gotoWebsite(url);

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Congrats!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              "You've made it through every image!",
              style: TextStyle(fontSize: 16),
            ),
            const FixedSpacer(16),
            RichText(
              text: TextSpan(children: [
                const TextSpan(text: '(shoutout to'),
                TextSpan(
                  text: '  Wikipedia  ',
                  style: const TextStyle(color: SuperColors.azure, height: 3),
                  recognizer: hyperlink('https://commons.wikimedia.org/w/index.php'
                      '?title=Special:MediaSearch&type=image&haslicense=unrestricted'),
                ),
                const TextSpan(text: 'and'),
                TextSpan(
                  text: '  rawpixel  ',
                  style: const TextStyle(color: SuperColors.azure, height: 3),
                  recognizer: hyperlink('https://www.rawpixel.com/public-domain'),
                ),
                const TextSpan(text: '\nfor hosting all those public domain images)'),
              ]),
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.black38),
              onPressed: () => context.goto(Pages.mainMenu),
              child: const Padding(
                padding: EdgeInsets.fromLTRB(8, 8, 8, 12),
                child: Text(
                  'back to menu',
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      );
}

class IntenseMode extends StatefulWidget {
  const IntenseMode([this.master, Key? key]) : super(key: key);
  final String? master;

  @override
  State<IntenseMode> createState() => _IntenseModeState();
}

class _IntenseModeState extends State<IntenseMode> {
  bool get masterMode => widget.master == 'master';
  bool get showPics => masterMode && casualMode;

  final List<(Widget, SuperColor)> pics = [];

  late final FocusNode? hueFocusNode;
  late final TextEditingController? hueController;
  late final NumPadController? numPadController;

  late final IntenseScoreKeeper? scoreKeeper;

  int get difficulty {
    if (!masterMode) return 0;
    return casualMode ? 50 : scoreKeeper!.rank;
  }

  /// used in 'master' mode if we're keeping score
  double masterRNG = rng.nextDouble();
  double get saturation => pow(1 + difficulty / 1000 * (masterRNG - 1), 20).toDouble();
  double get value => pow(1 - difficulty / 700 * masterRNG, 20).toDouble();

  int get guess =>
      externalKeyboard ? hueController!.value.toInt() : int.parse(numPadController!.displayValue);

  int get offBy {
    final int hueDiff = diff(hue, guess);
    return min(hueDiff, diff(hueDiff, 360));
  }

  int get accuracy => (pow(1 - offBy / 180, 2) * 100).round();

  void generatePic() {
    if (pics.length == 1) {
      showDialog(
        context: context,
        builder: (context) => const SawEveryPic(),
        barrierDismissible: false,
      );
      return;
    }
    pics.removeAt(0);
    setState(() => hue = HSVColor.fromColor(pics.first.$2).hue.round());
  }

  /// new random hue will be at least 30° away from previous.
  void generateHue() {
    numPadController?.clear();
    if (!hueMaster && offBy == 0) superHue = hue;
    int newHue = rng.nextInt(300);
    if (newHue + 30 >= hue) newHue += 60;

    setState(() {
      hue = newHue;
      masterRNG = rng.nextDouble();
    });
  }

  SuperColor get color {
    if (showPics) return pics.first.$2;

    c = SuperColor.hsv(hue, saturation, value);
    return c;
  }

  String get text => switch (offBy) {
        0 => 'SUPER!',
        1 => 'Just 1 away?!',
        <= 5 => 'Fantastic!',
        <= 10 => 'Great job!',
        <= 20 => 'Nicely done.',
        _ => 'oof…',
      };

  Widget? get image => (casualMode && masterMode) ? pics.first.$1 : null;

  void intenseScore() {
    scoreKeeper!.scores.add(accuracy);
    if (offBy == 0) scoreKeeper!.superCount++;
    scoreKeeper!.round++;
  }

  void masterScore() {
    if (scoreKeeper case final MasterScoreKeeper sk) {
      switch (offBy) {
        case > 20:
          sk.rank += 20 - offBy;
        case _ when sk.rank == 100:
          if (offBy > 10) sk.rank--;
        case 0:
          sk.rank += 11;
          sk.rank += 25 - (sk.rank % 25);
          sk.superCount++;
        case < 10:
          sk.rank += 10 - offBy;
      }

      sk.rank = sk.rank.stayInRange(0, 100);

      if (sk.rank == 100) sk.turnsAtRank100++;
      sk.round++;
    }
  }

  @override
  void initState() {
    super.initState();
    inverted = false;
    scoreKeeper = casualMode
        ? null
        : masterMode
            ? MasterScoreKeeper(scoring: masterScore)
            : IntenseScoreKeeper(scoring: intenseScore);
    if (externalKeyboard) {
      hueFocusNode = FocusNode();
      hueController = TextEditingController();
      numPadController = null;
    } else {
      hueFocusNode = null;
      hueController = null;
      numPadController = externalKeyboard ? null : NumPadController(setState);
    }
    if (showPics) {
      final ogPics = allImages.toList();
      ogPics.shuffle();
      final double width = screenHeight < 1200 ? screenHeight - 700 : 500;
      for (final ogPic in ogPics) {
        final randomColors = ogPic.randomColors;
        pics.add((ogPic.image(width: width), randomColors.$1));
        pics.add((ogPic.image(width: width), randomColors.$2));
      }
      hue = HSVColor.fromColor(pics.first.$2).hue.round();
    }
    hueFocusNode?.requestFocus();
  }

  static const List<Color> oranges = [
    Color(0xffb78049),
    Color(0xff96612b),
    Color(0xffb57c43),
  ];
  bool get isOrange => showPics && oranges.contains(pics.first.$2);

  Widget hueDialogBuilder(context) => isOrange
      ? HueDialog(
          (hue == guess) ? 'Nice work!' : 'Incorrect…',
          guess,
          hue,
          const ColorNameBox(SuperColors.orange),
        )
      : HueDialog(
          text,
          guess,
          hue,
          offBy == 0
              ? const HundredPercentGrade()
              : PercentGrade(accuracy: accuracy, color: color),
        );

  bool get littleBitSquished => image != null && context.screenHeight < 1200;
  @override
  Widget build(BuildContext context) {
    screenHeight = context.screenHeight;
    final double width = screenHeight < 1200 ? screenHeight - 700 : 500;
    return externalKeyboard
        ? KeyboardGame(
            color: color,
            hueFocusNode: hueFocusNode!,
            hueController: hueController!,
            hueDialogBuilder: hueDialogBuilder,
            generateHue: showPics ? generatePic : generateHue,
            scoreKeeper: scoreKeeper,
            image: image,
          )
        : NumPadGame(
            color: color,
            numPad: (submit) => NumPad(numPadController!, submit: submit),
            numPadVal: numPadController!.displayValue,
            hueDialogBuilder: hueDialogBuilder,
            scoreKeeper: scoreKeeper,
            generateHue: showPics ? generatePic : generateHue,
            image: littleBitSquished
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SuperContainer(width: 100, height: width, color: color),
                      image!,
                      SuperContainer(width: 100, height: width, color: color),
                    ],
                  )
                : image,
          );
  }
}
