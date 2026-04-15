import 'package:deep_link_sample/screen_a.dart';
import 'package:deep_link_sample/screen_b.dart';
import 'package:deep_link_sample/screen_c.dart';
import 'package:deep_link_sample/screen_d.dart';
import 'package:deep_link_sample/screen_e.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const MyApp());
}

// Định nghĩa Router
final GoRouter _router = GoRouter(
  initialLocation: '/',
  // Debug log để xem quá trình điều hướng
  debugLogDiagnostics: true,
  routes: <RouteBase>[
    // MÀN HÌNH A (GỐC)
    GoRoute(
      path: '/',
      builder: (context, state) => const ScreenA(),
      // Khai báo các màn hình con của A
      routes: [
        // MÀN HÌNH B (Url sẽ là /b)
        GoRoute(
          path: 'b', // Lưu ý: không có dấu '/' ở trước khi là route con
          builder: (context, state) => const ScreenB(),
          routes: [
            // MÀN HÌNH C (Url sẽ là /b/c)
            GoRoute(
              path: 'c',
              builder: (context, state) => const ScreenC(),
              routes: [
                // MÀN HÌNH D (Url sẽ là /b/c/d)
                GoRoute(
                  path: 'd',
                  builder: (context, state) => const ScreenD(),
                  routes: [
                    // MÀN HÌNH E (Url sẽ là /b/c/d/e)
                    GoRoute(
                      path: 'e',
                      builder: (context, state) => const ScreenE(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GoRouter Deep Link',
      // Cấu hình GoRouter vào MaterialApp
      routerConfig: _router,
    );
  }
}
