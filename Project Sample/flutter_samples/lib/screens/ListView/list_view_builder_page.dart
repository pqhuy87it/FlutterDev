import 'package:flutter/material.dart';

class ListViewBuilderPage extends StatelessWidget {
  const ListViewBuilderPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Chuẩn bị dữ liệu mẫu
    final List<String> items = List<String>.generate(100, (i) => 'Mục số ${i + 1}');

    return Scaffold(
      appBar: AppBar(title: const Text('List View Builder')),
      body: ListView.builder(
        itemCount: items.length, // Cung cấp tổng số mục
        itemBuilder: (BuildContext context, int index) {
          // Xây dựng giao diện cho từng mục
          return ListTile(
            title: Text(items[index]),
            leading: CircleAvatar(child: Text('${index + 1}')),
          );
        },
      ),
    );
  }
}
