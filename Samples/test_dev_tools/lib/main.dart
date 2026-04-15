import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

void main() {
  runApp(const DevToolsTestApp());
}

class DevToolsTestApp extends StatelessWidget {
  const DevToolsTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DevTools Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DevToolsTestScreen(),
    );
  }
}

class DevToolsTestScreen extends StatefulWidget {
  const DevToolsTestScreen({super.key});

  @override
  State<DevToolsTestScreen> createState() => _DevToolsTestScreenState();
}

class _DevToolsTestScreenState extends State<DevToolsTestScreen> {
  // Biến toàn cục cố tình giữ lại dữ liệu để gây rò rỉ bộ nhớ
  final List<String> _leakedMemoryList = [];
  bool _isLoading = false;

  // 1. Hàm cố tình chạy một vòng lặp khổng lồ đồng bộ trên Main Thread gây Jank (Giật lag)
  void _causeJank() {
    developer.log('Bắt đầu xử lý tính toán cực nặng...', name: 'PERFORMANCE');

    double result = 0;
    // Vòng lặp 50 triệu lần chạy trên luồng giao diện
    for (int i = 0; i < 50000000; i++) {
      result += i * 0.5;
    }

    developer.log('Tính toán xong: $result', name: 'PERFORMANCE');
    // Cập nhật UI để Frame này bị vẽ chậm
    setState(() {});
  }

  // 2. Hàm gọi API để test tab Network
  Future<void> _callApi() async {
    setState(() => _isLoading = true);
    developer.log('Bắt đầu gọi API JSONPlaceholder...', name: 'NETWORK');

    try {
      final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts/1'));
      developer.log('API Response Code: ${response.statusCode}', name: 'NETWORK');
    } catch (e) {
      developer.log('Lỗi API: $e', name: 'NETWORK', error: e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 3. Hàm liên tục nhồi data vào RAM mà không giải phóng để test tab Memory
  void _causeMemoryLeak() {
    developer.log('Đang bơm 100,000 chuỗi dài vào RAM...', name: 'MEMORY');

    for (int i = 0; i < 100000; i++) {
      // Tạo ra các chuỗi rất dài để ngốn RAM nhanh chóng
      _leakedMemoryList.add('CỐ TÌNH GÂY RÒ RỈ BỘ NHỚ LÀM TRÀN RAM DẦN DẦN ' * 10);
    }

    developer.log('Đã thêm xong. Tổng số phần tử hiện tại: ${_leakedMemoryList.length}', name: 'MEMORY');
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold chứa nhiều thành phần lồng nhau để test Inspector
    return Scaffold(
      appBar: AppBar(title: const Text('DevTools Testing')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Bấm các nút bên dưới và mở DevTools để xem hiện tượng',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Nút 1: Test Performance
            ElevatedButton(
              onPressed: _causeJank,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade100),
              child: const Text('1. Chạy hàm nặng (Gây Jank/Đỏ Frame)'),
            ),
            const SizedBox(height: 10),

            // Nút 2: Test Network
            ElevatedButton(
              onPressed: _isLoading ? null : _callApi,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade100),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('2. Gọi HTTP API (Test Network)'),
            ),
            const SizedBox(height: 10),

            // Nút 3: Test Memory
            ElevatedButton(
              onPressed: _causeMemoryLeak,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade100),
              child: const Text('3. Tạo rò rỉ RAM (Test Memory)'),
            ),
            const SizedBox(height: 30),

            // Khối 4: Test Inspector (Bố cục Flex)
            const Text('4. Soi Widget Tree (Test Inspector)'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                border: Border.all(color: Colors.black),
              ),
              child: Row(
                children: [
                  Expanded(flex: 1, child: Container(height: 50, color: Colors.green)),
                  Expanded(flex: 2, child: Container(height: 50, color: Colors.yellow)),
                  Expanded(flex: 1, child: Container(height: 50, color: Colors.purple)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}