import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'auth/auth_provider.dart';
import 'auth/auth_state.dart';
import 'models/navigation_item.dart';
import 'screens/login_screen.dart';
import 'screens/products_screen.dart';
// Import tất cả các màn hình khác...
import 'screens/profile_screen.dart';
// import 'screens/settings_screen.dart';
// import 'screens/posts_screen.dart';
// import 'screens/todos_screen.dart';
import 'widgets/scaffold_with_navigation.dart';

part 'router.g.dart';

// Placeholder screens for simplicity
class ProductScreen extends StatelessWidget {
  final int id;
  const ProductScreen(this.id, {super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('Product $id')));
}
// ... tạo các placeholder khác nếu cần

@riverpod
GoRouter router(RouterRef ref) {
  // Local notifier for the current auth state. The purpose of this notifier is
  // to provide a [Listenable] to the [GoRouter] exposed by this provider.
  final authStateNotifier = ValueNotifier(AuthState.unknown);
  ref
    ..onDispose(authStateNotifier.dispose)
    ..listen(currentAuthStateProvider, (_, value) {
      authStateNotifier.value = value;
    });

  final navigationItems = [
    NavigationItem(
      path: '/products',
      body: (_) => const ProductsScreen(),
      icon: Icons.widgets_outlined,
      selectedIcon: Icons.widgets,
      label: 'Products',
      routes: [
        GoRoute(
          path: ':id',
          builder: (_, state) {
            final id = int.parse(state.pathParameters['id']!);
            return ProductScreen(id);
          },
        ),
      ],
    ),
    // NavigationItem(
    //   path: '/todos',
    //   body: (_) => const TodosScreen(),
    //   icon: Icons.checklist_outlined,
    //   selectedIcon: Icons.checklist,
    //   label: 'Todos',
    // ),
    // NavigationItem(
    //   path: '/posts',
    //   body: (_) => const PostsScreen(),
    //   icon: Icons.article_outlined,
    //   selectedIcon: Icons.article,
    //   label: 'Posts',
    // ),
    NavigationItem(
      path: '/profile',
      body: (_) => const ProfileScreen(),
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'Profile',
    ),
  ];

  final router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/products',
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      // GoRoute(
      //   path: '/settings',
      //   builder: (_, __) => const SettingsScreen(),
      // ),
      // method 1
      /*
      ShellRoute(
        builder: (context, state, child) {
          // Tìm index của route hiện tại để highlight đúng mục
          final int selectedIndex = navigationItems.indexWhere((item) {
            final currentPath = state.uri.path;
            return currentPath.startsWith(item.path);
          });

          return ScaffoldWithNavigation(
            navigationItems: navigationItems,
            selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
            child: child,
          );
        },
        routes: [
          for (final item in navigationItems)
            GoRoute(
              path: item.path,
              builder: (context, state) => item.body(context),
              routes: item.routes,
            ),
        ],
      ),
       */
      // method 2
      ShellRoute(
        builder: (_, __, child) => child,
        routes: [
          for (final (index, item) in navigationItems.indexed)
            GoRoute(
              path: item.path,
              pageBuilder: (context, _) => NoTransitionPage(
                child: ScaffoldWithNavigation(
                  selectedIndex: index,
                  navigationItems: navigationItems,
                  child: item.body(context),
                ),
              ),
              routes: item.routes,
            ),
        ],
      ),
    ],
    refreshListenable: authStateNotifier,
    redirect: (context, state) {
      final authState = ref.read(currentAuthStateProvider);
      final isLoggingIn = state.matchedLocation == '/login';

      // Nếu chưa đăng nhập và không ở trang login, chuyển hướng đến login
      if (authState == AuthState.unauthenticated && !isLoggingIn) {
        return '/login';
      }

      // Nếu đã đăng nhập và đang ở trang login, chuyển hướng vào trang chủ
      if (authState == AuthState.authenticated && isLoggingIn) {
        return '/products';
      }

      return null;
    },
  );
  ref.onDispose(router.dispose);

  return router;
}
