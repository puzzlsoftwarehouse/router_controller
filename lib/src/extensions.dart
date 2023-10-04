import 'package:flutter/material.dart';

extension FluroBuildContextX on BuildContext {
  RouteSettings? get settings => ModalRoute.of(this)?.settings;
  Object? get arguments => ModalRoute.of(this)?.settings.arguments;
}
