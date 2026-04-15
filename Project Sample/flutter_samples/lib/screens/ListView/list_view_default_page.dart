import 'package:flutter/material.dart';

class ListViewDefaultPage extends StatelessWidget {
  const ListViewDefaultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('List View Default')),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Bản đồ'),
            subtitle: const Text('Mục danh sách đầu tiên'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              /* Xử lý khi nhấn */
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_album),
            title: const Text('Album'),
            subtitle: const Text('Mục danh sách thứ hai'),
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text('Điện thoại'),
            subtitle: const Text('Mục danh sách thứ ba'),
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
        ],
      ),
    );
  }
}
