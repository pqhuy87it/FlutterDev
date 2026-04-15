[DartPad](https://dartpad.dev/99a7c1cd3d773759d29c6e6160ad14dc)

<img width="972" height="1528" alt="CleanShot 2025-11-23 at 20 47 04@2x" src="https://github.com/user-attachments/assets/a68b4eaa-04f6-41b0-a6b2-c9d44c65dc89" />

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
      title: 'Airspace Login',
      theme: ThemeData(
        fontFamily: 'Arial', // Font chữ cơ bản
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AirspaceLoginScreen(),
    );
  }
}

class AirspaceLoginScreen extends StatefulWidget {
  const AirspaceLoginScreen({super.key});

  @override
  State<AirspaceLoginScreen> createState() => _AirspaceLoginScreenState();
}

class _AirspaceLoginScreenState extends State<AirspaceLoginScreen> {
  bool _isChecked = true; // Trạng thái Remember me
  bool _obscurePassword = true; // Trạng thái ẩn hiện mật khẩu

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. LOGO & APP NAME
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud, color: Color(0xFF2196F3), size: 40), // Icon đám mây
                      const SizedBox(width: 10),
                      Text(
                        "Airspace",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // 2. EMAIL INPUT
                _buildLabel("Email"),
                const SizedBox(height: 8),
                TextField(
                  decoration: _inputDecoration(
                    hintText: "Airspace@info.com",
                    prefixIcon: Icons.mail_outline,
                  ),
                ),
                const SizedBox(height: 20),

                // 3. PASSWORD INPUT
                _buildLabel("Password"),
                const SizedBox(height: 8),
                TextField(
                  obscureText: _obscurePassword,
                  decoration: _inputDecoration(
                    hintText: "************",
                    prefixIcon: Icons.vpn_key_outlined,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 4. REMEMBER ME CHECKBOX
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _isChecked,
                        activeColor: const Color(0xFF2196F3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (value) {
                          setState(() {
                            _isChecked = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Remember me",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Save my login details for next time.",
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 5. SIGN IN BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3), // Màu xanh dương chủ đạo
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Sign In",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                // 6. DIVIDER (OR)
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(child: Divider(color: Colors.grey)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text("OR", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ),
                    const Expanded(child: Divider(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 16),

                // 7. SIGN UP LINK
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account ? ", style: TextStyle(color: Colors.grey[600])),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          "Sign up",
                          style: TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 8. SOCIAL BUTTONS
                // Google
                _buildSocialButton(
                  text: "Sign in with Google",
                  icon: Icons.g_mobiledata, // Dùng tạm icon G có sẵn
                  iconColor: Colors.red,
                  bgColor: Colors.white,
                  textColor: Colors.black87,
                  hasBorder: true,
                ),
                const SizedBox(height: 12),
                
                // Facebook
                _buildSocialButton(
                  text: "Sign in with Facebook",
                  icon: Icons.facebook,
                  iconColor: Colors.white,
                  bgColor: const Color(0xFF1877F2),
                  textColor: Colors.white,
                  hasBorder: false,
                ),
                const SizedBox(height: 12),

                // Apple
                _buildSocialButton(
                  text: "Sign in with Apple",
                  icon: Icons.apple,
                  iconColor: Colors.white,
                  bgColor: Colors.black,
                  textColor: Colors.white,
                  hasBorder: false,
                ),

                const SizedBox(height: 40),

                // 9. FOOTER COPYRIGHT
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.copyright, size: 16, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        "Copyright 2023 Airspace Corporation",
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS (Hàm hỗ trợ để code gọn hơn) ---

  // Widget tiêu đề (Label) cho Input
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 15,
        color: Colors.black87,
      ),
    );
  }

  // Style chung cho TextField
  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[400]),
      prefixIcon: Icon(prefixIcon, color: Colors.grey),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2196F3)),
      ),
    );
  }

  // Widget nút Social
  Widget _buildSocialButton({
    required String text,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Color textColor,
    required bool hasBorder,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: hasBorder ? BorderSide(color: Colors.grey.shade300) : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
```
