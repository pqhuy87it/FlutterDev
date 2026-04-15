import 'package:flutter/material.dart';
import 'dart:math' as math; // Cần cho hàm max()

// Widget chính không thay đổi nhiều, chỉ cần lấy chiều cao của status bar
// và truyền nó vào delegate.
class TabBarDynamicHeader extends StatelessWidget {
  const TabBarDynamicHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // LẤY CHIỀU CAO CỦA VÙNG AN TOÀN PHÍA TRÊN (STATUS BAR)
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverPersistentHeader(
                delegate: DynamicHeaderWithTabBarDelegate(
                  // TRUYỀN CHIỀU CAO VÀO DELEGATE
                  statusBarHeight: statusBarHeight,
                  title: 'Hồ sơ của tôi',
                  imageUrl:
                      'https://www.hollywoodreporter.com/wp-content/uploads/2012/01/new_universal_logo_a_l.jpg',
                  tabBar: const TabBar(
                    tabs: [
                      Tab(icon: Icon(Icons.article), text: 'Bài viết'),
                      Tab(icon: Icon(Icons.photo), text: 'Ảnh'),
                      Tab(icon: Icon(Icons.people), text: 'Bạn bè'),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            children: [
              ListView.builder(
                itemCount: 50,
                itemBuilder: (context, index) =>
                    ListTile(title: Text('Bài viết số ${index + 1}')),
              ),
              GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemCount: 30,
                itemBuilder: (context, index) =>
                    Card(child: Center(child: Text('Ảnh ${index + 1}'))),
              ),
              const Center(child: Text('Danh sách bạn bè')),
            ],
          ),
        ),
      ),
    );
  }
}

class DynamicHeaderWithTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final String title;
  final String imageUrl;

  // THÊM BIẾN ĐỂ LƯU CHIỀU CAO STATUS BAR
  final double statusBarHeight;

  DynamicHeaderWithTabBarDelegate({
    required this.tabBar,
    required this.title,
    required this.imageUrl,
    // THÊM VÀO CONSTRUCTOR
    required this.statusBarHeight,
  });

  // CỘNG THÊM CHIỀU CAO STATUS BAR VÀO CẢ HAI
  @override
  double get maxExtent => 200.0 + tabBar.preferredSize.height + statusBarHeight;

  @override
  double get minExtent => tabBar.preferredSize.height + statusBarHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final double shrinkableHeight = maxExtent - minExtent;
    final progress = (shrinkOffset / shrinkableHeight).clamp(0.0, 1.0);
    final contentOpacity = math.max(0.0, 1.0 - (progress * 2));

    // Sử dụng một Container để có nền, tránh các vệt lạ khi cuộn quá
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Lớp dưới cùng: Nền banner (Image)
          // Ảnh nền vẫn bắt đầu từ top: 0 để tràn ra sau status bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            // Chiều cao của ảnh sẽ co lại nhưng vẫn tính cả phần status bar
            height: maxExtent - shrinkOffset - tabBar.preferredSize.height,
            child: Opacity(
              opacity: contentOpacity,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.3),
                colorBlendMode: BlendMode.darken,
              ),
            ),
          ),

          // Lớp trên: Nội dung (Title và TabBar)
          // Chúng ta sẽ đặt nội dung này vào một Column để dễ dàng thêm padding
          Positioned.fill(
            child: Column(
              children: [
                // 1. Đệm an toàn ở trên cùng
                SizedBox(height: statusBarHeight),

                // 2. Vùng chứa tiêu đề, nó sẽ co giãn
                Expanded(
                  child: Opacity(
                    opacity: contentOpacity,
                    child: Center(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(blurRadius: 4, color: Colors.black54),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // 3. TabBar ở dưới cùng của header
                Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: tabBar,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(DynamicHeaderWithTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar ||
        title != oldDelegate.title ||
        imageUrl != oldDelegate.imageUrl ||
        statusBarHeight != oldDelegate.statusBarHeight;
  }
}
