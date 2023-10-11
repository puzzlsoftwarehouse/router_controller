import 'package:flutter/material.dart';
import 'package:router_controller/router_controller.dart';
import 'package:router_controller/src/fluro_router.dart';
import 'package:universal_html/html.dart' as html;

class RouterController<T> with ChangeNotifier {
  late BuildContext context;
  late T builder;

  bool _disposed = false;
  FluroRouter router = FluroRouter();

  RouterController(this.builder);

  void setBuildContext(BuildContext context) => this.context = context;

  void setupRouter({
    required Map<String, Handler> allRoutes,
    Widget? notFoundWidget,
    TransitionType? transitionType,
  }) {
    router.notFoundHandler =
        Handler(func: (_, __) => notFoundWidget ?? const SizedBox.shrink());

    allRoutes.forEach((String nameRouter, Handler handler) {
      router.define(
        nameRouter,
        handler: handler,
        transitionType: transitionType,
      );
    });
  }

  Future<dynamic> navigateWithWidget({required Widget widget}) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => widget));

  void popRouter({Object? args}) => router.pop(context, args);
  void popContext({Object? args}) => Navigator.pop(context, args);

  Future<dynamic> navigateWithName({
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
      // "companyGroup": getIndex(args, 0),
      // "companyId": int.tryParse(getIndex(args, 1) ?? ""),
      // "quoteId": int.tryParse(getIndex(args, 3) ?? ""),
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
