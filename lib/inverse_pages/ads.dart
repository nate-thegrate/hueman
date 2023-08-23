import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:super_hueman/save_data.dart';
import 'package:super_hueman/structs.dart';
import 'package:super_hueman/widgets.dart';

class Snippet extends StatelessWidget {
  final String text;
  const Snippet(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall,
      );
}

class Ads extends StatefulWidget {
  const Ads({super.key});

  @override
  State<Ads> createState() => _AdsState();
}

class AdsAnimation {
  final double delay;
  final Widget Function(Color) widget;
  final bool replacePrevious;
  AdsAnimation(this.delay, this.widget, {this.replacePrevious = false});

  double opacity = 0;
}

class SnippetAnimation extends AdsAnimation {
  final String text;
  SnippetAnimation(double delay, this.text, {bool replacePrevious = false})
      : super(delay, (_) => Snippet(text), replacePrevious: replacePrevious);
}

Widget none(_) => empty;

class _AdsState extends State<Ads> {
  late final Ticker inverseHues;
  static const duration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    sleep(1).then((_) => clickedOnAds = true);
    inverseHues = inverseSetup(setState);
    animateThisPage();
  }

  @override
  void dispose() {
    inverseHues.dispose();
    super.dispose();
  }

  final List<AdsAnimation> allItems = [
    AdsAnimation(1, none),
    SnippetAnimation(
        6,
        'This game is free to play. It also uses cookies\n'
        'to communicate with third-party advertisers.'),
    SnippetAnimation(3.5, 'Just kidding.  :)', replacePrevious: true),
    SnippetAnimation(4, "This game is open-source: it doesn't have any ads or paywalls.",
        replacePrevious: true),
    SnippetAnimation(
        7.5,
        'Most open-source projects rely on community support\n'
        'to cover the cost of servers and ongoing development.'),
    SnippetAnimation(5, 'You can make a huge difference\n' 'by making a small donation.',
        replacePrevious: true),
    SnippetAnimation(3, 'Just kidding again  :)\n', replacePrevious: true),
    SnippetAnimation(4, 'asking people for money is super cringe lol\n', replacePrevious: true),
    SnippetAnimation(5, "But there's something else I'd like to ask, if it's all right."),
    SnippetAnimation(3.5, "I'm working on another game right now."),
    AdsAnimation(
        7,
        (c) => RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'Segoe UI',
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
                children: [
                  const TextSpan(text: "You're gonna love it just as much as super"),
                  TextSpan(
                    text: 'ʜ\u1d1cᴇ',
                    style: TextStyle(color: c, fontWeight: FontWeight.w600),
                  ),
                  const TextSpan(text: 'man,\nif not even more :D'),
                ],
              ),
            )),
    SnippetAnimation(
        5.5,
        "It's a much bigger project than this one though,\n"
        "so it's gonna be a while before I'm ready to release it."),
    SnippetAnimation(4, 'If you want me to send you an email when it comes out,'),
    AdsAnimation(
      4,
      (c) => SizedBox(
        height: 50,
        child: SuperButton(
          'click here!',
          color: c,
          onPressed: gotoWebsite('https://google.com/'),
        ),
      ),
    ),
    AdsAnimation(0, none),
    AdsAnimation(0, none),
    SnippetAnimation(
        5,
        'Hopefully a bunch of people join that email list,\n'
        "and it'll really motivate my ADHD brain to work on it."),
    SnippetAnimation(1.5, 'Thanks for your time.'),
    AdsAnimation(
      0,
      (_) => const GoBack(text: 'go back'),
    ),
  ];

  int get permanentItems {
    int total = 0;
    for (final item in allItems) {
      if (!item.replacePrevious) total++;
    }
    return total;
  }

  late final List<AdsAnimation?> items;

  void animateThisPage() async {
    items = List.filled(permanentItems, null);
    int childrenIndex = -1;

    for (final animation in allItems) {
      if (animation.replacePrevious) {
        setState(() => items[childrenIndex]!.opacity = 0);
        await Future.delayed(duration);
      } else {
        childrenIndex++;
      }
      setState(() => items[childrenIndex] = animation);
      await sleep(duration.inMilliseconds * 0.0005);
      setState(() => items[childrenIndex]!.opacity = 1);
      await sleep(animation.delay);
    }
  }

  @override
  Widget build(BuildContext context) => Theme(
        data: ThemeData(useMaterial3: true),
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final child in items) ...[
                  AnimatedSize(
                    duration: duration,
                    curve: curve,
                    child: AnimatedOpacity(
                      duration: duration,
                      opacity: child?.opacity ?? 0,
                      child: Center(child: child?.widget(inverseColor)),
                    ),
                  ),
                  const Spacer(),
                ]
              ],
            ),
          ),
          backgroundColor: SuperColors.lightBackground,
        ),
      );
}
