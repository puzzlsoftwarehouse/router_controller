import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../router_controller.dart';

class FluroRouter {
  final RouteTree _routeTree = RouteTree();
  Handler? notFoundHandler;

  static const defaultTransitionDuration = Duration(milliseconds: 250);

  void define(
    String routePath, {
    required Handler? handler,
    TransitionType? transitionType,
    Duration transitionDuration = defaultTransitionDuration,
    RouteTransitionsBuilder? transitionBuilder,
    bool? opaque,
  }) {
    _routeTree.addRoute(
      AppRoute(routePath, handler,
          transitionType: transitionType,
          transitionDuration: transitionDuration,
          transitionBuilder: transitionBuilder,
          opaque: opaque),
    );
  }

  AppRouteMatch? match(String path) {
    return _routeTree.matchRoute(path);
  }

  void pop<T>(BuildContext context, [T? result]) =>
      Navigator.of(context).pop(result);

  void popUntil(BuildContext context, String nameRouter, [Object? args]) {
    Navigator.of(context).popUntil((route) {
      return route.settings.name == nameRouter;
    });
  }

  Future navigateTo(
    BuildContext context,
    String path, {
    bool replace = false,
    bool clearStack = false,
    bool maintainState = true,
    bool rootNavigator = false,
    TransitionType? transition,
    Duration? transitionDuration,
    RouteTransitionsBuilder? transitionBuilder,
    RouteSettings? routeSettings,
    bool? opaque,
  }) {
    RouteMatch routeMatch = matchRoute(
      context,
      path,
      transitionType: transition,
      transitionsBuilder: transitionBuilder,
      transitionDuration: transitionDuration,
      maintainState: maintainState,
      routeSettings: routeSettings,
      opaque: opaque,
    );

    Route<dynamic>? route = routeMatch.route;
    Completer completer = Completer();
    Future future = completer.future;

    if (routeMatch.matchType == RouteMatchType.nonVisual) {
      completer.complete("Non visual route type.");
    } else {
      if (route == null && notFoundHandler != null) {
        route = _notFoundRoute(context, path, maintainState: maintainState);
      }

      if (route != null) {
        final navigator = Navigator.of(context, rootNavigator: rootNavigator);
        if (clearStack) {
          future = navigator.pushAndRemoveUntil(route, (check) => false);
        } else {
          future = replace
              ? navigator.pushReplacement(route)
              : navigator.push(route);
        }
        completer.complete();
      } else {
        final error = "No registered route was found to handle '$path'.";
        debugPrint(error);
        completer.completeError(RouteNotFoundException(error, path));
      }
    }

    return future;
  }

  Route<void> _notFoundRoute(
    BuildContext context,
    String path, {
    bool? maintainState,
  }) {
    creator(
      RouteSettings? routeSettings,
      Map<String, String> parameters,
    ) {
      return MaterialPageRoute<void>(
        settings: routeSettings,
        maintainState: maintainState ?? true,
        builder: (BuildContext context) {
          return notFoundHandler?.func(context, parameters) ??
              const SizedBox.shrink();
        },
      );
    }

    return creator(RouteSettings(name: path), {});
  }

  RouteMatch matchRoute(
    BuildContext? buildContext,
    String? path, {
    RouteSettings? routeSettings,
    TransitionType? transitionType,
    Duration? transitionDuration,
    RouteTransitionsBuilder? transitionsBuilder,
    bool maintainState = true,
    bool? opaque,
  }) {
    RouteSettings settingsToUse = routeSettings ?? RouteSettings(name: path);

    if (settingsToUse.name == null) {
      settingsToUse = settingsToUse.copyWithShim(name: path);
    }

    AppRouteMatch? match = _routeTree.matchRoute(path!);
    AppRoute? route = match?.route;

    if (transitionDuration == null && route?.transitionDuration != null) {
      transitionDuration = route?.transitionDuration;
    }

    Handler handler = (route != null ? route.handler : notFoundHandler);
    TransitionType? transition = transitionType;

    if (transitionType == null) {
      transition = route != null ? route.transitionType : TransitionType.native;
    }

    if (route == null && notFoundHandler == null) {
      return RouteMatch(
        matchType: RouteMatchType.noMatch,
        errorMessage: "No matching route was found",
      );
    }

    Map<String, String> parameters = match?.parameters ?? <String, String>{};

    if (handler.type == HandlerType.function) {
      handler.func(buildContext, parameters);
      return RouteMatch(matchType: RouteMatchType.nonVisual);
    }

    creator(
      RouteSettings? routeSettings,
      Map<String, String> parameters,
    ) {
      bool isNativeTransition = (transition == TransitionType.native ||
          transition == TransitionType.nativeModal);

      if (isNativeTransition) {
        return MaterialPageRoute<dynamic>(
          settings: routeSettings,
          fullscreenDialog: transition == TransitionType.nativeModal,
          maintainState: maintainState,
          builder: (BuildContext context) {
            return handler.func(context, parameters) ?? const SizedBox.shrink();
          },
        );
      }
      if (transition == TransitionType.material ||
          transition == TransitionType.materialFullScreenDialog) {
        return MaterialPageRoute<dynamic>(
          settings: routeSettings,
          fullscreenDialog:
              transition == TransitionType.materialFullScreenDialog,
          maintainState: maintainState,
          builder: (BuildContext context) {
            return handler.func(context, parameters) ?? const SizedBox.shrink();
          },
        );
      }
      if (transition == TransitionType.cupertino ||
          transition == TransitionType.cupertinoFullScreenDialog) {
        return CupertinoPageRoute<dynamic>(
          settings: routeSettings,
          fullscreenDialog:
              transition == TransitionType.cupertinoFullScreenDialog,
          maintainState: maintainState,
          builder: (BuildContext context) {
            return handler.func(context, parameters) ?? const SizedBox.shrink();
          },
        );
      }
      RouteTransitionsBuilder? routeTransitionsBuilder;

      if (transition == TransitionType.custom) {
        routeTransitionsBuilder =
            transitionsBuilder ?? route?.transitionBuilder;
      } else {
        routeTransitionsBuilder = _standardTransitionsBuilder(transition);
      }

      return PageRouteBuilder<dynamic>(
        opaque: opaque ?? route?.opaque ?? true,
        settings: routeSettings,
        maintainState: maintainState,
        pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return handler.func(context, parameters) ?? const SizedBox.shrink();
        },
        transitionDuration: transition == TransitionType.none
            ? Duration.zero
            : (transitionDuration ??
                route?.transitionDuration ??
                defaultTransitionDuration),
        reverseTransitionDuration: transition == TransitionType.none
            ? Duration.zero
            : (transitionDuration ??
                route?.transitionDuration ??
                defaultTransitionDuration),
        transitionsBuilder: transition == TransitionType.none
            ? (_, __, ___, child) => child
            : routeTransitionsBuilder!,
      );
    }

    return RouteMatch(
      matchType: RouteMatchType.visual,
      route: creator(settingsToUse, parameters),
    );
  }

  RouteTransitionsBuilder _standardTransitionsBuilder(
      TransitionType? transitionType) {
    return (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    ) {
      if (transitionType == TransitionType.fadeIn) {
        return FadeTransition(opacity: animation, child: child);
      }
      const topLeft = Offset(0.0, 0.0);
      const topRight = Offset(1.0, 0.0);
      const bottomLeft = Offset(0.0, 1.0);

      var startOffset = bottomLeft;
      var endOffset = topLeft;

      if (transitionType == TransitionType.inFromLeft) {
        startOffset = const Offset(-1.0, 0.0);
        endOffset = topLeft;
      } else if (transitionType == TransitionType.inFromRight) {
        startOffset = topRight;
        endOffset = topLeft;
      } else if (transitionType == TransitionType.inFromBottom) {
        startOffset = bottomLeft;
        endOffset = topLeft;
      } else if (transitionType == TransitionType.inFromTop) {
        startOffset = const Offset(0.0, -1.0);
        endOffset = topLeft;
      }

      return SlideTransition(
        position: Tween<Offset>(
          begin: startOffset,
          end: endOffset,
        ).animate(animation),
        child: child,
      );
    };
  }

  /// Route generation method. This function can be used as a way to create routes on-the-fly
  /// if any defined handler is found. It can also be used with the [MaterialApp.onGenerateRoute]
  /// property as callback to create routes that can be used with the [Navigator] class.
  Route<dynamic>? generator(RouteSettings routeSettings) {
    RouteMatch match = matchRoute(
      null,
      routeSettings.name,
      routeSettings: routeSettings,
    );

    return match.route;
  }

  /// Prints the route tree so you can analyze it.
  void printTree() {
    _routeTree.printTree();
  }
}

extension on RouteSettings {
  // shim for 3.5.0 breaking change
  // ignore: unused_element
  RouteSettings copyWithShim({String? name, Object? arguments}) {
    return RouteSettings(
      name: name ?? this.name,
      arguments: arguments ?? this.arguments,
    );
  }
}
