import 'package:example/pages/first_page.dart';
import 'package:example/router/navigation_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

GlobalKey<NavigatorState> navigationApp =
    GlobalKey<NavigatorState>(debugLabel: "navigationApp");

void main() {
  NavigationController routerController = NavigationController();
  routerController.setupRouter();

  runApp(MyApp(routerController: routerController));
}

class MyApp extends StatelessWidget {
  final NavigationController routerController;

  const MyApp({
    super.key,
    required this.routerController,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: routerController),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        navigatorKey: navigationApp,
        onGenerateRoute: routerController.router.generator,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: FirstPage(routerController: routerController),
      ),
    );
  }
}
