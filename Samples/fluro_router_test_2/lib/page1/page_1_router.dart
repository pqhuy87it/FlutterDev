import 'package:fluro/fluro.dart';
import 'package:fluro_router_test_2/i_router.dart';
import 'screen_page_1_1.dart';
import 'screen_page_1_2.dart';

class Page1Router implements IRouterProvider {
  static String screenPage1_1 = '/screen_page_1/screen_page_1_1';
  static String screenPage1_2 = '/screen_page_1/screen_page_1_2';

  @override
  void initRouter(FluroRouter router) {
    router.define(screenPage1_1, handler: Handler(handlerFunc: (_, __) => const ScreenPage1_1()));
    router.define(screenPage1_2, handler: Handler(handlerFunc: (_, __) => const ScreenPage1_2()));
  }
}