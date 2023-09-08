import 'package:flutter/material.dart';
import 'package:super_hueman/data/structs.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme.dark(primary: Colors.white),
        ),
        routes: Pages.routes,
        initialRoute: Pages.initialRoute,
      );
}

void main() => runApp(const App());
