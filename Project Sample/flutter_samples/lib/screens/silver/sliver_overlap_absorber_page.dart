import 'package:flutter/material.dart';

class SliverOverlapAbsorberPage extends StatefulWidget {
  const SliverOverlapAbsorberPage({super.key});

  @override
  State<SliverOverlapAbsorberPage> createState() =>
      _SliverOverlapAbsorberPageState();
}

class _SliverOverlapAbsorberPageState extends State<SliverOverlapAbsorberPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          // BƯỚC 1: SỬ DỤNG SliverOverlapAbsorber
          return <Widget>[
            SliverOverlapAbsorber(
              // 'handle' là kênh giao tiếp giữa Absorber và Injector.
              // Chúng ta lấy nó từ context của NestedScrollView.
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                title: const Text('Overlap Solved'),
                pinned: true,
                forceElevated: innerBoxIsScrolled,
                bottom: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Tab 1'),
                    Tab(text: 'Tab 2'),
                    Tab(text: 'Tab 3'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            // Mỗi tab bây giờ sẽ chứa một Builder để có context riêng
            // và một CustomScrollView để chứa Injector.
            _buildTabContent('Tab 1'),
            _buildTabContent('Tab 2'),
            _buildTabContent('Tab 3'),
          ],
        ),
      ),
    );
  }

  // Hàm trợ giúp xây dựng nội dung cho mỗi tab
  Widget _buildTabContent(String tabName) {
    // Builder cung cấp một context mới nằm bên dưới NestedScrollView,
    // điều này rất quan trọng để handle hoạt động chính xác.
    return Builder(
      builder: (BuildContext context) {
        // Nội dung của mỗi tab phải là một CustomScrollView
        return CustomScrollView(
          // Key để giữ trạng thái cuộn khi chuyển tab
          key: PageStorageKey<String>(tabName),
          slivers: <Widget>[
            // BƯỚC 2: SỬ DỤNG SliverOverlapInjector
            // Nó phải là sliver ĐẦU TIÊN!
            SliverOverlapInjector(
              // Sử dụng cùng một handle đã được cung cấp cho Absorber.
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            // Bây giờ mới đến nội dung thực sự của danh sách,
            // được bọc trong một sliver khác như SliverList.
            SliverList(
              delegate: SliverChildBuilderDelegate((
                BuildContext context,
                int index,
              ) {
                return ListTile(title: Text('$tabName - Item ${index + 1}'));
              }, childCount: 30),
            ),
          ],
        );
      },
    );
  }
}
