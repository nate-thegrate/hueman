import 'package:flutter/material.dart';
import 'reference.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: Colors.white,
          brightness: Brightness.dark,
        ),
        initialRoute: Pages.mainMenu(),
        routes: Pages.routes,
      );
}

void main() => runApp(const App());
