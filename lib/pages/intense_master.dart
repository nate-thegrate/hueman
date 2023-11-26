import 'dart:math';
import 'package:hueman/data/page_data.dart';
import 'package:hueman/data/super_color.dart';
import 'package:hueman/data/photo_colors.dart';
import 'package:hueman/data/super_container.dart';
import 'package:hueman/data/super_state.dart';
import 'package:hueman/data/super_text.dart';
import 'package:hueman/pages/score.dart';
import 'package:hueman/pages/find_the_hues.dart';
import 'package:hueman/data/save_data.dart';
import 'package:hueman/data/structs.dart';

import 'package:flutter/material.dart';

int hue = rng.nextInt(360);
SuperColor c = SuperColors.darkBackground;

class IntenseScoreKeeper implements ScoreKeeper {
  IntenseScoreKeeper({required this.scoring});
  final Function scoring;
  int round = 0, superCount = 0;
  final List<int> scores = [];

  @override
  void scoreTheRound() => scoring();

  @override
  void roundCheck(BuildContext context) {
    if (round != 30) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute<void>(builder: (context) => ScoreScreen(this)));
  }

  @override
  Widget get midRoundDisplay {
    const style = SuperStyle.sans(size: 24);
    final roundLabel = Text('round ${round + 1} / 30', style: style);
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
                text: 'SUPER',
                style: SuperStyle.sans(color: SuperColors.epic[hue], weight: 600, size: 18)),
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
  int get scoreVal => (30 * scores.average * (superCount + 1)).round();

  @override
  String get finalDetails {
    final String scoreDesc = '30 colors, ${scores.average.toStringAsFixed(2)}% accuracy';
    if (superCount == 0) return scoreDesc;
    return '$scoreDesc\n'
        '\u00d7${superCount + 1} bonus! '
        '($superCount superscore${superCount > 1 ? "s" : ""})';
  }

  @override
  final Pages page = Pages.intense;
}

class MasterScoreKeeper implements IntenseScoreKeeper {
  MasterScoreKeeper({required this.scoring});
  int rank = 0, turnsAtRank100 = 0;
  @override
  int superCount = 0, round = 0;
  @override
  final List<int> scores = [];

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
  Widget get midRoundDisplay => _MasterScoreDisplay(round, rank);

  @override
  int get scoreVal => rank * max(1, turnsAtRank100) * (superCount + 1) as int;

  @override
  String get finalDetails {
    String finalDesc = 'final rank: $rank';
    if (turnsAtRank100 > 1) {
      finalDesc += '\n\u00d7$turnsAtRank100 ($turnsAtRank100 turns at rank 100)';
    }
    if (superCount > 0) {
      finalDesc +=
          '\n\u00d7${superCount + 1} ($superCount superscore${superCount > 1 ? "s" : ""}!)';
    }
    return finalDesc;
  }

  @override
  final Pages page = Pages.master;
}

class _MasterScoreDisplay extends StatelessWidget {
  const _MasterScoreDisplay(this.round, this.rank);
  final int round, rank;

  @override
  Widget build(BuildContext context) {
    const style = SuperStyle.sans(size: 20);
    final Color? cardColor = Color.lerp(c, Colors.white, pow(c.computeLuminance(), 2).toDouble());

    final Widget roundLabel = Text('round ${round + 1} / 30', style: style);
    final Widget rankDesc = Padding(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 15),
      child: Text(
        'rank: $rank',
        style: rank == 100
            ? const SuperStyle.sans(size: 24, color: Colors.black, weight: 800)
            : style,
      ),
    );
    final Widget rankLabel = rank == 100
        ? Card(color: cardColor, elevation: 8, shadowColor: cardColor, child: rankDesc)
        : Card(color: Colors.black38, elevation: 0, child: rankDesc);

    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Flex(
          direction: hueTyping ? Axis.horizontal : Axis.vertical,
          mainAxisSize: MainAxisSize.min,
          children: [roundLabel, const SizedBox.square(dimension: 15), rankLabel],
        ),
      ),
    );
  }
}

class SawEveryPic extends StatelessWidget {
  const SawEveryPic({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Congrats!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "You've made it through every image!",
            style: SuperStyle.sans(size: 16),
          ),
          if (!Tutorial.mastered()) const _NewHuesUnlocked(),
        ],
      ),
      actions: [
        Center(
          child: TextButton(
            style: TextButton.styleFrom(backgroundColor: Colors.black38),
            onPressed: context.menu,
            child: const Padding(
              padding: EdgeInsets.fromLTRB(8, 8, 8, 12),
              child: Text(
                'back to menu',
                style: SuperStyle.sans(size: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NewHuesUnlocked extends StatefulWidget {
  const _NewHuesUnlocked();

  @override
  State<_NewHuesUnlocked> createState() => _NewHuesUnlockedState();
}

class _NewHuesUnlockedState extends EpicState<_NewHuesUnlocked> {
  @override
  void animate() => Tutorial.mastered.complete();

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text.rich(
        textAlign: TextAlign.center,
        softWrap: false,
        TextSpan(
          children: [
            TextSpan(
              text: '\n12 new hues unlocked!\n',
              style: SuperStyle.gaegu(
                size: 27,
                weight: FontWeight.bold,
                color: epicColor,
                shadows: const [
                  Shadow(blurRadius: 1),
                  Shadow(blurRadius: 2),
                  Shadow(blurRadius: 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
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
    if (scoreKeeper case final MasterScoreKeeper sk) return casualMode ? 50 : sk.rank;
    return 0;
  }

  /// used in 'master' mode if we're keeping score
  double masterRNG = rng.nextDouble();
  double get saturation => pow(1 + difficulty / 1000 * (masterRNG - 1), 20).toDouble();
  double get value => pow(1 - difficulty / 700 * masterRNG, 20).toDouble();

  late int _guess;
  int get guess {
    if (!hueTyping) return _guess;
    if (externalKeyboard) return hueController!.value.toInt();
    final val = numPadController!.displayValue;
    return val.isEmpty ? 0 : int.parse(val);
  }

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
    if (numPadController != null) setState(numPadController!.clear);
  }

  /// new random hue will be at least 30° away from previous.
  void generateHue() {
    if (!Score.superHue() && offBy == 0) {
      Score.superHue.set(hue);
    }
    if (numPadController != null) setState(numPadController!.clear);
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

  Widget? image(BoxConstraints constraints) {
    if (!casualMode || !masterMode) return null;
    final height = constraints.calcSize((w, h) => min(h - (externalKeyboard ? 333 : 425), w * 2));
    final pad = ((constraints.maxWidth - height) / 2 + 50).stayInRange(0, 50);
    final pic = pics.first.$1;
    if (!hueTyping) return pic;
    return SuperContainer(
      width: double.infinity,
      height: height,
      padding: EdgeInsets.symmetric(horizontal: pad),
      color: color,
      alignment: Alignment.center,
      child: pic,
    );
  }

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
    scoreKeeper = switch (masterMode) {
      _ when casualMode => null,
      true => MasterScoreKeeper(scoring: masterScore),
      false => IntenseScoreKeeper(scoring: intenseScore),
    };
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
      for (final ogPic in ogPics) {
        final randomColors = ogPic.randomColors;
        pics.add((ogPic, randomColors.$1));
        pics.add((ogPic, randomColors.$2));
      }
      hue = HSVColor.fromColor(pics.first.$2).hue.round();
    }
    hueFocusNode?.requestFocus();
  }

  static const List<Color> oranges = [
    SuperColor(0xB78049),
    SuperColor(0x96612B),
    SuperColor(0xB57C43),
  ];
  bool get isOrange => showPics && oranges.contains(pics.first.$2);

  Widget hueDialogBuilder(context) => isOrange
      ? HueDialog(
          (hue == guess) ? 'Nice work!' : 'Incorrect…',
          guess,
          hue,
          IntroGraphic(hue: hue, guess: guess),
        )
      : HueDialog(
          text,
          guess,
          hue,
          switch (offBy) {
            0 => const HundredPercentGrade(),
            _ when masterMode => PercentGrade(accuracy: accuracy, color: color),
            _ => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PercentGrade(accuracy: accuracy, color: color),
                  IntroGraphic(hue: hue, guess: guess),
                ],
              ),
          },
        );

  @override
  Widget build(BuildContext context) {
    // ignore: avoid_print
    if (!Score.superHue()) print(hue);

    if (!hueTyping) {
      final gameScreen = CircleGame(
        color: color,
        numColors: 360,
        generateHue: showPics ? generatePic : generateHue,
        updateGuess: (value) => _guess = value,
        hueDialogBuilder: hueDialogBuilder,
        scoreKeeper: scoreKeeper,
        image: image,
      );
      if (scoreKeeper case final MasterScoreKeeper sk) {
        final bars = RankBars(sk.rank, color: color);
        return Row(children: [bars, Expanded(child: gameScreen), bars]);
      }
      return gameScreen;
    }
    if (externalKeyboard) {
      return KeyboardGame(
        color: color,
        hueFocusNode: hueFocusNode!,
        hueController: hueController!,
        hueDialogBuilder: hueDialogBuilder,
        generateHue: showPics ? generatePic : generateHue,
        scoreKeeper: scoreKeeper,
        image: image,
      );
    }
    return NumPadGame(
      color: color,
      numPad: (submit) => NumPad(numPadController!, submit: submit),
      numPadVal: numPadController!.displayValue,
      hueDialogBuilder: hueDialogBuilder,
      scoreKeeper: scoreKeeper,
      generateHue: showPics ? generatePic : generateHue,
      image: image,
    );
  }
}
