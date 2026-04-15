import 'package:flutter/material.dart';
import 'dart:async';

class ProgressIndicatorExamplePage extends StatefulWidget {
  static String routeName = 'basics/progress_indicator_example';

  const ProgressIndicatorExamplePage({super.key});

  @override
  State<ProgressIndicatorExamplePage> createState() =>
      _ProgressIndicatorExamplePageState();
}

class _ProgressIndicatorExamplePageState
    extends State<ProgressIndicatorExamplePage> {
  bool _isLoading = false;
  double _progress = 0.0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel(); // Hủy timer khi widget bị hủy để tránh rò rỉ bộ nhớ
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CircularProgressIndicator Demo')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                '1. Chế độ Vô định (Indeterminate)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Chỉ báo quay liên tục
              const CircularProgressIndicator(
                strokeWidth: 6.0,
                color: Colors.amber,
              ),
              const SizedBox(height: 50),
              const Text(
                '2. Chế độ Xác định (Determinate)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Dùng Stack để hiển thị text phần trăm bên trong vòng tròn
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: _progress, // Giá trị tiến trình
                      strokeWidth: 8.0,
                      backgroundColor: Colors.grey.shade300,
                      color: Colors.blue,
                    ),
                  ),
                  // Hiển thị phần trăm
                  Text(
                    '${(_progress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                // Vô hiệu hóa nút khi đang tải
                onPressed: _isLoading ? null : _startLoading,
                child: const Text('Bắt đầu tải'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startLoading() {
    // Nếu đang tải thì không làm gì cả
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _progress = 0.0;
    });

    // Mô phỏng việc tải dữ liệu bằng Timer
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _progress += 0.02; // Tăng tiến trình lên 2% mỗi 100ms
        if (_progress >= 1.0) {
          _progress = 1.0;
          _timer?.cancel(); // Dừng timer khi hoàn thành
          _isLoading = false;
          // Có thể thêm thông báo hoàn thành ở đây
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Tải xuống hoàn tất!')));
        }
      });
    });
  }
}
