import 'package:flutter/material.dart';

class SearchBarDemo1Page extends StatefulWidget {
  const SearchBarDemo1Page({super.key});

  @override
  State<SearchBarDemo1Page> createState() => _SearchBarDemo1PageState();
}

class _SearchBarDemo1PageState extends State<SearchBarDemo1Page> {
  // Dữ liệu gốc của chúng ta
  final List<String> allFruits = [
    'Apple',
    'Banana',
    'Orange',
    'Mango',
    'Pineapple',
    'Strawberry',
    'Blueberry',
    'Raspberry',
    'Grapes',
    'Watermelon',
    'Kiwi',
  ];

  // Biến để lưu kết quả tìm kiếm được chọn
  String? selectedFruit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Bar Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. SEARCHANCHOR: BỘ NÃO ĐIỀU KHIỂN
            SearchAnchor(
              // 2. BUILDER: Xây dựng thanh tìm kiếm ban đầu (SearchBar)
              builder: (BuildContext context, SearchController controller) {
                return SearchBar(
                  controller: controller,
                  // Kết nối controller
                  hintText: 'Tìm kiếm trái cây...',
                  // Bắt sự kiện khi người dùng nhấn vào thanh tìm kiếm
                  onTap: () {
                    controller.openView(); // Lệnh mở chế độ xem tìm kiếm
                  },
                  // Bắt sự kiện khi nội dung thay đổi (tùy chọn)
                  onChanged: (_) {
                    controller.openView();
                  },
                  leading: const Icon(Icons.search),
                );
              },

              // 3. SUGGESTIONSBUILDER: Xây dựng danh sách gợi ý
              suggestionsBuilder:
                  (BuildContext context, SearchController controller) {
                    // Lấy từ khóa người dùng đang gõ
                    final String query = controller.text;

                    // Lọc danh sách trái cây dựa trên từ khóa
                    final List<String> filteredFruits = allFruits.where((
                      fruit,
                    ) {
                      return fruit.toLowerCase().contains(query.toLowerCase());
                    }).toList();

                    // Trả về một danh sách các ListTile
                    return List.generate(filteredFruits.length, (int index) {
                      final String item = filteredFruits[index];
                      return ListTile(
                        title: Text(item),
                        // Bắt sự kiện khi người dùng chọn một gợi ý
                        onTap: () {
                          setState(() {
                            // Cập nhật UI với kết quả đã chọn
                            selectedFruit = item;
                            // ĐÓNG chế độ xem tìm kiếm và trả về kết quả
                            controller.closeView(item);

                            controller.text = '';
                          });
                        },
                      );
                    });
                  },
            ),

            const SizedBox(height: 24),

            // Hiển thị kết quả đã chọn
            if (selectedFruit != null)
              Text(
                'Bạn đã chọn: $selectedFruit',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
          ],
        ),
      ),
    );
  }
}
