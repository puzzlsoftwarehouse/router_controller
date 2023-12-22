import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:router_controller/router_controller.dart';
import 'package:router_controller/src/route_utils.dart';
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

  Future<dynamic> navigateRouter<R>({
    required BuildContext context,
    required R routerPage,
    required Map<R, String> routerMap,
    required List<Route<dynamic>> routeStack,
    bool clearStack = false,
    Object? arguments,
    TransitionType? transitionType,
  }) async {
    //await Future.microtask(() {});

    String nameRouterSelected = routerMap[routerPage]!;
    Map<String, dynamic>? args = arguments as Map<String, dynamic>?;

    if (nameRouterSelected.contains(":")) {
      List<String> keysToReplace = nameRouterSelected.split("/");
      for (String keyReplace in keysToReplace) {
        if (!keyReplace.contains(":")) continue;
        if (nameRouterSelected.contains(keyReplace)) {
          nameRouterSelected = nameRouterSelected.replaceAll(
              keyReplace, args?[keyReplace.replaceAll(":", "")] ?? "");
        }
      }
    }

    if (args != null && args.containsKey("urlPage")) {
      if (!(routeStack.last.settings.name?.endsWith(args['urlPage']) ??
          false)) {
        nameRouterSelected = args['urlPage'];
      }
    }

    return navigateWithName(
      context: context,
      nameRouter: nameRouterSelected,
      clearStack: clearStack,
      arguments: arguments,
      transitionType: transitionType,
    );
  }

  Future<dynamic> navigateWithWidget({
    required BuildContext context,
    required Widget widget,
  }) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => widget));

  Future<dynamic> navigateReplacementWithWidget({
    required BuildContext context,
    required Widget widget,
  }) =>
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => widget));

  void popUntil({
    required BuildContext context,
    required String nameRouter,
    Object? args,
    required List<String> routes,
  }) {
    bool canPop = Navigator.of(context).canPop();
    if (canPop) {
      router.popUntil(context, nameRouter, args);
      return;
    }
    router.navigateTo(
      context,
      nameRouter,
      clearStack: true,
      replace: true,
    );
  }

  void pop({
    required BuildContext context,
    Object? args,
    required List<String> routes,
  }) async {
    String? url;
    if (kIsWeb) {
      url = html.window.location.href;
    }
    bool canPop = Navigator.of(context).canPop();
    router.pop(context, args);

    await _checkMorePopForRouter(context: context, args: args);
    if (kIsWeb && !canPop) {
      _checkHasRoutesBefore(context, routes, url ?? '');
    }
  }

  void _checkHasRoutesBefore(
      BuildContext context, List<String> routes, String url) {
    String pathUrl = html.window.location.href;

    Uri uri = Uri.parse(pathUrl);
    pathUrl = pathUrl.replaceAll(uri.origin, "").replaceAll("#/", "");

    String? beforeRoute = RouteUtils.findBeforeRoute(pathUrl, routes);

    if (beforeRoute != null) {
      router.navigateTo(context, beforeRoute);
    }
  }

  Future<void> _checkMorePopForRouter({
    required BuildContext context,
    Object? args,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1));

    String pathUrl = html.window.location.href;

    Uri uri = Uri.parse(pathUrl);
    pathUrl = pathUrl.replaceAll(uri.origin, "").replaceAll("#/", "");

    if (router.match(pathUrl) == null) {
      router.pop(context, args);
      await _checkMorePopForRouter(context: context, args: args);
    }
  }

  Future<dynamic> navigateWithName({
    required BuildContext context,
    required String nameRouter,
    Object? arguments,
    bool clearStack = false,
    TransitionType? transitionType,
  }) {
    if (!nameRouter.startsWith('/')) {
      nameRouter = '/$nameRouter';
    }
    return router.navigateTo(
      context,
      nameRouter,
      transition: transitionType,
      routeSettings: RouteSettings(arguments: arguments),
      clearStack: clearStack,
    );
  }

  Future<dynamic> navigateReplacementNamed({
    required BuildContext context,
    required String nameRouter,
    Object? arguments,
    bool clearStack = false,
    TransitionType? transitionType,
  }) {
    if (!nameRouter.startsWith('/')) {
      nameRouter = '/$nameRouter';
    }
    return router.navigateTo(
      context,
      nameRouter,
      transition: transitionType,
      routeSettings: RouteSettings(arguments: arguments),
      clearStack: clearStack,
      replace: true,
    );
  }

  Map<String, dynamic> getArguments({required Map<String, Handler> allRoutes}) {
    String pathUrl = html.window.location.href;

    Uri uri = Uri.parse(pathUrl);
    pathUrl = pathUrl.replaceAll(uri.origin, "").replaceAll("#/", "");

    List<String> args =
        pathUrl.split("/").where((item) => item.isNotEmpty).toList();

    String? routerPageName;
    String? router;

    for (String argumentUrl in args) {
      for (String routerName in allRoutes.keys) {
        if (argumentUrl == containsNameRouter(routerName, argumentUrl)) {
          routerPageName = '/$argumentUrl';
          router = routerName;
          break;
        }
      }
    }

    Map<String, String> mappedArgs = {};

    List<String>? routeParts = router?.split('/');
    routeParts?.removeWhere((item) => item.isEmpty);

    for (int i = 0; i < (routeParts?.length ?? 0); i++) {
      if (routeParts![i].startsWith(':')) {
        mappedArgs[routeParts[i].substring(1)] = args[i];
      } else if (routeParts[i] != args[i]) {
        break;
      }
    }
    return {
      "pageRouter": routerPageName,
      "arguments": mappedArgs,
      "urlPage": pathUrl,
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
