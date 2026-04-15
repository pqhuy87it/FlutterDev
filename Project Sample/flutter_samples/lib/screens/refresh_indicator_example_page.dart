import 'package:flutter/material.dart';

class RefreshIndicatorExamplePage extends StatefulWidget {
  static String routeName = 'basics/refresh_indicator_example';

  const RefreshIndicatorExamplePage({super.key});

  @override
  State<RefreshIndicatorExamplePage> createState() =>
      _RefreshIndicatorExamplePageState();
}

class _RefreshIndicatorExamplePageState
    extends State<RefreshIndicatorExamplePage> {
  // Danh sách dữ liệu ban đầu
  List<String> items = List.generate(10, (index) => 'Mục số ${index + 1}');
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  // Hàm xử lý việc làm mới dữ liệu
  // Hàm này bắt buộc phải trả về một Future<void>
  Future<void> _handleRefresh() async {
    // Giả lập việc gọi API mất 2 giây
    await Future.delayed(const Duration(seconds: 2));

    // Cập nhật lại state với dữ liệu mới
    setState(() {
      int newItemNumber = items.length + 1;
      items.add('Mục mới ${newItemNumber}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ví dụ RefreshIndicator')),
      body: RefreshIndicator(
        // key này không bắt buộc nhưng hữu ích nếu bạn muốn kích hoạt refresh từ code
        key: _refreshIndicatorKey,
        // Hàm callback sẽ được gọi khi người dùng kéo xuống
        onRefresh: _handleRefresh,
        // Child phải là một widget có thể cuộn
        child: ListView.builder(
          // Thêm physics để đảm bảo cuộn luôn hoạt động, ngay cả khi ít item
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return ListTile(title: Text(items[index]));
          },
        ),
      ),
    );
  }
}
