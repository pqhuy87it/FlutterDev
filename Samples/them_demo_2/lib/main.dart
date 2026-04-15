import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Dùng watch ở đây để MaterialApp tự rebuild khi ThemeMode thay đổi
    final themeNotifier = context.watch<ThemeNotifier>();

    return MaterialApp(
      title: 'ThemeMode Demo',

      // ĐÂY LÀ BỘ BA QUYỀN LỰC
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.blue),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black26),
      ),
      themeMode: themeNotifier.themeMode, // <-- KẾT NỐI VỚI PROVIDER

      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dùng read ở đây để gọi hàm, không cần rebuild khi theme thay đổi
    final themeNotifier = context.read<ThemeNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ThemeMode Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Chế độ hiện tại:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            // Dùng watch ở đây vì chỉ có Text này cần rebuild
            Text(
              context.watch<ThemeNotifier>().currentThemeModeName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Gọi phương thức để chuyển đổi ThemeMode
          themeNotifier.cycleThemeMode();
        },
        label: const Text('Đổi chế độ'),
        icon: const Icon(Icons.sync),
      ),
    );
  }
}
