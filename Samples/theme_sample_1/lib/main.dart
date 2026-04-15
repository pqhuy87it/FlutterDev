import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:theme_sample_1/theme_provider.dart';

void main() {
  runApp(
    // 1. Bọc ứng dụng của bạn bằng ChangeNotifierProvider
    ChangeNotifierProvider(
      // 2. Tạo một instance của ThemeNotifier
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'Provider Dark Mode',
          // 4. Kết nối themeMode của MaterialApp với themeMode trong Notifier
          themeMode: themeNotifier.themeMode,

          // 5. Định nghĩa theme cho chế độ Sáng
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            useMaterial3: true,
          ),

          // 6. Định nghĩa theme cho chế độ Tối
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.indigo,
            useMaterial3: true,
          ),

          home: const MyHomePage(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // Lấy themeNotifier để kiểm tra trạng thái hiện tại
    // Dùng context.watch để widget này rebuild khi theme thay đổi
    final themeNotifier = context.watch<ThemeNotifier>();
    final isDarkMode = themeNotifier.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          // Nút chuyển đổi theme
          Switch(
            value: isDarkMode,
            onChanged: (value) {
              // Dùng context.read để gọi một phương thức
              // Nó sẽ không làm widget này rebuild một cách không cần thiết
              context.read<ThemeNotifier>().toggleTheme();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
              size: 100,
            ),
            const SizedBox(height: 20),
            Text(
              'Chế độ hiện tại: ${isDarkMode ? "Tối" : "Sáng"}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}
