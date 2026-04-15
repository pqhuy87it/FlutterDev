import 'package:flutter/material.dart';

class DraggableScrollableSheetPage extends StatelessWidget {
  const DraggableScrollableSheetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DraggableScrollableSheet Demo')),
      // Sử dụng Stack để đặt sheet đè lên nội dung chính
      body: Stack(
        children: [
          // Nội dung nền (ví dụ: bản đồ, danh sách sản phẩm...)
          Center(
            child: Container(
              color: Colors.blue[100],
              alignment: Alignment.center,
              child: const Text('Đây là nội dung nền'),
            ),
          ),

          // DraggableScrollableSheet đây!
          DraggableScrollableSheet(
            // Kích thước ban đầu là 30% chiều cao
            initialChildSize: 0.3,
            // Kích thước nhỏ nhất là 15%
            minChildSize: 0.1,
            // Kích thước lớn nhất là 90%
            maxChildSize: 0.9,
            // Bật tính năng snap
            snap: true,
            // Các điểm neo khi snap
            snapSizes: const [0.3, 0.6, 0.9],

            // Hàm builder để xây dựng nội dung bên trong sheet
            builder: (BuildContext context, ScrollController scrollController) {
              // Bọc nội dung trong một Container để trang trí (bo góc, màu nền)
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                // Nội dung có thể cuộn được
                child: ListView.builder(
                  // !! Rất quan trọng: truyền scrollController vào đây
                  controller: scrollController,
                  itemCount: 50,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text('Mục số ${index + 1}'),
                      subtitle: const Text('Đây là nội dung mô tả'),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
