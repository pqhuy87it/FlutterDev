import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PassDataPageArgument extends StatefulWidget {
  const PassDataPageArgument({super.key});

  @override
  State<PassDataPageArgument> createState() => _PassDataPageArgumentState();
}

class _PassDataPageArgumentState extends State<PassDataPageArgument> {
  String _userName = 'PrivateGPT';

  void _navigateToEditName() async {
    // 1. Tạo một đối tượng arguments
    final args = InputTextPageArgumentsData(
      pageTitle: 'Chỉnh sửa tên',
      hintText: 'Nhập họ và tên mới',
      initialValue: _userName,
      maxLength: 30,
    );

    // 2. Điều hướng và truyền đối tượng arguments
    // Chúng ta await kết quả trả về từ InputTextPage
    final result = await Navigator.pushNamed(
      context,
      '/inputText',
      arguments: args,
    );

    // 3. Xử lý kết quả trả về
    if (result != null && result is String) {
      setState(() {
        _userName = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Tên người dùng: $_userName', style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _navigateToEditName,
              child: const Text('Chỉnh sửa tên'),
            ),
          ],
        ),
      ),
    );
  }
}

class InputTextPage extends StatefulWidget {
  const InputTextPage({Key? key}) : super(key: key);

  @override
  State<InputTextPage> createState() => _InputTextPageState();
}

class _InputTextPageState extends State<InputTextPage> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  // Chúng ta không thể truy cập ModalRoute trong initState,
  // vì vậy chúng ta sẽ làm điều đó trong didChangeDependencies hoặc build.
  // build là cách đơn giản nhất cho ví dụ này.

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Lấy đối tượng arguments từ route
    final args = ModalRoute.of(context)!.settings.arguments as InputTextPageArgumentsData;

    // 2. Gán giá trị ban đầu cho controller (chỉ lần đầu)
    if (_controller.text.isEmpty) {
      _controller.text = args.initialValue;
    }

    return Scaffold(
      appBar: AppBar(
        // 3. Sử dụng dữ liệu từ arguments
        title: Text(args.pageTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLength: args.maxLength,
              decoration: InputDecoration(
                hintText: args.hintText,
                labelText: 'Giá trị mới',
              ),
              inputFormatters: [
                LengthLimitingTextInputFormatter(args.maxLength),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 4. Trả về dữ liệu mới khi nhấn nút Lưu
                Navigator.pop(context, _controller.text);
              },
              child: const Text('Lưu thay đổi'),
            ),
          ],
        ),
      ),
    );
  }
}

class InputTextPageArgumentsData {
  final String initialValue;
  final String pageTitle;
  final String hintText;
  final int maxLength;

  InputTextPageArgumentsData({
    this.initialValue = '', // Cung cấp giá trị mặc định để an toàn hơn
    required this.pageTitle,
    required this.hintText,
    this.maxLength = 100,
  });
}
