import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:super_hueman/save_data.dart';
import 'package:super_hueman/structs.dart';

const Widget empty = SizedBox.shrink();

class FixedSpacer extends StatelessWidget {
  final double size;
  final bool horizontal;
  const FixedSpacer(this.size, {super.key}) : horizontal = false;
  const FixedSpacer.horizontal(this.size, {super.key}) : horizontal = true;

  @override
  Widget build(BuildContext context) =>
      horizontal ? SizedBox(width: size) : SizedBox(height: size);
}

class ContinueButton extends StatelessWidget {
  final void Function() onPressed;
  const ContinueButton({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 50,
        height: 50,
        child: Stack(
          children: [
            const Center(child: Icon(Icons.arrow_forward)),
            Center(
              child: SizedBox(
                width: 50,
                height: 50,
                child: OutlinedButton(
                  onPressed: onPressed,
                  child: empty,
                ),
              ),
            ),
          ],
        ),
      );
}

class SuperButton extends StatelessWidget {
  final String label;
  final void Function() onPressed;
  final Color color;
  final EdgeInsets? padding;
  const SuperButton(
    this.label, {
    required this.color,
    required this.onPressed,
    this.padding,
    super.key,
  });

  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: inverted ? Colors.white : Colors.black,
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.only(bottom: 4),
          child: Text(label, style: const TextStyle(fontSize: 24)),
        ),
      );
}

class NavigateButton extends StatelessWidget {
  final Pages page;
  final Color color;
  final EdgeInsets? padding;
  const NavigateButton(this.page, {required this.color, this.padding, super.key});

  @override
  Widget build(BuildContext context) => SuperButton(
        page(),
        color: color,
        onPressed: () => context.goto(page),
        padding: padding,
      );
}

class MenuCheckbox extends StatelessWidget {
  final ValueChanged<bool> toggle;
  final bool value;
  final String label;
  final (String, String) description;
  const MenuCheckbox(
    this.label, {
    required this.description,
    required this.value,
    required this.toggle,
    super.key,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => toggle(!value),
        child: Container(
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
  final String text;
  const GoBack({this.text = 'back', super.key});

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
  final SuperColor color;
  final Color backgroundColor;
  const ColorNameBox(this.color, {super.key}) : backgroundColor = Colors.black38;
  const ColorNameBox.trivial(this.color, {super.key})
      : backgroundColor = SuperColors.darkBackground;

  @override
  Widget build(BuildContext context) => Container(
        decoration:
            BoxDecoration(border: Border.all(color: color, width: 4), color: backgroundColor),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            color.name,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      );
}

class ManualColorCode extends StatefulWidget {
  final SuperColor color;
  const ManualColorCode(this.color, {super.key});

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
              Container(
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
