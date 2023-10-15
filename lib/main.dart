import 'package:flutter/material.dart';
import 'package:super_hueman/data/page_data.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(primary: Colors.white),
        fontFamily: 'Roboto',
      ),
      routes: Pages.routes,
      initialRoute: Pages.initialRoute,
    );
  }
}

void main() => runApp(const App());
