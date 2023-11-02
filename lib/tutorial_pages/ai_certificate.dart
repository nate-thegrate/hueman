import 'package:flutter/material.dart';
import 'package:hueman/data/save_data.dart';
import 'package:hueman/data/structs.dart';
import 'package:hueman/data/super_color.dart';
import 'package:hueman/data/super_container.dart';
import 'package:hueman/data/super_text.dart';
import 'package:hueman/data/widgets.dart';

class AiCertificate extends StatefulWidget {
  const AiCertificate({super.key});

  @override
  State<AiCertificate> createState() => _AiCertificateState();
}

class _AiCertificateState extends State<AiCertificate> {
  late bool showScreenshot, showBack;

  @override
  void initState() {
    super.initState();
    showBack = showScreenshot = Tutorial.aiCertificate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Theme(
              data: ThemeData(
                brightness: Brightness.dark,
                useMaterial3: true,
                fontFamily: 'Nunito Sans',
                scrollbarTheme: const ScrollbarThemeData(
                  thumbColor: MaterialStatePropertyAll(Colors.black54),
                ),
              ),
              child: SingleChildScrollView(
                child: Image.asset('assets/ChatGPT.png'),
              ),
            ),
          ),
          if (!showBack)
            Fader(
              !showScreenshot,
              child: SuperContainer(
                color: SuperColors.darkBackground,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SuperText('Nate (the game author) taught ChatGPT\n'
                          'how to describe the primary colors.'),
                      const SuperText("Here's a screenshot as proof."),
                      ContinueButton(onPressed: () {
                        setState(() => showScreenshot = true);
                        sleep(1, then: () => setState(() => showBack = true));
                        Tutorial.aiCertificate.complete();
                      }),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: showBack
          ? const Padding(
              padding: EdgeInsets.only(top: 20),
              child: GoBack(),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
    );
  }
}
