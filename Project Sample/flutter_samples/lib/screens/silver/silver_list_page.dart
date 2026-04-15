import 'package:flutter/material.dart';

class SilverListPage extends StatelessWidget {
  const SilverListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // CustomScrollView là cái khung chứa các "mảnh ghép" Sliver
      body: CustomScrollView(
        // 'slivers' là một danh sách các mảnh ghép
        slivers: <Widget>[
          // Mảnh ghép 1: SliverAppBar để tạo hiệu ứng thanh app bar co dãn
          SliverAppBar(
            expandedHeight: 200.0, // Chiều cao khi mở rộng tối đa
            floating: false, // Không "trôi nổi" khi cuộn lên
            pinned: true, // "Ghim" lại khi cuộn lên trên cùng
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('SliverList Demo'),
              background: Image.network(
                'https://images.unsplash.com/photo-1542831371-29b0f74f9713',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Mảnh ghép 2: SliverList để hiển thị danh sách
          // Chúng ta dùng SliverChildBuilderDelegate để tối ưu cho danh sách dài
          SliverList(
            delegate: SliverChildBuilderDelegate(
              // Hàm này sẽ được gọi để xây dựng mỗi item trong danh sách
              (BuildContext context, int index) {
                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text('Item số ${index + 1}'),
                  subtitle: const Text('Đây là một item trong SliverList'),
                );
              },
              // Số lượng item trong danh sách (có thể là null nếu vô hạn)
              childCount: 50,
            ),
          ),
        ],
      ),
    );
  }
}
