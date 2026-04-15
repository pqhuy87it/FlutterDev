import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'models/navigation_item.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/profile_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/widgets/scaffold_with_navigation.dart';

void main() {
  runApp(const MyApp());
}

// Khóa GlobalKey cho NavigatorState để ShellRoute có thể truy cập
final _rootNavigatorKey = GlobalKey<NavigatorState>();

// Danh sách các mục điều hướng
final List<NavigationItem> navigationItems = [
  NavigationItem(
    path: '/home',
    label: 'Trang chủ',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
    body: (context) => const HomeScreen(),
  ),
  NavigationItem(
    path: '/profile',
    label: 'Hồ sơ',
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
    body: (context) => const ProfileScreen(),
  ),
  NavigationItem(
    path: '/settings',
    label: 'Cài đặt',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    body: (context) => const SettingsScreen(),
  ),
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/home', // Màn hình bắt đầu
      routes: [
        // Sử dụng ShellRoute để bọc các màn hình con bằng ScaffoldWithNavigation
        ShellRoute(
          // builder này sẽ tạo ra UI chung (cái "vỏ")
          builder: (context, state, child) {
            // Tìm index của route hiện tại để highlight đúng mục
            final int selectedIndex = navigationItems.indexWhere((item) {
              // So sánh path, ví dụ: '/home' == state.matchedLocation
              return item.path == state.matchedLocation;
            });

            return ScaffoldWithNavigation(
              navigationItems: navigationItems,
              selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
              child: child, // `child` chính là màn hình con (HomeScreen, etc.)
            );
          },
          // routes là danh sách các màn hình sẽ được hiển thị bên trong "vỏ"
          routes: [
            for (final item in navigationItems)
              GoRoute(
                path: item.path,
                // builder này tạo ra nội dung chính của màn hình
                builder: (context, state) => item.body(context),
              ),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Flutter Responsive Scaffold Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}