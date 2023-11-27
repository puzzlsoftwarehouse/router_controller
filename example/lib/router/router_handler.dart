import 'package:example/pages/first_page.dart';
import 'package:example/pages/second_page.dart';
import 'package:example/pages/three_page.dart';
import 'package:example/router/navigation_controller.dart';
import 'package:flutter/material.dart';
import 'package:router_controller/router_controller.dart';
import 'package:universal_html/html.dart' as html;

class RouterHandler {
  RouterHandler._();

  static const String firstName = "/";
  static const String secondName = "/second";
  static const String threeName = "/three/:id";

  static final Map<String, Handler> _allRoutes = {
    firstName: _getHandler(const FirstPage()),
    secondName: _getHandler(const SecondPage()),
    threeName: _getHandler(const ThreePage()),
  };
  static Map<String, Handler> get allRoutes => _allRoutes;

  static Handler _getHandler(Widget page) => Handler(func: (_, __) => page);

  static Map<String, dynamic> get arguments {
    String pathUrl = html.window.location.href;

    Uri uri = Uri.parse(pathUrl);
    pathUrl = pathUrl.replaceAll(uri.origin, "").replaceAll("#/", "");

    List<String> args =
        pathUrl.split("/").where((item) => item.isNotEmpty).toList();

    String? pageRouterFiltered;

    for (String argumentUrl in args) {
      for (String routerName in _allRoutes.keys) {
        if (argumentUrl == getNameRouterUrl(routerName, argumentUrl)) {
          pageRouterFiltered = argumentUrl;
          break;
        }
      }
    }

    return {
      "pageRouter": pageRouterFiltered,
      "idThreePage": int.tryParse(getElementByIndex(args, 0) ?? ""),
    };
  }

  static bool existRouterForNavigation({
    required NavigationController routerController,
    required String pageRouter,
  }) {
    if (pageRouter == getNameRouterUrl(RouterHandler.firstName, pageRouter)) {
      routerController.navigateRouter(
        routerPage: RouterPage.first,
        arguments: arguments,
      );
      return true;
    }

    if (pageRouter == getNameRouterUrl(RouterHandler.secondName, pageRouter)) {
      routerController.navigateRouter(
        routerPage: RouterPage.second,
        arguments: arguments,
      );
      return true;
    }

    return false;
  }

  static String getNameRouterUrl(String allNameRouter, String router) {
    List<String> parts = allNameRouter.split('/');
    String nameRouter = parts.contains(router) ? router : '';

    return nameRouter;
  }

  static dynamic getElementByIndex(List<dynamic> list, int index) {
    if (index >= 0 && index < list.length) {
      return list[index];
    }

    return null;
  }
}
