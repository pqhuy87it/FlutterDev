import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'not_found_screen.dart';
import 'screen_page_1.dart';
import 'screen_page_2.dart';

class MyAppRouter {
  static final FluroRouter router = FluroRouter();

  // Định nghĩa handler cho màn hình không tìm thấy
  static final Handler _notFoundHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return const NotFoundScreen();
    },
  );

  // Định nghĩa handler cho màn hình chính
  static final Handler _screenPage1 = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return const ScreenPage1();
    },
  );

  // Định nghĩa handler cho màn hình chi tiết người dùng (có tham số)
  static final Handler _screenPage2 = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return const ScreenPage2();
    },
  );

  // Hàm setup các route
  static void setupRouter() {
    router.notFoundHandler = _notFoundHandler; // Gán handler khi không tìm thấy route

    // Định nghĩa các route
    router.define('/screen_page_1', handler: _screenPage1, transitionType: TransitionType.fadeIn);
    router.define('/screen_page_2', handler: _screenPage2, transitionType: TransitionType.fadeIn);
  }
}