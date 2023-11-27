import 'package:example/main.dart';
import 'package:example/router/navigation_controller.dart';
import 'package:example/router/router_handler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:router_controller/router_controller.dart';

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
    required NavigationController controller,
    required Map<String, Handler> routers,
  }) {
    routers.forEach((key, value) {
      controller.router.define(key, handler: value);
    });
  }

  static Future<void> mockBeforeScreen({
    required NavigationController routerController,
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
