import 'package:flutter/material.dart';
import 'package:hueman/data/page_data.dart';
import 'package:hueman/data/save_data.dart';
import 'package:hueman/data/structs.dart';
import 'package:hueman/data/super_color.dart';
import 'package:hueman/data/super_container.dart';
import 'package:hueman/data/super_state.dart';
import 'package:hueman/data/super_text.dart';
import 'package:hueman/data/widgets.dart';

class EvenFurtherTutorial extends StatefulWidget {
  const EvenFurtherTutorial({super.key});

  @override
  State<EvenFurtherTutorial> createState() => _EvenFurtherTutorialState();
}

class _EvenFurtherTutorialState extends EpicState<EvenFurtherTutorial> {
  bool visible = false,
      showTop = false,
      showBottom = false,
      whatIsaid = false,
      whatIshowed = false,
      showButton = false;
  @override
  void animate() async {
    musicPlayer.stop();
    await sleepState(1, () => visible = true);
    await sleepState(1.5, () => showTop = true);
    await sleepState(6, () => showBottom = true);
    await sleepState(3, () => whatIsaid = true);
    await sleepState(3, () => whatIshowed = true);
    await sleepState(2, () => showButton = true);
  }

  void liar() => context.noTransition(const _TrueFinalChallenge());

  @override
  Widget build(BuildContext context) {
    final color = SuperColor.hue(epicHue, 0.35);
    return Theme(
      data: ThemeData(useMaterial3: true, fontFamily: 'Gaegu'),
      child: Scaffold(
        body: Fader(
          visible,
          duration: const Duration(seconds: 2),
          child: SuperContainer(
            color: SuperColors.bsBackground,
            alignment: Alignment.center,
            child: Column(
              children: [
                const Spacer(flex: 4),
                Fader(
                  showTop,
                  duration: const Duration(seconds: 2),
                  child: const SuperRichText(
                    style: SuperStyle.gaegu(),
                    [
                      TextSpan(text: "I hope you've had a great time with "),
                      TextSpan(
                        text: 'H',
                        style: SuperStyle.gaegu(
                          size: 32,
                          weight: FontWeight.bold,
                          color: SuperColors.red,
                        ),
                      ),
                      TextSpan(
                        text: 'U',
                        style: SuperStyle.gaegu(
                          size: 32,
                          weight: FontWeight.bold,
                          color: SuperColors.yellow,
                          shadows: [Shadow(color: SuperColor(0x4040FF), blurRadius: 1)],
                        ),
                      ),
                      TextSpan(
                        text: 'E',
                        style: SuperStyle.gaegu(
                          size: 32,
                          weight: FontWeight.bold,
                          color: SuperColor(0x0060FF),
                        ),
                      ),
                      TextSpan(
                        text: 'man',
                        style: SuperStyle.gaegu(
                          size: 32,
                          color: SuperColors.bsBrown,
                          letterSpacing: -1.5,
                        ),
                      ),
                      TextSpan(
                        text: '!',
                        style: SuperStyle.gaegu(size: 32, weight: FontWeight.w300),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Fader(
                  showBottom,
                  child: SuperRichText(
                    style: const SuperStyle.gaegu(),
                    [
                      const TextSpan(text: 'You probably thought '),
                      TextSpan(
                        text: 'true mastery',
                        style: SuperStyle.sans(
                          size: 20,
                          width: 87.5,
                          letterSpacing: 0,
                          weight: 500,
                          extraBold: true,
                          color: color,
                          shadows: const [Shadow(color: Colors.white, blurRadius: 1)],
                        ),
                      ),
                      const TextSpan(text: ' was the final challenge'),
                    ],
                  ),
                ),
                Fader(
                  whatIsaid,
                  child: const SuperText(
                    "(since that's what I said earlier).",
                    style: SuperStyle.gaegu(),
                  ),
                ),
                const FixedSpacer(10),
                Fader(
                  whatIshowed,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text.rich(
                        style: const SuperStyle.gaegu(),
                        softWrap: false,
                        TextSpan(
                          children: [
                            const TextSpan(text: '(And also since there was a big '),
                            TextSpan(
                              text: '  The End  ',
                              style: SuperStyle.sans(
                                size: 20,
                                weight: 700,
                                extraBold: true,
                                backgroundColor: epicColor,
                              ),
                            ),
                            const TextSpan(text: ' screen.)'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 2),
                Fader(
                  showButton,
                  child: ContinueButton(onPressed: liar),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}

class _TrueFinalChallenge extends StatefulWidget {
  const _TrueFinalChallenge();

  @override
  State<_TrueFinalChallenge> createState() => _TrueFinalChallengeState();
}

class _TrueFinalChallengeState extends EpicState<_TrueFinalChallenge> with SinglePress {
  bool showAdmissionOfGuilt = true,
      daVinciAppear = false,
      showDaVinciLayer = true,
      goodLuck = false,
      showTop = false,
      showBottom = false,
      showDaVinci = false,
      showQuote = false,
      showFinalChallenge = false,
      justKidding = false,
      finalButton = false;

  @override
  void animate() async {
    await sleepState(2, () => daVinciAppear = true);
    playSound('liar');
    await sleepState(5 + androidLatency, () => showTop = true);
    await sleepState(2, () => showBottom = true);
  }

  void daVinci() async {
    setState(() {
      showAdmissionOfGuilt = false;
      showTop = false;
      showBottom = false;
    });
    await sleepState(3, () => showDaVinci = true);
    await sleepState(6, () => showQuote = true);
    await sleepState(4, () => showDaVinci = false);
    await sleepState(3, () => showFinalChallenge = true);
    await sleepState(5, () => goodLuck = true);
    await sleepState(2, () => showTop = true);
    await sleepState(5, () => showBottom = true);
  }

  void getPranked() async {
    setState(() => justKidding = true);
    await sleepState(3, () => finalButton = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (!justKidding)
              Fader(
                key: const Key('da vinci'),
                showDaVinciLayer,
                child: Opacity(
                  opacity: daVinciAppear ? 1 : 0,
                  child: _DaVinci(
                    showAdmissionOfGuilt,
                    showDaVinci,
                    showQuote,
                    showFinalChallenge,
                  ),
                ),
              ),
            if (goodLuck)
              _GoodLuck(key: const Key('good luck!'), getPranked, showTop, showBottom)
            else
              Fader(
                key: const Key('I lied. 😈'),
                showAdmissionOfGuilt,
                child: _ILied(daVinci, showTop, showBottom),
              ),
            if (justKidding)
              JustKidding(
                key: const Key('go even further'),
                'go even further',
                buttonVisible: finalButton,
                color: epicColor,
                onPressed: singlePress(() async {
                  await Tutorial.evenFurther.complete();
                  playMusic(once: 'invert_1', loop: 'invert_2');
                  context.goto(Pages.evenFurther);
                }),
              ),
          ],
        ),
      ),
    );
  }
}

class _ILied extends StatelessWidget {
  const _ILied(this.next, this.braceYourself, this.showButton);
  final VoidCallback next;
  final bool braceYourself, showButton;

  @override
  Widget build(BuildContext context) {
    inverted = true;
    return Column(
      children: [
        const Spacer(flex: 4),
        const SuperText(
          'I lied. 😈',
          style: SuperStyle.sans(size: 36, extraBold: true, color: SuperColors.darkBackground),
        ),
        const Spacer(),
        Fader(
          braceYourself,
          child: const SuperText(
            'brace yourself:\n'
            'what comes next is more difficult than anything in this game thus far.',
            style: SuperStyle.sans(color: Colors.black, size: 20),
          ),
        ),
        const Spacer(flex: 2),
        Fader(
          showButton,
          child: Theme(
            data: ThemeData(useMaterial3: true, brightness: Brightness.light),
            child: ContinueButton(onPressed: next),
          ),
        ),
        const Spacer(flex: 2),
      ],
    );
  }
}

class _DaVinci extends StatelessWidget {
  const _DaVinci(this.fillWithColor, this.showDaVinci, this.showQuote, this.showFinalChallenge);
  final bool fillWithColor, showDaVinci, showQuote, showFinalChallenge;

  @override
  Widget build(BuildContext context) {
    final color = epicColor;
    return Column(
      children: [
        const Spacer(),
        Expanded(
          flex: 6,
          child: AnimatedScale(
            scale: fillWithColor ? 5 : 1,
            duration: const Duration(milliseconds: 3333),
            curve: Curves.easeOutExpo,
            child: SuperContainer(
              color: color,
              child: Fader(
                showDaVinci || showQuote,
                child: Image.asset('assets/da_vinci.png'),
              ),
            ),
          ),
        ),
        const Spacer(),
        Fader(
          showDaVinci,
          duration: const Duration(seconds: 3),
          curve: Curves.easeInSine,
          child: const SuperText('This challenge was inspired by Leonardo da Vinci:'),
        ),
        Fader(
          showFinalChallenge,
          child: const SuperText(
            'Your final task is to gain knowledge and skills that surpass mine.',
          ),
        ),
        Fader(
          showDaVinci,
          duration: const Duration(seconds: 3),
          curve: Curves.easeInSine,
          child: Fader(
            showQuote,
            child: SuperText(
              '"Poor is the pupil who does not surpass his master."',
              style: SuperStyle.gaegu(
                color: color,
                shadows: const [
                  Shadow(blurRadius: 1),
                  Shadow(blurRadius: 2),
                  Shadow(blurRadius: 3),
                ],
              ),
            ),
          ),
        ),
        Fader(false, child: ContinueButton(onPressed: () {})),
        const Spacer(),
      ],
    );
  }
}

class _GoodLuck extends StatelessWidget {
  const _GoodLuck(this.onPressed, this.showTop, this.showBottom, {super.key});
  final bool showTop, showBottom;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      child: SuperContainer(
        constraints: const BoxConstraints.expand(),
        color: SuperColors.darkBackground,
        alignment: Alignment.center,
        child: Column(
          children: [
            const Spacer(flex: 2),
            Fader(
              showTop,
              child: const SuperText(
                'I know it might seem unfair\n'
                'for me to end with such a vague request,\n\n'
                'but I believe in you!',
              ),
            ),
            const Spacer(),
            Fader(
              showBottom,
              child: const SuperText(
                "There's nothing left in this game:\n"
                "it's time for you to venture beyond what I know "
                'and teach yourself more about colors.\n\n'
                'Good luck!',
              ),
            ),
            const Spacer(),
            Fader(showBottom, child: ContinueButton(onPressed: onPressed)),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
