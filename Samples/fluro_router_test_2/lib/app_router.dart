import 'package:fluro_router_test_2/page2/page_2_router.dart';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'i_router.dart';
import 'page1/screen_page_1.dart';
import 'page2/screen_page_2.dart';
import 'page1/page_1_router.dart';

class MyAppRouter {
  static final router = FluroRouter();

  static final List<IRouterProvider> _listRouter = [];

  static String screenPage1 = '/screen_page_1';
  static String screenPage2 = '/screen_page_2';

  static void initRouter() {
    router.define(screenPage1, handler: Handler(handlerFunc: (_, __) => const ScreenPage1()));
    router.define(screenPage2, handler: Handler(handlerFunc: (_, __) => const ScreenPage2()));

    _listRouter.clear();
    _listRouter.add(Page1Router());
    _listRouter.add(Page2Router());

    void initRouter(IRouterProvider routerProvider) {
      routerProvider.initRouter(router);
    }

    _listRouter.forEach(initRouter);
  }
}