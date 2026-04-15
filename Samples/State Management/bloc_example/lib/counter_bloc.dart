import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'counter_event.dart';
import 'counter_state.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  // 1. Khởi tạo trạng thái ban đầu
  CounterBloc() : super(const CounterState(count: 0)) {

    // 2. Đăng ký các trình xử lý sự kiện (event handlers)
    on<CounterIncrementPressed>((event, emit) {
      // Xử lý logic và phát ra state mới
      final newCount = state.count + 1;
      emit(CounterState(count: newCount));
    });

    on<CounterDecrementPressed>((event, emit) {
      // Xử lý logic và phát ra state mới
      final newCount = state.count - 1;
      emit(CounterState(count: newCount));
    });
  }
}