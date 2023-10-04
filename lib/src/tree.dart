import 'package:flutter/widgets.dart';
import 'package:router_controller/src/common.dart';

enum RouteTreeNodeType {
  component,
  parameter,
}

class AppRouteMatch {
  AppRouteMatch(this.route);

  AppRoute route;
  Map<String, List<String>> parameters = <String, List<String>>{};
}

class RouteTreeNodeMatch {
  RouteTreeNodeMatch(this.node);

  RouteTreeNode node;

  var parameters = <String, List<String>>{};

  RouteTreeNodeMatch.fromMatch(RouteTreeNodeMatch? match, this.node) {
    parameters = <String, List<String>>{};
    if (match != null) {
      parameters.addAll(match.parameters);
    }
  }
}

class RouteTreeNode {
  RouteTreeNode(this.part, this.type);

  String part;
  RouteTreeNodeType? type;

  RouteTreeNode? parent;

  var routes = <AppRoute>[];
  var nodes = <RouteTreeNode>[];

  bool isParameter() {
    return type == RouteTreeNodeType.parameter;
  }
}

class RouteTree {
  final List<RouteTreeNode> _nodes = <RouteTreeNode>[];
  bool _hasDefaultRoute = false;

  void addRoute(AppRoute route) {
    String path = route.route;
    if (path == Navigator.defaultRouteName) {
      if (_hasDefaultRoute) {
        throw ("Default route was already defined");
      }

      var node = RouteTreeNode(path, RouteTreeNodeType.component);
      node.routes = [route];
      _nodes.add(node);
      _hasDefaultRoute = true;
      return;
    }

    if (path.startsWith("/")) {
      path = path.substring(1);
    }

    final pathComponents = path.split('/');

    RouteTreeNode? parent;

    for (int i = 0; i < pathComponents.length; i++) {
      String? component = pathComponents[i];
      RouteTreeNode? node = _nodeForComponent(component, parent);

      if (node == null) {
        RouteTreeNodeType type = _typeForComponent(component);
        node = RouteTreeNode(component, type);
        node.parent = parent;

        if (parent == null) {
          _nodes.add(node);
        } else {
          parent.nodes.add(node);
        }
      }

      if (i == pathComponents.length - 1) {
        node.routes.add(route);
      }

      parent = node;
    }
  }

  AppRouteMatch? matchRoute(String path) {
    var usePath = path;

    if (usePath.startsWith("/")) {
      usePath = path.substring(1);
    }

    var components = usePath.split("/");

    if (path == Navigator.defaultRouteName) {
      components = ["/"];
    }

    var nodeMatches = <RouteTreeNode, RouteTreeNodeMatch>{};
    var nodesToCheck = _nodes;

    for (final checkComponent in components) {
      final currentMatches = <RouteTreeNode, RouteTreeNodeMatch>{};
      final nextNodes = <RouteTreeNode>[];

      var pathPart = checkComponent;
      Map<String, List<String>>? queryMap;

      if (checkComponent.contains("?")) {
        var splitParam = checkComponent.split("?");
        pathPart = splitParam[0];
        queryMap = parseQueryString(splitParam[1]);
      }

      for (final node in nodesToCheck) {
        final isMatch = (node.part == pathPart || node.isParameter());

        if (isMatch) {
          RouteTreeNodeMatch? parentMatch = nodeMatches[node.parent];
          final match = RouteTreeNodeMatch.fromMatch(parentMatch, node);
          if (node.isParameter()) {
            final paramKey = node.part.substring(1);
            match.parameters[paramKey] = [pathPart];
          }
          if (queryMap != null) {
            match.parameters.addAll(queryMap);
          }
          currentMatches[node] = match;
          nextNodes.addAll(node.nodes);
        }
      }

      nodeMatches = currentMatches;
      nodesToCheck = nextNodes;

      if (currentMatches.values.isEmpty) {
        return null;
      }
    }

    final matches = nodeMatches.values.toList();

    if (matches.isNotEmpty) {
      final match = matches.first;
      final nodeToUse = match.node;
      final routes = nodeToUse.routes;

      if (routes.isNotEmpty) {
        final routeMatch = AppRouteMatch(routes[0]);
        routeMatch.parameters = match.parameters;
        return routeMatch;
      }
    }

    return null;
  }

  void printTree() {
    _printSubTree();
  }

  void _printSubTree({RouteTreeNode? parent, int level = 0}) {
    List<RouteTreeNode> nodes = parent != null ? parent.nodes : _nodes;

    for (RouteTreeNode node in nodes) {
      var indent = "";

      for (var i = 0; i < level; i++) {
        indent += "    ";
      }

      debugPrint("$indent${node.part}: total routes=${node.routes.length}");

      if (node.nodes.isNotEmpty) {
        _printSubTree(parent: node, level: level + 1);
      }
    }
  }

  RouteTreeNode? _nodeForComponent(String component, RouteTreeNode? parent) {
    List<RouteTreeNode> nodes = _nodes;

    if (parent != null) {
      nodes = parent.nodes;
    }

    for (RouteTreeNode node in nodes) {
      if (node.part == component) {
        return node;
      }
    }

    return null;
  }

  RouteTreeNodeType _typeForComponent(String component) {
    var type = RouteTreeNodeType.component;

    if (_isParameterComponent(component)) {
      type = RouteTreeNodeType.parameter;
    }

    return type;
  }

  bool _isParameterComponent(String component) {
    return component.startsWith(":");
  }

  Map<String, List<String>> parseQueryString(String query) {
    final search = RegExp('([^&=]+)=?([^&]*)');
    final params = <String, List<String>>{};

    if (query.startsWith('?')) query = query.substring(1);

    decode(String s) => Uri.decodeComponent(s.replaceAll('+', ' '));

    for (Match match in search.allMatches(query)) {
      final key = decode(match.group(1)!);
      final value = decode(match.group(2)!);

      if (params.containsKey(key)) {
        params[key]!.add(value);
      } else {
        params[key] = [value];
      }
    }

    return params;
  }
}
