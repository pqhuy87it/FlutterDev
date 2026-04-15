import 'package:flutter/material.dart';

class Example {
  final String name;
  final String route;
  final WidgetBuilder builder;

  const Example({
    required this.name,
    required this.route,
    required this.builder,
  });
}