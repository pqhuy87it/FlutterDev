import 'package:flutter/material.dart';

class DrawerExamplePage extends StatelessWidget {
  static String routeName = 'basics/drawer_example';

  const DrawerExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. AppBar: Flutter sẽ tự động thêm icon menu để mở Drawer
      appBar: AppBar(
        title: const Text('Học về Drawer'),
        backgroundColor: Colors.teal,
      ),
      body: const Center(
        child: Text('Chào mừng đến với ứng dụng của tôi!'),
      ),
      // 2. Đây là nơi chúng ta định nghĩa Drawer
      drawer: Drawer(
        child: ListView(
          // Quan trọng: Xóa padding mặc định của ListView
          padding: EdgeInsets.zero,
          children: <Widget>[
            // 3. DrawerHeader: Phần đầu của Drawer
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.teal,
              ),
              child: Text(
                'Menu chính',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            // 4. ListTile: Các mục trong menu
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Trang chủ'),
              onTap: () {
                // Xử lý khi nhấn vào Trang chủ
                print('Đã nhấn vào Trang chủ');
                // Quan trọng: Đóng Drawer sau khi nhấn
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Tài khoản'),
              onTap: () {
                // Xử lý khi nhấn vào Tài khoản
                print('Đã nhấn vào Tài khoản');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Cài đặt'),
              onTap: () {
                // Xử lý khi nhấn vào Cài đặt
                print('Đã nhấn vào Cài đặt');
                Navigator.pop(context);
              },
            ),
            const Divider(), // Đường kẻ phân cách
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Đăng xuất'),
              onTap: () {
                // Xử lý đăng xuất
                print('Đã nhấn vào Đăng xuất');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
