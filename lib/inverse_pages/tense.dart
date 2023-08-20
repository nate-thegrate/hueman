import 'package:flutter/material.dart';
import 'package:super_hueman/structs.dart';

class TenseMode extends StatelessWidget {
  const TenseMode({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(useMaterial3: true),
      child: Scaffold(
        body: Center(
          child: Column(
            children: [
              const Spacer(),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: SuperColors.black80,
                  backgroundColor: Colors.white54,
                ),
                onPressed: () => context.goto(Pages.inverseMenu),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'back',
                    style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
        backgroundColor: SuperColors.lightBackground,
      ),
    );
  }
}
