import 'package:flutter/material.dart';
import 'package:super_hueman/structs.dart';

class TriviaButton extends StatelessWidget {
  final String colorName;
  final bool selected;
  final void Function() submit;
  const TriviaButton(this.colorName, this.selected, {required this.submit, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 75,
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: selected
          ? BoxDecoration(
              border: Border.all(color: Colors.white, width: 5),
              boxShadow: const [BoxShadow(color: Colors.black, blurRadius: 10)],
            )
          : null,
      child: ElevatedButton(
        onPressed: submit,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: colorFromName(colorName),
          shape: const BeveledRectangleBorder(),
        ),
        child: Text(colorName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              shadows: [
                Shadow(color: Colors.white24, blurRadius: 1),
                Shadow(color: Colors.white30, blurRadius: 25),
              ],
              height: -0.1,
            )),
      ),
    );
  }
}

class TriviaQuestion {
  final String question;
  final String? explanation;
  final List<BestColors> answers;
  TriviaQuestion(this.question, BestColors answer, {this.explanation}) : answers = [answer];
  TriviaQuestion.multipleAnswers(this.question, this.answers, {this.explanation});
}

final List<TriviaQuestion> triviaQuestions = [
  TriviaQuestion(
    'The longest electromagnetic wavelength visible to the human eye is perceived as this color:',
    BestColors.red,
    explanation: 'red light has a wavelength of ~700 nm, '
        'roughly 150 times smaller than the width of a human hair.',
  ),
  TriviaQuestion(
    'The highest electromagnetic frequency visible to the human eye is perceived as this color:',
    BestColors.violet,
    explanation: 'violet light photons oscillate at a frequency of 750 THz, '
        'or 750,000,000,000,000 times per second.',
  ),
  TriviaQuestion(
    '"When mixing paint, the 3 primary colors are red, yellow, and blue."\n'
    'Only 1 of those 3 colors is correct—which is it?',
    BestColors.yellow,
    explanation: 'The subtractive primary colors are cyan, magenta and yellow.\n'
        'These 3 colors apply when mixing pigments (e.g. dyes, inks, and paints).',
  ),
  TriviaQuestion(
    'Complementary colors are 180° apart on the color wheel. '
    "What's the complementary color to rose?",
    BestColors.spring,
    explanation: 'Another way to think of complementary colors is to take the negative: '
        'i.e. flip the RGB values upside down so that the 2 colors add up to 100% white.\n'
        'For example, rose is 100% red / 0% green / 50% blue, '
        'and its complement spring is 0% red / 100% green / 50% blue',
  ),
  TriviaQuestion(
    'Which color is also the name of a cloud computing platform?',
    BestColors.azure,
    explanation: 'Microsoft Azure is a tool you can use to create websites and virtual machines.',
  ),
  TriviaQuestion(
    'The official color of the Dutch royal family:',
    BestColors.orange,
    explanation: 'The Netherlands national football team wears orange because of this.',
  ),
  TriviaQuestion(
    "What's my favorite color?",
    BestColors.cyan,
    explanation: "100% useless information, but that's what trivia's all about!.\n"
        "I think it's a very aesthetically pleasing color, "
        'and cyan (along with magenta) is a primary color that no one seems to be talking about. '
        "Hopefully that's about to change!",
  ),
  TriviaQuestion(
    'If you were born in August, what color would your birthstone be?',
    BestColors.lime,
    explanation: 'According to what I just read on Wikipedia, '
        "Peridot is one of only two gems observed to be formed not in Earth's crust, "
        'but in the molten rock of the upper mantle.',
  ),
  TriviaQuestion(
    'The color "brown" is really just a darker shade of:',
    BestColors.orange,
    explanation: "This is why there's no such thing as a brown light bulb—"
        'once brown gets bright enough, it takes on an orange appearance.',
  ),
  TriviaQuestion.multipleAnswers(
    'These two colors never appear in a rainbow:',
    [BestColors.magenta, BestColors.rose],
    explanation: 'Blue light has a higher frequency than red light. '
        'But the highest frequencies of visible light '
        'stimulate our "red" cones a little bit as well, and we perceive it as "violet".'
        'The only way to stimulate the red and blue cones equally '
        'is to use two different light frequencies at once.',
  ),
  TriviaQuestion.multipleAnswers(
    'The most common type of color-blindness involves being unable to tell _____ and _____ apart.',
    [BestColors.red, BestColors.green],
    explanation: '"Congenital red-green color blindness" is the official term for '
        'the most prevalent type of color-blindness.'
        "It's caused by a recessive gene in the X-chromosome, "
        'so males are more likely to inherit this color-blindness than females.',
  ),
  TriviaQuestion(
    'The more distant another star is from our solar system, the more _____ it appears to us.',
    BestColors.red,
    explanation: 'When we observe stars that are rapidly moving away from us, '
        'the photons are "stretched" into longer wavelengths. '
        'Thanks to our expanding universe, '
        'far-away stars are rapidly accelerating away from our galaxy, '
        'which gives them more of a red hue.',
  ),
  TriviaQuestion.multipleAnswers(
    'Morpheus offered Neo two pills. What colors were they?',
    [BestColors.red, BestColors.blue],
    explanation: 'The Matrix was a fun movie.',
  ),
  TriviaQuestion.multipleAnswers(
    "What are the colors of Jon Arbuckle's two pets?",
    [BestColors.orange, BestColors.yellow],
    explanation: 'Their names are "Garfield" and "Odie".',
  ),
];

class TriviaMode extends StatefulWidget {
  const TriviaMode({super.key});

  @override
  State<TriviaMode> createState() => _TriviaModeState();
}

class _TriviaModeState extends State<TriviaMode> {
  late List<(String, bool)> buttonData;

  void resetButtons() =>
      buttonData = [for (final colorName in BestColors.names) (colorName, false)];

  @override
  void initState() {
    super.initState();
    resetButtons();
  }

  void Function() submit(int i) => () {
        final (name, value) = buttonData[i];
        setState(() => buttonData[i] = (name, !value));
      };

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(useMaterial3: true),
      child: Scaffold(
        body: Center(
          child: Column(
            children: [
              const Spacer(),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xcc000000),
                  backgroundColor: Colors.white54,
                ),
                onPressed: () => context.goto(Pages.inverseMenu),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'back',
                    style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                  ),
                ),
              ),
              const Spacer(),
              ...[
                for (int i = 0; i < 6; i++)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TriviaButton(buttonData[i].$1, buttonData[i].$2, submit: submit(i)),
                      TriviaButton(buttonData[11 - i].$1, buttonData[11 - i].$2,
                          submit: submit(11 - i)),
                    ],
                  )
              ],
              const Spacer(),
            ],
          ),
        ),
        backgroundColor: const Color(0xffeef3f8),
      ),
    );
  }
}
