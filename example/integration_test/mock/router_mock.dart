import 'package:example/main.dart';
import 'package:example/router/router_controller.dart';
import 'package:example/router/router_handler.dart';
import 'package:router_controller/fluro.dart';
import 'package:flutter_test/flutter_test.dart';

class RouterMock {
  RouterMock._();

  static int quoteId = 1;
  static int companyId = 1;
  static String companyGroup = "sunDogs";

  static Map<String, dynamic> argumentsJobQuote = {
    "companyId": companyId,
    "companyGroup": companyGroup,
    "quoteId": quoteId,
  };

  static mock({
    required RouterController controller,
    required Map<String, Handler> routers,
  }) {
    routers.forEach((key, value) {
      controller.router.define(key, handler: value);
    });
  }

  static Future<void> mockBeforeScreen({
    required RouterController routerController,
    required String beforeNameRouter,
    required WidgetTester tester,
  }) async {
    routerController.router.navigateTo(
      navigationApp.currentContext!,
      beforeNameRouter,
    );

    routerController.router.navigateTo(
      navigationApp.currentContext!,
      RouterHandler.firstName,
    );

    await tester.pumpAndSettle();
  }
}
