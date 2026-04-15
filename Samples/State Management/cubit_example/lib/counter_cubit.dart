import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// 1. Cubit sẽ quản lý một trạng thái kiểu 'int'
class CounterCubit extends Cubit<int> {
  // 2. Khởi tạo trạng thái ban đầu là 0
  CounterCubit() : super(0);

  // 3. Tạo một hàm public để UI có thể gọi
  void increment() {
    // 4. Dùng emit() để phát ra state mới.
    // 'state' là giá trị hiện tại của Cubit.
    emit(state + 1);
  }

  // 5. Một hàm public khác
  void decrement() {
    emit(state - 1);
  }
}
