import 'package:flutter/material.dart';

class AspectRatioGridviewBuildPage extends StatelessWidget {
  const AspectRatioGridviewBuildPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aspect Ratio Gridview Build')),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 cột
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.0, // MỖI ITEM SẼ LÀ MỘT HÌNH VUÔNG
        ),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(child: Center(child: Text('Sản phẩm ${index + 1}')));
        },
      ),
    );
  }
}
