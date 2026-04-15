import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  // Trạng thái ban đầu của theme là Sáng (light)
  ThemeMode _themeMode = ThemeMode.light;

  // Getter để các widget khác có thể đọc được trạng thái hiện tại
  ThemeMode get themeMode => _themeMode;

  // Phương thức để chuyển đổi theme
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;

    // Thông báo cho tất cả các widget đang "lắng nghe" rằng trạng thái đã thay đổi
    // để chúng có thể rebuild lại giao diện.
    notifyListeners();
  }
}