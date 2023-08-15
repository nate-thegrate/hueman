import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:super_hueman/structs.dart';
import 'package:super_hueman/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class Snippet extends StatelessWidget {
  final String text;
  const Snippet(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      );
}

class Ads extends StatefulWidget {
  const Ads({super.key});

  @override
  State<Ads> createState() => _AdsState();
}

class _AdsState extends State<Ads> {
  late final Ticker ticker;

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

  List<(double, Widget)> get items => [
        (0, const Spacer()),
        (
          5,
          const Snippet('This game uses cookies\n' 'to share data with third-party advertisers.')
        ),
        (3, const Snippet('Just kidding.  :)')),
        (5, const Snippet('This is an open-source game\n' 'with zero ads or paywalls.')),
        (5, const Snippet('Lots of open-source projects run on donations\n' 'from the community…')),
        (5, const Snippet("…but to be honest, I don't need money.")),
        (
          5,
          const Snippet("I'm actually working on another mobile game right now.\n"
              "It's a much bigger project than this one.")
        ),
        (5, const Snippet('If you want me to send you an email when it comes out,')),
        (
          5,
          MenuButton(
            'click here!',
            color: epicColor,
            onPressed: () => visibleIndex >= 8 ? launchUrl(Uri.parse('https://google.com/')) : null,
          )
        ),
        (0, const Spacer()),
        (
          5,
          const Snippet('Hopefully a bunch of people join that email list,\n'
              'and my ADHD brain will feel super motivated to work on it.')
        ),
        (5, const Snippet('Thanks for your time.')),
        (
          5,
          OutlinedButton(
              onPressed: visibleIndex >= 12 ? goBack : null,
              child: const Padding(
                padding: EdgeInsets.only(top: 5, bottom: 8),
                child: Text('go back', style: TextStyle(fontSize: 18)),
              ))
        ),
        (5, const Spacer()),
      ];

  int visibleIndex = 0;

  void animateThisPage() async {
    for (final (delay, _) in items) {
      await sleep(delay);
      visibleIndex += 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < items.length; i++)
              Expanded(
                child: Center(
                  child: AnimatedOpacity(
                      opacity: i <= visibleIndex ? 1 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: items[i].$2),
                ),
              )
          ],
        ),
      ),
    );
  }
}
