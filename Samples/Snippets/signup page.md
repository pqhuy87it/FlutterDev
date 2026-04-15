[DartPad](https://dartpad.dev/925de3683510c11586de551970d31e85)

<img width="840" height="1500" alt="CleanShot 2025-11-23 at 18 03 44@2x" src="https://github.com/user-attachments/assets/4a13a394-4783-4eec-892f-f82d61ea8ef4" />

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sign Up UI Demo',
      theme: ThemeData(
        fontFamily: 'Arial',
        // Màu nền xám xanh nhạt giống thiết kế
        scaffoldBackgroundColor: const Color(0xFFF0F4F8),
        primarySwatch: Colors.blue,
      ),
      home: const SignUpScreen(),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isAgreed = false; // Trạng thái checkbox điều khoản
  bool _obscureText = true; // Trạng thái ẩn/hiện mật khẩu

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Header Section
                const SizedBox(height: 20),
                const Text(
                  "Sign up",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Create an account or log in to\nexplore about our app.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5, // Khoảng cách dòng
                  ),
                ),
                const SizedBox(height: 30),

                // 2. Name Input
                _buildLabel("Name"),
                const SizedBox(height: 8),
                TextField(
                  decoration: _inputDecoration(hintText: "Enter your name"),
                ),
                const SizedBox(height: 20),

                // 3. Email Input
                _buildLabel("Email"),
                const SizedBox(height: 8),
                TextField(
                  decoration: _inputDecoration(hintText: "Enter your email"),
                ),
                const SizedBox(height: 20),

                // 4. Password Input
                _buildLabel("Password"),
                const SizedBox(height: 8),
                TextField(
                  obscureText: _obscureText,
                  decoration: _inputDecoration(
                    hintText: "• • • • • • • •",
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                ),

                // 5. Terms Checkbox
                const SizedBox(height: 16),
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _isAgreed,
                        activeColor: const Color(0xFF1E88E5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        side: BorderSide(color: Colors.grey.shade400),
                        onChanged: (value) {
                          setState(() {
                            _isAgreed = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "I agree with privacy and policy",
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      ),
                    ),
                  ],
                ),

                // 6. Sign Up Button
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5), // Màu xanh dương
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0, // Thiết kế phẳng, không đổ bóng nhiều
                  ),
                  child: const Text(
                    "Sign up",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                // 7. Divider "Or"
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Or",
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300])),
                  ],
                ),

                // 8. Social Buttons
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _socialButton(
                        text: "Google",
                        icon: const Icon(Icons.g_mobiledata,
                            color: Colors.red, size: 32),
                        // Trong thực tế nên dùng Image.asset('assets/google.png')
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _socialButton(
                        text: "Facebook",
                        icon: const Icon(Icons.facebook,
                            color: Color(0xFF1877F2), size: 26),
                      ),
                    ),
                  ],
                ),

                // 9. Footer Link
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ", // Text giống trong ảnh (dù logic Sign up thường là "Already have...")
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        "Log in",
                        style: TextStyle(
                          color: Color(0xFF1E88E5),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets (Tái sử dụng code) ---

  // 1. Widget Label (Name, Email, Password)
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: Colors.black87,
      ),
    );
  }

  // 2. Decoration cho TextField (Bo tròn, nền trắng)
  InputDecoration _inputDecoration({required String hintText, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      // Border khi không focus (không viền)
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      // Border khi focus (không viền hoặc viền mỏng tùy ý, ở đây để none cho giống ảnh phẳng)
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 1),
      ),
    );
  }

  // 3. Widget nút Social (Google/Facebook)
  Widget _socialButton({required String text, required Widget icon}) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0, // Phẳng
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide.none, // Không viền
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
```
