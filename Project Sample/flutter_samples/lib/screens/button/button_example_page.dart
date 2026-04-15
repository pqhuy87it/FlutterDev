import 'package:flutter/material.dart';
import 'package:project_samples/utils/color_alpha+extension.dart';

class ButtonExamplePage extends StatefulWidget {
  static String routeName = 'basics/button_example';

  const ButtonExamplePage({super.key});

  @override
  State<ButtonExamplePage> createState() => _ButtonExamplePageState();
}

class _ButtonExamplePageState extends State<ButtonExamplePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Button Example')),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: <Widget>[
          TextButton(
            style: flatButtonStyle,
            onPressed: () {},
            child: Text('Looks like a FlatButton'),
          ),
          SizedBox(height: 16),
          // 2. Button được tùy chỉnh toàn diện
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              // Màu chữ
              backgroundColor: Colors.teal,
              // Màu nền
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
              shadowColor: Colors.black.withOpacity(0.5),
              side: const BorderSide(color: Colors.tealAccent, width: 2),
            ),
            child: const Text('Button Tùy Chỉnh'),
          ),
          SizedBox(height: 16),
          // 3. Button hình viên thuốc
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Thêm vào giỏ'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.deepPurple,
              backgroundColor: Colors.purple.shade50,
              shape: const StadiumBorder(),
            ),
          ),
          SizedBox(height: 16),
          // 4. Button bị vô hiệu hóa
          TextButton(
            onPressed: null, // Đặt onPressed là null để vô hiệu hóa
            style: TextButton.styleFrom(
              disabledForegroundColor: Colors.grey.shade400,
              disabledBackgroundColor: Colors.grey.shade200,
            ),
            child: const Text('Button Vô Hiệu Hóa'),
          ),
          SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.only(top: 20.0),
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      // Xử lý logic khi nhấn nút ở đây
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(
                        0xff3B5998,
                      ), // Tương đương với 'color'
                      foregroundColor:
                      Colors.white, // Màu cho chữ và icon bên trong
                      padding: EdgeInsets
                          .zero, // Bỏ padding mặc định để tự kiểm soát layout
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      // Hiệu ứng splash color (khi nhấn giữ)
                      overlayColor: Colors.white.withAlphas(0.1),
                    ),
                    child: Row(
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsets.only(left: 20.0),
                          child: Text(
                            "LOGIN WITH FACEBOOK",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        Expanded(child: Container()),
                        Transform.translate(
                          offset: const Offset(-5.0, 0.0),
                          child: TextButton(
                            onPressed: () => {},
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28.0),
                              ),
                              overlayColor: Colors.white,
                            ),
                            child: const Icon(
                              IconData(0x0066, fontFamily: 'icomoon'),
                              color: Color(0xff3b5998),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: <Widget>[
                  const SizedBox(height: 30),
                  const Text('Filled'),
                  const SizedBox(height: 15),
                  FilledButton(onPressed: () {}, child: const Text('Enabled')),
                  const SizedBox(height: 30),
                  const FilledButton(onPressed: null, child: Text('Disabled')),
                ],
              ),
              const SizedBox(width: 30),
              Column(
                children: <Widget>[
                  const SizedBox(height: 30),
                  const Text('Filled tonal'),
                  const SizedBox(height: 15),
                  FilledButton.tonal(onPressed: () {}, child: const Text('Enabled')),
                  const SizedBox(height: 30),
                  const FilledButton.tonal(onPressed: null, child: Text('Disabled')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

final ButtonStyle flatButtonStyle = TextButton.styleFrom(
  backgroundColor: Colors.grey.shade300,
  foregroundColor: Colors.black87,
  minimumSize: Size(88, 36),
  padding: EdgeInsets.symmetric(horizontal: 16),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(2)),
  ),
);
