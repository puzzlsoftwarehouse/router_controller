import 'package:example/main.dart';
import 'package:example/not_found_widget.dart';
import 'package:example/router/router_handler.dart';
import 'package:flutter/material.dart';
import 'package:router_controller/fluro.dart';

enum RouterPage {
  first,
  second,
  three,
}

class RouterController with ChangeNotifier {
  bool _disposed = false;

  TransitionType get transitionType => TransitionType.fadeIn;

  Map<String, Handler> get _allRoutes => RouterHandler.allRoutes;

  FluroRouter router = FluroRouter();

  void setupRouter() {
    router.notFoundHandler =
        Handler(func: (context, parameters) => const NotFoundWidget());

    _allRoutes.forEach((String nameRouter, Handler handler) {
      router.define(
        nameRouter,
        handler: handler,
        transitionType: transitionType,
      );
    });
  }

  Future<dynamic> navigateWithName({
    required String nameRouter,
    Object? arguments,
    bool clearStack = false,
    TransitionType? transitionType,
  }) {
    return router.navigateTo(
      navigationApp.currentContext!,
      nameRouter,
      transition: transitionType ?? this.transitionType,
      routeSettings: RouteSettings(arguments: arguments),
      clearStack: clearStack,
    );
  }

  Future<dynamic> navigateWithWidget({required Widget widget}) =>
      Navigator.push(navigationApp.currentContext!,
          MaterialPageRoute(builder: (_) => widget));

  void popContext({Object? args}) => Navigator.pop(
        navigationApp.currentContext!,
        args,
      );

  void popRouter({Object? args}) =>
      router.pop(navigationApp.currentContext!, args);

  Future<bool> checkNavigationRouterWithUrl() async {
    Map<String, dynamic> arguments = RouterHandler.allRoutes;

    String? pageRouter = arguments['pageRouter'];
    int? idThreePage = arguments['idThreePage'];

    if (pageRouter == null || idThreePage == null) {
      navigateRouter(routerPage: RouterPage.first);
      return false;
    }

    bool existRouterForNavigation = RouterHandler.existRouterForNavigation(
      routerController: this,
      pageRouter: pageRouter,
    );

    if (existRouterForNavigation) return false;

    navigateRouter(
      routerPage: RouterPage.first,
      arguments: arguments,
    );
    return false;
  }

  Future<dynamic> navigateRouter({
    required RouterPage routerPage,
    bool clearStack = false,
    Object? arguments,
  }) async {
    await Future.microtask(() {});

    String nameRouterSelected = _allRoutes.keys
        .firstWhere((String name) => name == "/${routerPage.name}");

    return navigateWithName(
      nameRouter: nameRouterSelected,
      clearStack: clearStack,
      arguments: arguments,
      transitionType: transitionType,
    );
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
