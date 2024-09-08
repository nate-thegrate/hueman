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
    final width = context.screenWidth;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Theme(
                data: ThemeData(
                  brightness: Brightness.dark,
                  useMaterial3: true,
                  fontFamily: 'Nunito Sans',
                  scrollbarTheme: const ScrollbarThemeData(
                    thumbColor: WidgetStatePropertyAll(Colors.black54),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Theme.of(context).platform == TargetPlatform.iOS
                      ? Image.asset(
                          'assets/ChatGPT.png',
                          width: width,
                          height: width * 17988 / 1056,
                          fit: BoxFit.fill,
                        )
                      : Image.asset('assets/ChatGPT.png'),
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
                      children: [
                        const Spacer(flex: 4),
                        const SuperText('I taught ChatGPT\n'
                            'how to describe the primary colors.'),
                        const Spacer(),
                        const SuperText("Here's a screenshot as proof."),
                        const Spacer(flex: 3),
                        ContinueButton(onPressed: () {
                          Tutorial.aiCertificate.complete();
                          setState(() => showScreenshot = true);
                          sleep(1, then: () => setState(() => showBack = true));
                        }),
                        const Spacer(flex: 2),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
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
