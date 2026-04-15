// counter_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Tạo một provider toàn cục.
// StateProvider sẽ cung cấp một giá trị (ở đây là int) và một cách để thay đổi nó.
// Giá trị khởi tạo là 0.
final counterProvider = StateProvider<int>((ref) {
  return 0;
});