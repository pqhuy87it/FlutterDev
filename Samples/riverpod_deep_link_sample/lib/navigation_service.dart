import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'navigation_events.dart';

final navigationServiceProvider = Provider((ref) => NavigationService());

class NavigationService extends NavigatorObserver {
  // Stream để bắn sự kiện ra ngoài UI
  final _eventController = StreamController<NavigationEvent>.broadcast();
  Stream<NavigationEvent> get eventStream => _eventController.stream;

  // Theo dõi màn hình hiện tại
  String? _currentRoute;
  bool get isAtScreenE => _currentRoute == '/screen_e';

  // --- Logic theo dõi Route (Giữ nguyên) ---
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _currentRoute = route.settings.name;
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _currentRoute = previousRoute?.settings.name;
  }

  // --- Thay vì gọi Navigator trực tiếp, ta bắn Event ---
  void requestNavigateToE(String data) {
    _eventController.add(NavigateToEScreenWithStackEvent(data));
  }

  void dispose() {
    _eventController.close();
  }
}