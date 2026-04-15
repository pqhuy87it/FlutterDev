import 'package:flutter/material.dart';

class ToolTipExamplePage extends StatelessWidget {
  static String routeName = 'basics/tool_tip_example';

  const ToolTipExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tooltip Demo'),
        actions: [
          // 1. Bọc IconButton bằng Tooltip
          Tooltip(
            // 2. Cung cấp một message rõ ràng
            message: 'Lưu vào danh sách yêu thích',

            // 3. Đặt IconButton làm child
            child: IconButton(
              icon: const Icon(Icons.favorite),
              onPressed: () {
                // Logic khi nhấn nút
              },
            ),
          ),
          Tooltip(
            message: 'Chia sẻ',
            child: IconButton(icon: const Icon(Icons.share), onPressed: () {}),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Tooltip(
              message: 'Đây là một Flutter Logo!',
              child: FlutterLogo(size: 150),
            ),
            const SizedBox(height: 20),
            Tooltip(
              message: 'Custom Tooltip',
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blueAccent),
              ),
              child: IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {
                  // Logic khi nhấn nút
                },
              ),
            ),
            SizedBox(height: 20),
            Tooltip(
                message: 'Styled Text',
                textStyle: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                child: IconButton(
                  icon: const Icon(Icons.home),
                  onPressed: () {
                    // Logic khi nhấn nút
                  },
                ),
            ),
          ],
        ),
      ),
    );
  }
}
