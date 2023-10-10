import 'package:example/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CupertinoButton(
            color: Colors.red,
            onPressed: () {
              Navigator.pop(navigationApp.currentContext!);
            },
            child: const Text("Navigate First Page"),
          ),
        ],
      ),
    );
  }
}
