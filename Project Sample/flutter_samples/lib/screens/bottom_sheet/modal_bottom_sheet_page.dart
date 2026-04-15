import 'package:flutter/material.dart';

class ModalBottomSheetPage extends StatelessWidget {
  const ModalBottomSheetPage({super.key});

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          // Dùng Column để xếp các widget theo chiều dọc
          child: Column(
            mainAxisSize: MainAxisSize.min, // Giúp sheet chỉ cao bằng nội dung
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Chọn một hành động',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Chia sẻ'),
                onTap: () {
                  print('Đã chọn Chia sẻ');
                  Navigator.pop(context); // Đóng BottomSheet sau khi chọn
                },
              ),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Sao chép liên kết'),
                onTap: () {
                  print('Đã chọn Sao chép liên kết');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Chỉnh sửa'),
                onTap: () {
                  print('Đã chọn Chỉnh sửa');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ví dụ BottomSheet'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Mở Modal Bottom Sheet'),
          onPressed: () {
            // Gọi hàm để hiển thị bottom sheet
            _showBottomSheet(context);
          },
        ),
      ),
    );
  }
}
