import 'package:example/main.dart';
import 'package:example/router/navigation_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<NavigationController>(
        builder: (_, routerController, __) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoButton(
                color: Colors.red,
                onPressed: () {
                  Navigator.pop(navigationApp.currentContext!);
                },
                child: const Text("Navigate First Page"),
              ),
              const SizedBox(height: 12),
              CupertinoButton(
                color: Colors.red,
                onPressed: () {
                  routerController.navigateReplacementNamed(
                    nameRouter: "/three/3030",
                  );
                },
                child: const Text("Navigate Page Removing the Before Screen"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
