import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BaseScreen extends StatelessWidget {
  final String title;
  final VoidCallback? onNext;

  const BaseScreen({super.key, required this.title, this.onNext});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Màn hình $title")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Đây là màn hình $title", style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            if (onNext != null)
              ElevatedButton(
                onPressed: onNext,
                child: Text("Đi tới màn hình tiếp theo"),
              ),
            // Thêm nút về trang chủ để test
            if (title != 'A')
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text("Về trang chủ (Screen A)"),
              ),
          ],
        ),
      ),
    );
  }
}