import 'package:flutter/material.dart';

class FocusNodeExamplePage extends StatefulWidget {
  static String routeName = 'basics/focus_node_example';

  const FocusNodeExamplePage({super.key});

  @override
  State<FocusNodeExamplePage> createState() => _FocusNodeExamplePageState();
}

class _FocusNodeExamplePageState extends State<FocusNodeExamplePage> {
  // Bước 1: Khai báo
  late FocusNode _usernameFocusNode;
  late FocusNode _passwordFocusNode;

  @override
  void initState() {
    super.initState();
    _usernameFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();

    // Thêm một ví dụ về lắng nghe sự thay đổi focus
    _passwordFocusNode.addListener(() {
      // Dùng setState để build lại UI khi focus thay đổi
      // isFocused sẽ là true khi widget có focus, và ngược lại
      setState(() {
        // Có thể làm gì đó ở đây, ví dụ đổi màu viền
        print("Password field has focus: ${_passwordFocusNode.hasFocus}");
      });
    });
  }

  @override
  void dispose() {
    // Bước 3: Dọn dẹp
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _login() {
    // Đóng bàn phím bằng cách bỏ focus khỏi mọi thứ
    _passwordFocusNode.unfocus();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đang xử lý đăng nhập...')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Focus Node Example')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bước 2: Gắn FocusNode
            TextField(
              focusNode: _usernameFocusNode,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
              // Hiển thị nút "Next" trên bàn phím
              textInputAction: TextInputAction.next,
              // Bước 4: Điều khiển focus
              onSubmitted: (value) {
                // Khi nhấn "Next", chuyển focus đến password
                FocusScope.of(context).requestFocus(_passwordFocusNode);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              focusNode: _passwordFocusNode,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                // Ví dụ: Thay đổi màu viền khi có focus
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _passwordFocusNode.hasFocus
                        ? Colors.blue
                        : Colors.grey,
                    width: _passwordFocusNode.hasFocus ? 2.0 : 1.0,
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ),
              ),
              // Hiển thị nút "Done" trên bàn phím
              textInputAction: TextInputAction.done,
              onSubmitted: (value) {
                // Khi nhấn "Done", thực hiện hành động đăng nhập
                _login();
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(onPressed: _login, child: const Text('Login')),
          ],
        ),
      ),
    );
  }
}
