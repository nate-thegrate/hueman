import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:hueman/data/page_data.dart';
import 'package:hueman/data/save_data.dart';
import 'package:hueman/data/structs.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  didChangeAppLifecycleState(AppLifecycleState state) {
    if (state case AppLifecycleState.inactive || AppLifecycleState.hidden) {
      if (musicPlayer.state == PlayerState.playing) {
        musicPlayer.pause();
        paused = true;
      }
    } else if (paused && music) {
      musicPlayer.resume();
      paused = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(primary: Colors.white),
        fontFamily: 'nunito sans',
      ),
      debugShowCheckedModeBanner: false,
      routes: Pages.routes,
      initialRoute: Pages.initialRoute,
    );
  }
}

void main() => loadData().then((_) => runApp(const App()));
