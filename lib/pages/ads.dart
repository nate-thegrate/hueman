import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:super_hueman/structs.dart';
import 'package:super_hueman/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

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

class _AdsState extends State<Ads> {
  late final Ticker ticker;
  static const duration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    ticker = epicSetup(setState);
    animateThisPage();
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  void goBack() => context.goto(Pages.mainMenu);

  List<AdsAnimation> get allItems => [
        AdsAnimation(1, (_) => empty),
        SnippetAnimation(
            5.5, 'This game uses cookies\n' 'to share data with third-party advertisers.'),
        SnippetAnimation(3.5, 'Just kidding.  :)', replacePrevious: true),
        SnippetAnimation(4, "This game is open-source: it doesn't have any ads or paywalls.",
            replacePrevious: true),
        SnippetAnimation(
            7.5,
            'Most open-source projects rely on donations from the community\n'
            'to cover the cost of servers and ongoing development.'),
        SnippetAnimation(
            5,
            'Even if you just make a small contribution,\n'
            'it would make a huge difference.'),
        SnippetAnimation(3, 'Just kidding again   :)\n', replacePrevious: true),
        SnippetAnimation(4, 'asking people for money is super cringe lol\n', replacePrevious: true),
        SnippetAnimation(5, "There's something else I'd like to ask, if that's all right."),
        SnippetAnimation(4, "I'm actually working on another mobile game right now."),
        AdsAnimation(
            7,
            (c) => RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                        fontFamily: 'Segoe UI', fontSize: 24, fontWeight: FontWeight.w400),
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
        SnippetAnimation(4, "It's a much bigger project than this one though."),
        SnippetAnimation(4, 'If you want me to send you an email when it comes out,'),
        AdsAnimation(
          4,
          (c) => MenuButton(
            'click here!',
            color: c,
            onPressed: () => launchUrl(Uri.parse('https://google.com/')),
          ),
        ),
        AdsAnimation(0, (_) => empty),
        SnippetAnimation(
            5,
            'Hopefully a bunch of people join that email list,\n'
            "and it'll really motivate my ADHD brain to work on it."),
        SnippetAnimation(1.5, 'Thanks for your time.'),
        AdsAnimation(
            0,
            (_) => TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white70,
                    backgroundColor: Colors.black26,
                  ),
                  onPressed: goBack,
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(5, 10, 5, 13),
                    child: Text(
                      'go back',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                    ),
                  ),
                )),
        AdsAnimation(0, (_) => empty),
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
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final child in items) ...[
                AnimatedSize(
                  duration: duration,
                  curve: Curves.easeOutCubic,
                  child: AnimatedOpacity(
                    duration: duration,
                    opacity: child?.opacity ?? 0,
                    child: Center(child: child?.widget(epicColor)),
                  ),
                ),
                const Spacer(),
              ]
            ],
          ),
        ),
      );
}
