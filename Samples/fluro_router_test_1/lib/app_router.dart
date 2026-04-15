import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'i_router.dart';
import 'screen_page_1.dart';
import 'screen_page_2.dart';

class MyAppRouter {
  static final router = FluroRouter();

  static String screenPage1 = '/screen_page_1';
  static String screenPage2 = '/screen_page_2';

  static void initRouter() {
    router.define(screenPage1, handler: Handler(handlerFunc: (_, __) => const ScreenPage1()));
    router.define(screenPage2, handler: Handler(handlerFunc: (_, __) => const ScreenPage2()));
  }
}