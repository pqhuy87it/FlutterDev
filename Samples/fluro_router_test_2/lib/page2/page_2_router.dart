import 'package:fluro/fluro.dart';
import 'package:fluro_router_test_2/i_router.dart';
import 'screen_page_2_1.dart';
import 'screen_page_2_2.dart';

class Page2Router implements IRouterProvider {
  static String screenPage2_1 = '/screen_page_2/screen_page_2_1';
  static String screenPage2_2 = '/screen_page_2/screen_page_2_2';

  @override
  void initRouter(FluroRouter router) {
    router.define(screenPage2_1, handler: Handler(handlerFunc: (_, __) => const ScreenPage2_1()));
    router.define(screenPage2_2, handler: Handler(handlerFunc: (_, __) => const ScreenPage2_2()));
  }
}