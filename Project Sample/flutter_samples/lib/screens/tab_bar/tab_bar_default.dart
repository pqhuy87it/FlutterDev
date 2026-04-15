import 'package:flutter/material.dart';

class TabBarDefaultPage extends StatelessWidget {
  const TabBarDefaultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Số lượng tab
      child: Scaffold(
        body: NestedScrollView(
          // NestedScrollView là một lựa chọn tốt cho kịch bản này
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                title: Text('Profile'),
                pinned: true, // Ghim AppBar lại
                floating: true,
              ),
              // 2. Sử dụng SliverPersistentHeader
              SliverPersistentHeader(
                delegate: MyTabBarDelegate(
                  tabBar: TabBar(
                    tabs: [
                      Tab(text: 'Bài viết'),
                      Tab(text: 'Ảnh'),
                      Tab(text: 'Bạn bè'),
                    ],
                  ),
                ),
                pinned: true, // QUAN TRỌNG: Ghim TabBar lại ở trên cùng
              ),
            ];
          },
          // 3. Nội dung của các tab
          body: TabBarView(
            children: [
              // Nội dung cho tab 1 (một danh sách dài để cuộn)
              ListView.builder(
                itemCount: 50,
                itemBuilder: (context, index) =>
                    ListTile(title: Text('Bài viết số ${index + 1}')),
              ),
              Center(child: Text('Nội dung trang Ảnh')),
              Center(child: Text('Nội dung trang Bạn bè')),
            ],
          ),
        ),
      ),
    );
  }
}

class MyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  MyTabBarDelegate({required this.tabBar});

  // maxExtent và minExtent sẽ là chiều cao của TabBar
  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  // Phương thức build, chỉ cần trả về TabBar
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // Bọc trong một Container có màu nền để không bị trong suốt
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor, // Hoặc một màu bạn muốn
      child: tabBar,
    );
  }

  // Nếu TabBar không bao giờ thay đổi, ta có thể trả về false
  @override
  bool shouldRebuild(MyTabBarDelegate oldDelegate) {
    return false;
  }
}
