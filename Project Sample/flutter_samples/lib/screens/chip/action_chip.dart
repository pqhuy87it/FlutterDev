import 'package:flutter/material.dart';

class MyActionChip extends StatelessWidget {
  const MyActionChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ActionChip(
        avatar: const Icon(Icons.call),
        label: const Text('Gọi hỗ trợ'),
        onPressed: () {
          // Hiển thị một SnackBar hoặc Dialog khi nhấn
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đang thực hiện cuộc gọi...')),
          );
        },
      ),
    );
  }
}