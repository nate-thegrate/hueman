import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hueman/data/page_data.dart';
import 'package:hueman/data/save_data.dart';
import 'package:hueman/inverse_pages/menu.dart';
import 'package:hueman/pages/menu.dart';
import 'package:meta/meta.dart';

/// ```dart
///
/// await sleep(3); // in an async function
/// sleep(3, then: do_something()); // anywhere
/// ```
/// Just like `time.sleep(3)` in Python.
Future<void> sleep(double seconds, {VoidCallback? then}) =>
    Future.delayed(Duration(milliseconds: (seconds * 1000).toInt()), then);

void quickly(VoidCallback function) =>
    WidgetsBinding.instance.addPostFrameCallback((_) => function());

const oneSec = Duration(seconds: 1);
const twoSecs = Duration(seconds: 2);
const threeSecs = Duration(seconds: 3);
const halfSec = Duration(milliseconds: 500);
const quarterSec = Duration(milliseconds: 250);
const Curve curve = Curves.easeOutCubic;
final double androidLatency = Platform.isAndroid ? 0.4 : 0.0;

final rng = Random();

final sfx = AssetPlayer();
final music = MusicPlayer();

extension type AssetPlayer.fromPlayer(AudioPlayer player) implements AudioPlayer {
  AssetPlayer() : this.fromPlayer(AudioPlayer());

  @redeclare
  Future<void> play(String name) => player.play(AssetSource('audio/$name.mp3'));
}

extension type MusicPlayer.fromAssetPlayer(AssetPlayer player) implements AssetPlayer {
  MusicPlayer() : this.fromAssetPlayer(AssetPlayer());

  static StreamSubscription? _loop;

  @redeclare
  Future<void> play({String? once, String? loop}) async {
    if (!enableMusic) return;
    assert((once ?? loop) != null);
    await player.stop();
    await _loop?.cancel();

    Future<void> playLoop() async {
      await player.play(loop!);
      await _loop?.cancel();
      return player.setReleaseMode(ReleaseMode.loop);
    }

    Future<void> playOnce() async {
      await player.play(once!);
      if (loop != null) _loop = player.onPlayerComplete.listen((_) => playLoop());
      return player.setReleaseMode(ReleaseMode.release);
    }

    return once == null ? playLoop() : playOnce();
  }
}

extension PauseMusic on AppLifecycleState {
  /// pauses the music when the app isn't in use.
  void pauseMusic() {
    if (this == AppLifecycleState.resumed && enableMusic && paused) {
      music.resume();
      paused = false;
    } else if (music.state == PlayerState.playing) {
      music.pause();
      paused = true;
    }
  }
}

HardwareKeyboard get keyboard => HardwareKeyboard.instance;

Color contrastWith(Color c, {double threshold = .2}) =>
    (c.computeLuminance() > threshold) ? Colors.black : Colors.white;

abstract interface class ScoreKeeper {
  Pages get page;
  Widget get midRoundDisplay;
  String get finalDetails;
  int get scoreVal;
  void scoreTheRound();
  void roundCheck(BuildContext context);
}

/// easy-to-type functions & getters that use the current [BuildContext].
extension ContextStuff on BuildContext {
  void goto(Pages page) => Navigator.pushReplacementNamed(this, page.name);
  void menu() => goto(Pages.menu);

  void noTransition(Widget screen) => Navigator.pushReplacement<void, void>(
        this,
        PageRouteBuilder<void>(
          pageBuilder: (context, animation1, animation2) => screen,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );

  void invert() => noTransition(inverted ? const MainMenu() : const InverseMenu());

  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
}

extension CalcSize on BoxConstraints {
  double calcSize(double Function(double w, double h) widthHeight) =>
      widthHeight(maxWidth, maxHeight);
}

class HueQueue {
  HueQueue(this.numColors) {
    choices = [for (int hue = 0; hue < 360; hue += 360 ~/ numColors) hue];
    recentChoices = [];
    minChoices = numColors == 3 ? 2 : 3;
  }
  final int numColors;
  late final List<int> choices, recentChoices;
  late final int minChoices;

  /// grabs the next hue to use and updates the queue.
  int get queuedHue {
    final hue = choices.removeAt(rng.nextInt(choices.length));
    if (choices.length < minChoices) choices.add(recentChoices.removeAt(0));
    recentChoices.add(hue);
    return hue;
  }
}

extension ToInt on TextEditingValue {
  int toInt() => text.isEmpty ? 0 : int.parse(text);
}

extension HexByte on int {
  String get hexByte => '0x${toRadixString(16).padLeft(2, '0').toUpperCase()}';
}

extension NumStuff<T extends num> on T {
  T get squared => this * this as T;
  int roundToNearest(int roundTo) => ((this / roundTo).round() * roundTo) % 360;
}

extension Average<T extends num> on List<T> {
  /// it better not be an empty list :)
  double get average => reduce((total, val) => total + val as T) / length;
}

T diff<T extends num>(T a, T b) => (a - b).abs() as T;
