import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

// Dòng này là bắt buộc để code generator hoạt động
part 'counter_store.g.dart';

// Đây là lớp Store của bạn
class CounterStore = _CounterStore with _$CounterStore;

// Lớp trừu tượng chứa state và actions
abstract class _CounterStore with Store {
  // 1. Đánh dấu 'value' là một observable
  @observable
  int value = 0;

  // 2. Đánh dấu 'increment' là một action
  @action
  void increment() {
    value++;
  }

  // 3. Đánh dấu đây là một computed observable
  @computed
  String get doubleCountMessage => "Giá trị gấp đôi là: ${value * 2}";
}