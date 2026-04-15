import 'package:flutter/material.dart';

class MyCheckboxListTileExample extends StatefulWidget {
  const MyCheckboxListTileExample({super.key});

  @override
  State<MyCheckboxListTileExample> createState() => _MyCheckboxListTileExampleState();
}

class _MyCheckboxListTileExampleState extends State<MyCheckboxListTileExample> {
  bool _isAgreed = false;
  bool _isSubscribed = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CheckboxListTile(
          title: const Text('Đồng ý với các điều khoản dịch vụ'),
          subtitle: const Text('Nhấn vào đây để đọc chi tiết'),
          value: _isAgreed,
          onChanged: (bool? newValue) {
            setState(() {
            });
          },
          // Đặt checkbox ở bên trái
          controlAffinity: ListTileControlAffinity.leading,
          // Làm cho checkbox có màu xanh khi được chọn
          activeColor: Colors.green,
        ),
        CheckboxListTile(
          title: const Text('Đăng ký nhận bản tin'),
          value: _isSubscribed,
          onChanged: (bool? newValue) {
            setState(() {
              _isSubscribed = newValue!;
            });
          },
          // controlAffinity mặc định là platform (iOS ở cuối, Android ở đầu)
          // hoặc có thể set là trailing để luôn ở cuối
        ),
      ],
    );
  }
}