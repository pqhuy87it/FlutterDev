import 'package:flutter/material.dart';

class PassValueRouteSetting extends StatelessWidget {
  const PassValueRouteSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Trang chủ')),
      body: Center(
        child: ElevatedButton(
          child: Text('Xem chi tiết mục 123'),
          onPressed: () {
            // 1. Truyền một đối tượng (hoặc Map, String,...) qua arguments
            Navigator.pushNamed(
              context,
              '/settings',
              arguments: 'Dữ liệu siêu bí mật',
            );
          },
        ),
      ),
    );
  }
}

// Màn hình B: SettingsScreen.dart
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Lấy arguments
    final String? args = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      appBar: AppBar(title: Text('Cài đặt')),
      body: Center(
        child: Text('Dữ liệu nhận được: ${args ?? "Không có"}'),
      ),
    );
  }
}
