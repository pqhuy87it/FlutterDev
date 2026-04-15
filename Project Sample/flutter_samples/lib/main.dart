import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project_samples/screens/home_page.dart';
import 'package:provider/provider.dart';
import 'package:project_samples/screens/provider/user_settings.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => UserSettings())],
      child: FlutterExamplesApp(),
    ),
  );
}

class FlutterExamplesApp extends StatelessWidget {
  FlutterExamplesApp({super.key});

  // Tạo các bảng màu
  final lightColorScheme = ColorScheme.fromSeed(seedColor: Colors.teal);
  final darkColorScheme = ColorScheme.fromSeed(
    seedColor: Colors.teal,
    brightness: Brightness.dark,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Examples',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
        // appBarTheme: AppBarThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: lightColorScheme.surface,
          foregroundColor: lightColorScheme.onSurface,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
        // appBarTheme: AppBarThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: darkColorScheme.surface,
          foregroundColor: darkColorScheme.onSurface,
        ),
      ),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
      routes: [
        for (final example in basicExamples)
          GoRoute(
            path: example.route,
            builder: (context, state) => example.builder(context),
          ),
      ],
    ),
  ],
);
