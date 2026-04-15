[DartPad](https://dartpad.dev/26cbd74f63b946d0d2c18d97d270a3d5)
<img width="1054" height="886" alt="CleanShot 2025-11-23 at 14 39 09@2x" src="https://github.com/user-attachments/assets/5de2371b-b472-4368-a476-f0ffa5a2b78d" />
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
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: const BestsellingItemsCard(),
          ),
        ),
      ),
    );
  }
}

class BestsellingItemsCard extends StatelessWidget {
  const BestsellingItemsCard({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Bọc tất cả trong DefaultTabController (3 tabs)
    return DefaultTabController(
      length: 3, // Uptrend, Flat, Downtrend
      initialIndex: 2, // Mặc định chọn "Downtrend" giống ảnh
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 2. Widget TabBar được bọc Container để tạo nền xám
          Container(
            height: 45,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[200], // Màu nền xám của cả thanh
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              // --- Tùy chỉnh giao diện Tab ---
              indicatorSize: TabBarIndicatorSize.tab, // Indicator phủ kín tab
              dividerColor: Colors.transparent, // Ẩn đường kẻ ngăn cách mặc định
              
              // Tạo hiệu ứng "Thẻ trắng nổi lên" cho tab đang chọn
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              
              // Màu chữ
              labelColor: Colors.black, // Chữ khi chọn
              unselectedLabelColor: Colors.grey[600], // Chữ khi không chọn
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
              
              // Danh sách Tabs
              tabs: const [
                Tab(text: "Uptrend"),
                Tab(text: "Flat"),
                Tab(text: "Downtrend"),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 3. Header (Giữ nguyên vị trí cố định)
          const Text(
            "CONSUMPTION",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Bestselling Items",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Icon(Icons.help_outline, color: Colors.blue[200]),
            ],
          ),

          const SizedBox(height: 20),

          // 4. Nội dung thay đổi theo Tab (TabBarView)
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(), // Tắt vuốt ngang nếu muốn giống Web
              children: [
                // Nội dung Tab 1: Uptrend
                _buildDataTable(dataMode: "Uptrend"),
                
                // Nội dung Tab 2: Flat
                _buildDataTable(dataMode: "Flat"),
                
                // Nội dung Tab 3: Downtrend (Giống ảnh mẫu)
                _buildDataTable(dataMode: "Downtrend"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Hàm dựng bảng dữ liệu (Được tái sử dụng cho cả 3 tab)
  Widget _buildDataTable({required String dataMode}) {
    return Column(
      children: [
        // Header bảng
        _buildTableRow("ITEM", "GROSS", "NET", isHeader: true),
        const Divider(height: 1, thickness: 1),

        // Dữ liệu (Ở đây mình demo dữ liệu giống nhau, thực tế bạn sẽ truyền List khác nhau vào)
        _buildTableRow("Design systems", "1,256.50", "1,241.50"),
        const Divider(height: 1, thickness: 1),
        
        _buildTableRow("UI kits", "159.50", "149.50"),
        const Divider(height: 1, thickness: 1),
        
        _buildTableRow("Templates", "624.20", "584.20"),
        const Divider(height: 1, thickness: 1),
        
        _buildTableRow("Presentations", "96.00", "88.00"),
        const Divider(height: 1, thickness: 2),

        // Total
        _buildTableRow("Total ($dataMode)", "832.70", "732.70", isTotal: true),
      ],
    );
  }

  // Widget tạo dòng (Giữ nguyên logic cũ)
  Widget _buildTableRow(String col1, String col2, String col3,
      {bool isHeader = false, bool isTotal = false}) {
    
    TextStyle style = TextStyle(fontSize: 15, color: Colors.black87, height: 1.5);

    if (isHeader) {
      style = const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.0);
    }
    if (isTotal) {
      style = const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text(col1, style: style)),
          Expanded(flex: 2, child: Text(col2, textAlign: TextAlign.right, style: style)),
          Expanded(flex: 2, child: Text(col3, textAlign: TextAlign.right, style: style)),
        ],
      ),
    );
  }
}
```
