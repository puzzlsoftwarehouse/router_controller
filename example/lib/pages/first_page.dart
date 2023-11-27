import 'package:example/router/navigation_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FirstPage extends StatelessWidget {
  final NavigationController? routerController;

  const FirstPage({
    super.key,
    this.routerController,
  });

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
                routerController?.navigateRouter(routerPage: RouterPage.second);
              },
              child: const Text("Navigate Second Page"),
            ),
            const SizedBox(height: 12),
            CupertinoButton(
              color: Colors.red,
              onPressed: () {
                routerController?.navigateWithName(nameRouter: "/three/3030");
              },
              child: const Text("Navigate Page With Arguments"),
            ),
          ],
        ),
      ),
    );
  }
}
