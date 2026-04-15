import 'package:flutter/material.dart';

enum AuthState {
  unknown,
  authenticated,
  unauthenticated;

  /// Các đường dẫn được phép cho mỗi trạng thái.
  List<String> get allowedPaths {
    switch (this) {
      case AuthState.unknown:
        return []; // Không cho phép đi đâu khi đang kiểm tra
      case AuthState.unauthenticated:
        return ['/login']; // Chỉ được phép vào trang login
      case AuthState.authenticated:
      // Được phép vào tất cả các trang trừ trang login
        return ['/products', '/todos', '/posts', '/profile', '/settings'];
    }
  }

  /// Đường dẫn chuyển hướng nếu truy cập bị từ chối.
  String get redirectPath {
    switch (this) {
      case AuthState.unknown:
        return '/login'; // Tạm thời
      case AuthState.unauthenticated:
        return '/login';
      case AuthState.authenticated:
      // Nếu người dùng đã đăng nhập mà vào /login thì đá về trang chủ
        return '/products';
    }
  }
}