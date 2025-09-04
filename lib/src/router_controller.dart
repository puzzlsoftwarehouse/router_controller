import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:router_controller/router_controller.dart';
import 'package:router_controller/src/route_utils.dart';
import 'non_web.dart'
    if (dart.library.js_interop) 'package:web/web.dart'
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
      router.notFoundHandler = Handler(func: (_, _) => notFoundWidget);
    }
  }

  String getPathWithRouter<R>({
    required R routerPage,
    required Map<R, String> routerMap,
    required List<Route<dynamic>> routeStack,
    Object? arguments,
  }) {
    String nameRouterSelected = routerMap[routerPage]!;
    Map<String, dynamic> args = arguments as Map<String, dynamic>? ?? {};
    args.removeWhere((key, value) => value == null);

    if (nameRouterSelected.contains(":")) {
      nameRouterSelected = nameRouterSelected.replaceAllMapped(
        RegExp(r":([a-zA-Z_]+)(?=/|$)"),
        (Match match) {
          String parameterName = match.group(1)!;
          Map<String, dynamic> newArgs = args;

          if (!newArgs.containsKey(parameterName)) {
            if (args.containsKey("arguments")) {
              newArgs = args['arguments'];
              newArgs.removeWhere((key, value) => value == null);
            }
          }

          return newArgs.containsKey(parameterName)
              ? newArgs[parameterName]
              : "";
        },
      );
    }

    if (args.containsKey('urlPage')) {
      final String? lastRouteName = routeStack.last.settings.name;
      final String urlPage = args['urlPage'];
      if (lastRouteName == null || !lastRouteName.endsWith(urlPage)) {
        nameRouterSelected = urlPage;
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
  }) async {
    String nameRouterSelected = routerMap[routerPage]!;

    nameRouterSelected = getPathWithRouter(
      routerPage: routerPage,
      routerMap: routerMap,
      routeStack: routeStack,
      arguments: arguments,
    );

    return _navigateName(
      context: context,
      nameRouter: nameRouterSelected,
      clearStack: clearStack,
      replace: replace,
      arguments: arguments,
      transitionType: transitionType,
    );
  }

  Future<dynamic> navigateWidget({
    required BuildContext context,
    required Widget widget,
  }) => Navigator.push(context, MaterialPageRoute(builder: (_) => widget));

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

    router.navigateTo(context, nameRouter, clearStack: true, replace: true);
  }

  void pop({
    required BuildContext context,
    required List<String> routes,
    Object? args,
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
      );
    }
  }

  Map<String, dynamic> getArguments({
    required Map<String, Handler> allRoutes,
    String? path,
  }) {
    String? pathUrl = _getPathUrlOrigin(path: path);
    if (pathUrl == null) return {};

    List<String> args =
        pathUrl.split("/").where((item) => item.isNotEmpty).toList();

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

    for (int i = 0; i < (routeParts?.length ?? 0) && i < args.length; i++) {
      if (routeParts![i].startsWith(':')) {
        mappedArgs[routeParts[i].substring(1)] = args[i];
        continue;
      }
      if (routeParts[i] != args[i]) {
        break;
      }
    }

    final Map<String, String> extractedArgs = extractRouteArguments(
      routePattern: router,
      pathUrl: pathUrl,
    );

    final Map<String, String> mergedArgs = Map<String, String>.from(mappedArgs);

    extractedArgs.forEach((key, value) {
      mergedArgs.putIfAbsent(key, () => value);
    });

    return {
      "pageRouter": routerPageName,
      "arguments": mergedArgs,
      "urlPage": pathUrl,
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
  }) {
    String? pathUrl = _getPathUrlOrigin();

    if (pathUrl != null) {
      String? beforeRoute = RouteUtils.findBeforeRoute(pathUrl, routes);

      if (beforeRoute != null) {
        router.navigateTo(
          context,
          beforeRoute,
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

  String? _getPathUrlOrigin({String? path}) {
    String? pathUrl = path ?? web.window.location.href;
    if (pathUrl == null) return null;

    Uri uri = Uri.parse(pathUrl);
    pathUrl = pathUrl
        .split("?")
        .firstOrNull
        ?.replaceAll(uri.origin, "")
        .replaceAll("#/", "");

    return pathUrl;
  }

  Map<String, String> extractRouteArguments({
    required String? routePattern,
    required String pathUrl,
  }) {
    if (routePattern == null) return {};

    final routeSegments =
        routePattern.split('/').where((e) => e.isNotEmpty).toList();

    final pathSegments = pathUrl.split('/').where((e) => e.isNotEmpty).toList();

    final Map<String, String> args = {};

    for (int i = 0; i < routeSegments.length && i < pathSegments.length; i++) {
      final routeSegment = routeSegments[i];

      if (routeSegment.startsWith(':')) {
        final key = routeSegment.substring(1);
        args[key] = pathSegments[i];
      }
    }

    return args;
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
