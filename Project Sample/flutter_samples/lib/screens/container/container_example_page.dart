import 'package:flutter/material.dart';
import 'package:project_samples/utils/layout_spacer.dart';

class ContainerExamplePage extends StatelessWidget {
  static String routeName = 'basics/container_example';

  const ContainerExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grid View Example')),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: <Widget>[
          Column(
            children: [
              Container(
                width: 150.0,
                height: 100.0,
                color: Colors.green,
              ),
            ],
          ),
          LayoutSpacer.vertical10,
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                color: Colors.lightBlue,
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(20),
                child: Container(
                  color: Colors.white,
                  child: Text("Hello!"),
                ),
              ),
            ],
          ),
          LayoutSpacer.vertical10,
          Container(
            width: 200,
            height: 100,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white, // Nhớ đặt màu ở đây
              borderRadius: BorderRadius.circular(12.0), // Bo góc
              border: Border.all(color: Colors.grey.shade300, width: 1), // Thêm viền
              boxShadow: [ // Thêm hiệu ứng đổ bóng
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Text(
              'Đây là một chiếc thẻ',
              style: TextStyle(fontSize: 16),
            ),
          ),
          LayoutSpacer.vertical10,
          Container(
            width: 200,
            height: 100,
            color: Colors.yellow,
            alignment: Alignment.bottomRight, // Căn chỉnh child ở góc dưới bên phải
            child: const Text('Góc dưới'),
          ),
          LayoutSpacer.vertical10,
          Container(
            color: Colors.purple,
            width: 100,
            height: 100,
            alignment: Alignment.center,
            // Xoay container 45 độ quanh tâm của nó
            transform: Matrix4.rotationZ(0.785), // 0.785 radians ≈ 45 độ
            child: const Text('Xoay!', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}
