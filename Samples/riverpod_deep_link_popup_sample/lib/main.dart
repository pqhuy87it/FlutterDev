import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_deep_link_sample/screen_a.dart';
import 'package:riverpod_deep_link_sample/screen_b.dart';
import 'package:riverpod_deep_link_sample/screen_c.dart';
import 'package:riverpod_deep_link_sample/screen_d.dart';
import 'package:riverpod_deep_link_sample/screen_e.dart';

import 'app_link_controller.dart';
import 'navigation_listener.dart';
import 'navigation_service.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});
  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Khởi tạo Controller logic
    ref.read(appLinkControllerProvider);
  }

  @override
  Widget build(BuildContext context) {
    final navService = ref.watch(navigationServiceProvider);

    return MaterialApp(
      // Gán observer để Service biết đang ở màn hình nào
      navigatorKey: navService.navigatorKey,
      navigatorObservers: [navService],
      initialRoute: '/',
      routes: {
        '/': (context) => const ScreenA(),
        '/screen_b': (context) => const ScreenB(),
        '/screen_c': (context) => const ScreenC(),
        '/screen_d': (context) => const ScreenD(),
        '/screen_e': (context) => const ScreenE(),
      },
      // QUAN TRỌNG: Sử dụng builder để chèn NavigationListener
      // Listener này sẽ có context chứa Navigator do MaterialApp tạo ra
      builder: (context, child) {
        return NavigationListener(
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}
