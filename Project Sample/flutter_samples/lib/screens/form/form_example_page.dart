import 'package:flutter/material.dart';

class FormExamplePage extends StatefulWidget {
  static String routeName = 'basics/form_example';

  const FormExamplePage({super.key});

  @override
  State<FormExamplePage> createState() => _FormExamplePageState();
}

class _FormExamplePageState extends State<FormExamplePage> {
  // 1. Tạo GlobalKey để định danh và quản lý Form
  final _formKey = GlobalKey<FormState>();

  // Biến để lưu trữ dữ liệu sau khi form được lưu
  String _email = '';
  String _password = '';

  // Hàm xử lý khi nhấn nút Submit
  void _submitForm() {
    // 5. Kích hoạt validation
    final isValid = _formKey.currentState?.validate();

    // Nếu form không hợp lệ, không làm gì cả
    if (isValid == null || !isValid) {
      return;
    }

    // Nếu form hợp lệ, gọi onSaved trên từng TextFormField
    _formKey.currentState?.save();

    // In ra để kiểm tra
    print('Email: $_email');
    print('Password: $_password');

    // Hiển thị SnackBar thông báo thành công
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đăng nhập thành công!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 2. Xây dựng UI với Form widget
    return Scaffold(
      appBar: AppBar(title: Text('Form Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Gán key cho Form
          child: Column(
            children: [
              // 3. Sử dụng TextFormField cho email
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                // Logic validation
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập email.';
                  }
                  if (!value.contains('@')) {
                    return 'Email không hợp lệ.';
                  }
                  return null; // Hợp lệ
                },
                // Logic saving
                onSaved: (value) {
                  _email = value ?? '';
                },
              ),
              SizedBox(height: 16),
              // TextFormField cho mật khẩu
              TextFormField(
                decoration: InputDecoration(labelText: 'Mật khẩu'),
                obscureText: true, // Ẩn mật khẩu
                // Logic validation
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập mật khẩu.';
                  }
                  if (value.length < 6) {
                    return 'Mật khẩu phải có ít nhất 6 ký tự.';
                  }
                  return null; // Hợp lệ
                },
                // Logic saving
                onSaved: (value) {
                  _password = value ?? '';
                },
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm, // Gọi hàm xử lý khi nhấn
                child: Text('Đăng nhập'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
