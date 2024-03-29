import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hueman/data/save_data.dart';
import 'package:hueman/data/structs.dart';
import 'package:hueman/data/super_color.dart';
import 'package:hueman/data/super_container.dart';
import 'package:hueman/data/super_state.dart';
import 'package:hueman/data/super_text.dart';
import 'package:hueman/data/widgets.dart';

int get superHue => Score.superHue.value!;

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
  final superColor = SuperColor.hue(superHue);
  Widget text = const SuperText('Thanks for playing!');

  @override
  void animate() => sleepState(4, () => showCredits = true);

  void next() async {
    final double size = min(20, context.screenWidth / 24);

    Future<void> textCycle(double timeToRead, String str) async {
      await sleepState(1, () {
        showText = true;
        text = SuperText(str, style: SuperStyle.sans(size: size));
      });
      await sleepState(timeToRead, () => showText = false);
    }

    setState(() {
      showText = false;
      showCredits = false;
      colorChange = true;
    });
    if (!enableMusic) {
      await sleepState(1.5, () {
        text = _MusicSwitch(next);
        showText = true;
      });
      return;
    }
    await sleepState(3, () => showSuperHue = true);
    await sleepState(0.1, () => hideSuperHue = false);
    await sleep(1);
    sfx.play('game_end'); // using playSound so it doesn't auto-pause when not focused
    await textCycle(4 + androidLatency, 'Remember this?');
    await textCycle(4, 'This was the first time you chose correctly\nout of 360 options.');
    await sleepState(1, () {
      text = SuperRichText([
        const TextSpan(text: 'Your super'),
        TextSpan(
          text: 'HUE',
          style: SuperStyle.sans(color: superColor, weight: 800, size: size * .75),
        ),
        const TextSpan(text: '.'),
      ], style: SuperStyle.sans(size: size));
      showText = true;
      showHueVal = true;
    });
    await sleepState(4, () => showText = false);
    await sleepState(1, () {
      text = SuperRichText([
        TextSpan(text: '$superHue degree${superHue == 1 ? '' : 's'}. '),
        ...hueDescription,
      ], style: SuperStyle.sans(size: size));
      showText = true;
    });
    await sleepState(7, () => showText = false);
    await sleepState(1, () {
      text = SuperRichText(
        [
          const TextSpan(text: 'Fun fact: your super'),
          TextSpan(
            text: 'HUE',
            style: SuperStyle.sans(color: superColor, weight: 800, size: size * .75),
          ),
          const TextSpan(text: ' actually says a lot about you,\njust like a zodiac sign.'),
        ],
        style: SuperStyle.sans(size: size),
      );
      showText = true;
    });
    await sleepState(5.5, () => showText = false);
    await textCycle(4, 'Wanna know what your hue says?');
    await textCycle(5.5, '$superHue°:\n\n$hueZodiac');
    setState(() => hideSuperHue = true);
    await sleepState(1, () {
      text = SuperText(
        'This game is 100% free & open-source software.',
        style: SuperStyle.sans(size: size),
      );
      showText = true;
      showSuperHue = false;
    });
    await sleepState(5, () => showText = false);
    await sleepState(1, () {
      text = SuperText(
        "If you want to show support,\nhere's what you can do:",
        style: SuperStyle.sans(size: size),
      );
      showText = true;
    });
    await sleepState(4, () {
      text = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          text,
          const FixedSpacer(20),
          _HowToSupport(SuperStyle.sans(size: size)),
        ],
      );
      showText = true;
    });
    await sleep(14);
    context.noTransition(const _TheEnd());
  }

  @override
  Widget build(BuildContext context) {
    final height = context.screenHeight;
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        fontFamily: 'nunito sans',
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
                              style: const SuperStyle.sans(
                                color: Colors.black,
                                size: 100,
                                weight: 800,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
              ],
              const Spacer(),
              if (!showCredits) Expanded(flex: 3, child: Fader(showText, child: text)),
              AnimatedContainer(
                duration: oneSec,
                curve: Curves.easeInOutQuart,
                height: showCredits ? height : 0,
                color: const SuperColor(0xDEE3E8),
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: SizedBox(
                    height: height,
                    child: SafeArea(child: _Credits(next)),
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
  'game & music': [
    _CreditsButton(
      name: 'nate-thegrate',
      label: 'github',
      website: 'https://github.com/nate-thegrate/hueman',
      color: SuperColor(0x80FFF8),
    ),
  ],
  'animations': [
    _CreditsButton(
      name: ' Flutter',
      gradient: LinearGradient(
        colors: [
          SuperColor(0x54CCFF),
          SuperColor(0x004080),
          SuperColor(0x0060C0),
          SuperColor(0x0060C0),
        ],
        stops: [0.37, 0.375, 0.45, 1],
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
      website:
          'https://commons.wikimedia.org/w/index.php?title=Special:MediaSearch&type=image&haslicense=unrestricted',
      color: SuperColor(0xFCFAF7),
    ),
  ],
  'inspiration': [
    _CreditsButton(
      name: ' Echo Gillette',
      label: 'youtube',
      gradient: LinearGradient(
        colors: [SuperColors.red, SuperColors.black],
        stops: [0.325, 0.33],
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
              const FixedSpacer.horizontal(16),
              SuperContainer(
                width: 32,
                alignment: Alignment.center,
                child: Image.asset('assets/end_credits_icons/$logo.png'),
              ),
              SizedBox(
                width: 125,
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  style: SuperStyle.sans(
                    size: 16,
                    height: 0,
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
      if (sleeping) sleep(2);
      setState(() => lineData[label] = (Colors.black54, Offset.zero, true));
    }
  }

  @override
  void animate() async {
    sleep(5);
    await resetLines(sleeping: true);
    await sleepState(2, () => showButton = true);
  }

  VoidCallback onPressed(BuildContext context, Color color, String label, String website) =>
      () async {
        resetLines();
        setState(() => lineData[label] = (color, const Offset(-0.5, 0), true));
        await sleepState(0.2, () => lineData[label] = (color, Offset.zero, true));
        sleep(0.4);
        if (website == verifyAge) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/end_credits_icons/youtube_red.png', width: 48),
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("Echo's video", style: SuperStyle.sans()),
                  ),
                ],
              ),
              content: const Text(
                'This YouTube video has a little bit of adult language.\n\n'
                "Please only watch if you have an adult's permission.\n",
                style: SuperStyle.sans(),
              ),
              actionsAlignment: MainAxisAlignment.spaceEvenly,
              actions: [
                const WarnButton(),
                WarnButton(action: () => gotoWebsite('https://youtu.be/NVhA18_dmg0')),
              ],
            ),
          );
        } else {
          gotoWebsite(website);
        }
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        const Text(
          'Credits',
          style: SuperStyle.sans(
            size: 32,
            extraBold: true,
            color: Colors.black,
            height: 1,
            letterSpacing: 0.5,
          ),
        ),
        const SuperText(
          '(tap a button to go check it out!)',
          style: SuperStyle.sans(size: 12, width: 87.5, color: Colors.black),
        ),
        const Spacer(),
        for (final MapEntry(key: label, value: buttons) in _credits.entries) ...[
          SuperContainer(
            height: buttons.length * 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Fader(
                  lineData[label]!.$3,
                  child: SizedBox(
                    child: SuperContainer(
                      width: 100,
                      margin: const EdgeInsets.only(right: 14),
                      alignment: Alignment.centerRight,
                      child: Text(
                        label,
                        textAlign: TextAlign.right,
                        style: const SuperStyle.sans(
                          size: 16,
                          width: 75,
                          weight: 500,
                          color: Colors.black54,
                          extraBold: true,
                        ),
                      ),
                    ),
                  ),
                ),
                AnimatedSlide(
                  duration: halfSec,
                  curve: Curves.easeOutCubic,
                  offset: lineData[label]!.$2,
                  child: AnimatedContainer(
                    duration: Durations.short2,
                    width: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: lineData[label]!.$1,
                      borderRadius: BorderRadius.circular(0xFF),
                    ),
                    child: SexyBox(child: lineData[label]!.$3 ? const SizedBox.expand() : flat),
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
                      ),
                  ],
                ),
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

List<TextSpan> get hueDescription {
  final bool extraHues = Tutorial.mastered();

  final degreeSpan = extraHues ? 15 : 30;
  final (int i, int mix) = (superHue ~/ degreeSpan, superHue % degreeSpan);
  final (SuperColor start, SuperColor end) =
      (SuperColors.hueList[i], SuperColors.hueList[(i + 1) % (extraHues ? 24 : 12)]);
  final List<TextSpan> between = [
    const TextSpan(text: 'between '),
    ColorTextSpan(start),
    const TextSpan(text: ' and '),
    ColorTextSpan(end),
  ];
  final (SuperColor closer, SuperColor further) =
      mix > (degreeSpan / 2) ? (end, start) : (start, end);
  if (extraHues) {
    return switch (min(mix, 15 - mix)) {
      > 5 => [
          const TextSpan(text: 'In '),
          ...between,
          const TextSpan(text: '.'),
        ],
      > 2 => [
          const TextSpan(text: 'Mostly '),
          ColorTextSpan(closer),
          const TextSpan(text: ', but a little bit '),
          ColorTextSpan(further),
          const TextSpan(text: '.'),
        ],
      > 0 => [
          const TextSpan(text: "It's "),
          ColorTextSpan(closer),
          const TextSpan(text: ', but ever-so-slightly '),
          ColorTextSpan(further),
          const TextSpan(text: '.'),
        ],
      _ => switch (start) {
          // SuperColors.red => [],
          // SuperColors.orange => [],
          // SuperColors.yellow => [],
          SuperColors.chartreuse => const [TextSpan(text: "Chartreuse?! I'm beyond impressed.")],
          // SuperColors.green => [],
          // SuperColors.spring => [],
          SuperColors.cyan => const [
              TextSpan(text: 'The best hue of them all. Well done, friend.')
            ],
          SuperColors.azure => const [
              TextSpan(text: 'Nice work—differentiating '),
              ColorTextSpan.azure,
              TextSpan(text: ' from '),
              ColorTextSpan.blue,
              TextSpan(text: ' is a rare skill.'),
            ],
          // SuperColors.blue => [],
          // SuperColors.violet => [],
          // SuperColors.magenta => [],
          // SuperColors.rose => [],
          _ => [
              const TextSpan(text: 'Exactly '),
              ColorTextSpan(start),
              const TextSpan(text: '. Way to go!'),
            ],
        }
    };
  }
  return switch (min(mix, 30 - mix)) {
    15 => [
        const TextSpan(text: "That's the exact midpoint "),
        ...between,
        const TextSpan(text: '!'),
      ],
    > 8 => [
        const TextSpan(text: 'In '),
        ...between,
        const TextSpan(text: '.'),
      ],
    > 3 => [
        const TextSpan(text: 'Mostly '),
        ColorTextSpan(closer),
        const TextSpan(text: ', but a little bit '),
        ColorTextSpan(further),
        const TextSpan(text: '.'),
      ],
    > 0 => [
        const TextSpan(text: "It's "),
        ColorTextSpan(closer),
        const TextSpan(text: ', but ever-so-slightly '),
        ColorTextSpan(further),
        const TextSpan(text: '.'),
      ],
    _ => switch (start) {
        // SuperColors.red => [],
        // SuperColors.orange => [],
        // SuperColors.yellow => [],
        SuperColors.chartreuse => const [TextSpan(text: "Chartreuse?! I'm beyond impressed.")],
        // SuperColors.green => [],
        // SuperColors.spring => [],
        SuperColors.cyan => const [
            TextSpan(text: 'The best hue of them all. Well done, friend.')
          ],
        SuperColors.azure => const [
            TextSpan(text: 'Nice work—differentiating '),
            ColorTextSpan.azure,
            TextSpan(text: ' from '),
            ColorTextSpan.blue,
            TextSpan(text: ' is a rare skill.'),
          ],
        // SuperColors.blue => [],
        // SuperColors.violet => [],
        // SuperColors.magenta => [],
        // SuperColors.rose => [],
        _ => [
            const TextSpan(text: 'Exactly '),
            ColorTextSpan(start),
            const TextSpan(text: '. Way to go!'),
          ],
      },
  };
}

/// Gives a unique message based on your superʜᴜᴇ.
String get hueZodiac => switch (superHue) {
      000 => "You're unique and intelligent. And you like to have fun!",
      001 => "You're unique and intelligent. And you like to have fun!",
      002 => "You're unique and intelligent. And you like to have fun!",
      003 => "You're unique and intelligent. And you like to have fun!",
      004 => "You're unique and intelligent. And you like to have fun!",
      005 => "You're unique and intelligent. And you like to have fun!",
      006 => "You're unique and intelligent. And you like to have fun!",
      007 => "You're unique and intelligent. And you like to have fun!",
      008 => "You're unique and intelligent. And you like to have fun!",
      009 => "You're unique and intelligent. And you like to have fun!",
      010 => "You're unique and intelligent. And you like to have fun!",
      011 => "You're unique and intelligent. And you like to have fun!",
      012 => "You're unique and intelligent. And you like to have fun!",
      013 => "You're unique and intelligent. And you like to have fun!",
      014 => "You're unique and intelligent. And you like to have fun!",
      015 => "You're unique and intelligent. And you like to have fun!",
      016 => "You're unique and intelligent. And you like to have fun!",
      017 => "You're unique and intelligent. And you like to have fun!",
      018 => "You're unique and intelligent. And you like to have fun!",
      019 => "You're unique and intelligent. And you like to have fun!",
      020 => "You're unique and intelligent. And you like to have fun!",
      021 => "You're unique and intelligent. And you like to have fun!",
      022 => "You're unique and intelligent. And you like to have fun!",
      023 => "You're unique and intelligent. And you like to have fun!",
      024 => "You're unique and intelligent. And you like to have fun!",
      025 => "You're unique and intelligent. And you like to have fun!",
      026 => "You're unique and intelligent. And you like to have fun!",
      027 => "You're unique and intelligent. And you like to have fun!",
      028 => "You're unique and intelligent. And you like to have fun!",
      029 => "You're unique and intelligent. And you like to have fun!",
      030 => "You're unique and intelligent. And you like to have fun!",
      031 => "You're unique and intelligent. And you like to have fun!",
      032 => "You're unique and intelligent. And you like to have fun!",
      033 => "You're unique and intelligent. And you like to have fun!",
      034 => "You're unique and intelligent. And you like to have fun!",
      035 => "You're unique and intelligent. And you like to have fun!",
      036 => "You're unique and intelligent. And you like to have fun!",
      037 => "You're unique and intelligent. And you like to have fun!",
      038 => "You're unique and intelligent. And you like to have fun!",
      039 => "You're unique and intelligent. And you like to have fun!",
      040 => "You're unique and intelligent. And you like to have fun!",
      041 => "You're unique and intelligent. And you like to have fun!",
      042 => "You're unique and intelligent. And you like to have fun!",
      043 => "You're unique and intelligent. And you like to have fun!",
      044 => "You're unique and intelligent. And you like to have fun!",
      045 => "You're unique and intelligent. And you like to have fun!",
      046 => "You're unique and intelligent. And you like to have fun!",
      047 => "You're unique and intelligent. And you like to have fun!",
      048 => "You're unique and intelligent. And you like to have fun!",
      049 => "You're unique and intelligent. And you like to have fun!",
      050 => "You're unique and intelligent. And you like to have fun!",
      051 => "You're unique and intelligent. And you like to have fun!",
      052 => "You're unique and intelligent. And you like to have fun!",
      053 => "You're unique and intelligent. And you like to have fun!",
      054 => "You're unique and intelligent. And you like to have fun!",
      055 => "You're unique and intelligent. And you like to have fun!",
      056 => "You're unique and intelligent. And you like to have fun!",
      057 => "You're unique and intelligent. And you like to have fun!",
      058 => "You're unique and intelligent. And you like to have fun!",
      059 => "You're unique and intelligent. And you like to have fun!",
      060 => "You're unique and intelligent. And you like to have fun!",
      061 => "You're unique and intelligent. And you like to have fun!",
      062 => "You're unique and intelligent. And you like to have fun!",
      063 => "You're unique and intelligent. And you like to have fun!",
      064 => "You're unique and intelligent. And you like to have fun!",
      065 => "You're unique and intelligent. And you like to have fun!",
      066 => "You're unique and intelligent. And you like to have fun!",
      067 => "You're unique and intelligent. And you like to have fun!",
      068 => "You're unique and intelligent. And you like to have fun!",
      069 => "You're unique and intelligent. And you like to have fun!",
      070 => "You're unique and intelligent. And you like to have fun!",
      071 => "You're unique and intelligent. And you like to have fun!",
      072 => "You're unique and intelligent. And you like to have fun!",
      073 => "You're unique and intelligent. And you like to have fun!",
      074 => "You're unique and intelligent. And you like to have fun!",
      075 => "You're unique and intelligent. And you like to have fun!",
      076 => "You're unique and intelligent. And you like to have fun!",
      077 => "You're unique and intelligent. And you like to have fun!",
      078 => "You're unique and intelligent. And you like to have fun!",
      079 => "You're unique and intelligent. And you like to have fun!",
      080 => "You're unique and intelligent. And you like to have fun!",
      081 => "You're unique and intelligent. And you like to have fun!",
      082 => "You're unique and intelligent. And you like to have fun!",
      083 => "You're unique and intelligent. And you like to have fun!",
      084 => "You're unique and intelligent. And you like to have fun!",
      085 => "You're unique and intelligent. And you like to have fun!",
      086 => "You're unique and intelligent. And you like to have fun!",
      087 => "You're unique and intelligent. And you like to have fun!",
      088 => "You're unique and intelligent. And you like to have fun!",
      089 => "You're unique and intelligent. And you like to have fun!",
      090 => "You're unique and intelligent. And you like to have fun!",
      091 => "You're unique and intelligent. And you like to have fun!",
      092 => "You're unique and intelligent. And you like to have fun!",
      093 => "You're unique and intelligent. And you like to have fun!",
      094 => "You're unique and intelligent. And you like to have fun!",
      095 => "You're unique and intelligent. And you like to have fun!",
      096 => "You're unique and intelligent. And you like to have fun!",
      097 => "You're unique and intelligent. And you like to have fun!",
      098 => "You're unique and intelligent. And you like to have fun!",
      099 => "You're unique and intelligent. And you like to have fun!",
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

class _MusicSwitch extends StatefulWidget {
  const _MusicSwitch(this.onPressed);
  final VoidCallback onPressed;

  @override
  State<_MusicSwitch> createState() => _MusicSwitchState();
}

class _MusicSwitchState extends SuperState<_MusicSwitch> {
  /// doesn't save, so music will be off on next boot
  void musicOn() => enableMusic = true;

  @override
  void animate() => sleepState(2, musicOn);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SuperText("Let's turn the music on!"),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 25),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.headphones_outlined, size: 50),
              const FixedSpacer.horizontal(10),
              Switch.adaptive(value: enableMusic, onChanged: (_) => setState(musicOn)),
            ],
          ),
        ),
        if (enableMusic) FadeIn(child: ContinueButton(onPressed: widget.onPressed)),
      ],
    );
  }
}

class _HowToSupport extends StatefulWidget {
  const _HowToSupport(this.style);
  final SuperStyle style;

  @override
  State<_HowToSupport> createState() => _HowToSupportState();
}

class _HowToSupportState extends EpicState<_HowToSupport> {
  static const text = 'Just randomly bring up color theory\n'
      'in your next conversation with your friends!';

  int visibleLetters = 0;
  @override
  void animate() async {
    for (int i = 0; i < text.length; i++) {
      await sleepState(0.08, () => visibleLetters++);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SuperRichText([
      for (final (i, letter) in text.characters.indexed)
        TextSpan(
          text: letter,
          style: TextStyle(
            color: visibleLetters > i ? epicColor : Colors.transparent,
            shadows: visibleLetters > i
                ? const [
                    Shadow(blurRadius: 1),
                    Shadow(blurRadius: 2),
                    Shadow(blurRadius: 2),
                  ]
                : null,
          ),
        ),
    ], style: widget.style);
  }
}

class _TheEnd extends StatefulWidget {
  const _TheEnd();

  @override
  State<_TheEnd> createState() => _TheEndState();
}

class _TheEndState extends EpicState<_TheEnd> with SinglePress {
  bool showQuit = false;

  @override
  void animate() async {
    await Tutorial.gameEnd.complete();
    await sleepState(3, () => showQuit = true);
  }

  @override
  Widget build(BuildContext context) {
    final color = epicColor;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const Spacer(flex: 4),
              SuperContainer(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                width: 250,
                height: 100,
                alignment: Alignment.center,
                child: const Text(
                  'The End',
                  style: SuperStyle.sans(
                    color: Colors.black,
                    size: 50,
                    weight: 800,
                  ),
                ),
              ),
              const Spacer(),
              SuperRichText([
                const TextSpan(text: 'see '),
                TextSpan(
                  text: 'HUE',
                  style: SuperStyle.sans(color: color, weight: 800, size: 15),
                ),
                const TextSpan(text: ' later  :)'),
              ]),
              const Spacer(),
              Fader(
                showQuit,
                child: switch (Theme.of(context).platform) {
                  TargetPlatform.android => OutlinedButton(
                      onPressed: () => gotoWebsite(
                        'https://play.google.com/store/apps/details?id=com.natethegrate.hueman',
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: color, width: 2),
                        foregroundColor: color,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(5, 10, 5, 12),
                        child: Text(
                          'rate on the Play Store',
                          style: SuperStyle.sans(
                            size: 18,
                            width: 96,
                            letterSpacing: 1 / 3,
                            extraBold: true,
                          ),
                        ),
                      ),
                    ),
                  TargetPlatform.iOS || TargetPlatform.macOS => OutlinedButton(
                      onPressed: () => gotoWebsite(
                        'https://apps.apple.com/us/app/hueman-a-game-about-colors/id6471395924',
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: color, width: 2),
                        foregroundColor: color,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(5, 10, 5, 12),
                        child: Text(
                          'rate on the App Store',
                          style: SuperStyle.sans(
                            size: 18,
                            width: 96,
                            letterSpacing: 1 / 3,
                            extraBold: true,
                          ),
                        ),
                      ),
                    ),
                  TargetPlatform.windows => OutlinedButton(
                      onPressed: () => gotoWebsite(
                        'https://www.microsoft.com/store/productId/9NNNTH9JV380',
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: color, width: 2),
                        foregroundColor: color,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(5, 10, 5, 12),
                        child: Text(
                          'rate on the Windows Store',
                          style: SuperStyle.sans(
                            size: 18,
                            width: 96,
                            letterSpacing: 1 / 3,
                            extraBold: true,
                          ),
                        ),
                      ),
                    ),
                  _ => empty,
                },
              ),
              const Spacer(),
              Fader(
                showQuit,
                child: SizedBox(
                  height: 33,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white10,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                    ),
                    onPressed: singlePress(() => exit(0)),
                    child: const Padding(
                      padding: EdgeInsets.only(bottom: 2),
                      child: Text(
                        'quit',
                        style: SuperStyle.sans(
                          weight: 300,
                          size: 16,
                          color: Colors.white70,
                          height: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
