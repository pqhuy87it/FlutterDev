import 'package:flutter/material.dart';

abstract class NavigationEvent {}

class NavigateToEScreenWithStackEvent extends NavigationEvent {
  final String data;
  NavigateToEScreenWithStackEvent(this.data);
}