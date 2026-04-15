import 'package:flutter/material.dart';

class ScrollConfigurationExamplePage extends StatelessWidget {
  const ScrollConfigurationExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Scroll Configuration Example"),
      ),
      body: ScrollConfiguration(
        behavior: NoGlowBehavior(), // Áp dụng behavior tùy chỉnh ở đây!
        child: ListView.builder(
          itemCount: 50,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('Item số $index'),
            );
          },
        ),
      ),
    );
  }
}

// Class này sẽ ghi đè hành vi mặc định và không hiển thị hiệu ứng glow
class NoGlowBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    // Chỉ cần trả về widget con (child) mà không thêm hiệu ứng nào
    return child;
  }
}
