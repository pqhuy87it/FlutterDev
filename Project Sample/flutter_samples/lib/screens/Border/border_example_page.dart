import 'package:flutter/material.dart';

class BorderExamplePage extends StatefulWidget {
  static String routeName = 'basics/border_example';

  const BorderExamplePage({super.key});

  @override
  State<BorderExamplePage> createState() => _BorderExamplePageState();
}

class _BorderExamplePageState extends State<BorderExamplePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Border Example')),
      body: ListView(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.lightBlue[100], // Màu nền của box
                    border: Border.all(
                      color: Colors.black, // Màu của đường viền
                      width: 3.0, // Độ dày của đường viền
                      style: BorderStyle.solid, // Kiểu đường viền
                    ),
                  ),
                  child: Center(child: Text('Border.all()')),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.yellow[100],
                    border: Border(
                      top: BorderSide(color: Colors.red, width: 5.0),
                      bottom: BorderSide(color: Colors.blue, width: 2.0),
                    ),
                  ),
                  child: Center(child: Text('Border()')),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    border: Border.symmetric(
                      vertical: BorderSide(color: Colors.green, width: 4.0),
                    ),
                  ),
                  child: Center(child: Text('Border.symmetric()')),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.purple[100],
                    border: Border.all(color: Colors.purple, width: 2.0),
                    // Thêm borderRadius ở đây
                    borderRadius: BorderRadius.circular(
                      20,
                    ), // Bo tròn tất cả các góc
                  ),
                  child: Center(child: Text('Border + Radius')),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.purple[100],
                    border: Border.all(color: Colors.purple, width: 2.0),
                    // Thêm borderRadius ở đây
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ), // Bo tròn tất cả các góc
                  ),
                  child: Center(child: Text('Border + Radius Only')),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: ShapeDecoration(
                    color: Colors.orange[100],
                    shape: CircleBorder(
                      side: BorderSide(color: Colors.orange, width: 4.0),
                    ),
                  ),
                  child: Center(child: Text('CircleBorder')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
