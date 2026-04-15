[DartPad](https://dartpad.dev/3dcc6be158be7bde9363c3b67813c950)
<img width="598" height="141" alt="Screenshot 2025-11-23 at 11 47 13" src="https://github.com/user-attachments/assets/bdc804bc-ea75-46ff-a457-eec53b61d1bb" />
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
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.blue,
        // Loại bỏ hiệu ứng splash khi nhấn vào tab nếu muốn giống ảnh tĩnh hoàn toàn
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Danh sách các Tab
  final List<String> _tabs = const [
    "Cards",
    "Lists",
    "Accordions",
    "Icons",
    "Navigation"
  ];

  @override
  Widget build(BuildContext context) {
    // 1. Bọc Scaffold trong DefaultTabController
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Header (Giữ nguyên)
              const CustomHeader(),

              const SizedBox(height: 10),

              // 2. Widget TabBar tùy chỉnh
              Container(
                height: 60, // Chiều cao cho khu vực Tab
                alignment: Alignment.centerLeft,
                child: TabBar(
                  isScrollable: true, // Cho phép cuộn ngang
                  tabAlignment: TabAlignment.start, // Căn lề trái (Flutter 3.13+)
                  padding: const EdgeInsets.symmetric(horizontal: 10.0), // Padding tổng thể
                  
                  // --- Cấu hình Style ---
                  indicatorColor: Colors.transparent, // Ẩn thanh gạch chân mặc định
                  dividerColor: Colors.transparent, // Ẩn đường kẻ mờ ngăn cách
                  labelPadding: const EdgeInsets.symmetric(horizontal: 16.0), // Khoảng cách giữa các tab
                  
                  // Style cho Tab ĐANG CHỌN (To, Đậm, Đen)
                  labelColor: Colors.black,
                  labelStyle: const TextStyle(
                    fontSize: 28, 
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Arial',
                  ),
                  
                  // Style cho Tab KHÔNG CHỌN (Nhỏ, Thường, Xám)
                  unselectedLabelColor: Colors.grey.shade500,
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Arial',
                  ),

                  // Tạo danh sách Tabs từ mảng String
                  tabs: _tabs.map((String name) => Tab(text: name)).toList(),
                ),
              ),

              // 3. Nội dung tương ứng của từng Tab (TabBarView)
              Expanded(
                child: TabBarView(
                  children: _tabs.map((String name) {
                    // Ở đây bạn sẽ return các Widget màn hình thật (VD: CardsScreen, ListsScreen...)
                    // Demo tôi dùng Container hiển thị tên
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.layers, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            "$name Content", 
                            style: TextStyle(fontSize: 24, color: Colors.grey.shade400)
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Footer màu sắc (Giữ nguyên)
              const ColorfulBottomBar(),
            ],
          ),
        ),
      ),
    );
  }
}

// --- CÁC WIDGET PHỤ (HEADER & FOOTER) GIỮ NGUYÊN ---

class CustomHeader extends StatelessWidget {
  const CustomHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage('https://as2.ftcdn.net/v2/jpg/11/66/06/77/1000_F_1166067709_2SooAuPWXp20XkGev7oOT7nuK1VThCsN.jpg'),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("SET", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -2, height: 1.0)),
              Text("PRODUCT", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueAccent.shade700, letterSpacing: 2.0)),
            ],
          ),
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
            child: IconButton(icon: const Icon(Icons.filter_list, color: Colors.black), onPressed: () {}),
          ),
        ],
      ),
    );
  }
}

class ColorfulBottomBar extends StatelessWidget {
  const ColorfulBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 10,
      child: Row(
        children: [
          Expanded(child: Container(color: Colors.black)),
          Expanded(child: Container(color: Colors.red)),
          Expanded(child: Container(color: Colors.orange)),
          Expanded(child: Container(color: Colors.purple)),
          Expanded(child: Container(color: Colors.green)),
        ],
      ),
    );
  }
}
```
