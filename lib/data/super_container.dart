/// [Container], but with a `const` constructor!
///
/// I made a pull request to update the official Container, sadly it did not go well lol
///
/// https://github.com/flutter/flutter/pull/134605

import 'package:flutter/material.dart';

class _DynamicBox extends StatelessWidget {
  const _DynamicBox(this.config, {required this.child});

  final dynamic config;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return switch (config) {
      null || (null, null) || (null, null, null) || (null, Clip.none) => child,
      final EdgeInsets p => Padding(padding: p, child: child),
      (final double? w, final double? h, null) => SizedBox(width: w, height: h, child: child),
      (final double? w, final double? h, final BoxConstraints c) => ConstrainedBox(
          constraints: (w != null || h != null) ? c.tighten(width: w, height: h) : c,
          child: child,
        ),
      final Color c => ColoredBox(color: c, child: child),
      (final Decoration d, Clip.none) => DecoratedBox(decoration: d, child: child),
      (final Decoration d, final Clip c) => DecoratedBox(
          decoration: d,
          child: ClipPath(
            clipper: _DecorationClipper(
              textDirection: Directionality.maybeOf(context),
              decoration: d,
            ),
            clipBehavior: c,
            child: child,
          ),
        ),
      final Alignment a => Align(alignment: a, child: child),
      (final Matrix4 t, final AlignmentGeometry? a) =>
        Transform(transform: t, alignment: a, child: child),
      _ => throw Exception('problem with config type ${config.runtimeType}'),
    };
  }
}

class SuperContainer extends StatelessWidget {
  const SuperContainer({
    super.key,
    this.alignment,
    this.padding,
    this.color,
    this.decoration,
    this.foregroundDecoration,
    this.width,
    this.height,
    this.constraints,
    this.margin,
    this.transform,
    this.transformAlignment,
    this.child,
    this.clipBehavior = Clip.none,
  });

  final Widget? child;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Decoration? decoration;
  final Decoration? foregroundDecoration;
  final double? width, height;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry? margin;
  final Matrix4? transform;
  final AlignmentGeometry? transformAlignment;
  final Clip clipBehavior;

  EdgeInsetsGeometry? get _paddingIncludingDecoration => switch ((decoration?.padding, padding)) {
        (null, final pad) || (final pad, null) => pad,
        (final deco, final pad) => pad!.add(deco!),
      };

  Widget get _child {
    if (child != null) {
      return _DynamicBox(alignment, child: child!);
    }
    if (constraints?.isTight ?? true) {
      return const LimitedBox(
        maxWidth: 0.0,
        maxHeight: 0.0,
        child: SizedBox.expand(),
      );
    }
    return const SizedBox.shrink();
  }

  List<dynamic> get _layers => [
        _paddingIncludingDecoration,
        (decoration, clipBehavior),
        foregroundDecoration,
        color,
        (width, height, constraints),
        margin,
        (transform, transformAlignment),
      ];

  @override
  Widget build(BuildContext context) {
    Widget current = _child;

    for (final layer in _layers) {
      current = _DynamicBox(layer, child: current);
    }
    return current;
  }
}

class _DecorationClipper extends CustomClipper<Path> {
  _DecorationClipper({
    TextDirection? textDirection,
    required this.decoration,
  }) : textDirection = textDirection ?? TextDirection.ltr;

  final TextDirection textDirection;
  final Decoration decoration;

  @override
  Path getClip(Size size) => decoration.getClipPath(Offset.zero & size, textDirection);

  @override
  bool shouldReclip(_DecorationClipper oldClipper) =>
      oldClipper.decoration != decoration || oldClipper.textDirection != textDirection;
}
