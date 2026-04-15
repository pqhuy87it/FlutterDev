[DartPad](https://dartpad.dev/e7daebe11dacb21cfd5a8bc38049f7a7)
<img width="2482" height="648" alt="CleanShot 2025-11-23 at 10 11 15@2x" src="https://github.com/user-attachments/assets/2002efd1-0dde-489a-bb12-ecd1ef958992" />
```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white, // Nền trắng toàn màn hình
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Căn giữa màn hình
              children: [
                // 1. Hộp thông tin (Màu xám)
                const ErrorInfoBox(),
                
                const SizedBox(height: 30), // Khoảng cách giữa hộp và nút
                
                // 2. Nút bấm (Màu xanh)
                SizedBox(
                  width: double.infinity, // Nút rộng full màn hình
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // Xử lý sự kiện quay lại
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3E8E41), // Màu xanh lá đậm (giống ảnh)
                      foregroundColor: Colors.white, // Màu chữ
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // Bo góc nút
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '前画面へ戻る',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ErrorInfoBox extends StatelessWidget {
  const ErrorInfoBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA), // Màu nền xám nhạt
        borderRadius: BorderRadius.circular(6), // Bo góc nhẹ
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          // Tiêu đề
          Text(
            '想定される原因',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16),
          
          // Danh sách các nguyên nhân (Bullet points)
          BulletPointItem(text: '15歳未満の方の申し込み'),
          BulletPointItem(text: '住所が「東京都」以外の方の申し込み'),
          BulletPointItem(text: 'すでに申し込み、東京ポイントを受け取った方'),
          BulletPointItem(text: 'ネットワーク接続状況'),
        ],
      ),
    );
  }
}

// Widget con để tạo từng dòng gạch đầu dòng
class BulletPointItem extends StatelessWidget {
  final String text;

  const BulletPointItem({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ', 
            style: TextStyle(fontSize: 16, height: 1.4),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4, // Khoảng cách dòng giúp dễ đọc tiếng Nhật
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```
