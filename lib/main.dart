import 'package:flutter/material.dart';
import 'package:hueman/data/page_data.dart';
import 'package:hueman/data/save_data.dart';

class App extends StatelessWidget {
  const App({super.key});

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
