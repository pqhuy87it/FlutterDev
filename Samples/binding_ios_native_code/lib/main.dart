import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import thư viện services

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 1. Khai báo channel với một tên duy nhất
  static const platform = MethodChannel('com.fai.abc/device_info');

  String _deviceName = 'Unknown device';

  // 2. Tạo một hàm để gọi phương thức native
  Future<void> _getDeviceName() async {
    String deviceName;
    try {
      // 3. Gọi phương thức 'getDeviceName' bên phía native
      final String result = await platform.invokeMethod('getDeviceName');
      deviceName = 'Device Name: $result';
    } on PlatformException catch (e) {
      // Xử lý lỗi nếu có
      deviceName = "Failed to get device name: '${e.message}'.";
    }

    setState(() {
      _deviceName = deviceName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('iOS Native Binding Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_deviceName),
            ElevatedButton(
              onPressed: _getDeviceName,
              child: Text('Get Device Name'),
            ),
          ],
        ),
      ),
    );
  }
}