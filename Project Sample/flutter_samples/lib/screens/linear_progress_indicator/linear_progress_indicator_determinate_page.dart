import 'package:flutter/material.dart';
import 'dart:async';

class LinearProgressIndicatorDeterminatePage extends StatefulWidget {
  const LinearProgressIndicatorDeterminatePage({super.key});

  @override
  State<LinearProgressIndicatorDeterminatePage> createState() =>
      _LinearProgressIndicatorDeterminatePageState();
}

class _LinearProgressIndicatorDeterminatePageState
    extends State<LinearProgressIndicatorDeterminatePage> {
  double _progress = 0.0; // Biến để lưu trữ tiến độ (từ 0.0 đến 1.0)
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  void _startLoading() {
    // Hủy timer cũ nếu có
    _timer?.cancel();

    // Tạo một timer mới chạy 100ms một lần để cập nhật tiến độ
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        if (_progress >= 1.0) {
          // Nếu đã hoàn thành, hủy timer
          timer.cancel();
        } else {
          // Tăng tiến độ lên 1% mỗi lần
          _progress += 0.01;
        }
      });
    });
  }

  @override
  void dispose() {
    // Rất quan trọng: Hủy timer khi widget bị gỡ bỏ để tránh rò rỉ bộ nhớ
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Determinate Progress')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Đang tải xuống: ${(_progress * 100).toStringAsFixed(0)}%'),
              SizedBox(height: 20),
              // Cung cấp giá trị 'value' để tạo ra thanh tiến trình xác định
              LinearProgressIndicator(
                value: _progress,
                minHeight: 10, // Tăng độ dày của thanh
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _progress = 0; // Reset tiến độ
                  });
                  _startLoading(); // Bắt đầu lại
                },
                child: Text('Tải lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
