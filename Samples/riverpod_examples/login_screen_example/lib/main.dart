import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'global/variable.dart';

void main() async {
  // Đảm bảo Flutter đã được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();

  // Lấy đối tượng SharedPreferences trước khi chạy app
  final prefs = await SharedPreferences.getInstance();
  globalSharedPreferences = prefs;

  runApp(
    ProviderScope(
      overrides: [
        // Ghi đè provider để cung cấp đối tượng prefs đã được khởi tạo
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lắng nghe trạng thái xác thực
    final authState = ref.watch(authNotifierProvider);

    return MaterialApp(
      title: 'Riverpod Login Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      // Dựa vào username trong trạng thái để quyết định hiển thị màn hình nào
      // Nếu username khác null -> đã đăng nhập -> HomeScreen
      // Nếu username là null -> chưa đăng nhập -> LoginScreen
      home: authState.username != null
          ? const HomeScreen()
          : const LoginScreen(),
    );
  }
}
