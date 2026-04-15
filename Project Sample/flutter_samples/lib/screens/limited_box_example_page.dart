import 'package:flutter/material.dart';

class LimitedBoxExamplePage extends StatelessWidget {
  static String routeName = 'basics/limited_box_example';

  const LimitedBoxExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sử dụng LimitedBox')),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return LimitedBox(
            // Đặt giới hạn chiều cao tối đa là 150.
            // Vì ListView có chiều cao vô hạn, giới hạn này sẽ được áp dụng.
            maxHeight: 150,
            child: Container(
              color: Colors.blue[100 * (index % 9)],
              child: Center(
                child: Text(
                  'Item $index\n(Tôi có thể nhỏ hơn 150)',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
