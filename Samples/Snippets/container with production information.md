[Dartpad](https://dartpad.dev)
<img width="1266" height="478" alt="CleanShot 2025-11-23 at 11 31 48@2x" src="https://github.com/user-attachments/assets/3f90557a-8335-4ec2-9cca-dd4c3e9b20a2" />
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
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: const BunaProductCard(),
          ),
        ),
      ),
    );
  }
}

class BunaProductCard extends StatelessWidget {
  const BunaProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5), // Màu nền xám nhạt
        borderRadius: BorderRadius.circular(24), // Bo góc thẻ
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- CỘT BÊN TRÁI (Thông tin) ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Tiêu đề
                const Text(
                  "Buna. Fits for your tuna.\nBuy one, get second for FREE. Limited deal",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800, // Chữ đậm
                    height: 1.2, // Khoảng cách dòng
                    color: Colors.black,
                  ),
                ),
                
                const SizedBox(height: 12),

                // 2. Thông tin loại và thời gian
                Row(
                  children: [
                    const Icon(Icons.menu_book, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      "Non-fiction • 1 hr 50 min",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // 3. Đánh giá (Rating)
                Row(
                  children: [
                    const Text(
                      "4.6",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Tạo 5 ngôi sao
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          // Giả lập 4.5 sao (ngôi sao cuối cùng outline hoặc half)
                          // Ở đây để đơn giản tôi để 4 sao full và 1 sao rỗng
                          index < 4 ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 18,
                        );
                      }),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "(128)",
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 4. Nút bấm (Add to cart)
                SizedBox(
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 0, // Không đổ bóng
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFE0E0E0)), // Viền xám nhẹ
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    child: const Text(
                      "Add to cart",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16), // Khoảng cách giữa chữ và ảnh

          // --- CỘT BÊN PHẢI (Hình ảnh) ---
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              // Link ảnh mẫu (Coffee bag mock)
              'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
              width: 110,
              height: 160,
              fit: BoxFit.cover,
              // Xử lý khi ảnh load lỗi
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 110,
                  height: 160,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, color: Colors.grey),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```
