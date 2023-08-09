import 'package:flutter/material.dart';
import 'reference.dart';

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
      // routes: {
      //   Pages.mainMenu(): (context) => const MainMenu(),
      //   Pages.intro(): (context) => const IntroMode(),
      //   Pages.intense(): (context) => const IntenseMode(),
      //   Pages.master(): (context) => const MasterMode(),
      // },
      routes: Pages.routes,
    );
  }
}
