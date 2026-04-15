// counter_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Lớp này chứa logic và state
class CounterNotifier extends StateNotifier<int> {
  // Khởi tạo state ban đầu là 0
  CounterNotifier() : super(0);

  // Các phương thức để thay đổi state
  void increment() {
    state = state + 1; // State là bất biến, ta tạo ra một giá trị mới
  }
}