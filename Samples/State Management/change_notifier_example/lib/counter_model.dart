import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class CounterModel extends ChangeNotifier {
  int _count = 0;

  // Cung cấp một getter công khai để các widget khác có thể đọc giá trị này
  int get count => _count;

  void increment() {
    _count++;
    // Đây là phần quan trọng nhất!
    // Thông báo cho tất cả các "radio" (widget đang lắng nghe) rằng dữ liệu đã thay đổi.
    notifyListeners();
  }
}