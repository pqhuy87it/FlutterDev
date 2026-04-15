import 'package:flutter/material.dart';

class InkWellDemo1 extends StatelessWidget {
  const InkWellDemo1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('InkWell Demo')),
      body: Center(
        // Dùng Material để InkWell có thể vẽ hiệu ứng
        child: Material(
          color: Colors.amber,
          borderRadius: BorderRadius.circular(20), // Bo góc cho Material
          elevation: 5, // Tạo hiệu ứng đổ bóng
          child: InkWell(
            // Cung cấp cùng một borderRadius để hiệu ứng không bị tràn
            borderRadius: BorderRadius.circular(20),
            splashColor: Colors.red.withOpacity(0.5), // Tùy chỉnh màu splash
            onTap: () {
              print('Nút tùy chỉnh được nhấn!');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Button tapped!')),
              );
            },
            child: Container(
              // Container không cần màu vì Material đã có màu
              // Container không cần decoration vì Material đã xử lý bo góc và đổ bóng
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              child: Text(
                'Nhấn vào tôi',
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
