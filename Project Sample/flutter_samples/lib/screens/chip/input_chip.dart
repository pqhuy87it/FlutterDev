import 'package:flutter/material.dart';

class MyInputChip extends StatefulWidget {
  const MyInputChip({super.key});

  @override
  State<MyInputChip> createState() => _MyInputChipState();
}

class _MyInputChipState extends State<MyInputChip> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    // Chỉ hiển thị chip nếu nó chưa bị xóa
    return _isVisible
        ? InputChip(
      label: const Text('example@gmail.com'),
      avatar: const CircleAvatar(
        child: Icon(Icons.person),
      ),
      // Hành động khi nhấn vào chip (ví dụ: xem chi tiết)
      onPressed: () {
        print('Xem chi tiết liên hệ');
      },
      // Hành động khi nhấn nút xóa
      onDeleted: () {
        setState(() {
          _isVisible = false; // Ẩn chip đi
        });
      },
    )
        : const SizedBox.shrink(); // Widget rỗng khi chip đã bị xóa
  }
}