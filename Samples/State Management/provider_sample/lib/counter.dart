// file: counter_provider.dart
import 'package:flutter/material.dart';

class Counter with ChangeNotifier {
  int _count = 0;

  int get count => _count; // Getter để các widget khác có thể đọc giá trị

  void increment() {
    _count++;
    notifyListeners(); // Thông báo cho các widget đang lắng nghe rằng dữ liệu đã thay đổi!
  }

  void decrement() {
    _count--;
    notifyListeners(); // Thông báo!
  }
}