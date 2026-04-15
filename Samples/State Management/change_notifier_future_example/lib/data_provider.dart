import 'package:flutter/foundation.dart';

// Lớp này sẽ quản lý trạng thái của ứng dụng.
class DataProvider with ChangeNotifier {
  // 1. Định nghĩa các biến trạng thái
  String _data = "Nhấn nút để tải dữ liệu";
  bool _isLoading = false;
  String? _errorMessage;

  // 2. Tạo các getter để UI có thể truy cập an toàn
  String get data => _data;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 3. Đây là hàm bất đồng bộ chính (Future<void>)
  Future<void> fetchData() async {
    // Bắt đầu quá trình tải
    _isLoading = true;
    _errorMessage = null; // Xóa lỗi cũ
    notifyListeners(); // Thông báo cho UI rằng "đang tải", hãy cập nhật

    try {
      // Mô phỏng việc gọi API mất 2 giây
      await Future.delayed(const Duration(seconds: 2));

      // Mô phỏng một lỗi ngẫu nhiên (50% thành công, 50% thất bại)
      if (DateTime.now().second % 2 == 0) {
        // Nếu thành công, cập nhật dữ liệu
        _data = "Dữ liệu đã được tải thành công lúc ${DateTime.now().toIso8601String()}";
      } else {
        // Nếu thất bại, ném ra một Exception
        throw Exception("Không thể kết nối đến máy chủ!");
      }
    } catch (e) {
      // Nếu có lỗi, cập nhật thông báo lỗi
      _errorMessage = e.toString();
    } finally {
      // Dù thành công hay thất bại, quá trình tải đã kết thúc
      _isLoading = false;
      notifyListeners(); // Thông báo cho UI rằng quá trình đã xong, hãy cập nhật lần nữa
    }
  }
}