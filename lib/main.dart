import 'package:flutter/material.dart';
import 'package:super_hueman/pages/easy.dart';
import 'package:super_hueman/pages/intense.dart';
import 'package:super_hueman/pages/master.dart';
import 'reference.dart';
import 'pages/main_menu.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: Colors.white,
        brightness: Brightness.dark,
      ),
      initialRoute: Pages.mainMenu(),
      routes: {
        Pages.mainMenu(): (context) => const MainMenu(),
        Pages.easy(): (context) => const EasyMode(),
        Pages.intense(): (context) => const IntenseMode(),
        Pages.master(): (context) => const MasterMode(),
      },
    );
  }
}
