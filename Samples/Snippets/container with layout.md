[DartPad](https://dartpad.dev/9103c80b1cff44d2a4ece384c0cabd3c)
<img width="2486" height="1008" alt="CleanShot 2025-11-23 at 10 19 14@2x" src="https://github.com/user-attachments/assets/e514bea0-ef44-4eb4-bdd2-bae39b26ac59" />
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
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Badge STEP 1
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8EFDE), // Màu nền xanh nhạt
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "STEP 1",
                    style: TextStyle(
                      color: Color(0xFF007F3D), // Màu chữ xanh đậm
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),

                // 2. Tiêu đề chính
                const Text(
                  "認証に必要なものを準備",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 16),

                // 3. Đoạn văn mô tả
                const Text(
                  "お手元のスマートフォンで手続きを進めます。",
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
                
                const SizedBox(height: 8),

                // 4. Các dòng lưu ý (màu xám)
                const Text(
                  "※タッチ機能（NFC）に対応していないスマートフォンでは、操作を進めることはできません。",
                  style: TextStyle(color: Colors.grey, height: 1.5, fontSize: 14),
                ),
                const SizedBox(height: 8),
                const Text(
                  "※下記の利用者証明用電子証明書の暗証番号と券面事項入力補助用の暗証番号は、マイナンバーカード交付時に登録をした番号です。",
                  style: TextStyle(color: Colors.grey, height: 1.5, fontSize: 14),
                ),

                const SizedBox(height: 30),

                // 5. Các thẻ thông tin (Card)
                
                // Card 1: Thẻ My Number
                _buildInfoCard(
                  icon: const Icon(Icons.chrome_reader_mode, color: Colors.orange, size: 40),
                  // Lưu ý: Nếu có ảnh asset thật thì dùng Image.asset(...) thay vì Icon
                  title: "マイナンバーカード",
                ),

                const SizedBox(height: 12),

                // Card 2: Khóa màu xanh lá
                _buildInfoCard(
                  icon: const Icon(Icons.lock_outline, color: Colors.green, size: 40),
                  title: "利用者証明用電子証明書の暗証番号\n(4桁の数字)",
                ),

                const SizedBox(height: 12),

                // Card 3: Khóa màu xanh dương
                _buildInfoCard(
                  icon: const Icon(Icons.lock_outline, color: Colors.blue, size: 40),
                  title: "券面事項入力補助用の暗証番号\n(4桁の数字)",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget tái sử dụng cho các thẻ thông tin
  Widget _buildInfoCard({required Widget icon, required String title}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA), // Màu nền xám rất nhạt
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Phần Icon bên trái
          SizedBox(
            width: 50,
            child: Center(child: icon),
          ),
          const SizedBox(width: 16),
          // Phần Text bên phải
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```
