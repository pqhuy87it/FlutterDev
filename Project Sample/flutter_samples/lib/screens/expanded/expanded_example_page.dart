import 'package:flutter/material.dart';
import 'package:project_samples/utils/layout_spacer.dart';

class ExpandedExamplePage extends StatelessWidget {
  static String routeName = 'basics/expanded_example';

  const ExpandedExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expanded Example')),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.email),
              SizedBox(width: 16), // Một khoảng cách nhỏ
              // Text sẽ giãn ra để chiếm hết không gian còn lại trong Row
              Expanded(
                child: Text(
                  'Đây là một dòng văn bản rất dài để minh họa cách nó lấp đầy không gian',
                  overflow: TextOverflow.ellipsis, // Xử lý nếu văn bản quá dài
                ),
              ),
            ],
          ),
          LayoutSpacer.vertical20,
          Row(
            children: <Widget>[
              // Cả 3 đều có flex = 1 (mặc định), nên chúng sẽ chia đều không gian
              Expanded(
                child: ElevatedButton(onPressed: () {}, child: Text('Nút 1')),
              ),
              Expanded(
                child: ElevatedButton(onPressed: () {}, child: Text('Nút 2')),
              ),
              Expanded(
                child: ElevatedButton(onPressed: () {}, child: Text('Nút 3')),
              ),
            ],
          ),
          LayoutSpacer.vertical30,
          // using flex
          SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 1, // Chiếm 1 phần
                  child: Container(color: Colors.red),
                ),
                Expanded(
                  flex: 2, // Chiếm 2 phần (gấp đôi)
                  child: Container(color: Colors.green),
                ),
                Expanded(
                  flex: 1, // Chiếm 1 phần
                  child: Container(color: Colors.blue),
                ),
              ],
            ),
          ),
          LayoutSpacer.vertical20,
          Row(
            children: <Widget>[
              Text('Bên trái'),
              Spacer(), // Tương đương với Expanded(child: SizedBox())
              Text('Bên phải'),
            ],
          ),
          LayoutSpacer.vertical20,
          // ko cần truyền vào width nó sẽ tự chia 3 phần bằng nhau
          Row(
            children: [
              Expanded(child: Container(height: 100, color: Colors.red)),
              Expanded(child: Container(height: 100, color: Colors.green)),
              Expanded(child: Container(height: 100, color: Colors.blue)),
            ],
          )
        ],
      ),
    );
  }
}
