[DardPad](https://dartpad.dev/8f51e6dfd331571c94b8c96f021c78bd)

<img width="1247" height="427" alt="Untitled" src="https://github.com/user-attachments/assets/87380f03-43e2-447d-92ff-230a2d44e545" />

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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: const [
              SizedBox(height: 50),
              
              // TRƯỜNG HỢP 1: Giống ảnh số 1 (Mặc định/Không thay đổi)
              // isChanged = false
              InfoSection(
                title: "氏名",
                beforeValue: "山田太郎",
                afterValue: "山田太郎",
                isChanged: false,
              ),

              SizedBox(height: 24),

              // TRƯỜNG HỢP 2: Giống ảnh số 2 (Có thay đổi/Nhập liệu)
              // isChanged = true
              InfoSection(
                title: "住所",
                beforeValue: "東京都新宿区西新宿2丁目8−1",
                afterValue: "東京都新宿区西新宿3丁目8−1",
                isChanged: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoSection extends StatelessWidget {
  final String title;
  final String beforeValue;
  final String afterValue;
  final bool isChanged;

  const InfoSection({
    super.key,
    required this.title,
    required this.beforeValue,
    required this.afterValue,
    this.isChanged = false,
  });

  @override
  Widget build(BuildContext context) {
    // --- CẤU HÌNH MÀU SẮC DỰA TRÊN TRẠNG THÁI ---
    
    // Ảnh 1: Màu nền xám rất nhạt. Ảnh 2: Màu xanh nhạt.
    final backgroundColor = isChanged ? const Color(0xFFE2F0E5) : const Color(0xFFF9F9F9);
    
    // Ảnh 1: Không viền (hoặc trùng màu nền). Ảnh 2: Viền xanh đậm.
    final borderColor = isChanged ? const Color(0xFF2E7D32) : Colors.transparent;
    
    // Màu chữ tiêu đề
    final titleColor = Colors.black;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        // Chỉ hiện viền nếu có thay đổi (isChanged = true)
        border: isChanged ? Border.all(color: borderColor, width: 2.0) : null,
        borderRadius: BorderRadius.circular(12.0), // Bo góc mềm mại hơn
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Tiêu đề và Badge
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              // Chỉ hiện Badge khi isChanged = true (Giống ảnh 2)
              if (isChanged) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32), // Nền xanh đậm
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "変更あり",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ]
            ],
          ),
          const SizedBox(height: 16),

          // Dòng 1: Trước khi thay đổi (変更前)
          _buildInputRow(
            label: "変更前",
            value: beforeValue,
            textColor: Colors.black87, // Luôn màu đen
          ),
          
          const SizedBox(height: 12),

          // Dòng 2: Sau khi thay đổi (変更後)
          _buildInputRow(
            label: "変更後",
            value: afterValue,
            // Nếu giống ảnh 2 (isChanged = true) thì chữ màu xanh đậm và in đậm
            // Nếu giống ảnh 1 thì chữ màu đen bình thường
            textColor: isChanged ? const Color(0xFF2E7D32) : Colors.black87,
            isBold: isChanged, 
          ),
        ],
      ),
    );
  }

  // Widget con để tạo từng dòng nhập liệu
  Widget _buildInputRow({
    required String label,
    required String value,
    required Color textColor,
    bool isBold = false,
  }) {
    return Row(
      children: [
        // Label (Bên trái)
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.grey, // Màu xám cho label như trong ảnh
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        
        // Input Box (Bên phải)
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white, // Nền ô input luôn màu trắng
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300), // Viền xám nhạt cho ô input
            ),
            child: Text(
              value,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```
