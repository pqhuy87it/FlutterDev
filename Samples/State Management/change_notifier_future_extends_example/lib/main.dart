import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_profile_notifier.dart'; // Import file notifier

void main() {
  runApp(
    // Cung cấp UserProfileNotifier cho cây widget
    ChangeNotifierProvider(
      create: (BuildContext context) => UserProfileNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notifier & Future Demo',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const ProfilePage(),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Lắng nghe notifier để rebuild UI khi có thay đổi
    final profileNotifier = context.watch<UserProfileNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hồ sơ người dùng"),
        actions: [
          // Nút refresh để gọi lại hàm fetch
          IconButton(
            icon: const Icon(Icons.refresh),
            // Chỉ cho phép nhấn khi không đang tải
            onPressed: profileNotifier.isLoading
                ? null
                : () {
              // Dùng context.read để gọi hàm mà không gây rebuild
              context.read<UserProfileNotifier>().fetchUserProfile();
            },
          ),
        ],
      ),
      body: Center(
        child: _buildBody(context, profileNotifier),
      ),
    );
  }

  // Tách logic hiển thị ra một widget riêng cho dễ đọc
  Widget _buildBody(BuildContext context, UserProfileNotifier notifier) {
    if (notifier.isLoading) {
      return const CircularProgressIndicator();
    }

    if (notifier.error != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          notifier.error!,
          style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (notifier.userProfile != null) {
      return Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person, size: 60, color: Colors.indigo),
              const SizedBox(height: 16),
              Text(
                notifier.userProfile!.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                notifier.userProfile!.email,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    // Trạng thái ban đầu
    return const Text("Nhấn nút refresh để tải hồ sơ.");
  }
}