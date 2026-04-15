import 'package:flutter/material.dart';
import 'package:project_samples/utils/layout_spacer.dart';

class ConstrainedBoxExamplePage extends StatelessWidget {
  static String routeName = 'basics/constrained_box_example';

  const ConstrainedBoxExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sử dụng ConstrainedBox')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ConstrainedBox(
              // Áp đặt ràng buộc ở đây
              constraints: const BoxConstraints(
                minHeight: 100.0, // Luôn cao ít nhất 100 pixels
                minWidth: 200.0, // Luôn rộng ít nhất 200 pixels
              ),
              child: Container(
                color: Colors.lightBlue,
                // Container này không định nghĩa kích thước,
                // nó sẽ cố gắng nhỏ nhất có thể để vừa với Text.
                // Nhưng ConstrainedBox sẽ buộc nó phải lớn ra.
                child: const Center(
                  child: Text(
                    'Hello!',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 320.0, // Nút không bao giờ được rộng hơn 300 pixels
              ),
              child: SizedBox(
                // SizedBox này sẽ cố gắng rộng hết mức có thể (vì nó nằm trong Center)
                // nhưng sẽ bị ConstrainedBox chặn lại ở 300.
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Đăng nhập'),
                ),
              ),
            ),
            LayoutSpacer.vertical20,
            // Widget cha là một Container rộng 150px
            Container(
              width: 150,
              height: 150,
              color: Colors.red,
              child: ConstrainedBox(
                // ConstrainedBox yêu cầu con phải rộng từ 200 đến 300
                constraints: const BoxConstraints(
                  minWidth: 200,
                  maxWidth: 300,
                ),
                child: Container(
                  color: Colors.green,
                  // Widget con này sẽ được vẽ với kích thước nào?
                  child: const Text('Width?'),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
