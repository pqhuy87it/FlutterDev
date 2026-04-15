import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CounterController extends GetxController {
  // Thêm .obs vào sau biến để biến nó thành một biến "phản ứng" (observable)
  var count = 0.obs;

  void increment() {
    count++; // Chỉ cần thay đổi giá trị, UI sẽ tự động cập nhật!
  }
}