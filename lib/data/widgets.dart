import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:hueman/data/page_data.dart';
import 'package:hueman/data/save_data.dart';
import 'package:hueman/data/structs.dart';
import 'package:hueman/data/super_color.dart';
import 'package:hueman/data/super_state.dart';
import 'package:hueman/data/super_text.dart';
import 'package:rive/rive.dart' as rive;
import 'package:url_launcher/url_launcher_string.dart';

const Widget empty = SizedBox.shrink();
const Widget emptyContainer = LimitedBox(
  maxWidth: 0,
  maxHeight: 0,
  child: SizedBox.expand(),
);
const Widget flat = SizedBox(width: double.infinity);

/// It's extremely useful knowing the maximum width/height inside a [SafeArea],
/// and [LayoutBuilder] is the only good way to do it.
///
/// This class combines the two, so there's less boilerplate.
class SafeLayout extends StatelessWidget {
  const SafeLayout(this.builder, {super.key, this.top = true, this.bottom = true});
  final Widget Function(BuildContext context, BoxConstraints constraints) builder;
  final bool top, bottom;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: top,
      bottom: bottom,
      child: LayoutBuilder(builder: builder),
    );
  }
}

/// Used in [Row]s and [Column]s that are set to [MainAxisSize.min]
/// to add spacing between elements.
class FixedSpacer extends SingleChildRenderObjectWidget {
  const FixedSpacer(this.size, {super.key});

  /// A non-`const` constructor, for use in situations where the flex direction
  /// switches back & forth.
  @factory
  static Widget dynamic(double size) => FixedSpacer(size, key: UniqueKey());

  final double size;

  BoxConstraints _constraints(BuildContext context) {
    Axis axis = Axis.vertical;
    context.visitAncestorElements((element) {
      if (element.widget case Flex(:final direction)) {
        axis = direction;
        return false;
      }
      return true;
    });

    return switch (axis) {
      Axis.horizontal => BoxConstraints.tightFor(width: size),
      Axis.vertical => BoxConstraints.tightFor(height: size),
    };
  }

  @override
  RenderConstrainedBox createRenderObject(BuildContext context) {
    return RenderConstrainedBox(additionalConstraints: _constraints(context));
  }

  @override
  void updateRenderObject(BuildContext context, RenderConstrainedBox renderObject) {
    renderObject.additionalConstraints = _constraints(context);
  }
}

class Fader extends AnimatedOpacity {
  /// There's a whole lot of [AnimatedOpacity] in this app
  /// that just alternates between fully opaque and fully transparent
  /// with a 1-second duration.
  ///
  /// So this class makes it easy.
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
  /// Makes the child widget smoothly fade in instead of just appearing.
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

class _FadeInState extends State<FadeIn> with SingleTickerProviderStateMixin {
  late final animation = AnimationController(
    vsync: this,
  )..animateTo(1.0, duration: widget.duration, curve: widget.curve);

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: animation, child: widget.child);
  }
}

class SlideItIn extends StatelessWidget {
  /// Similar to [FadeIn], but instead it slides from off the screen.
  const SlideItIn(
    this.isItInYet, {
    super.key,
    this.duration = oneSec,
    this.curve = Curves.easeOutExpo,
    required this.direction,
    required this.child,
  });
  final bool isItInYet;
  final Duration duration;
  final Curve curve;
  final AxisDirection direction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: switch (direction) {
        _ when isItInYet => Offset.zero,
        AxisDirection.up => const Offset(0, 10),
        AxisDirection.down => const Offset(0, -10),
        AxisDirection.left => const Offset(-10, 0),
        AxisDirection.right => const Offset(10, 0),
      },
      duration: duration,
      curve: curve,
      child: child,
    );
  }
}

class SexyBox extends AnimatedSize {
  /// very slick size change animation :)
  const SexyBox({super.child, super.key}) : super(duration: oneSec, curve: Curves.easeInOutQuart);
}

/// spam-clicking buttons can sometimes crash the app, so this is a handy mixin.
mixin SinglePress {
  bool pressed = false;

  VoidCallback singlePress(VoidCallback? onPressed, {bool noDelay = false}) => () {
        if (pressed) return;
        pressed = true;
        Future.delayed(noDelay ? Duration.zero : halfSec, onPressed);
      };
}

class ContinueButton extends StatefulWidget {
  /// Circular button with an arrow pointing right.
  ///
  /// It's used a whole lot throughout the tutorials.
  const ContinueButton({required this.onPressed, super.key});

  final void Function()? onPressed;

  @override
  State<ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<ContinueButton> with SinglePress {
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white;
    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        children: [
          const Center(child: Icon(Icons.arrow_forward)),
          SizedBox.expand(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color, width: 2),
              ),
              onPressed: singlePress(widget.onPressed),
              child: empty,
            ),
          ),
        ],
      ),
    );
  }
}

class BrandNew extends StatelessWidget {
  /// Gives a fun little "new!" tag next to things you haven't seen yet.
  const BrandNew({super.key, required this.child, required this.color, this.text = 'new!'});

  final SuperColor color;
  final Widget child;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        child,
        Transform.translate(
          offset: Offset(text == 'new!' ? 40 : 55, 0),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: SuperStyle.sans(
              color: color,
              lowercaseHeight: 540,
              height: 0,
              shadows: [
                for (double i = 0; i < 5; i++)
                  Shadow(color: inverted ? Colors.white : Colors.black, blurRadius: i),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SuperButton extends StatefulWidget {
  /// Colorful buttons that show up in the main menu
  /// and a few other places.
  const SuperButton(
    this.label, {
    super.key,
    required this.color,
    required this.onPressed,
    this.padding,
    this.isNew = false,
    this.noDelay = false,
    this.further = false,
  });

  final String label;
  final void Function() onPressed;
  final SuperColor color;
  final EdgeInsets? padding;
  final bool isNew, noDelay, further;

  @override
  State<SuperButton> createState() => _SuperButtonState();
}

class _SuperButtonState extends State<SuperButton> with SinglePress {
  @override
  Widget build(BuildContext context) {
    final contrasted = inverted ? Colors.white : Colors.black;
    final button = ElevatedButton(
      onPressed: singlePress(widget.onPressed, noDelay: widget.noDelay),
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.further ? contrasted : widget.color,
        foregroundColor: widget.further ? widget.color : contrasted,
      ),
      child: Padding(
        padding: widget.padding ?? const EdgeInsets.only(bottom: 2),
        child: Text(
          widget.label,
          style: const SuperStyle.sans(
            size: 24,
            weight: 350,
            extraBold: true,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
    if (widget.isNew) return BrandNew(color: widget.color, child: button);
    if (widget.label == 'intro' && casualMode && !Tutorial.casual()) {
      return BrandNew(color: widget.color, text: 'casual\nmode', child: button);
    }
    return button;
  }
}

class NavigateButton extends StatelessWidget {
  /// The [page] member determines both the button's text and its functionality.
  const NavigateButton(
    this.page, {
    super.key,
    required this.color,
    this.padding,
    this.isNew = false,
    this.noDelay = false,
    this.further = false,
  });

  final Pages page;
  final SuperColor color;
  final EdgeInsets? padding;
  final bool isNew, noDelay, further;

  @override
  Widget build(BuildContext context) {
    return SuperButton(
      page(),
      color: color,
      onPressed: () => context.goto(page),
      padding: padding,
      isNew: isNew,
      noDelay: noDelay,
      further: further,
    );
  }
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => toggle(!value),
      child: ColoredBox(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  // checkbox size is constrained since different platforms lack consistency
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: value,
                    onChanged: (_) => toggle(!value),
                  ),
                ),
                const FixedSpacer(10),
                Text(
                  label,
                  style: const SuperStyle.sans(size: 17),
                ),
              ],
            ),
            Text(
              value ? description.$1 : description.$2,
              style: const SuperStyle.sans(size: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class DismissibleDialog extends StatelessWidget {
  /// lets you tap either inside or outside the dialog to dismiss it.
  const DismissibleDialog({
    super.key,
    required this.title,
    required this.content,
    this.backgroundColor,
    this.surfaceTintColor,
  });

  final Widget title, content;
  final Color? backgroundColor, surfaceTintColor;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        colorScheme: inverted ? null : const ColorScheme.dark(primary: Colors.white),
        brightness: inverted ? Brightness.light : Brightness.dark,
        dialogTheme: DialogThemeData(backgroundColor: backgroundColor),
      ),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: AlertDialog(
          title: title,
          content: content,
          surfaceTintColor: surfaceTintColor,
        ),
      ),
    );
  }
}

class FeedbackButton extends StatelessWidget {
  const FeedbackButton(this.color, {super.key});
  final SuperColor color;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => launchUrlString('https://forms.gle/G2yTa9xMygg913ZU8'),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color, width: 2),
        foregroundColor: color,
      ),
      child: const Padding(
        padding: EdgeInsets.fromLTRB(0, 6, 0, 8),
        child: Text('send feedback', style: SuperStyle.sans(size: 18, width: 87.5)),
      ),
    );
  }
}

class WarnButton extends StatelessWidget {
  const WarnButton({this.action, super.key});

  final VoidCallback? action;

  @override
  Widget build(BuildContext context) {
    final bool proceed = action != null;

    return SizedBox(
      height: 33,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: inverted ? const Color(0x10000000) : const Color(0x10FFFFFF),
          foregroundColor: inverted ? Colors.black : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 15),
        ),
        onPressed: () {
          Navigator.pop(context);
          if (proceed) action!();
        },
        child: Text(
          proceed ? 'continue' : 'go back',
          style: const SuperStyle.sans(size: 16, height: 2),
        ),
      ),
    );
  }
}

class GoBack extends StatelessWidget {
  /// takes you back to the menu.
  const GoBack({super.key, this.text = 'back'});

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 33,
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: inverted ? SuperColors.black80 : Colors.white60,
          backgroundColor: inverted ? Colors.white54 : const SuperColor(0x0D0D0D),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onPressed: context.menu,
        child: Text(
          text,
          style: SuperStyle.sans(
            weight: inverted ? 300 : 100,
            width: 96,
            size: 16,
            letterSpacing: 0.5,
            height: 2,
          ),
        ),
      ),
    );
  }
}

class JustKidding extends StatelessWidget {
  /// used in 2 different places :)
  const JustKidding(
    this.text, {
    super.key,
    required this.buttonVisible,
    required this.color,
    required this.onPressed,
  });

  final bool buttonVisible;
  final SuperColor color;
  final VoidCallback onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      duration: quarterSec,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            children: [
              const Spacer(),
              const Text(
                'just kidding  :)',
                style: SuperStyle.sans(size: 24, weight: 200),
              ),
              const Spacer(flex: 3),
              Fader(
                buttonVisible,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: color,
                        side: BorderSide(color: color, width: 2),
                        shadowColor: color,
                        elevation: epicSine * 8,
                      ),
                      onPressed: onPressed,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
                        child: Text(
                          text,
                          style: const SuperStyle.sans(size: 48, weight: 750),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class ColorNameBox extends StatelessWidget {
  const ColorNameBox(this.color, {super.key}) : backgroundColor = Colors.black38;

  const ColorNameBox.trivial(this.color, {super.key})
      : backgroundColor = SuperColors.darkBackground;

  final SuperColor color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 4),
        color: backgroundColor,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 9),
        child: Text(
          color.name,
          style: SuperStyle.sans(color: color, weight: 800, size: 16),
        ),
      ),
    );
  }
}

class ColorLabel extends StatelessWidget {
  const ColorLabel(this.property, this.value, {this.style, super.key})
      : colorCode = false,
        update = null;

  const ColorLabel.colorCode(
    this.property,
    this.value,
    ValueChanged<SuperColor> updateColorCode, {
    super.key,
  })  : style = null,
        colorCode = true,
        update = updateColorCode;

  final String property, value;
  final SuperStyle? style;
  final ValueChanged<SuperColor>? update;
  final bool colorCode;

  @override
  Widget build(BuildContext context) {
    const SuperStyle defaultStyle = SuperStyle.sans(size: 16);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 100,
            child: Text('$property:', style: defaultStyle, textAlign: TextAlign.right),
          ),
          if (colorCode)
            SizedBox(
              height: 33,
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: inverted ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                ),
                onPressed: () => ManualColorCode.run(
                  context,
                  color: SuperColor(int.parse(value.substring(1), radix: 16)),
                  updateColor: update!,
                ),
                child: Text(value, style: const SuperStyle.mono(size: 18)),
              ),
            )
          else ...[
            const FixedSpacer(15),
            Text(value, style: style ?? defaultStyle),
          ],
        ],
      ),
    );
  }
}

/// Used in "sandbox" and "true mastery" so you can type in a color code.
class ManualColorCode extends StatefulWidget {
  const ManualColorCode(this.color, {super.key});

  final SuperColor color;

  static Future<void> run(
    BuildContext context, {
    required SuperColor color,
    required void Function(SuperColor) updateColor,
  }) async {
    final value = await showDialog<String>(
      context: context,
      builder: (context) => ManualColorCode(color),
    );
    if (value == null) return;
    if (value.length == 6) {
      final int colorCode = int.parse(value, radix: 16);
      updateColor(SuperColor(colorCode));
      if (colorCode == 0x8080FF) sfx.play('k_color');
    } else if (value.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('invalid hex code: $value')),
      );
    }
  }

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
    (oldValue, newValue) => newValue.text.length > 6 ? oldValue : newValue,
  );

  @override
  void initState() {
    super.initState();
    focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        fontFamily: 'nunito sans',
        colorScheme: ColorScheme(
          brightness: inverted ? Brightness.light : Brightness.dark,
          primary: widget.color,
          onPrimary: widget.color,
          secondary: widget.color,
          onSecondary: widget.color,
          error: widget.color,
          onError: widget.color,
          surface: inverted ? Colors.black : Colors.white,
          onSurface: inverted ? Colors.black : Colors.white,
        ),
      ),
      child: AlertDialog(
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'enter color code',
          style: SuperStyle.sans(weight: 200, extraBold: true, width: 96, letterSpacing: 1 / 3),
        ),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ColoredBox(
              color: inverted ? const Color(0x08000000) : const Color(0x08FFFFFF),
              child: SizedBox(
                width: 167,
                child: TextField(
                  focusNode: focusNode,
                  style: const SuperStyle.mono(),
                  textAlign: TextAlign.center,
                  cursorColor: inverted ? Colors.black : Colors.white,
                  controller: controller,
                  onSubmitted: (_) => popText(),
                  inputFormatters: [onlyHexChars, maxLength6],
                ),
              ),
            ),
            const FixedSpacer(10),
            IconButton(
              onPressed: popText,
              icon: const Icon(Icons.check),
            ),
          ],
        ),
      ),
    );
  }
}

/// ```dart
///
/// ColorTextSpan.red
/// ```
/// is the word "red" in bold red text.
class ColorTextSpan extends TextSpan {
  const ColorTextSpan(this.color, {this.fontWeight = 600});
  final SuperColor color;
  final double fontWeight;

  @override
  String get text => color.name;

  @override
  SuperStyle get style => SuperStyle.sans(color: color, weight: fontWeight);

  static const red = ColorTextSpan(SuperColors.red);
  static const green = ColorTextSpan(SuperColors.green);
  static const blue = ColorTextSpan(SuperColors.blue);
  static const visibleBlue = ColorTextSpan(SuperColors.visibleBlue);
  static ColorTextSpan get flexibleBlue => inverted ? blue : visibleBlue;

  static const cyan = ColorTextSpan(SuperColors.cyan);
  static const magenta = ColorTextSpan(SuperColors.magenta);
  static const yellow = ColorTextSpan(SuperColors.yellow);
  static const orange = ColorTextSpan(SuperColors.orange);
  static const azure = ColorTextSpan(SuperColors.azure);
}

class Rive extends StatelessWidget {
  const Rive({super.key, required this.name, required this.controllers, this.artboard});

  final String name;
  final String? artboard;
  final List<rive.RiveAnimationController<dynamic>> controllers;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints.loose(Size.fromWidth(context.screenHeight * 2 / 3)),
        child: rive.RiveAnimation.asset(
          'assets/animations/$name.riv',
          fit: BoxFit.cover,
          artboard: artboard,
          controllers: controllers,
        ),
      ),
    );
  }
}

// ignore: camel_case_types, stylistic choice :)
class K_glitch extends StatefulWidget {
  /// K
  const K_glitch({super.key}) : theEnd = false;
  const K_glitch.destroyer({super.key}) : theEnd = true;

  final bool theEnd;

  @override
  State<K_glitch> createState() => _KGlitchState();
}

class _KGlitchState extends SuperState<K_glitch> {
  double opacity = 0;
  bool glitched = false;
  String get filename => glitched ? 'glitched' : 'art';

  /// sets opacity; negative values make it look 'glitched'
  void newOpacity(double? o) {
    if (o == null) return;
    setState(() {
      opacity = o.abs();
      glitched = o.isNegative;
    });
  }

  int counter = 0;
  late final Ticker ticker = Ticker(tick);

  void tick(_) {
    counter++;
    newOpacity(switch (counter) {
      30 => 2 / 3,
      33 => 0,
      40 => -0.5,
      42 => -1,
      44 => 0,
      > 66 && < 120 => -2 / 3 * rng.nextDouble(),
      120 => 1,
      _ => null,
    });

    if (counter == 150 && !widget.theEnd) newOpacity(0.02);
  }

  @override
  void animate() async {
    if (!widget.theEnd) {
      ticker.start();
      return;
    }

    Tutorial.worldEnd.complete();
    await sleep(4);
    ticker.start();
    await sleep(3.33);
    exit(0);
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Image.asset('assets/k_$filename.png'),
        ),
      ),
    );
  }
}

/// The fun spinny circle that shows up after you submit a hue.
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

    final Widget line = SizedBox(
      width: double.infinity,
      height: 4,
      child: ColoredBox(color: lineColor),
    );

    return Fader(
      visible,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: SizedBox(
          width: width + 2,
          height: width,
          child: Stack(
            children: [
              const Positioned.fill(child: DecoratedBox(decoration: SuperColors.colorWheel)),
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
                      ),
                    ),
                  ),
                ),
              ),
              Fader(
                showRightAngle,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 60, left: 80),
                    child: Text(
                      '$hue°',
                      style: const SuperStyle.sans(
                        size: 24,
                        color: Colors.black,
                        weight: 800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Used when measuring "chartreuse" for the first time.
class _RightAngleBox extends StatelessWidget {
  const _RightAngleBox({required this.size, required this.thiccness});

  final double size, thiccness;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(-thiccness / 2, -(size - thiccness / 2)),
      child: DecoratedBox(
        decoration: BoxDecoration(border: Border.all(width: thiccness)),
        child: SizedBox.square(dimension: size),
      ),
    );
  }
}

class Flicker extends StatelessWidget {
  const Flicker(this.flickerValue, this.color, {super.key});

  final bool flickerValue;
  final SuperColor color;

  @override
  Widget build(BuildContext context) {
    final color2 = inverted ? SuperColors.lightBackground : SuperColors.bsBackground;
    return Align(
      alignment: const Alignment(1, -0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Spacer(flex: 2),
          SizedBox(
            width: context.screenWidth,
            height: 1,
            child: ColoredBox(color: color),
          ),
          SizedBox(
            width: context.screenWidth * .75,
            height: 2,
            child: ColoredBox(color: color),
          ),
          const FixedSpacer(4),
          SizedBox(
            width: double.infinity,
            height: 25,
            child: flickerValue ? ColoredBox(color: color) : null,
          ),
          const FixedSpacer(3),
          SizedBox(
            width: context.screenWidth / 2,
            height: 2,
            child: ColoredBox(color: color),
          ),
          const FixedSpacer(10),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(color: color2, width: 300),
              ),
            ),
            child: const SizedBox(width: 40, height: 5),
          ),
          SizedBox(
            width: context.screenWidth / 2,
            height: 3,
            child: ColoredBox(color: color2),
          ),
          const FixedSpacer(10),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(color: color2, width: 250),
              ),
            ),
            child: const SizedBox(width: 80, height: 3),
          ),
          Expanded(
            flex: 3,
            child: FittedBox(
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (int row = 0; row < 15; row++)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int i = 0; i < 33; i++)
                          SizedBox(
                            width: 10,
                            height: 10,
                            child: ColoredBox(
                              color: switch ((i + row) % 2) {
                                _ when i < row - 5 => Colors.transparent,
                                0 when rng.nextBool() && rng.nextBool() =>
                                  SuperColors.darkBackground,
                                1 when rng.nextBool() && rng.nextBool() => color2,
                                0 => color,
                                _ => Colors.transparent,
                              },
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
