import 'package:example/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ThreePage extends StatelessWidget {
  const ThreePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoButton(
              color: Colors.red,
              onPressed: () {
                Navigator.pop(navigationApp.currentContext!);
              },
              child: const Text("Navigate Three Page"),
            ),
          ],
        ),
      ),
    );
  }
}
