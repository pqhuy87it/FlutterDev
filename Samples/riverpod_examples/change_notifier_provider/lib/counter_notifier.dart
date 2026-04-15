import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ChangeNotifierProvider nhận một hàm callback trả về một instance của CounterNotifier.
// ref là một đối tượng cho phép provider tương tác với các provider khác (không cần dùng ở đây).
final counterNotifierProvider = ChangeNotifierProvider<CounterNotifier>((ref) {
  return CounterNotifier();
});

// Lớp này sẽ chứa state và logic của chúng ta.
// Nó kế thừa (extends) từ ChangeNotifier để có thể sử dụng notifyListeners().
class CounterNotifier extends ChangeNotifier {
  int _count = 0; // State nội bộ, nên để private

  // Cung cấp một getter công khai để UI có thể đọc giá trị
  int get count => _count;

  // Phương thức để thay đổi state
  void increment() {
    _count++;
    // Đây là bước quan trọng nhất!
    // Sau khi thay đổi state, gọi notifyListeners() để thông báo
    // cho tất cả các "listeners" (trong trường hợp này là ChangeNotifierProvider)
    // rằng dữ liệu đã được cập nhật.
    notifyListeners();
  }

  void reset() {
    _count = 0;
    notifyListeners();
  }
}