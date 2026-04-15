import 'package:flutter/material.dart';

// Giả lập class Anne và dữ liệu
class Anne {
  static const filters = {
    'Color': '🎨', // Dùng emoji cho đơn giản
    'Size': '📏',
    'Price': '💰',
    'Brand': '🏷️',
  };
}

// Widget Filtercards tùy chỉnh
class Filtercards extends StatelessWidget {
  final String title;
  final String imgUrl; // Ở đây là emoji

  const Filtercards({Key? key, required this.title, required this.imgUrl})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(imgUrl, style: TextStyle(fontSize: 30)),
            SizedBox(height: 4),
            Text(title),
          ],
        ),
      ),
    );
  }
}

class IterableExamplePage extends StatelessWidget {
  static String routeName = 'basics/iterable_example';

  const IterableExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dynamic Filters')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Áp dụng đoạn code của bạn ở đây!
            ...Anne.filters.entries.map((aFilter) {
              return Filtercards(title: aFilter.key, imgUrl: aFilter.value);
            }),
          ],
        ),
      ),
    );
  }
}
