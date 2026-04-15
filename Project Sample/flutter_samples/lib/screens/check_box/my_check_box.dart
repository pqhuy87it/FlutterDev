import 'package:flutter/material.dart';

class MyCheckboxExample extends StatefulWidget {
  const MyCheckboxExample({super.key});

  @override
  State<MyCheckboxExample> createState() => _MyCheckboxExampleState();
}

class _MyCheckboxExampleState extends State<MyCheckboxExample> {
  // 1. Biến để lưu trữ trạng thái của checkbox
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 2. Widget Checkbox
            Checkbox(
              // 3. Gán trạng thái cho thuộc tính `value`
              value: _isChecked,
              // 4. Hàm được gọi khi người dùng tương tác
              onChanged: (bool? newValue) {
                // 5. Cập nhật trạng thái bên trong setState
                setState(() {
                  _isChecked = newValue!;
                });
              },
            ),
            const Text('Đồng ý với các điều khoản'),
          ],
        ),
      ),
    );
  }
}