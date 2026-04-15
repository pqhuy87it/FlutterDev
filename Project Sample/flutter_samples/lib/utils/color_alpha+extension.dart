import 'package:flutter/material.dart';

extension ColorAlpha on Color {
  /// Trả về một màu mới với giá trị alpha được chỉ định.
  /// Đây là giải pháp thay thế cho `withOpacity` để tránh mất độ chính xác.
  Color withAlphas(double alpha) {
    // Đảm bảo alpha nằm trong khoảng 0.0 - 1.0
    assert(alpha >= 0.0 && alpha <= 1.0, 'Alpha must be between 0.0 and 1.0');
    return HSLColor.fromColor(this).withAlpha(alpha).toColor();
  }
}