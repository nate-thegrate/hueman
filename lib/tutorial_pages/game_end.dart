import 'dart:io';
import 'dart:math';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:super_hueman/data/save_data.dart';
import 'package:super_hueman/data/structs.dart';
import 'package:super_hueman/data/super_color.dart';
import 'package:super_hueman/data/super_container.dart';
import 'package:super_hueman/data/super_state.dart';
import 'package:super_hueman/data/widgets.dart';

class ThanksForPlaying extends StatefulWidget {
  const ThanksForPlaying({super.key});

  @override
  State<ThanksForPlaying> createState() => _ThanksForPlayingState();
}

class _ThanksForPlayingState extends SuperState<ThanksForPlaying> {
  bool showCredits = false,
      colorChange = false,
      showSuperHue = false,
      hideSuperHue = true,
      showHueVal = false,
      showText = true;
  final superColor = SuperColor.hue(superHue!);
  Widget text = const EasyText('Thanks for playing!');

  @override
  void animate() => sleepState(4, () => showCredits = true);

  void next() async {
    setState(() {
      showText = false;
      showCredits = false;
      colorChange = true;
    });
    await sleepState(3, () => showSuperHue = true);
    await sleepState(0.1, () => hideSuperHue = false);
    await sleepState(2, () {
      showText = true;
      text = const EasyText('Remember this?');
    });
    await sleepState(4, () => showText = false);
    await sleepState(1, () {
      text = const EasyText('This was the first time you chose correctly\nout of 360 options.');
      showText = true;
    });
    await sleepState(4, () => showText = false);
    await sleepState(1, () {
      text = EasyRichText([
        const TextSpan(text: 'Your super'),
        TextSpan(
          text: 'ʜᴜᴇ',
          style: TextStyle(
            color: superColor,
            fontWeight: FontWeight.w600,
            fontSize: 25,
          ),
        ),
        const TextSpan(text: '.'),
      ]);
      showText = true;
      showHueVal = true;
    });
    await sleepState(4, () => showText = false);
    await sleepState(1, () {
      text = EasyText('$superHue degree${superHue == 1 ? '' : 's'}. $hueDescription');
      showText = true;
    });
    await sleepState(5, () => showText = false);
    await sleepState(1, () {
      text = EasyRichText([
        const TextSpan(text: 'Fun fact: your super'),
        TextSpan(
          text: 'ʜᴜᴇ',
          style: TextStyle(
            color: superColor,
            fontWeight: FontWeight.w600,
            fontSize: 25,
          ),
        ),
        const TextSpan(text: ' actually says a lot about you,\njust like a zodiac sign.'),
      ]);
      showText = true;
    });
    await sleepState(6, () => showText = false);
    await sleepState(1, () {
      text = const EasyText('Wanna know what your hue says?');
      showText = true;
    });
    await sleepState(4, () => showText = false);
    await sleepState(1, () {
      text = EasyText('$superHue°:\n\n$hueZodiac');
      showText = true;
    });
    await sleepState(6, () {
      showText = false;
      hideSuperHue = true;
    });
    await sleepState(3, () {
      text = const EasyText('This game is 100% free & open-source software.');
      showText = true;
      showSuperHue = false;
    });
    await sleepState(5, () => showText = false);
    await sleepState(1, () {
      text = const EasyText("If you want to show support,\nhere's what you can do:");
      showText = true;
    });
    await sleepState(5, () {
      text = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          text,
          const FixedSpacer(20),
          const FadeIn(
            child: EasyText(
              'Just randomly bring up color theory\n'
              'in your next conversation with your friends.',
            ),
          ),
        ],
      );
      showText = true;
    });
    await sleepState(9, () => showText = false);
    await sleepState(1, () {
      text = const EasyText('When I say "it\'s a really fun time",');
      showText = true;
    });
    await sleepState(3, () {
      text = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          text,
          const FixedSpacer(10),
          const FadeIn(child: EasyText("that's me speaking from experience.")),
        ],
      );
      showText = true;
    });
    await sleepState(5, () => showText = false);
    await sleep(1);
    context.noTransition(const _TheEnd());
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: colorChange ? const ColorScheme.dark(primary: Colors.white) : null,
      ),
      child: Scaffold(
        body: Center(
          child: Column(
            children: [
              const Spacer(),
              if (showSuperHue) ...[
                const Spacer(),
                Fader(
                  !hideSuperHue,
                  child: SuperContainer(
                    width: 400,
                    height: 400,
                    color: superColor,
                    alignment: Alignment.center,
                    child: showHueVal
                        ? FadeIn(
                            child: Text(
                              '$superHue°',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 100,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
              ],
              const Spacer(),
              if (!showCredits) Expanded(flex: 2, child: Fader(showText, child: text)),
              AnimatedContainer(
                duration: oneSec,
                curve: Curves.easeInOutQuart,
                height: showCredits ? context.screenHeight : 0,
                color: const SuperColor(0xDEE3E8),
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  child: SizedBox(
                    height: context.screenHeight,
                    child: _Credits(next),
                  ),
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
        backgroundColor: colorChange ? SuperColors.darkBackground : SuperColors.lightBackground,
      ),
    );
  }
}

const Map<String, List<_CreditsButton>> _credits = {
  'author': [
    _CreditsButton(
      name: 'Nate Wilson',
      label: 'github',
      website: 'https://github.com/nate-thegrate/super_hueman',
      color: SuperColor(0x80FFF8),
    ),
  ],
  'animations': [
    _CreditsButton(
      name: ' Flutter',
      gradient: LinearGradient(
        colors: [
          SuperColor(0x54ccff),
          SuperColor(0x004080),
          SuperColor(0x0060C0),
          SuperColor(0x0060C0),
        ],
        stops: [0.36, 0.365, 0.45, 1],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      website: 'https://flutter.dev/',
      white: true,
    ),
    _CreditsButton(
      name: 'Rive',
      website: 'https://rive.app/',
      gradient: LinearGradient(
        colors: [SuperColor(0xff5580), SuperColor(0xcc3399)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ],
  'public domain\nimages': [
    _CreditsButton(
      name: 'rawpixel',
      website: 'https://www.rawpixel.com/public-domain',
      gradient: LinearGradient(colors: [SuperColor(0x66AAF0), SuperColor(0x7000C0)]),
      white: true,
    ),
    _CreditsButton(
      name: 'Wikipedia',
      website: 'https://commons.wikimedia.org/w/index.php'
          '?title=Special:MediaSearch&type=image&haslicense=unrestricted',
      color: SuperColor(0xfcfaf7),
    ),
  ],
  'inspiration': [
    _CreditsButton(
      name: ' Echo Gillette',
      label: 'youtube',
      gradient: LinearGradient(
        colors: [SuperColors.red, SuperColors.black],
        stops: [0.31, 0.315],
        begin: Alignment(-1, 0.5),
        end: Alignment(1, -0.5),
      ),
      white: true,
    ),
    _CreditsButton(
      name: 'Technology\nConnections',
      label: 'youtube',
      website: 'https://youtu.be/wh4aWZRtTwU',
      gradient: LinearGradient(
        colors: [SuperColor(0xffA040), SuperColor(0xc06000)],
        begin: Alignment.topCenter,
        end: Alignment.bottomRight,
      ),
    ),
  ],
};
const verifyAge = 'verify age';

class _CreditsButton extends StatelessWidget {
  const _CreditsButton({
    required this.name,
    this.website = verifyAge,
    this.gradient,
    this.color,
    this.label,
    this.white = false,
    this.onPressed,
  }) : assert((color ?? gradient) != null);

  final String name, website;
  final String? label;
  final SuperColor? color;
  final Gradient? gradient;
  final bool white;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final logo = label ?? name.trim().toLowerCase();
    return SuperContainer(
      margin: const EdgeInsets.all(5),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.zero,
          foregroundColor: Colors.white,
        ),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: color,
            gradient: gradient,
          ),
          child: Row(
            children: [
              const FixedSpacer.horizontal(25),
              SuperContainer(
                width: 40,
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  height: 33,
                  'assets/end_credits_icons/$logo.svg',
                ),
              ),
              SizedBox(
                width: 200,
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    height: 0,
                    fontWeight: FontWeight.normal,
                    color: white ? const Color(0xF0FFFFFF) : Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EchoButton extends StatelessWidget {
  const _EchoButton(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: const Color(0x10000000),
        foregroundColor: Colors.black,
      ),
      onPressed: () {
        Navigator.pop(context);
        if (label == 'continue') gotoWebsite('https://youtu.be/NVhA18_dmg0');
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
      ),
    );
  }
}

class _Credits extends StatefulWidget {
  const _Credits(this.buttonPress);
  final VoidCallback buttonPress;

  @override
  State<_Credits> createState() => _CreditsState();
}

class _CreditsState extends SuperState<_Credits> {
  bool showButton = false;
  late Map<String, (Color, Offset, bool)> lineData = {
    for (final label in _credits.keys) label: (Colors.black54, Offset.zero, false),
  };
  Future<void> resetLines({bool sleeping = false}) async {
    for (final label in _credits.keys) {
      if (sleeping) await sleep(2);
      setState(() => lineData[label] = (Colors.black54, Offset.zero, true));
    }
  }

  @override
  void animate() async {
    await sleep(5);
    await resetLines(sleeping: true);
    await sleepState(2, () => showButton = true);
  }

  VoidCallback onPressed(BuildContext context, Color color, String label, String website) =>
      () async {
        resetLines();
        setState(() => lineData[label] = (color, const Offset(-0.5, 0), true));
        await sleepState(0.2, () => lineData[label] = (color, const Offset(0, 0), true));
        await sleep(0.4);
        if (website == verifyAge) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/end_credits_icons/youtube.svg',
                    width: 50,
                    colorFilter: const ColorFilter.mode(SuperColors.red, BlendMode.srcIn),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("Echo's video"),
                  ),
                ],
              ),
              content: const Text(
                'This YouTube video has a little bit of adult language.\n\n'
                "Please only watch if you have an adult's permission.\n",
              ),
              actionsAlignment: MainAxisAlignment.spaceEvenly,
              actions: const [_EchoButton('go back'), _EchoButton('continue')],
            ),
          );
        } else {
          gotoWebsite(website);
        }
      };

  @override
  Widget build(BuildContext context) {
    // final inkColor = color.withAlpha(0x40);
    return Column(
      children: [
        const Spacer(),
        const Text(
          'Credits',
          style: TextStyle(fontSize: 48, fontWeight: FontWeight.w600),
        ),
        const EasyText('(tap on a button to go check it out!)', size: 14),
        const Spacer(),
        for (final MapEntry(key: label, value: buttons) in _credits.entries) ...[
          SuperContainer(
            height: buttons.length * 90,
            margin: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Fader(
                  lineData[label]!.$3,
                  child: SizedBox(
                    child: SuperContainer(
                      width: 175,
                      margin: const EdgeInsets.only(right: 25),
                      alignment: Alignment.centerRight,
                      child: Text(
                        label,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                ),
                AnimatedSlide(
                  duration: halfSec,
                  curve: Curves.easeOutCubic,
                  offset: lineData[label]!.$2,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: lineData[label]!.$1,
                      borderRadius: BorderRadius.circular(0xFF),
                    ),
                    child: SexyBox(child: lineData[label]!.$3 ? const SizedBox.expand() : flat),
                    // child: const SizedBox.expand(),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final _CreditsButton(
                          :name,
                          :website,
                          :gradient,
                          :color,
                          label: buttonLabel,
                          :white
                        ) in buttons)
                      Expanded(
                        child: Fader(
                          lineData[label]!.$3,
                          child: AnimatedSlide(
                            duration: halfSec,
                            offset: lineData[label]!.$3 ? Offset.zero : const Offset(0.5, 0),
                            curve: curve,
                            child: _CreditsButton(
                              name: name,
                              website: website,
                              gradient: gradient,
                              color: color,
                              label: buttonLabel,
                              white: white,
                              onPressed: onPressed(
                                context,
                                color ?? gradient!.colors[0],
                                label,
                                website,
                              ),
                            ),
                          ),
                        ),
                      )
                  ],
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
          const Spacer(),
        ],
        Fader(showButton, child: ContinueButton(onPressed: widget.buttonPress)),
        const Spacer(),
      ],
    );
  }
}

String get hueDescription {
  final (int i, int mix) = (superHue! ~/ 30, superHue! % 30);
  final (SuperColor start, SuperColor end) =
      (SuperColors.twelveHues[i], SuperColors.twelveHues[(i + 1) % 12]);
  final String between = 'between ${start.name} and ${end.name}';
  final (String closer, String further) =
      mix > 15 ? (end.name, start.name) : (start.name, end.name);

  return switch (min(mix, 30 - mix)) {
    15 => "That's the exact midpoint $between!",
    > 8 => 'In $between.',
    > 3 => 'Mostly $closer, but a little bit $further.',
    > 0 => "It's $closer, but ever-so-slightly $further.",
    _ => switch (start) {
        // SuperColors.red => '',
        // SuperColors.orange => '',
        // SuperColors.yellow => '',
        SuperColors.chartreuse => "Chartreuse?! I'm beyond impressed.",
        // SuperColors.green => '',
        // SuperColors.spring => '',
        SuperColors.cyan => 'The best hue of them all. Well done, friend.',
        SuperColors.azure => 'Nice work—differentiating azure from blue is a rare skill.',
        // SuperColors.blue => '',
        // SuperColors.violet => '',
        // SuperColors.magenta => '',
        // SuperColors.rose => '',
        _ => 'Exactly ${start.name}. Way to go!',
      },
  };
}

/// Gives a unique message based on your superʜᴜᴇ.
String get hueZodiac => switch (superHue) {
      0 => "You're unique and intelligent. And you like to have fun!",
      1 => "You're unique and intelligent. And you like to have fun!",
      2 => "You're unique and intelligent. And you like to have fun!",
      3 => "You're unique and intelligent. And you like to have fun!",
      4 => "You're unique and intelligent. And you like to have fun!",
      5 => "You're unique and intelligent. And you like to have fun!",
      6 => "You're unique and intelligent. And you like to have fun!",
      7 => "You're unique and intelligent. And you like to have fun!",
      8 => "You're unique and intelligent. And you like to have fun!",
      9 => "You're unique and intelligent. And you like to have fun!",
      10 => "You're unique and intelligent. And you like to have fun!",
      11 => "You're unique and intelligent. And you like to have fun!",
      12 => "You're unique and intelligent. And you like to have fun!",
      13 => "You're unique and intelligent. And you like to have fun!",
      14 => "You're unique and intelligent. And you like to have fun!",
      15 => "You're unique and intelligent. And you like to have fun!",
      16 => "You're unique and intelligent. And you like to have fun!",
      17 => "You're unique and intelligent. And you like to have fun!",
      18 => "You're unique and intelligent. And you like to have fun!",
      19 => "You're unique and intelligent. And you like to have fun!",
      20 => "You're unique and intelligent. And you like to have fun!",
      21 => "You're unique and intelligent. And you like to have fun!",
      22 => "You're unique and intelligent. And you like to have fun!",
      23 => "You're unique and intelligent. And you like to have fun!",
      24 => "You're unique and intelligent. And you like to have fun!",
      25 => "You're unique and intelligent. And you like to have fun!",
      26 => "You're unique and intelligent. And you like to have fun!",
      27 => "You're unique and intelligent. And you like to have fun!",
      28 => "You're unique and intelligent. And you like to have fun!",
      29 => "You're unique and intelligent. And you like to have fun!",
      30 => "You're unique and intelligent. And you like to have fun!",
      31 => "You're unique and intelligent. And you like to have fun!",
      32 => "You're unique and intelligent. And you like to have fun!",
      33 => "You're unique and intelligent. And you like to have fun!",
      34 => "You're unique and intelligent. And you like to have fun!",
      35 => "You're unique and intelligent. And you like to have fun!",
      36 => "You're unique and intelligent. And you like to have fun!",
      37 => "You're unique and intelligent. And you like to have fun!",
      38 => "You're unique and intelligent. And you like to have fun!",
      39 => "You're unique and intelligent. And you like to have fun!",
      40 => "You're unique and intelligent. And you like to have fun!",
      41 => "You're unique and intelligent. And you like to have fun!",
      42 => "You're unique and intelligent. And you like to have fun!",
      43 => "You're unique and intelligent. And you like to have fun!",
      44 => "You're unique and intelligent. And you like to have fun!",
      45 => "You're unique and intelligent. And you like to have fun!",
      46 => "You're unique and intelligent. And you like to have fun!",
      47 => "You're unique and intelligent. And you like to have fun!",
      48 => "You're unique and intelligent. And you like to have fun!",
      49 => "You're unique and intelligent. And you like to have fun!",
      50 => "You're unique and intelligent. And you like to have fun!",
      51 => "You're unique and intelligent. And you like to have fun!",
      52 => "You're unique and intelligent. And you like to have fun!",
      53 => "You're unique and intelligent. And you like to have fun!",
      54 => "You're unique and intelligent. And you like to have fun!",
      55 => "You're unique and intelligent. And you like to have fun!",
      56 => "You're unique and intelligent. And you like to have fun!",
      57 => "You're unique and intelligent. And you like to have fun!",
      58 => "You're unique and intelligent. And you like to have fun!",
      59 => "You're unique and intelligent. And you like to have fun!",
      60 => "You're unique and intelligent. And you like to have fun!",
      61 => "You're unique and intelligent. And you like to have fun!",
      62 => "You're unique and intelligent. And you like to have fun!",
      63 => "You're unique and intelligent. And you like to have fun!",
      64 => "You're unique and intelligent. And you like to have fun!",
      65 => "You're unique and intelligent. And you like to have fun!",
      66 => "You're unique and intelligent. And you like to have fun!",
      67 => "You're unique and intelligent. And you like to have fun!",
      68 => "You're unique and intelligent. And you like to have fun!",
      69 => "You're unique and intelligent. And you like to have fun!",
      70 => "You're unique and intelligent. And you like to have fun!",
      71 => "You're unique and intelligent. And you like to have fun!",
      72 => "You're unique and intelligent. And you like to have fun!",
      73 => "You're unique and intelligent. And you like to have fun!",
      74 => "You're unique and intelligent. And you like to have fun!",
      75 => "You're unique and intelligent. And you like to have fun!",
      76 => "You're unique and intelligent. And you like to have fun!",
      77 => "You're unique and intelligent. And you like to have fun!",
      78 => "You're unique and intelligent. And you like to have fun!",
      79 => "You're unique and intelligent. And you like to have fun!",
      80 => "You're unique and intelligent. And you like to have fun!",
      81 => "You're unique and intelligent. And you like to have fun!",
      82 => "You're unique and intelligent. And you like to have fun!",
      83 => "You're unique and intelligent. And you like to have fun!",
      84 => "You're unique and intelligent. And you like to have fun!",
      85 => "You're unique and intelligent. And you like to have fun!",
      86 => "You're unique and intelligent. And you like to have fun!",
      87 => "You're unique and intelligent. And you like to have fun!",
      88 => "You're unique and intelligent. And you like to have fun!",
      89 => "You're unique and intelligent. And you like to have fun!",
      90 => "You're unique and intelligent. And you like to have fun!",
      91 => "You're unique and intelligent. And you like to have fun!",
      92 => "You're unique and intelligent. And you like to have fun!",
      93 => "You're unique and intelligent. And you like to have fun!",
      94 => "You're unique and intelligent. And you like to have fun!",
      95 => "You're unique and intelligent. And you like to have fun!",
      96 => "You're unique and intelligent. And you like to have fun!",
      97 => "You're unique and intelligent. And you like to have fun!",
      98 => "You're unique and intelligent. And you like to have fun!",
      99 => "You're unique and intelligent. And you like to have fun!",
      100 => "You're unique and intelligent. And you like to have fun!",
      101 => "You're unique and intelligent. And you like to have fun!",
      102 => "You're unique and intelligent. And you like to have fun!",
      103 => "You're unique and intelligent. And you like to have fun!",
      104 => "You're unique and intelligent. And you like to have fun!",
      105 => "You're unique and intelligent. And you like to have fun!",
      106 => "You're unique and intelligent. And you like to have fun!",
      107 => "You're unique and intelligent. And you like to have fun!",
      108 => "You're unique and intelligent. And you like to have fun!",
      109 => "You're unique and intelligent. And you like to have fun!",
      110 => "You're unique and intelligent. And you like to have fun!",
      111 => "You're unique and intelligent. And you like to have fun!",
      112 => "You're unique and intelligent. And you like to have fun!",
      113 => "You're unique and intelligent. And you like to have fun!",
      114 => "You're unique and intelligent. And you like to have fun!",
      115 => "You're unique and intelligent. And you like to have fun!",
      116 => "You're unique and intelligent. And you like to have fun!",
      117 => "You're unique and intelligent. And you like to have fun!",
      118 => "You're unique and intelligent. And you like to have fun!",
      119 => "You're unique and intelligent. And you like to have fun!",
      120 => "You're unique and intelligent. And you like to have fun!",
      121 => "You're unique and intelligent. And you like to have fun!",
      122 => "You're unique and intelligent. And you like to have fun!",
      123 => "You're unique and intelligent. And you like to have fun!",
      124 => "You're unique and intelligent. And you like to have fun!",
      125 => "You're unique and intelligent. And you like to have fun!",
      126 => "You're unique and intelligent. And you like to have fun!",
      127 => "You're unique and intelligent. And you like to have fun!",
      128 => "You're unique and intelligent. And you like to have fun!",
      129 => "You're unique and intelligent. And you like to have fun!",
      130 => "You're unique and intelligent. And you like to have fun!",
      131 => "You're unique and intelligent. And you like to have fun!",
      132 => "You're unique and intelligent. And you like to have fun!",
      133 => "You're unique and intelligent. And you like to have fun!",
      134 => "You're unique and intelligent. And you like to have fun!",
      135 => "You're unique and intelligent. And you like to have fun!",
      136 => "You're unique and intelligent. And you like to have fun!",
      137 => "You're unique and intelligent. And you like to have fun!",
      138 => "You're unique and intelligent. And you like to have fun!",
      139 => "You're unique and intelligent. And you like to have fun!",
      140 => "You're unique and intelligent. And you like to have fun!",
      141 => "You're unique and intelligent. And you like to have fun!",
      142 => "You're unique and intelligent. And you like to have fun!",
      143 => "You're unique and intelligent. And you like to have fun!",
      144 => "You're unique and intelligent. And you like to have fun!",
      145 => "You're unique and intelligent. And you like to have fun!",
      146 => "You're unique and intelligent. And you like to have fun!",
      147 => "You're unique and intelligent. And you like to have fun!",
      148 => "You're unique and intelligent. And you like to have fun!",
      149 => "You're unique and intelligent. And you like to have fun!",
      150 => "You're unique and intelligent. And you like to have fun!",
      151 => "You're unique and intelligent. And you like to have fun!",
      152 => "You're unique and intelligent. And you like to have fun!",
      153 => "You're unique and intelligent. And you like to have fun!",
      154 => "You're unique and intelligent. And you like to have fun!",
      155 => "You're unique and intelligent. And you like to have fun!",
      156 => "You're unique and intelligent. And you like to have fun!",
      157 => "You're unique and intelligent. And you like to have fun!",
      158 => "You're unique and intelligent. And you like to have fun!",
      159 => "You're unique and intelligent. And you like to have fun!",
      160 => "You're unique and intelligent. And you like to have fun!",
      161 => "You're unique and intelligent. And you like to have fun!",
      162 => "You're unique and intelligent. And you like to have fun!",
      163 => "You're unique and intelligent. And you like to have fun!",
      164 => "You're unique and intelligent. And you like to have fun!",
      165 => "You're unique and intelligent. And you like to have fun!",
      166 => "You're unique and intelligent. And you like to have fun!",
      167 => "You're unique and intelligent. And you like to have fun!",
      168 => "You're unique and intelligent. And you like to have fun!",
      169 => "You're unique and intelligent. And you like to have fun!",
      170 => "You're unique and intelligent. And you like to have fun!",
      171 => "You're unique and intelligent. And you like to have fun!",
      172 => "You're unique and intelligent. And you like to have fun!",
      173 => "You're unique and intelligent. And you like to have fun!",
      174 => "You're unique and intelligent. And you like to have fun!",
      175 => "You're unique and intelligent. And you like to have fun!",
      176 => "You're unique and intelligent. And you like to have fun!",
      177 => "You're unique and intelligent. And you like to have fun!",
      178 => "You're unique and intelligent. And you like to have fun!",
      179 => "You're unique and intelligent. And you like to have fun!",
      180 => "You're unique and intelligent. And you like to have fun!",
      181 => "You're unique and intelligent. And you like to have fun!",
      182 => "You're unique and intelligent. And you like to have fun!",
      183 => "You're unique and intelligent. And you like to have fun!",
      184 => "You're unique and intelligent. And you like to have fun!",
      185 => "You're unique and intelligent. And you like to have fun!",
      186 => "You're unique and intelligent. And you like to have fun!",
      187 => "You're unique and intelligent. And you like to have fun!",
      188 => "You're unique and intelligent. And you like to have fun!",
      189 => "You're unique and intelligent. And you like to have fun!",
      190 => "You're unique and intelligent. And you like to have fun!",
      191 => "You're unique and intelligent. And you like to have fun!",
      192 => "You're unique and intelligent. And you like to have fun!",
      193 => "You're unique and intelligent. And you like to have fun!",
      194 => "You're unique and intelligent. And you like to have fun!",
      195 => "You're unique and intelligent. And you like to have fun!",
      196 => "You're unique and intelligent. And you like to have fun!",
      197 => "You're unique and intelligent. And you like to have fun!",
      198 => "You're unique and intelligent. And you like to have fun!",
      199 => "You're unique and intelligent. And you like to have fun!",
      200 => "You're unique and intelligent. And you like to have fun!",
      201 => "You're unique and intelligent. And you like to have fun!",
      202 => "You're unique and intelligent. And you like to have fun!",
      203 => "You're unique and intelligent. And you like to have fun!",
      204 => "You're unique and intelligent. And you like to have fun!",
      205 => "You're unique and intelligent. And you like to have fun!",
      206 => "You're unique and intelligent. And you like to have fun!",
      207 => "You're unique and intelligent. And you like to have fun!",
      208 => "You're unique and intelligent. And you like to have fun!",
      209 => "You're unique and intelligent. And you like to have fun!",
      210 => "You're unique and intelligent. And you like to have fun!",
      211 => "You're unique and intelligent. And you like to have fun!",
      212 => "You're unique and intelligent. And you like to have fun!",
      213 => "You're unique and intelligent. And you like to have fun!",
      214 => "You're unique and intelligent. And you like to have fun!",
      215 => "You're unique and intelligent. And you like to have fun!",
      216 => "You're unique and intelligent. And you like to have fun!",
      217 => "You're unique and intelligent. And you like to have fun!",
      218 => "You're unique and intelligent. And you like to have fun!",
      219 => "You're unique and intelligent. And you like to have fun!",
      220 => "You're unique and intelligent. And you like to have fun!",
      221 => "You're unique and intelligent. And you like to have fun!",
      222 => "You're unique and intelligent. And you like to have fun!",
      223 => "You're unique and intelligent. And you like to have fun!",
      224 => "You're unique and intelligent. And you like to have fun!",
      225 => "You're unique and intelligent. And you like to have fun!",
      226 => "You're unique and intelligent. And you like to have fun!",
      227 => "You're unique and intelligent. And you like to have fun!",
      228 => "You're unique and intelligent. And you like to have fun!",
      229 => "You're unique and intelligent. And you like to have fun!",
      230 => "You're unique and intelligent. And you like to have fun!",
      231 => "You're unique and intelligent. And you like to have fun!",
      232 => "You're unique and intelligent. And you like to have fun!",
      233 => "You're unique and intelligent. And you like to have fun!",
      234 => "You're unique and intelligent. And you like to have fun!",
      235 => "You're unique and intelligent. And you like to have fun!",
      236 => "You're unique and intelligent. And you like to have fun!",
      237 => "You're unique and intelligent. And you like to have fun!",
      238 => "You're unique and intelligent. And you like to have fun!",
      239 => "You're unique and intelligent. And you like to have fun!",
      240 => "You're unique and intelligent. And you like to have fun!",
      241 => "You're unique and intelligent. And you like to have fun!",
      242 => "You're unique and intelligent. And you like to have fun!",
      243 => "You're unique and intelligent. And you like to have fun!",
      244 => "You're unique and intelligent. And you like to have fun!",
      245 => "You're unique and intelligent. And you like to have fun!",
      246 => "You're unique and intelligent. And you like to have fun!",
      247 => "You're unique and intelligent. And you like to have fun!",
      248 => "You're unique and intelligent. And you like to have fun!",
      249 => "You're unique and intelligent. And you like to have fun!",
      250 => "You're unique and intelligent. And you like to have fun!",
      251 => "You're unique and intelligent. And you like to have fun!",
      252 => "You're unique and intelligent. And you like to have fun!",
      253 => "You're unique and intelligent. And you like to have fun!",
      254 => "You're unique and intelligent. And you like to have fun!",
      255 => "You're unique and intelligent. And you like to have fun!",
      256 => "You're unique and intelligent. And you like to have fun!",
      257 => "You're unique and intelligent. And you like to have fun!",
      258 => "You're unique and intelligent. And you like to have fun!",
      259 => "You're unique and intelligent. And you like to have fun!",
      260 => "You're unique and intelligent. And you like to have fun!",
      261 => "You're unique and intelligent. And you like to have fun!",
      262 => "You're unique and intelligent. And you like to have fun!",
      263 => "You're unique and intelligent. And you like to have fun!",
      264 => "You're unique and intelligent. And you like to have fun!",
      265 => "You're unique and intelligent. And you like to have fun!",
      266 => "You're unique and intelligent. And you like to have fun!",
      267 => "You're unique and intelligent. And you like to have fun!",
      268 => "You're unique and intelligent. And you like to have fun!",
      269 => "You're unique and intelligent. And you like to have fun!",
      270 => "You're unique and intelligent. And you like to have fun!",
      271 => "You're unique and intelligent. And you like to have fun!",
      272 => "You're unique and intelligent. And you like to have fun!",
      273 => "You're unique and intelligent. And you like to have fun!",
      274 => "You're unique and intelligent. And you like to have fun!",
      275 => "You're unique and intelligent. And you like to have fun!",
      276 => "You're unique and intelligent. And you like to have fun!",
      277 => "You're unique and intelligent. And you like to have fun!",
      278 => "You're unique and intelligent. And you like to have fun!",
      279 => "You're unique and intelligent. And you like to have fun!",
      280 => "You're unique and intelligent. And you like to have fun!",
      281 => "You're unique and intelligent. And you like to have fun!",
      282 => "You're unique and intelligent. And you like to have fun!",
      283 => "You're unique and intelligent. And you like to have fun!",
      284 => "You're unique and intelligent. And you like to have fun!",
      285 => "You're unique and intelligent. And you like to have fun!",
      286 => "You're unique and intelligent. And you like to have fun!",
      287 => "You're unique and intelligent. And you like to have fun!",
      288 => "You're unique and intelligent. And you like to have fun!",
      289 => "You're unique and intelligent. And you like to have fun!",
      290 => "You're unique and intelligent. And you like to have fun!",
      291 => "You're unique and intelligent. And you like to have fun!",
      292 => "You're unique and intelligent. And you like to have fun!",
      293 => "You're unique and intelligent. And you like to have fun!",
      294 => "You're unique and intelligent. And you like to have fun!",
      295 => "You're unique and intelligent. And you like to have fun!",
      296 => "You're unique and intelligent. And you like to have fun!",
      297 => "You're unique and intelligent. And you like to have fun!",
      298 => "You're unique and intelligent. And you like to have fun!",
      299 => "You're unique and intelligent. And you like to have fun!",
      300 => "You're unique and intelligent. And you like to have fun!",
      301 => "You're unique and intelligent. And you like to have fun!",
      302 => "You're unique and intelligent. And you like to have fun!",
      303 => "You're unique and intelligent. And you like to have fun!",
      304 => "You're unique and intelligent. And you like to have fun!",
      305 => "You're unique and intelligent. And you like to have fun!",
      306 => "You're unique and intelligent. And you like to have fun!",
      307 => "You're unique and intelligent. And you like to have fun!",
      308 => "You're unique and intelligent. And you like to have fun!",
      309 => "You're unique and intelligent. And you like to have fun!",
      310 => "You're unique and intelligent. And you like to have fun!",
      311 => "You're unique and intelligent. And you like to have fun!",
      312 => "You're unique and intelligent. And you like to have fun!",
      313 => "You're unique and intelligent. And you like to have fun!",
      314 => "You're unique and intelligent. And you like to have fun!",
      315 => "You're unique and intelligent. And you like to have fun!",
      316 => "You're unique and intelligent. And you like to have fun!",
      317 => "You're unique and intelligent. And you like to have fun!",
      318 => "You're unique and intelligent. And you like to have fun!",
      319 => "You're unique and intelligent. And you like to have fun!",
      320 => "You're unique and intelligent. And you like to have fun!",
      321 => "You're unique and intelligent. And you like to have fun!",
      322 => "You're unique and intelligent. And you like to have fun!",
      323 => "You're unique and intelligent. And you like to have fun!",
      324 => "You're unique and intelligent. And you like to have fun!",
      325 => "You're unique and intelligent. And you like to have fun!",
      326 => "You're unique and intelligent. And you like to have fun!",
      327 => "You're unique and intelligent. And you like to have fun!",
      328 => "You're unique and intelligent. And you like to have fun!",
      329 => "You're unique and intelligent. And you like to have fun!",
      330 => "You're unique and intelligent. And you like to have fun!",
      331 => "You're unique and intelligent. And you like to have fun!",
      332 => "You're unique and intelligent. And you like to have fun!",
      333 => "You're unique and intelligent. And you like to have fun!",
      334 => "You're unique and intelligent. And you like to have fun!",
      335 => "You're unique and intelligent. And you like to have fun!",
      336 => "You're unique and intelligent. And you like to have fun!",
      337 => "You're unique and intelligent. And you like to have fun!",
      338 => "You're unique and intelligent. And you like to have fun!",
      339 => "You're unique and intelligent. And you like to have fun!",
      340 => "You're unique and intelligent. And you like to have fun!",
      341 => "You're unique and intelligent. And you like to have fun!",
      342 => "You're unique and intelligent. And you like to have fun!",
      343 => "You're unique and intelligent. And you like to have fun!",
      344 => "You're unique and intelligent. And you like to have fun!",
      345 => "You're unique and intelligent. And you like to have fun!",
      346 => "You're unique and intelligent. And you like to have fun!",
      347 => "You're unique and intelligent. And you like to have fun!",
      348 => "You're unique and intelligent. And you like to have fun!",
      349 => "You're unique and intelligent. And you like to have fun!",
      350 => "You're unique and intelligent. And you like to have fun!",
      351 => "You're unique and intelligent. And you like to have fun!",
      352 => "You're unique and intelligent. And you like to have fun!",
      353 => "You're unique and intelligent. And you like to have fun!",
      354 => "You're unique and intelligent. And you like to have fun!",
      355 => "You're unique and intelligent. And you like to have fun!",
      356 => "You're unique and intelligent. And you like to have fun!",
      357 => "You're unique and intelligent. And you like to have fun!",
      358 => "You're unique and intelligent. And you like to have fun!",
      359 => "You're unique and intelligent. And you like to have fun!",
      _ => "You're unique and intelligent. And you like to have fun!",
    };

class _TheEnd extends StatefulWidget {
  const _TheEnd();

  @override
  State<_TheEnd> createState() => _TheEndState();
}

class _TheEndState extends EpicState<_TheEnd> with SinglePress {
  bool seeYa = false, showQuit = false;

  @override
  void animate() async {
    await sleepState(3, () => seeYa = true);
    await sleepState(3, () => showQuit = true);
  }

  @override
  Widget build(BuildContext context) {
    final color = epicColor;
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const Spacer(flex: 4),
            FadeIn(
              child: SuperContainer(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                width: 250,
                height: 100,
                alignment: Alignment.center,
                child: const Text(
                  'The End',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const Spacer(),
            Fader(
              seeYa,
              child: EasyRichText([
                const TextSpan(text: 'see '),
                TextSpan(
                  text: 'ʜᴜᴇ',
                  style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 25),
                ),
                const TextSpan(text: ' later  :)'),
              ]),
            ),
            const Spacer(),
            Fader(
              showQuit,
              child: TextButton(
                style: TextButton.styleFrom(backgroundColor: Colors.white10),
                onPressed: singlePress(() => exit(0)),
                child: const Text(
                  'quit',
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}
