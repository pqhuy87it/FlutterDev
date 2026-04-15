import 'package:flutter/material.dart';

// Dành cho chế độ Sáng
final ColorScheme lightColorScheme = ColorScheme.fromSeed(
  seedColor: Colors.deepPurple, // Màu hạt giống của bạn
  brightness: Brightness.light,
);

// Dành cho chế độ Tối
final ColorScheme darkColorScheme = ColorScheme.fromSeed(
  seedColor: Colors.deepPurple, // Dùng cùng màu hạt giống
  brightness: Brightness.dark,
);

class AppColor {
  static const primary = Color(0xFF333333);
  static const secondary = Color(0xFFe96561);

  static const darker = Color(0xFF3E4249);
  static const cardColor = Colors.white;
  static const mainColor = Color(0xFF000000);
  static const appBgColor = Color(0xFFF7F7F7);
  static const appBarColor = Color(0xFFF7F7F7);
  static const shadowColor = Colors.black87;
  static const textBoxColor = Colors.white;
  static const textColor = Color(0xFF333333);
  static const Color text = Color(0xFF333333);
  static const Color darkText = Color(0xFFB8B8B8);
  static const glassTextColor = Colors.white;
  static const labelColor = Color(0xFF8A8989);
  static const glassLabelColor = Colors.white;
  static const actionColor = Color(0xFFe54140);

  static const bottomBarColor = Colors.white;
  static const inActiveColor = Colors.grey;

  static const yellow = Color(0xFFffcb66);
  static const green = Color(0xFFa2e1a6);
  static const pink = Color(0xFFf5bde8);
  static const purple = Color(0xFFcdacf9);
  static const red = Color(0xFFe54140);
  static const orange = Color(0xFFf5ba92);
  static const sky = Color(0xFFABDEE6);
  static const blue = Color(0xFF509BE4);

  static const listColors = [
    green,
    purple,
    yellow,
    orange,
    sky,
    secondary,
    red,
    blue,
    pink,
    yellow,
  ];
}

extension ColorAlpha on Color {
  /// Trả về một màu mới với giá trị alpha được chỉ định.
  /// Đây là giải pháp thay thế cho `withOpacity` để tránh mất độ chính xác.
  Color withAlphas(double alpha) {
    // Đảm bảo alpha nằm trong khoảng 0.0 - 1.0
    assert(alpha >= 0.0 && alpha <= 1.0, 'Alpha must be between 0.0 and 1.0');
    return HSLColor.fromColor(this).withAlpha(alpha).toColor();
  }
}
