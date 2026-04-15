import 'package:flutter/material.dart';
import 'package:project_samples/utils/layout_spacer.dart';

class SwitchExamplePage extends StatefulWidget {
  static String routeName = 'basics/switch_example';

  const SwitchExamplePage({super.key});

  @override
  State<SwitchExamplePage> createState() => _SwitchExamplePageState();
}

class _SwitchExamplePageState extends State<SwitchExamplePage> {
  // 1. Biến trạng thái để lưu giá trị của Switch (bật/tắt)
  bool _isSwitched = false; // Giá trị ban đầu là 'tắt'
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Switch Example')),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: <Widget>[
          Row(
            children: [
              Switch(
                // 2. `value`: Thuộc tính bắt buộc, quyết định trạng thái hiện tại của Switch.
                // Nó nhận vào một biến boolean.
                value: _isSwitched,

                // 3. `onChanged`: Thuộc tính bắt buộc, là một hàm callback.
                // Hàm này sẽ được gọi mỗi khi người dùng gạt công tắc.
                // Nó nhận vào một giá trị boolean mới (newValue) là trạng thái mới của công tắc.
                onChanged: (bool newValue) {
                  // 4. Cập nhật trạng thái và rebuild UI
                  // Bạn PHẢI gọi setState để cập nhật biến trạng thái và
                  // báo cho Flutter biết cần vẽ lại widget với giá trị mới.
                  setState(() {
                    _isSwitched = newValue;
                  });

                  // Bạn có thể thực hiện các hành động khác ở đây
                  print('Giá trị mới của Switch là: $_isSwitched');
                },
              ),
            ],
          ),
          SizedBox(width: 20.0),
          Row(
            children: [
              Switch(
                value: _isSwitched,
                onChanged: (value) {
                  setState(() {
                    _isSwitched = value;
                  });
                },
                // activeThumbColor: Colors.green, // Màu khi bật
                inactiveThumbColor: Colors.grey, // Màu núm gạt khi tắt
                inactiveTrackColor: Colors.red[200], // Màu rãnh khi tắt
              )
            ],
          ),
          SizedBox(width: 20.0),
          Column(
            children: [
              SwitchListTile(
                title: const Text('Bật thông báo'),
                subtitle: const Text('Nhận thông báo về các cập nhật quan trọng.'),
                secondary: const Icon(Icons.notifications), // Icon ở đầu dòng
                value: _notificationsEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Chế độ ban đêm'),
                value: _darkModeEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _darkModeEnabled = value;
                    // Thêm logic để thay đổi theme của ứng dụng ở đây
                  });
                },
              ),
              // Một SwitchListTile bị vô hiệu hóa
              SwitchListTile(
                title: const Text('Tính năng cao cấp (vô hiệu hóa)'),
                value: false,
                onChanged: null, // Truyền null để vô hiệu hóa
              ),
            ],
          ),
          SizedBox(width: 20.0),
          Row(
            children: [
              Switch.adaptive(
                value: _isSwitched,
                onChanged: (value) {
                  setState(() {
                    _isSwitched = value;
                  });
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}
