import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart' as rive;
import 'package:super_hueman/data/save_data.dart';
import 'package:super_hueman/data/structs.dart';
import 'package:super_hueman/data/super_color.dart';
import 'package:super_hueman/data/super_container.dart';

const Widget empty = SizedBox.shrink();

class FixedSpacer extends StatelessWidget {
  const FixedSpacer(this.size, {super.key}) : horizontal = false;
  const FixedSpacer.horizontal(this.size, {super.key}) : horizontal = true;
  final double size;
  final bool horizontal;

  @override
  Widget build(BuildContext context) =>
      horizontal ? SizedBox(width: size) : SizedBox(height: size);
}

class Fader extends AnimatedOpacity {
  const Fader(
    this.visible, {
    required super.child,
    super.duration = oneSec,
    super.curve,
    super.key,
  }) : super(opacity: visible ? 1 : 0);
  final bool visible;
}

class FadeIn extends StatefulWidget {
  const FadeIn({
    required this.child,
    this.duration = oneSec,
    this.curve = Curves.linear,
    super.key,
  });
  final Widget child;
  final Duration duration;
  final Curve curve;

  @override
  State<FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> {
  bool visible = false;

  @override
  void initState() {
    super.initState();
    quickly(() => setState(() => visible = true));
  }

  @override
  Widget build(BuildContext context) => Fader(
        visible,
        duration: widget.duration,
        curve: widget.curve,
        child: widget.child,
      );
}

class SexyBox extends AnimatedSize {
  /// very slick size change animation :)
  const SexyBox({super.child, super.key}) : super(duration: oneSec, curve: Curves.easeInOutQuart);
}

mixin DelayedPress {
  bool pressed = false;

  delayed(void Function()? onPressed, {Duration delay = halfSec}) => () {
        if (pressed) return;

        pressed = true;
        Future.delayed(delay, onPressed);
      };
}

class ContinueButton extends StatefulWidget {
  const ContinueButton({required this.onPressed, super.key});
  final void Function()? onPressed;

  @override
  State<ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<ContinueButton> with DelayedPress {
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 50,
        height: 50,
        child: Stack(
          children: [
            const Center(child: Icon(Icons.arrow_forward)),
            SizedBox.expand(
              child: OutlinedButton(onPressed: delayed(widget.onPressed), child: empty),
            ),
          ],
        ),
      );
}

class SuperButton extends StatefulWidget {
  const SuperButton(
    this.label, {
    required this.color,
    required this.onPressed,
    this.padding,
    super.key,
  });
  final String label;
  final void Function() onPressed;
  final Color color;
  final EdgeInsets? padding;

  @override
  State<SuperButton> createState() => _SuperButtonState();
}

class _SuperButtonState extends State<SuperButton> with DelayedPress {
  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: delayed(widget.onPressed),
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.color,
          foregroundColor: inverted ? Colors.white : Colors.black,
        ),
        child: Padding(
          padding: widget.padding ?? const EdgeInsets.only(bottom: 4),
          child: Text(widget.label, style: const TextStyle(fontSize: 24)),
        ),
      );
}

class NavigateButton extends StatelessWidget {
  const NavigateButton(this.page, {required this.color, this.padding, super.key});
  final Pages page;
  final Color color;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) => SuperButton(
        page(),
        color: color,
        onPressed: () => context.goto(page),
        padding: padding,
      );
}

class MenuCheckbox extends StatelessWidget {
  const MenuCheckbox(
    this.label, {
    required this.description,
    required this.value,
    required this.toggle,
    super.key,
  });
  final ValueChanged<bool> toggle;
  final bool value;
  final String label;
  final (String, String) description;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => toggle(!value),
        child: ColoredBox(
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Checkbox(
                    value: value,
                    onChanged: (_) => toggle(!value),
                  ),
                  const FixedSpacer.horizontal(10),
                  Text(
                    label,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
              Text(
                value ? description.$1 : description.$2,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      );
}

class GoBack extends StatelessWidget {
  const GoBack({this.text = 'back', super.key});
  final String text;

  static const _style = TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: 16,
    letterSpacing: 0.5,
  );

  @override
  Widget build(BuildContext context) {
    final Widget button = TextButton(
      style: TextButton.styleFrom(
        foregroundColor: inverted ? SuperColors.black80 : Colors.white60,
        backgroundColor: inverted ? Colors.white54 : Colors.black26,
      ),
      onPressed: () => context.goto(inverted ? Pages.inverseMenu : Pages.mainMenu),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 9),
        child: Text(text, style: _style),
      ),
    );
    return button;
  }
}

class ColorNameBox extends StatelessWidget {
  const ColorNameBox(this.color, {super.key}) : backgroundColor = Colors.black38;
  const ColorNameBox.trivial(this.color, {super.key})
      : backgroundColor = SuperColors.darkBackground;
  final SuperColor color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) => SuperContainer(
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 4),
          color: backgroundColor,
        ),
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 9),
        child: Text(
          color.name,
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      );
}

class ColorLabel extends StatelessWidget {
  const ColorLabel(this.property, this.value, {this.textStyle, super.key})
      : colorCode = false,
        update = null;

  const ColorLabel.colorCode(this.property, this.value,
      {required ValueChanged<SuperColor> updateColorCode, super.key})
      : textStyle = null,
        colorCode = true,
        update = updateColorCode;
  final String property, value;
  final TextStyle? textStyle;
  final ValueChanged<SuperColor>? update;
  final bool colorCode;

  @override
  Widget build(BuildContext context) {
    final TextStyle? defaultStyle = Theme.of(context).textTheme.bodyLarge;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
              width: 200,
              child: Text(
                '$property:',
                style: defaultStyle,
                textAlign: TextAlign.right,
              )),
          if (!colorCode) const FixedSpacer.horizontal(15),
          SizedBox(
            width: colorCode ? 200 : 190,
            child: colorCode
                ? Align(
                    alignment: Alignment.bottomLeft,
                    child: TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor: inverted ? Colors.black : Colors.white),
                      onPressed: () => ManualColorCode.run(
                        context,
                        color: SuperColor(int.parse(value.substring(1), radix: 16)),
                        updateColor: update!,
                      ),
                      child: Text(
                        value,
                        style: const TextStyle(fontFamily: 'Consolas', fontSize: 18),
                      ),
                    ),
                  )
                : Text(value, style: textStyle ?? defaultStyle),
          ),
        ],
      ),
    );
  }
}

class ManualColorCode extends StatefulWidget {
  const ManualColorCode(this.color, {super.key});
  final SuperColor color;

  static Future<void> run(
    BuildContext context, {
    required SuperColor color,
    required void Function(SuperColor) updateColor,
  }) =>
      showDialog(
        context: context,
        builder: (context) => ManualColorCode(color),
      ).then(verifyHexCode(context, updateColor: updateColor));

  static void Function(dynamic) verifyHexCode(BuildContext context,
          {required void Function(SuperColor) updateColor}) =>
      (dynamic value) {
        if (value is String) {
          if (value.length == 6) {
            final int colorCode = int.parse(value, radix: 16);
            updateColor(SuperColor(colorCode));
          } else if (value.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('invalid hex code: $value')),
            );
          }
        }
      };

  @override
  State<ManualColorCode> createState() => _ManualColorCodeState();
}

class _ManualColorCodeState extends State<ManualColorCode> {
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();

  void popText() => Navigator.pop(context, controller.text);

  final TextInputFormatter onlyHexChars = TextInputFormatter.withFunction(
    (oldValue, newValue) {
      final inputChars = newValue.text.toUpperCase().characters;
      final validChars = '0123456789ABCDEF'.characters;

      for (final char in inputChars) {
        if (!validChars.contains(char)) return oldValue;
      }
      return newValue;
    },
  );
  final TextInputFormatter maxLength6 = TextInputFormatter.withFunction(
      (oldValue, newValue) => newValue.text.length > 6 ? oldValue : newValue);

  @override
  void initState() {
    super.initState();
    focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) => Theme(
        data: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme(
            brightness: Brightness.light,
            primary: widget.color,
            onPrimary: widget.color,
            secondary: widget.color,
            onSecondary: widget.color,
            error: widget.color,
            onError: widget.color,
            background: SuperColors.lightBackground,
            onBackground: SuperColors.lightBackground,
            surface: Colors.black,
            onSurface: Colors.black,
          ),
        ),
        child: AlertDialog(
          surfaceTintColor: Colors.transparent,
          title: const Text('enter color code'),
          content: Row(
            children: [
              SuperContainer(
                color: const Color(0x08000000),
                width: 200,
                child: TextField(
                  focusNode: focusNode,
                  style: const TextStyle(fontFamily: 'Consolas'),
                  textAlign: TextAlign.center,
                  cursorColor: Colors.black,
                  controller: controller,
                  onSubmitted: (_) => popText(),
                  inputFormatters: [onlyHexChars, maxLength6],
                ),
              ),
              const FixedSpacer.horizontal(10),
              IconButton(
                onPressed: popText,
                icon: const Icon(Icons.check),
              ),
            ],
          ),
        ),
      );
}

class EasyText extends StatelessWidget {
  const EasyText(this.data, {super.key, this.size = 24});
  final String data;
  final double size;

  @override
  Widget build(BuildContext context) => Text(
        data,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: size),
      );
}

class EasyRichText extends StatelessWidget {
  const EasyRichText(this.children, {super.key});
  final List<TextSpan> children;

  @override
  Widget build(BuildContext context) => Text.rich(
        TextSpan(children: children),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 24),
      );
}

class ColorTextSpan extends TextSpan {
  const ColorTextSpan(this.color, {this.fontWeight = FontWeight.w600});
  final SuperColor color;
  final FontWeight fontWeight;

  @override
  String get text => color.name;

  @override
  TextStyle get style => TextStyle(color: color, fontWeight: FontWeight.w600);
}

class Rive extends StatelessWidget {
  const Rive({super.key, required this.name, required this.controllers, this.artboard});
  final String name;
  final String? artboard;
  final List<rive.RiveAnimationController<dynamic>> controllers;

  @override
  Widget build(BuildContext context) {
    return SuperContainer(
      alignment: Alignment.center,
      constraints: BoxConstraints.loose(
        Size(context.screenHeight * 2 / 3, double.infinity),
      ),
      child: rive.RiveAnimation.asset(
        'assets/animations/$name.riv',
        fit: BoxFit.cover,
        artboard: artboard,
        controllers: controllers,
      ),
    );
  }
}

class MeasuringOrb extends StatelessWidget {
  const MeasuringOrb({
    required this.step,
    required this.width,
    required this.duration,
    required this.lineColor,
    required this.hue,
    int? guess,
    super.key,
  }) : guess = guess ?? hue;
  final int step;
  final double width;
  final Duration duration;
  final Color lineColor;
  final int hue, guess;

  @override
  Widget build(BuildContext context) {
    final bool visible, linesVisible, rotating, showRightAngle;
    visible = step >= 1;
    linesVisible = step >= 2;
    rotating = step >= 4;
    showRightAngle = step >= 5;
    // print('step $step');
    final Widget line = SuperContainer(
      width: double.infinity,
      height: 4,
      color: lineColor,
    );

    return Fader(
      visible,
      child: SuperContainer(
        margin: const EdgeInsets.symmetric(vertical: 20),
        width: width + 2,
        height: width,
        child: Stack(
          children: [
            const SuperContainer(decoration: SuperColors.colorWheel),
            Fader(
              linesVisible,
              child: Padding(
                padding: EdgeInsets.fromLTRB(width / 2, width / 2 + 2, 0, 0),
                child: Stack(
                  children: [
                    Transform.translate(
                      offset: const Offset(0, -2),
                      child: line,
                    ),
                    Transform.translate(
                      offset: const Offset(0, -2),
                      child: AnimatedRotation(
                        turns: rotating ? -hue / 360 : 0,
                        curve: curve,
                        duration: duration,
                        alignment: Alignment.centerLeft,
                        child: line,
                      ),
                    ),
                    Fader(
                      showRightAngle,
                      child: const _RightAngleBox(size: 25, thiccness: 4),
                    ),
                  ],
                ),
              ),
            ),
            Fader(
              linesVisible,
              child: Transform.rotate(
                angle: -2 * pi * (guess - 90) / 360,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Transform.translate(
                      offset: const Offset(0, -37),
                      child: Icon(
                        Icons.arrow_drop_down,
                        size: 50,
                        color: SuperColor.hue(guess),
                      )),
                ),
              ),
            ),
            Fader(
              showRightAngle,
              child: Align(
                alignment: const Alignment(0.2, -0.2),
                child: Text(
                  '$hue°',
                  style: const TextStyle(
                    fontSize: 28,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RightAngleBox extends StatelessWidget {
  const _RightAngleBox({required this.size, required this.thiccness});
  final double size, thiccness;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(-thiccness / 2, -(size - thiccness / 2)),
      child: SuperContainer(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: thiccness),
        ),
        width: size,
        height: size,
      ),
    );
  }
}
