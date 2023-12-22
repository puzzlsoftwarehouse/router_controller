class RouteUtils {
  RouteUtils._();
  static List<String> getRouteParts(String route) {
    List<String> routeParts = route.split('/');
    routeParts.removeWhere((item) => item.isEmpty);
    return routeParts;
  }

  static String? getCurrentRoute(String route, List<String> routes) {
    List<String> routeParts = getRouteParts(route);
    for (String item in routes) {
      List<String> parts = getRouteParts(item);
      if (routeParts.length != parts.length) continue;
      parts = getPartsOfRoute(routeParts, parts);
      if (("/${parts.join('/')}") == route) {
        return item;
      }
    }
    return null;
  }

  static List<String> getPartsOfRoute(
      List<String> routeParts, List<String> parts) {
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].startsWith(':')) {
        parts[i] = routeParts[i];
      }
    }
    return parts;
  }

  static String? findBeforeRoute(String route, List<String> routes) {
    String? currentRoute = getCurrentRoute(route, routes);
    if (currentRoute == null) return null;
    routes.remove(currentRoute);
    List<String> before = routesBefore(currentRoute, routes);
    if (before.isEmpty) return null;
    before.sort((a, b) => b.length.compareTo(a.length));

    String beforeRoute = getNewBeforeRoute(before.first, route);
    return beforeRoute;
  }

  static String getNewBeforeRoute(String beforeRoute, String route) {
    List<String> beforeRouteParts = getRouteParts(beforeRoute);
    List<String> routeParts = getRouteParts(route);
    for (int i = 0; i < beforeRouteParts.length; i++) {
      if (beforeRouteParts[i].startsWith(':')) {
        beforeRouteParts[i] = routeParts[i];
      }
    }
    return "/${beforeRouteParts.join('/')}";
  }

  static List<String> routesBefore(String route, List<String> routes) {
    List<String> routesBefore = [];

    for (String item in routes) {
      if (route.contains(item)) {
        routesBefore.add(item);
      }
    }
    return routesBefore;
  }
}
