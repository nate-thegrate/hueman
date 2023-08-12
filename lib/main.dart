import 'package:flutter/material.dart';
import 'reference.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme.dark(primary: Colors.white70),
          brightness: Brightness.dark,
        ),
        initialRoute: Pages.mainMenu(),
        routes: Pages.routes,
      );
}

void main() => runApp(const App());
