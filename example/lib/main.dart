import 'package:example/pages/first_page.dart';
import 'package:example/router/router_controller.dart';
import 'package:flutter/material.dart';

GlobalKey<NavigatorState> navigationApp =
    GlobalKey<NavigatorState>(debugLabel: "navigationApp");

void main() {
  RouterController routerController = RouterController();
  routerController.setupRouter();

  runApp(MyApp(routerController: routerController));
}

class MyApp extends StatelessWidget {
  final RouterController routerController;

  const MyApp({
    super.key,
    required this.routerController,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      navigatorKey: navigationApp,
      onGenerateRoute: routerController.router.generator,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FirstPage(routerController: routerController),
    );
  }
}
