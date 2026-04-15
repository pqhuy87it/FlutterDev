import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SaveDataScreen(),
    );
  }
}

class SaveDataScreen extends StatefulWidget {
  const SaveDataScreen({super.key});

  @override
  State<SaveDataScreen> createState() => _SaveDataScreenState();
}

class _SaveDataScreenState extends State<SaveDataScreen> {
  // Controller để quản lý văn bản trong TextField
  final TextEditingController _controller = TextEditingController();

  // Key để định danh dữ liệu trong SharedPreferences
  static const String _storageKey = 'user_input_data';

  @override
  void initState() {
    super.initState();
    // Gọi hàm load dữ liệu ngay khi màn hình được khởi tạo
    _loadData();
  }

  // Hàm load dữ liệu từ SharedPreferences
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Lấy chuỗi đã lưu, nếu chưa có thì lấy chuỗi rỗng ''
      _controller.text = prefs.getString(_storageKey) ?? '';
    });
  }

  // Hàm lưu dữ liệu vào SharedPreferences
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, _controller.text);

    // Hiển thị thông báo nhỏ
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu dữ liệu thành công!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lưu dữ liệu App Flutter')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Nhập nội dung cần lưu:"),
            const SizedBox(height: 10),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Nhập gì đó vào đây...',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _saveData,
              icon: const Icon(Icons.save),
              label: const Text("Lưu lại"),
            ),
          ],
        ),
      ),
    );
  }
}