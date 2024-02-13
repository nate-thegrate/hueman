import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hueman/data/page_data.dart';
import 'package:hueman/data/save_data.dart';
import 'package:hueman/data/structs.dart';
import 'package:hueman/data/super_color.dart';
import 'package:hueman/data/super_container.dart';
import 'package:hueman/data/super_state.dart';
import 'package:hueman/data/super_text.dart';
import 'package:hueman/data/widgets.dart';

class SandboxTutorial extends StatefulWidget {
  const SandboxTutorial({super.key});

  @override
  State<SandboxTutorial> createState() => _SandboxTutorialState();
}

class _SandboxTutorialState extends SuperState<SandboxTutorial> {
  bool visible = false;
  late final pages = [
    _Page1(nextPage),
    _Page2(nextPage),
    _Page3(nextPage),
    _Page4(nextPage),
    _Page5(nextPage),
    const _FinalPage(),
  ];
  int page = 1;

  Duration duration = oneSec;

  void nextPage() {
    setState(() {
      duration = halfSec;
      visible = false;
    });
    sleepState(1, () {
      page++;
      visible = true;
      duration = oneSec;
    });
  }

  @override
  void animate() {
    musicPlayer.stop();
    sleepState(1, () => visible = true);
  }

  @override
  Widget build(BuildContext context) {
    final screen = Scaffold(
      body: SafeArea(
        child: Center(
          child: Fader(
            visible,
            duration: duration,
            child: pages[page - 1],
          ),
        ),
      ),
      backgroundColor: inverted ? SuperColors.lightBackground : null,
    );
    if (!inverted) return screen;
    return Theme(
      data: ThemeData(useMaterial3: true, fontFamily: 'nunito sans'),
      child: screen,
    );
  }
}

class _Page1 extends StatefulWidget {
  const _Page1(this.nextPage);
  final void Function() nextPage;

  @override
  State<_Page1> createState() => _Page1State();
}

class _Page1State extends SuperState<_Page1> {
  bool visible = false;

  @override
  void animate() => sleepState(5, () => visible = true);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 3),
        SuperRichText([
          const TextSpan(text: 'Each pixel on this screen has 256 different levels for '),
          ColorTextSpan.red,
          const TextSpan(text: ', '),
          ColorTextSpan.green,
          const TextSpan(text: ', and '),
          ColorTextSpan.flexibleBlue,
          const TextSpan(text: '.'),
        ]),
        const Spacer(),
        Fader(visible, child: const SuperText('But why 256?')),
        const Spacer(flex: 2),
        Fader(visible, child: ContinueButton(onPressed: widget.nextPage)),
        const Spacer(),
      ],
    );
  }
}

class _Page2 extends StatefulWidget {
  const _Page2(this.nextPage);
  final void Function() nextPage;

  @override
  State<_Page2> createState() => _Page2State();
}

class _Page2State extends SuperState<_Page2> {
  int progress = 0;

  @override
  void animate() async {
    for (final i in <double>[3, 3, 2, 2, 1.5, 1]) {
      await sleepState(i, () => progress++);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 2),
        const SuperText("It's time for some computer science! 🤓"),
        const Spacer(),
        SizedBox(
          height: 60,
          child: switch (progress) {
            0 => empty,
            1 => const _NumberRow(ObjectKey(10)),
            _ => const _NumberRow(ObjectKey(2)),
          },
        ),
        SizedBox(height: 25, child: progress > 2 ? _BinaryCaption(progress) : empty),
        const Spacer(),
        Fader(progress > 0, child: const SuperText('We usually count using base ten.')),
        Fader(progress > 1, child: const SuperText('But computers use binary.')),
        const Spacer(flex: 2),
        Fader(progress > 5, child: ContinueButton(onPressed: widget.nextPage)),
        const Spacer(),
      ],
    );
  }
}

class _BinaryCaption extends StatelessWidget {
  const _BinaryCaption(this.progress);
  final int progress;

  @override
  Widget build(BuildContext context) {
    final quote = SexyBox(child: progress > 3 ? const FadeIn(child: Text('"')) : empty);
    return FadeIn(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          quote,
          const Text('bi'),
          SexyBox(child: progress > 3 ? empty : const Text('nary digi')),
          const Text('ts'),
          quote,
          AnimatedSize(
            duration: halfSec,
            curve: Curves.easeOutCubic,
            child: progress > 4 ? const FadeIn(child: Text(' for short!')) : empty,
          ),
        ],
      ),
    );
  }
}

class _NumberRow extends StatefulWidget {
  const _NumberRow(this.base) : super(key: base);
  final ObjectKey base;

  @override
  State<_NumberRow> createState() => _NumberRowState();
}

class _NumberRowState extends SuperState<_NumberRow> {
  int get base => widget.base.value as int;
  int visibleNumbers = 0;

  @override
  void animate() async {
    final max = base;
    final seconds = 1.5 / max;
    for (int i = 0; i < max; i++) {
      await sleepState(seconds, () => visibleNumbers++);
    }
  }

  @override
  Widget build(BuildContext context) {
    const duration = Duration(milliseconds: 150);
    final binary = base == 2;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < base; i++)
          Fader(
            i < visibleNumbers,
            duration: duration,
            child: AnimatedSlide(
              offset: i < visibleNumbers ? Offset.zero : const Offset(0, -1),
              duration: duration,
              curve: Curves.easeInQuad,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  '$i',
                  style:
                      binary ? const SuperStyle.mono(size: 40) : const SuperStyle.sans(size: 30),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Page3 extends StatefulWidget {
  const _Page3(this.nextPage);
  final void Function() nextPage;

  @override
  State<_Page3> createState() => _Page3State();
}

class _Page3State extends SuperState<_Page3> {
  bool funDontStop = false,
      byteDesc = false,
      nibbleDesc = false,
      showCounter = false,
      nibbleStorage = false,
      showButton = false;
  int counter = 0;
  @override
  void animate() async {
    await sleepState(2.5, () => funDontStop = true);
    await sleepState(2.5, () => byteDesc = true);
    await sleepState(1.7, () => nibbleDesc = true);
    await sleepState(2.5, () => showCounter = true);

    await sleepState(2, () => nibbleStorage = true);

    const delay = 0.6;

    while (counter < 16) {
      await sleepState(delay, () => counter++);
    }
    while (counter < 255) {
      await sleepState(delay / 32, () => counter++);
    }

    setState(() => showButton = true);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 5),
        const SuperText('"bits" is a really fun name.'),
        const Spacer(),
        Fader(funDontStop, child: const SuperText("And the fun doesn't stop there:")),
        const Spacer(),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Opacity(opacity: 0, child: SuperText('and ', pad: false)),
                Fader(byteDesc, child: const SuperText('8 bits is called a "byte"', pad: false)),
              ],
            ),
            Fader(nibbleDesc,
                child: const SuperText('and 4 bits is called a "nibble" :)', pad: false)),
          ],
        ),
        const Spacer(),
        Fader(
          nibbleStorage,
          child: const SuperText('A nibble can store 16 different values, 0 to 15.'),
        ),
        Fader(counter >= 15, child: const SuperText('And a byte can store 256 values!')),
        const Spacer(),
        SexyBox(
          child: showCounter
              ? SuperContainer(
                  decoration: BoxDecoration(
                    color: inverted ? Colors.white : Colors.black38,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  width: 300,
                  height: 100,
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: const Alignment(0.75, 0),
                          child: Text(
                            counter.toString(),
                            style: const SuperStyle.mono(size: 24),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Text(
                            counter
                                .toRadixString(2)
                                .padLeft(counter > 15 ? 8 : 4, '0')
                                .padLeft(8),
                            style: const SuperStyle.mono(size: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : empty,
        ),
        const Spacer(flex: 5),
        Fader(showButton, child: ContinueButton(onPressed: widget.nextPage)),
        const Spacer(flex: 3),
      ],
    );
  }
}

class _Page4 extends StatefulWidget {
  const _Page4(this.nextPage);
  final void Function() nextPage;

  @override
  State<_Page4> createState() => _Page4State();
}

class _Page4State extends SuperState<_Page4> {
  bool visible = true,
      showBTS = false,
      showBinary = false,
      showButton = false,
      consolidating = false,
      kindaHard = false,
      collapsed = true,
      heckaSmart = false;

  @override
  void animate() async {
    await sleepState(1, () => collapsed = false);
    await sleepState(5, () => showBTS = true);
    await sleepState(2, () => showBinary = true);
    await sleepState(1, () => showButton = true);
  }

  void consolidate() async {
    setState(() => showButton = false);
    await sleepState(0.75, () {
      consolidating = true;
      showBinary = false;
    });
    await sleepState(4, () => showBinary = true);
    await sleepState(6, () {
      kindaHard = true;
      showButton = true;
    });
  }

  void leave() async {
    setState(() {
      showButton = false;
      kindaHard = false;
      showBTS = false;
      collapsed = true;
    });
    await sleep(1, then: widget.nextPage);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 5),
        Fader(
          visible,
          child: _ColorCard(collapsed, consolidating, showBTS, showBinary),
        ),
        const Spacer(),
        Fader(kindaHard, child: const SuperText("that's kinda hard to understand though.")),
        const Spacer(flex: 2),
        Fader(showButton,
            child: consolidating
                ? ContinueButton(key: const Key('1'), onPressed: leave)
                : ContinueButton(key: const Key('2'), onPressed: consolidate)),
        const Spacer(flex: 2),
      ],
    );
  }
}

/// I admit this class is not well-organized, but if it works, it works
class _ColorCard extends StatefulWidget {
  const _ColorCard(this.collapsed, this.consolidating, this.showBTS, this.showBinary)
      : showHex = null,
        haveFun = false;
  const _ColorCard.hex(this.showHex, this.showBTS, this.consolidating, this.collapsed)
      : showBinary = true,
        haveFun = true;
  final bool collapsed, consolidating, showBTS, showBinary, haveFun;
  final bool? showHex;

  @override
  State<_ColorCard> createState() => _ColorCardState();
}

class _ColorCardState extends DynamicState<_ColorCard> {
  @override
  Widget build(BuildContext context) {
    final color = inverted ? inverseColor : epicColor;
    return Card(
      color: color,
      elevation: (sin(color.hue / 60 * 2 * pi) + 1) * 6,
      shadowColor: color,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SexyBox(
            child: widget.collapsed || widget.consolidating
                ? const SizedBox(width: 25, height: 25)
                : Padding(
                    padding: const EdgeInsets.all(25),
                    child: FadeIn(
                      child: Text(
                        widget.haveFun
                            ? 'Have fun in Sandbox mode!'
                            : 'when you see\nstuff like this,',
                        textAlign: TextAlign.center,
                        style: SuperStyle.sans(
                          color: inverted ? Colors.white : Colors.black,
                          size: 24,
                          extraBold: true,
                          width: 96,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
          ),
          SexyBox(
            child: widget.showBTS
                ? _BTS(
                    color,
                    widget.consolidating,
                    widget.showBinary,
                    btsDesc: switch ((widget.showHex, widget.consolidating)) {
                      (false, _) => 'So instead of this amalgamation:',
                      (true, _) => 'We can use this bad boy:',
                      (_, true) => 'but instead of being stored as 3 values,\n'
                          "it's usually just one big long color code"
                          '${widget.showBinary ? ':' : '.'}',
                      (_, false) => "here's what's going on\nbehind the scenes:",
                    },
                    showHex: widget.showHex ?? false,
                  )
                : empty,
          ),
        ],
      ),
    );
  }
}

class _BTS extends StatelessWidget {
  const _BTS(this.color, this.consolidating, this.showBinary,
      {required this.btsDesc, this.showHex = false});
  final SuperColor color;
  final bool consolidating, showBinary, showHex;
  final String btsDesc;

  @override
  Widget build(BuildContext context) {
    final binary = [
      for (final code in [color.red, color.green, color.blue])
        showHex
            ? code.toRadixString(16).padLeft(2, '0').toUpperCase()
            : code.toRadixString(2).padLeft(8, '0')
    ];

    final colorCode = consolidating
        ? Padding(
            padding: const EdgeInsets.only(top: 18, left: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SexyBox(
                  child: showHex ? const Text('#', style: SuperStyle.mono(size: 16)) : empty,
                ),
                for (final code in binary)
                  SexyBox(child: Text(code, style: const SuperStyle.mono(size: 16))),
              ],
            ),
          )
        : Text(
            '\n'
            '    red: ${binary[0]}\n'
            '  green: ${binary[1]}\n'
            '   blue: ${binary[2]}',
            style: const SuperStyle.mono(size: 16),
          );

    return SuperContainer(
      decoration: BoxDecoration(
        color: inverted ? SuperColors.white80 : SuperColors.black80,
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.all(25),
      margin: const EdgeInsets.fromLTRB(25, 0, 25, 25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            btsDesc,
            style: const SuperStyle.mono(size: 16),
          ),
          SexyBox(
            child: showBinary ? colorCode : const SizedBox(width: 200),
          ),
        ],
      ),
    );
  }
}

class _Page5 extends StatefulWidget {
  const _Page5(this.nextPage);
  final void Function() nextPage;

  @override
  State<_Page5> createState() => _Page5State();
}

class _Page5State extends SuperState<_Page5> {
  bool realization = false,
      prefix1 = false,
      prefix2 = false,
      question = false,
      answer = false,
      showButton = false;
  int hexRows = -3;

  @override
  void animate() async {
    await sleepState(4, () => realization = true);
    await sleepState(7, () => prefix1 = true);
    await sleepState(6, () => prefix2 = true);
    await sleepState(5, () => question = true);
    await sleepState(3, () => answer = true);
    await sleepState(2, () => hexRows++);
    await sleep(1);
    const cycleTime = 0.6;
    while (hexRows <= 16) {
      await sleepState(cycleTime, () => hexRows++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double size = min(20, context.screenWidth / 24);
    return Column(
      children: [
        const Spacer(flex: 4),
        SexyBox(
          child: hexRows == -3
              ? SuperText(
                  'But computer science people are hecka smart. 🤓',
                  style: SuperStyle.sans(size: size),
                )
              : empty,
        ),
        const Spacer(),
        SexyBox(
          child: hexRows == -3
              ? Fader(
                  realization,
                  child: SuperText(
                    'They realized that if you use base 16,\n'
                    'you can represent a nibble with 1 digit!',
                    style: SuperStyle.sans(size: size),
                  ),
                )
              : empty,
        ),
        const Spacer(flex: 2),
        Fader(
          prefix1,
          child: SuperRichText(style: SuperStyle.sans(size: size), [
            const TextSpan(text: "To show that you're writing in base 16,\nyou can put a "),
            TextSpan(
              text: "'0x'",
              style: SuperStyle.mono(
                color: inverted ? SuperColors.black80 : SuperColors.white80,
                backgroundColor: inverted ? Colors.white : Colors.black38,
              ),
            ),
            const TextSpan(text: ' before the number,'),
          ]),
        ),
        Fader(
          prefix2,
          child: SuperRichText(style: SuperStyle.sans(size: size), [
            const TextSpan(text: 'or you can use '),
            TextSpan(
              text: "'#'",
              style: SuperStyle.mono(
                backgroundColor: inverted ? Colors.white : Colors.black38,
                color: inverted ? SuperColors.black80 : SuperColors.white80,
              ),
            ),
            const TextSpan(text: ' for 6-digit color codes.'),
          ]),
        ),
        const Spacer(flex: 2),
        Fader(question,
            child: SuperText(
              'How do you write with 16 different digits?',
              style: SuperStyle.sans(size: size),
            )),
        Fader(answer,
            child: SuperText(
              'Just use letters when you run out of numbers :)',
              style: SuperStyle.sans(size: size),
            )),
        const Spacer(flex: 2),
        SexyBox(
          child: hexRows == -3
              ? flat
              : SuperContainer(
                  width: double.infinity,
                  height: 460,
                  color: inverted ? Colors.white : Colors.black38,
                  alignment: Alignment.center,
                  child: _HexRows(hexRows),
                ),
        ),
        const Spacer(flex: 2),
        Opacity(
          opacity: hexRows > 16 ? 1 : 0,
          child: ContinueButton(onPressed: widget.nextPage),
        ),
        const Spacer(flex: 2),
      ],
    );
  }
}

class _HexRows extends StatelessWidget {
  const _HexRows(this.visibleRows);
  final int visibleRows;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = -2; i < 16; i++)
          Opacity(
            opacity: i < visibleRows ? 0.8 : 0,
            child: SizedBox(
              width: 300,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      switch (i) {
                        -2 => 'hexadecimal',
                        -1 => '-----------',
                        _ => '0x${i.toRadixString(16).toUpperCase()}'.padLeft(7),
                      },
                      style: const SuperStyle.mono(size: 16),
                    ),
                  ),
                  const Text('| ', style: SuperStyle.mono(size: 16)),
                  Expanded(
                    flex: 2,
                    child: Text(
                      switch (i) {
                        -2 => 'decimal',
                        -1 => '-------',
                        _ => '$i'.padLeft(2, '0').padLeft(4),
                      },
                      style: const SuperStyle.mono(size: 16),
                    ),
                  ),
                  const Text('| ', style: SuperStyle.mono(size: 16)),
                  Expanded(
                    flex: 2,
                    child: Text(
                      switch (i) {
                        -2 => 'binary',
                        -1 => '------',
                        _ => i.toRadixString(2).padLeft(4, '0').padLeft(5),
                      },
                      style: const SuperStyle.mono(size: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _FinalPage extends StatefulWidget {
  const _FinalPage();

  @override
  State<_FinalPage> createState() => _FinalPageState();
}

class _FinalPageState extends SuperState<_FinalPage> {
  bool visible = true,
      showBTS = true,
      showButton = false,
      consolidating = true,
      collapsed = true,
      showHex = false;

  @override
  void animate() async {
    await sleepState(1, () => collapsed = false);
    await sleepState(5, () => showHex = true);
    await sleepState(4, () => showButton = true);
  }

  void leave() => () async {
        setState(() {
          showButton = false;
          showBTS = false;
        });
        await sleepState(1, () => consolidating = false);
        await sleepState(3, () => collapsed = true);
        await Tutorial.sandbox.complete();
        await sleep(1);
      }()
          .then((_) => context.goto(Pages.sandbox));

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 2),
        Fader(
          visible,
          child: _ColorCard.hex(showHex, showBTS, consolidating, collapsed),
        ),
        const Spacer(),
        Fader(showButton, child: ContinueButton(onPressed: leave)),
        const Spacer(),
      ],
    );
  }
}
