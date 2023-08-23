import 'package:flutter/material.dart';
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


// START


