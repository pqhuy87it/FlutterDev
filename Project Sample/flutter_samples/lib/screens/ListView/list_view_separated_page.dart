import 'package:flutter/material.dart';

class ListViewSeparatedPage extends StatelessWidget {
  const ListViewSeparatedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> items = List<String>.generate(
      50,
      (i) => 'Sản phẩm ${i + 1}',
    );

    return Scaffold(
      appBar: AppBar(title: const Text('List View Separated')),
      body: ListView.separated(
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(title: Text(items[index]), onTap: () {});
        },
        separatorBuilder: (BuildContext context, int index) {
          // Trả về widget phân cách
          return const Divider(
            color: Colors.grey,
            thickness: 1,
            indent: 16, // Khoảng trống bên trái
            endIndent: 16, // Khoảng trống bên phải
          );
        },
      ),
    );
  }
}
