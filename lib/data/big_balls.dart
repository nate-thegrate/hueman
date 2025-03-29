import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hueman/data/structs.dart';
import 'package:hueman/data/super_color.dart';
import 'package:hueman/data/super_state.dart';
import 'package:hueman/data/widgets.dart';

class Balls extends StatefulWidget {
  /// big and blurry.
  ///
  /// (used in the "even further" page.)
  const Balls({super.key})
      : colors = SuperColors.epic,
        cycleSeconds = 6;

  /// big. blurry. black.
  ///
  /// (used during the "true mastery" tutorial)
  const Balls.bigAndBlack({super.key})
      : colors = const [
          SuperColor(0x3E0000),
          SuperColor(0x3D0100),
          SuperColor(0x3C0200),
          SuperColor(0x3C0300),
          SuperColor(0x3B0400),
          SuperColor(0x3A0500),
          SuperColor(0x390600),
          SuperColor(0x390700),
          SuperColor(0x380700),
          SuperColor(0x380800),
          SuperColor(0x370900),
          SuperColor(0x360A00),
          SuperColor(0x360B00),
          SuperColor(0x350B00),
          SuperColor(0x350C00),
          SuperColor(0x340D00),
          SuperColor(0x330D00),
          SuperColor(0x330E00),
          SuperColor(0x320F00),
          SuperColor(0x311000),
          SuperColor(0x311000),
          SuperColor(0x2F1000),
          SuperColor(0x2F1100),
          SuperColor(0x2E1100),
          SuperColor(0x2E1200),
          SuperColor(0x2D1300),
          SuperColor(0x2C1300),
          SuperColor(0x2C1400),
          SuperColor(0x2B1400),
          SuperColor(0x2B1500),
          SuperColor(0x291500),
          SuperColor(0x291500),
          SuperColor(0x281500),
          SuperColor(0x271600),
          SuperColor(0x271600),
          SuperColor(0x271700),
          SuperColor(0x261700),
          SuperColor(0x251700),
          SuperColor(0x251700),
          SuperColor(0x241700),
          SuperColor(0x231700),
          SuperColor(0x231800),
          SuperColor(0x231800),
          SuperColor(0x221800),
          SuperColor(0x221900),
          SuperColor(0x211800),
          SuperColor(0x201900),
          SuperColor(0x201900),
          SuperColor(0x201900),
          SuperColor(0x1F1900),
          SuperColor(0x1F1A00),
          SuperColor(0x1E1A00),
          SuperColor(0x1E1A00),
          SuperColor(0x1E1A00),
          SuperColor(0x1E1B00),
          SuperColor(0x1D1B00),
          SuperColor(0x1D1B00),
          SuperColor(0x1C1B00),
          SuperColor(0x1C1B00),
          SuperColor(0x1B1B00),
          SuperColor(0x1B1B00),
          SuperColor(0x1A1B00),
          SuperColor(0x1A1B00),
          SuperColor(0x191B00),
          SuperColor(0x191B00),
          SuperColor(0x191C00),
          SuperColor(0x191C00),
          SuperColor(0x181C00),
          SuperColor(0x181C00),
          SuperColor(0x171C00),
          SuperColor(0x171C00),
          SuperColor(0x171C00),
          SuperColor(0x161C00),
          SuperColor(0x161C00),
          SuperColor(0x161C00),
          SuperColor(0x151D00),
          SuperColor(0x151D00),
          SuperColor(0x151D00),
          SuperColor(0x141D00),
          SuperColor(0x141D00),
          SuperColor(0x131D00),
          SuperColor(0x131D00),
          SuperColor(0x121D00),
          SuperColor(0x121D00),
          SuperColor(0x111D00),
          SuperColor(0x111E00),
          SuperColor(0x111E00),
          SuperColor(0x101E00),
          SuperColor(0x101E00),
          SuperColor(0x0F1E00),
          SuperColor(0x0F1E00),
          SuperColor(0x0E1E00),
          SuperColor(0x0E1E00),
          SuperColor(0x0D1E00),
          SuperColor(0x0D1E00),
          SuperColor(0x0C1E00),
          SuperColor(0x0C1E00),
          SuperColor(0x0C1E00),
          SuperColor(0x0B1F00),
          SuperColor(0x0B1F00),
          SuperColor(0x0A1F00),
          SuperColor(0x0A1F00),
          SuperColor(0x091F00),
          SuperColor(0x091F00),
          SuperColor(0x081F00),
          SuperColor(0x081F00),
          SuperColor(0x071F00),
          SuperColor(0x071F00),
          SuperColor(0x061F00),
          SuperColor(0x061F00),
          SuperColor(0x051F00),
          SuperColor(0x051F00),
          SuperColor(0x041F00),
          SuperColor(0x041F00),
          SuperColor(0x032000),
          SuperColor(0x032000),
          SuperColor(0x022000),
          SuperColor(0x022000),
          SuperColor(0x012000),
          SuperColor(0x012000),
          SuperColor(0x002000),
          SuperColor(0x002001),
          SuperColor(0x002001),
          SuperColor(0x002002),
          SuperColor(0x002002),
          SuperColor(0x002003),
          SuperColor(0x002003),
          SuperColor(0x002004),
          SuperColor(0x002004),
          SuperColor(0x002005),
          SuperColor(0x002005),
          SuperColor(0x002006),
          SuperColor(0x002006),
          SuperColor(0x002007),
          SuperColor(0x002007),
          SuperColor(0x002008),
          SuperColor(0x002008),
          SuperColor(0x002009),
          SuperColor(0x002009),
          SuperColor(0x001F0A),
          SuperColor(0x001F0A),
          SuperColor(0x001F0B),
          SuperColor(0x001F0B),
          SuperColor(0x001F0C),
          SuperColor(0x001F0C),
          SuperColor(0x001F0D),
          SuperColor(0x001F0D),
          SuperColor(0x001F0E),
          SuperColor(0x001F0E),
          SuperColor(0x001F0F),
          SuperColor(0x001F0F),
          SuperColor(0x001F10),
          SuperColor(0x001F10),
          SuperColor(0x001F11),
          SuperColor(0x001F11),
          SuperColor(0x001F12),
          SuperColor(0x001F12),
          SuperColor(0x001F13),
          SuperColor(0x001F13),
          SuperColor(0x001F14),
          SuperColor(0x001F14),
          SuperColor(0x001F15),
          SuperColor(0x001F15),
          SuperColor(0x001F16),
          SuperColor(0x001F16),
          SuperColor(0x001F17),
          SuperColor(0x001F17),
          SuperColor(0x001F18),
          SuperColor(0x001F19),
          SuperColor(0x001F19),
          SuperColor(0x001F1A),
          SuperColor(0x001E1A),
          SuperColor(0x001E1A),
          SuperColor(0x001E1A),
          SuperColor(0x001E1B),
          SuperColor(0x001E1B),
          SuperColor(0x001E1C),
          SuperColor(0x001E1C),
          SuperColor(0x001E1D),
          SuperColor(0x001E1D),
          SuperColor(0x001E1E),
          SuperColor(0x001E1E),
          SuperColor(0x001E1F),
          SuperColor(0x001E1F),
          SuperColor(0x001E20),
          SuperColor(0x001D20),
          SuperColor(0x001D21),
          SuperColor(0x001E22),
          SuperColor(0x001E22),
          SuperColor(0x001D23),
          SuperColor(0x001D23),
          SuperColor(0x001D23),
          SuperColor(0x001C24),
          SuperColor(0x001D25),
          SuperColor(0x001C25),
          SuperColor(0x001D26),
          SuperColor(0x001D27),
          SuperColor(0x001C28),
          SuperColor(0x001C29),
          SuperColor(0x001C2A),
          SuperColor(0x001C2B),
          SuperColor(0x001C2B),
          SuperColor(0x001C2C),
          SuperColor(0x001B2D),
          SuperColor(0x001C2E),
          SuperColor(0x001B2F),
          SuperColor(0x001C31),
          SuperColor(0x001B31),
          SuperColor(0x001A32),
          SuperColor(0x001A33),
          SuperColor(0x001B35),
          SuperColor(0x001A36),
          SuperColor(0x001937),
          SuperColor(0x001939),
          SuperColor(0x00193A),
          SuperColor(0x00193B),
          SuperColor(0x00183D),
          SuperColor(0x00183E),
          SuperColor(0x001740),
          SuperColor(0x001741),
          SuperColor(0x001643),
          SuperColor(0x001644),
          SuperColor(0x001547),
          SuperColor(0x001548),
          SuperColor(0x00144A),
          SuperColor(0x00134C),
          SuperColor(0x00134F),
          SuperColor(0x001251),
          SuperColor(0x001052),
          SuperColor(0x000F54),
          SuperColor(0x000E56),
          SuperColor(0x000D58),
          SuperColor(0x000C59),
          SuperColor(0x000B5B),
          SuperColor(0x00095D),
          SuperColor(0x00085F),
          SuperColor(0x000661),
          SuperColor(0x000562),
          SuperColor(0x000364),
          SuperColor(0x000265),
          SuperColor(0x000068),
          SuperColor(0x020067),
          SuperColor(0x030067),
          SuperColor(0x050066),
          SuperColor(0x070065),
          SuperColor(0x080065),
          SuperColor(0x0A0064),
          SuperColor(0x0C0064),
          SuperColor(0x0D0063),
          SuperColor(0x0F0062),
          SuperColor(0x100062),
          SuperColor(0x120061),
          SuperColor(0x130060),
          SuperColor(0x15005F),
          SuperColor(0x16005F),
          SuperColor(0x17005E),
          SuperColor(0x19005D),
          SuperColor(0x1A005C),
          SuperColor(0x1B005B),
          SuperColor(0x1D005A),
          SuperColor(0x1E0059),
          SuperColor(0x1F0058),
          SuperColor(0x200057),
          SuperColor(0x210056),
          SuperColor(0x220055),
          SuperColor(0x230054),
          SuperColor(0x240053),
          SuperColor(0x250051),
          SuperColor(0x260050),
          SuperColor(0x26004F),
          SuperColor(0x27004F),
          SuperColor(0x28004D),
          SuperColor(0x29004C),
          SuperColor(0x29004B),
          SuperColor(0x2A004A),
          SuperColor(0x2B0049),
          SuperColor(0x2B0048),
          SuperColor(0x2C0047),
          SuperColor(0x2D0046),
          SuperColor(0x2D0045),
          SuperColor(0x2E0044),
          SuperColor(0x2E0044),
          SuperColor(0x2F0042),
          SuperColor(0x300042),
          SuperColor(0x300041),
          SuperColor(0x300040),
          SuperColor(0x310040),
          SuperColor(0x31003E),
          SuperColor(0x31003E),
          SuperColor(0x31003D),
          SuperColor(0x32003C),
          SuperColor(0x33003C),
          SuperColor(0x32003A),
          SuperColor(0x33003A),
          SuperColor(0x330039),
          SuperColor(0x330038),
          SuperColor(0x330037),
          SuperColor(0x340037),
          SuperColor(0x350037),
          SuperColor(0x350036),
          SuperColor(0x350035),
          SuperColor(0x350034),
          SuperColor(0x350033),
          SuperColor(0x360033),
          SuperColor(0x360032),
          SuperColor(0x360031),
          SuperColor(0x360031),
          SuperColor(0x370030),
          SuperColor(0x37002F),
          SuperColor(0x37002E),
          SuperColor(0x37002D),
          SuperColor(0x37002D),
          SuperColor(0x38002C),
          SuperColor(0x38002C),
          SuperColor(0x38002B),
          SuperColor(0x38002A),
          SuperColor(0x380029),
          SuperColor(0x390029),
          SuperColor(0x390028),
          SuperColor(0x390027),
          SuperColor(0x390026),
          SuperColor(0x390025),
          SuperColor(0x3A0024),
          SuperColor(0x3A0023),
          SuperColor(0x3A0023),
          SuperColor(0x3A0022),
          SuperColor(0x3A0021),
          SuperColor(0x3A0020),
          SuperColor(0x3B001F),
          SuperColor(0x3B001E),
          SuperColor(0x3B001D),
          SuperColor(0x3B001C),
          SuperColor(0x3B001B),
          SuperColor(0x3B001A),
          SuperColor(0x3B001A),
          SuperColor(0x3C0019),
          SuperColor(0x3C0018),
          SuperColor(0x3C0017),
          SuperColor(0x3C0016),
          SuperColor(0x3C0015),
          SuperColor(0x3C0014),
          SuperColor(0x3C0013),
          SuperColor(0x3C0012),
          SuperColor(0x3C0011),
          SuperColor(0x3D0010),
          SuperColor(0x3D000F),
          SuperColor(0x3D000E),
          SuperColor(0x3D000D),
          SuperColor(0x3D000C),
          SuperColor(0x3D000B),
          SuperColor(0x3D000A),
          SuperColor(0x3D0009),
          SuperColor(0x3D0008),
          SuperColor(0x3D0007),
          SuperColor(0x3D0006),
          SuperColor(0x3D0005),
          SuperColor(0x3D0004),
          SuperColor(0x3E0003),
          SuperColor(0x3E0002),
          SuperColor(0x3E0001),
        ],
        cycleSeconds = 10;
  final List<Color> colors;
  final int cycleSeconds;

  @override
  State<Balls> createState() => _BallsState();
}

class _BallsState extends SuperState<Balls> {
  final List<Widget> balls = [];
  static const ballCount = 75;
  @override
  void animate() async {
    await sleep(0.1);
    final size = context.screenSize;
    final ballScale = (size.width + size.height) / 8;
    for (int i = 0; i < ballCount; i++) {
      setState(() {
        balls.insert(
          rng.nextInt(balls.length + 1),
          _ColorBall(
            key: ObjectKey(i),
            widget.colors[(360 * i) ~/ ballCount],
            ballScale,
            widget.cycleSeconds,
          ),
        );
      });
      await sleep(widget.cycleSeconds / ballCount);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: balls);
  }
}

class _ColorBall extends StatefulWidget {
  const _ColorBall(this.color, this.scale, this.cycleSeconds, {super.key});
  final Color color;
  final double scale;
  final int cycleSeconds;

  @override
  State<_ColorBall> createState() => _ColorBallState();
}

extension _RandAlign on Random {
  Alignment get align => Alignment(nextDouble() * 2 - 1, nextDouble() * 2 - 1);
}

class _ColorBallState extends SuperState<_ColorBall> {
  bool visible = false;
  Alignment alignment = rng.align;

  @override
  void animate() async {
    while (mounted) {
      const startupTime = 2.0;
      quickly(() => setState(() {
            alignment = rng.align;
            visible = true;
          }));
      await sleepState(widget.cycleSeconds - startupTime, () => visible = false);
      await sleep(startupTime);
    }
  }

  late final blob = Transform.scale(
    scale: widget.scale,
    child: SizedBox(
        width: 1,
        height: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [widget.color, widget.color.withAlpha(0)]),
          ),
        )),
  );
  late final child = Stack(children: [blob, blob]);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Fader(
        visible,
        duration: twoSecs,
        child: child,
      ),
    );
  }
}
