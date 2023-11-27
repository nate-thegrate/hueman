import 'dart:io';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hueman/data/save_data.dart';
import 'package:hueman/data/structs.dart';
import 'package:hueman/data/super_color.dart';
import 'package:hueman/data/super_state.dart';

enum FontFamily { sans, mono, gaegu }

class SuperStyle extends TextStyle {
  /// ```
  /// ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
  /// ███▀▀▄▄▄▄▄▄▄▄▄▀▀███
  /// ██ █████████████ ██
  /// █ ███████████████ █
  /// █ ██████████   ██ █
  /// █▄▀█▄▄▄█▀ ▀█▄▄▄█▀▄█
  /// █ ▄█ ▀▀▀▀▀▀▀▀▀ █▄ █
  /// █▄▀▀█▄▀ ▀ ▀ ▀▄█▀▀▄█
  /// ████▄▄▀▀▀▀▀▀▀▄▄████
  /// ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
  /// ```
  /// (not comic sans)
  const SuperStyle.sans({
    double? size,
    bool italic = false,
    bool extraBold = false,
    this.weight = 400,
    this.width = 100,
    this.lowercaseHeight = 500,
    this.opticalSize = true,
    super.inherit,
    super.color,
    super.backgroundColor,
    super.letterSpacing,
    super.wordSpacing,
    super.textBaseline,
    super.height,
    super.leadingDistribution,
    super.locale,
    super.foreground,
    super.background,
    super.shadows,
    super.decoration,
    super.decorationColor,
    super.decorationStyle,
    super.decorationThickness,
    super.debugLabel,
    super.overflow,
  })  : family = FontFamily.sans,
        super(
          fontSize: size,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          fontFamily: 'nunito sans',
          fontWeight: extraBold ? FontWeight.bold : FontWeight.normal,
        );
  const SuperStyle.mono({
    double? size,
    bool italic = false,
    bool extraBold = false,
    this.weight = 400,
    this.opticalSize = true,
    super.inherit,
    super.color,
    super.backgroundColor,
    super.letterSpacing,
    super.wordSpacing,
    super.textBaseline,
    super.height,
    super.leadingDistribution,
    super.locale,
    super.foreground,
    super.background,
    super.shadows,
    super.decoration,
    super.decorationColor,
    super.decorationStyle,
    super.decorationThickness,
    super.debugLabel,
    super.package,
    super.overflow,
  })  : family = FontFamily.mono,
        width = 0,
        lowercaseHeight = 0,
        super(
          fontSize: size,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          fontFamily: 'sometype mono',
          fontWeight: extraBold ? FontWeight.bold : FontWeight.normal,
        );
  const SuperStyle.gaegu({
    double size = 24,
    bool italic = false,
    FontWeight? weight,
    this.opticalSize = true,
    super.inherit,
    super.color,
    super.backgroundColor,
    super.letterSpacing,
    super.wordSpacing,
    super.textBaseline,
    super.height,
    super.leadingDistribution,
    super.locale,
    super.foreground,
    super.background,
    super.shadows,
    super.decoration,
    super.decorationColor,
    super.decorationStyle,
    super.decorationThickness,
    super.debugLabel,
    super.package,
    super.overflow,
  })  : family = FontFamily.gaegu,
        weight = 0,
        width = 0,
        lowercaseHeight = 0,
        super(
          fontSize: size,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          fontFamily: 'gaegu',
          fontWeight: weight,
        );

  final FontFamily family;
  final bool opticalSize;

  /// ```
  ///
  ///  sans: 200 - 1000
  ///  mono: 400 - 700
  /// gaegu: w300, w400, w700
  /// ```
  final double weight;

  /// 75 - 125
  final double width;

  /// 440 - 540
  final double lowercaseHeight;

  @override
  List<FontFeature>? get fontFeatures => switch (family) {
        FontFamily.sans => [FontFeature('opsz', opticalSize ? 100 : 0)],
        FontFamily.mono || FontFamily.gaegu => null,
      };

  @override
  List<FontVariation>? get fontVariations => switch (family) {
        FontFamily.sans => [
            FontVariation('wght', weight),
            FontVariation('wdth', width),
            FontVariation('YTLC', lowercaseHeight),
          ],
        FontFamily.mono => [FontVariation('wght', weight)],
        FontFamily.gaegu => null,
      };
}

class SuperText extends StatelessWidget {
  const SuperText(
    this.data, {
    super.key,
    this.style = const SuperStyle.sans(size: 20),
    this.pad = true,
  });
  final String data;
  final SuperStyle style;
  final bool pad;

  @override
  Widget build(BuildContext context) {
    final text = Text(data, textAlign: TextAlign.center, style: style);

    if (!pad) return text;
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: text);
  }
}

class SuperRichText extends StatelessWidget {
  const SuperRichText(
    this.children, {
    super.key,
    this.style = const SuperStyle.sans(size: 20),
    this.align = TextAlign.center,
    this.pad = true,
  });
  final List<TextSpan> children;
  final SuperStyle style;
  final TextAlign align;
  final bool pad;

  @override
  Widget build(BuildContext context) {
    final text = Text.rich(
      TextSpan(children: children),
      textAlign: align,
      style: style,
    );
    if (!pad) return text;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: text,
    );
  }
}

GestureRecognizer hyperlink(String url) => TapGestureRecognizer()..onTap = () => gotoWebsite(url);
const linkStyle = SuperStyle.sans(
  extraBold: true,
  color: SuperColors.azure,
  decoration: TextDecoration.underline,
  decorationColor: SuperColors.azure,
);

class SuperHUEman extends StatefulWidget {
  /// The majestic game logo.
  const SuperHUEman(this.color, {super.key});
  final SuperColor color;

  @override
  State<SuperHUEman> createState() => _SuperHUEmanState();
}

class _SuperHUEmanState extends SuperState<SuperHUEman> {
  late final Ticker? ticker;
  late double weight;

  @override
  void animate() async {
    const double startWeight = 200, endWeight = 800;
    if (booted || Platform.isIOS) {
      weight = endWeight;
      ticker = null;
    } else {
      weight = startWeight;
      await sleep(1);
      ticker = Ticker((elapsed) {
        setState(() => weight += 7500 ~/ weight);
        if (weight >= endWeight) ticker?.stop();
      })
        ..start();
    }
  }

  @override
  void dispose() {
    ticker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double size = 30;
    const space = TextSpan(text: ' ', style: SuperStyle.sans(size: 1));
    return SuperRichText(
      style: const SuperStyle.sans(size: size, weight: 250),
      [
        const TextSpan(text: 'super'),
        space,
        TextSpan(
          text: 'HUE',
          style: SuperStyle.sans(size: size * 0.7, color: widget.color, weight: weight),
        ),
        space,
        const TextSpan(text: 'man'),
      ],
    );
  }
}
