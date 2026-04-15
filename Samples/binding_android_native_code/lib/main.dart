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
  // 1. Khai báo channel với một tên duy nhất.
  // Tên này phải giống hệt với tên sẽ khai báo bên phía Android.
  static const platform = MethodChannel('com.fai.abc/os_info');

  String _osVersion = 'Unknown OS version';

  // 2. Tạo một hàm để gọi phương thức native
  Future<void> _getOSVersion() async {
    String osVersion;
    try {
      // 3. Gọi phương thức 'getOSVersion' bên phía native
      final String result = await platform.invokeMethod('getOSVersion');
      osVersion = 'Android Version: $result';
    } on PlatformException catch (e) {
      osVersion = "Failed to get OS version: '${e.message}'.";
    }

    setState(() {
      _osVersion = osVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Android Native Binding Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_osVersion),
            ElevatedButton(
              onPressed: _getOSVersion,
              child: Text('Get Android Version'),
            ),
          ],
        ),
      ),
    );
  }
}