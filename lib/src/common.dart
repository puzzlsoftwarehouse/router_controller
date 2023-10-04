import 'package:flutter/widgets.dart';

enum HandlerType {
  route,
  function,
}

class Handler {
  Handler({
    this.type = HandlerType.route,
    required this.handlerFunc,
  });

  final HandlerType type;
  final HandlerFunc handlerFunc;
}

typedef RouteCreator<T> = Route<T> Function(
  RouteSettings route,
  Map<String, List<String>> parameters,
);

typedef HandlerFunc = Widget? Function(
  BuildContext? context,
  Map<String, List<String>> parameters,
);

class AppRoute {
  AppRoute(
    this.route,
    this.handler, {
    this.transitionType,
    this.transitionDuration,
    this.transitionBuilder,
    this.opaque,
  });

  String route;
  dynamic handler;
  TransitionType? transitionType;
  Duration? transitionDuration;
  RouteTransitionsBuilder? transitionBuilder;
  bool? opaque;
}

enum TransitionType {
  native,
  nativeModal,
  inFromLeft,
  inFromTop,
  inFromRight,
  inFromBottom,
  fadeIn,
  custom,
  material,
  materialFullScreenDialog,
  cupertino,
  cupertinoFullScreenDialog,
  none,
}

enum RouteMatchType {
  visual,
  nonVisual,
  noMatch,
}

class RouteMatch {
  RouteMatch({
    this.matchType = RouteMatchType.noMatch,
    this.route,
    this.errorMessage = "Unable to match route. Please check the logs.",
  });

  final Route<dynamic>? route;
  final RouteMatchType matchType;
  final String errorMessage;
}

class RouteNotFoundException implements Exception {
  RouteNotFoundException(
    this.message,
    this.path,
  );

  final String message;
  final String path;

  @override
  String toString() {
    return "No registered route was found to handle '$path'";
  }
}
