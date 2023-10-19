import 'package:flutter/material.dart';
import 'package:router_controller/router_controller.dart';
import 'package:router_controller/src/fluro_router.dart';
import 'package:universal_html/html.dart' as html;

class RouterController<T> with ChangeNotifier {
  late T builder;

  bool _disposed = false;
  FluroRouter router = FluroRouter();

  RouterController(this.builder);

  void setupRouter({
    required Map<String, Handler> allRoutes,
    Widget? notFoundWidget,
    TransitionType? transitionType,
  }) {
    // router.notFoundHandler =
    //     Handler(func: (_, __) => notFoundWidget ?? const SizedBox.shrink());

    for (String nameRouter in allRoutes.keys.toList()) {
      router.define(
        nameRouter,
        handler: allRoutes[nameRouter],
        transitionType: transitionType,
      );
    }
  }

  Future<dynamic> navigateWithWidget({
    required BuildContext context,
    required Widget widget,
  }) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => widget));

  void popRouter({required BuildContext context, Object? args}) =>
      router.pop(context, args);
  void popContext({required BuildContext context, Object? args}) =>
      Navigator.pop(context, args);

  Future<dynamic> navigateWithName({
    required BuildContext context,
    required String nameRouter,
    Object? arguments,
    bool clearStack = false,
    TransitionType? transitionType,
  }) {
    return router.navigateTo(
      context,
      nameRouter,
      transition: transitionType,
      routeSettings: RouteSettings(arguments: arguments),
      clearStack: clearStack,
    );
  }

  Map<String, dynamic> getArguments({required Map<String, Handler> allRoutes}) {
    String pathUrl = html.window.location.href;

    Uri uri = Uri.parse(pathUrl);
    pathUrl = pathUrl.replaceAll(uri.origin, "").replaceAll("#/", "");

    List<String> args =
        pathUrl.split("/").where((item) => item.isNotEmpty).toList();

    String? pageRouterFiltered;

    for (String argumentUrl in args) {
      for (String routerName in allRoutes.keys) {
        if (argumentUrl == containsNameRouter(routerName, argumentUrl)) {
          pageRouterFiltered = argumentUrl;
          break;
        }
      }
    }

    return {
      "pageRouter": pageRouterFiltered,
      "arguments": args,
    };
  }

  String containsNameRouter(String routerUrl, String router) {
    List<String> parts = routerUrl.split('/');
    String nameRouter = parts.contains(router) ? router : '';

    return nameRouter;
  }

  dynamic getIndex(List<dynamic> list, int index) {
    if (index >= 0 && index < list.length) {
      return list[index];
    }

    return null;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }
}
