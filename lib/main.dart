import 'package:flutter/material.dart';
import 'package:super_hueman/save_data.dart';
import 'package:super_hueman/structs.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme.dark(primary: Colors.white),
        ),
        initialRoute: inverted ? Pages.inverseMenu.name : Pages.mainMenu.name,
        routes: Pages.routes,
      );
}

void main() => runApp(const App());
