import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:router_controller/router_controller.dart';
import 'package:router_controller/src/route_utils.dart';
import 'non_web.dart' if (dart.library.js_interop) 'package:web/web.dart'
    as web;

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
    allRoutes.forEach((String nameRouter, Handler handler) {
      router.define(
        nameRouter,
        handler: handler,
        transitionType: transitionType,
      );
    });
    if (notFoundWidget != null) {
      router.notFoundHandler = Handler(func: (_, __) => notFoundWidget);
    }
  }

  String getPathWithRouter<R>({
    required R routerPage,
    required Map<R, String> routerMap,
    required List<Route<dynamic>> routeStack,
    Object? arguments,
  }) {
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

    return nameRouterSelected;
  }

  Future<dynamic> navigateRouter<R>({
    required BuildContext context,
    required R routerPage,
    required Map<R, String> routerMap,
    required List<Route<dynamic>> routeStack,
    bool clearStack = false,
    bool replace = false,
    Object? arguments,
    TransitionType? transitionType,
    Map<String, String>? parameters,
  }) async {
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

    return _navigateName(
      context: context,
      nameRouter: nameRouterSelected,
      clearStack: clearStack,
      replace: replace,
      arguments: arguments,
      transitionType: transitionType,
      parameters: parameters,
    );
  }

  Future<dynamic> navigateWidget({
    required BuildContext context,
    required Widget widget,
  }) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => widget));

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
    required List<String> routes,
    Object? args,
    Map<String, String>? parameters,
  }) async {
    String? url;
    if (kIsWeb) {
      url = web.window.location.href;
    }

    bool canPop = Navigator.of(context).canPop();
    router.pop(context, args);

    await _checkMorePopForRouter(context: context, args: args);

    if (kIsWeb && !canPop) {
      _checkHasRoutesBefore(
        context: context,
        routes: routes,
        url: url ?? '',
        arguments: args,
        parameters: parameters,
      );
    }
  }

  Map<String, dynamic> getArguments({required Map<String, Handler> allRoutes}) {
    String? pathUrl = _getPathUrlOrigin();
    if (pathUrl == null) return {};

    // Split URL into path and query string
    String path = pathUrl.split("?").first;
    Map<String, String> queryParams = {};

    // Extract query parameters if present
    if (pathUrl.contains("?")) {
      String queryString = pathUrl.split("?").last;
      queryParams = Uri.splitQueryString(queryString);
    }

    List<String> args =
        path.split("/").where((item) => item.isNotEmpty).toList();

    String? routerPageName;
    String? router;

    for (String argumentUrl in args) {
      for (String routerName in allRoutes.keys) {
        if (argumentUrl == _containsNameRouter(routerName, argumentUrl)) {
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
      if (i >= args.length) break;
      if (routeParts![i].startsWith(':')) {
        mappedArgs[routeParts[i].substring(1)] = args[i];
        continue;
      }
      if (routeParts[i] != args[i]) {
        break;
      }
    }

    return {
      "pageRouter": routerPageName,
      "arguments": mappedArgs,
      "urlPage": path,
      "queryParameters": queryParams,
    };
  }

  void updateUrlParameters(Map<String, String> newParameters) {
    final currentUrl = web.window.location.href;
    final newUrl =
        '${currentUrl?.split('?')[0]}?${newParameters.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    web.window.history.replaceState(web.window.history.state, '', newUrl);
  }

  Map<String, String> getAllParameters() {
    final currentUrl = web.window.location.href;
    Map<String, String> parameters =
        Uri.parse(Uri.parse(currentUrl ?? "").fragment).queryParameters;
    return Map.from(parameters);
  }

  Future<dynamic> _navigateName({
    required BuildContext context,
    required String nameRouter,
    Object? arguments,
    bool clearStack = false,
    bool replace = false,
    TransitionType? transitionType,
    Map<String, String>? parameters,
  }) {
    if (!nameRouter.startsWith('/')) {
      nameRouter = '/$nameRouter';
    }

    // Add query parameters to the URL if provided
    if (parameters != null && parameters.isNotEmpty) {
      String queryString = parameters.entries
          .map((e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
      if (queryString.isNotEmpty) {
        nameRouter = '$nameRouter?$queryString';
      }
    }

    return router.navigateTo(
      context,
      nameRouter,
      transition: transitionType,
      routeSettings: RouteSettings(arguments: arguments),
      clearStack: clearStack,
      replace: replace,
    );
  }

  String _containsNameRouter(String routerUrl, String router) {
    List<String> parts = routerUrl.split('/');
    String nameRouter = parts.contains(router) ? router : '';

    return nameRouter;
  }

  void _checkHasRoutesBefore({
    required BuildContext context,
    required List<String> routes,
    required String url,
    Object? arguments,
    Map<String, String>? parameters,
  }) {
    String? pathUrl = _getPathUrlOrigin();

    if (pathUrl != null) {
      String? beforeRoute = RouteUtils.findBeforeRoute(pathUrl, routes);

      if (beforeRoute != null) {
        String routeWithParams = beforeRoute;

        // Add query parameters to the URL if provided
        if (parameters != null && parameters.isNotEmpty) {
          String queryString = parameters.entries
              .map((e) =>
                  '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
              .join('&');
          if (queryString.isNotEmpty) {
            routeWithParams = '$beforeRoute?$queryString';
          }
        }

        router.navigateTo(
          context,
          routeWithParams,
          transition: TransitionType.fadeIn,
          routeSettings: RouteSettings(arguments: arguments),
        );
      }
    }
  }

  Future<void> _checkMorePopForRouter({
    required BuildContext context,
    Object? args,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1));

    String? pathUrl = _getPathUrlOrigin();

    if (pathUrl != null) {
      if (router.match(pathUrl) == null) {
        router.pop(context, args);
        await _checkMorePopForRouter(context: context, args: args);
      }
    }
  }

  String? _getPathUrlOrigin() {
    String? pathUrl = web.window.location.href;
    if (pathUrl == null) return null;

    Uri uri = Uri.parse(pathUrl);
    pathUrl = pathUrl
        .split("?")
        .firstOrNull
        ?.replaceAll(uri.origin, "")
        .replaceAll("#/", "");

    return pathUrl;
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
