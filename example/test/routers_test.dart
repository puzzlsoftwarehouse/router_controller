import 'package:example/router/router_controller.dart';
import 'package:example/router/router_handler.dart';
import 'package:flutter/material.dart';
import 'package:router_controller/fluro.dart';
import 'package:flutter_test/flutter_test.dart';

class MockHomeScreen extends StatelessWidget {
  const MockHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}

void main() {
  late RouterController routerController;

  setUp(() {
    routerController = RouterController();
  });

  AppRouteMatch? getRouteMatch(String match) =>
      routerController.router.match(match);

  group('Tests Routers', () {
    void expectRouter(String firstRoute, String expectRouter, {dynamic args}) {
      expect(firstRoute, expectRouter);
      expect(firstRoute, getRouteMatch(expectRouter)?.route.route);
      expect(getRouteMatch(expectRouter)?.parameters, args ?? isEmpty);
    }

    test('Testing router initial', () {
      String url = "/";

      routerController.router.define(
        RouterHandler.firstName,
        handler: Handler(func: (_, __) => const MockHomeScreen()),
      );

      expectRouter(RouterHandler.firstName, url);
    });

    test('Testing router second', () {
      String url = "/second";

      routerController.router.define(
        RouterHandler.secondName,
        handler: Handler(func: (_, __) => const MockHomeScreen()),
      );

      expectRouter(RouterHandler.secondName, url);
    });

    test('Testing router three', () {
      String url = "/three/:id";

      routerController.router.define(
        RouterHandler.threeName,
        handler: Handler(func: (_, __) => const MockHomeScreen()),
      );

      expectRouter(
        RouterHandler.threeName,
        url,
        args: {
          'id': [':id']
        },
      );
    });
  });
}
