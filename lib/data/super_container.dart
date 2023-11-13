/// [Container], but with a `const` constructor!
///
/// I made a pull request to update the official Container, sadly it did not go well lol
///
/// https://github.com/flutter/flutter/pull/134605
library;

import 'package:flutter/material.dart';

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
  })  : assert(decoration != null || clipBehavior == Clip.none),
        assert(
          color == null || decoration == null,
          'Cannot provide both a color and a decoration\n'
          'To provide both, use "decoration: BoxDecoration(color: color)".',
        );

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

  BoxConstraints? get _constraints => switch ((width, height, constraints)) {
        (null, null, _) => constraints,
        (_, _, null) => BoxConstraints.tightFor(width: width, height: height),
        _ => constraints!.tighten(width: width, height: height),
      };

  EdgeInsetsGeometry? get _paddingIncludingDecoration => switch ((decoration?.padding, padding)) {
        (null, final EdgeInsetsGeometry? padding) ||
        (final EdgeInsetsGeometry? padding, null) =>
          padding,
        _ => padding!.add(decoration!.padding),
      };

  @override
  Widget build(BuildContext context) {
    Widget? current = child;

    if (child == null && (constraints == null || !constraints!.isTight)) {
      current = const LimitedBox(
        maxWidth: 0.0,
        maxHeight: 0.0,
        child: SizedBox.expand(),
      );
    } else if (alignment != null) {
      current = Align(alignment: alignment!, child: current);
    }

    assert(padding == null || padding!.isNonNegative);
    final EdgeInsetsGeometry? effectivePadding = _paddingIncludingDecoration;
    if (effectivePadding != null) {
      current = Padding(padding: effectivePadding, child: current);
    }

    if (color != null) {
      current = ColoredBox(color: color!, child: current);
    }

    if (clipBehavior != Clip.none) {
      assert(decoration != null);
      current = ClipPath(
        clipper: _DecorationClipper(
          textDirection: Directionality.maybeOf(context),
          decoration: decoration!,
        ),
        clipBehavior: clipBehavior,
        child: current,
      );
    }

    if (decoration != null) {
      assert(decoration!.debugAssertIsValid());
      current = DecoratedBox(decoration: decoration!, child: current);
    }

    if (foregroundDecoration != null) {
      current = DecoratedBox(
        decoration: foregroundDecoration!,
        position: DecorationPosition.foreground,
        child: current,
      );
    }

    final BoxConstraints? effectiveConstraints = _constraints;
    if (effectiveConstraints != null) {
      assert(effectiveConstraints.debugAssertIsValid());
      current = ConstrainedBox(constraints: effectiveConstraints, child: current);
    }

    if (margin != null) {
      assert(margin!.isNonNegative);
      current = Padding(padding: margin!, child: current);
    }

    if (transform != null) {
      current = Transform(transform: transform!, alignment: transformAlignment, child: current);
    }

    return current!;
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
