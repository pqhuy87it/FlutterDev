import 'package:flutter/material.dart';

class PassValueForward extends StatefulWidget {
  const PassValueForward({super.key});

  @override
  State<PassValueForward> createState() => _PassValueForwardState();
}

class _PassValueForwardState extends State<PassValueForward> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Trang chủ')),
      body: Center(
        child: ElevatedButton(
          child: Text('Xem chi tiết mục 123'),
          onPressed: () {
            // 3. Điều hướng và truyền dữ liệu
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(
                  itemId: '123',
                  message: 'Đây là dữ liệu từ Trang chủ',
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Màn hình B: DetailScreen.dart
class DetailScreen extends StatelessWidget {
  // 1. Khai báo các biến để lưu dữ liệu
  final String itemId;
  final String message;

  // 2. Thêm chúng vào constructor
  const DetailScreen({Key? key, required this.itemId, required this.message})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chi tiết mục $itemId')),
      body: Center(child: Text(message)),
    );
  }
}
