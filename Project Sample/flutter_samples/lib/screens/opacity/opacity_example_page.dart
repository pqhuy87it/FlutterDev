import 'package:flutter/material.dart';

class OpacityExamplePage extends StatefulWidget {
  static String routeName = 'basics/opacity_example';

  const OpacityExamplePage({super.key});

  @override
  State<OpacityExamplePage> createState() => _OpacityExamplePageState();
}

class _OpacityExamplePageState extends State<OpacityExamplePage> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Opacity Example')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 300,
                height: 200,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    // Lớp nền là hình ảnh
                    Image.network(
                      'https://images.unsplash.com/photo-1542831371-29b0f74f9713',
                      fit: BoxFit.cover,
                    ),
                    // Lớp phủ
                    Opacity(
                      opacity: 0.2, // Trong suốt 20%
                      child: Container(
                        color: Colors.black, // Màu đen
                      ),
                    ),
                    // Văn bản nằm trên cùng
                    Center(
                      child: Text(
                        'Hello Flutter',
                        style: TextStyle(color: Colors.white, fontSize: 40),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Opacity(
                opacity: _isVisible ? 1.0 : 0.0, // Dựa vào biến _isVisible
                child: const Text(
                  'Widget này có thể ẩn/hiện',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isVisible = !_isVisible;
                  });
                },
                child: Text(_isVisible ? 'Ẩn đi' : 'Hiện ra'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
