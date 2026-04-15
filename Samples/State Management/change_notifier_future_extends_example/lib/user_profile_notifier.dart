import 'package:flutter/foundation.dart';

// Một class đơn giản để đại diện cho dữ liệu người dùng
class UserProfile {
  final String name;
  final String email;

  UserProfile({required this.name, required this.email});
}

// Lớp Notifier kế thừa từ ChangeNotifier
class UserProfileNotifier extends ChangeNotifier {
  // 1. Trạng thái (State)
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _error;

  // 2. Getters để UI có thể truy cập trạng thái một cách an toàn
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 3. Phương thức bất đồng bộ (Future<void>) để thực hiện tác vụ
  Future<void> fetchUserProfile() async {
    // Bắt đầu quá trình: đặt trạng thái là đang tải
    _isLoading = true;
    _error = null; // Xóa lỗi cũ
    notifyListeners(); // Thông báo cho UI cập nhật (để hiển thị loading spinner)

    try {
      // Mô phỏng độ trễ mạng trong 2 giây
      await Future.delayed(const Duration(seconds: 2));

      // Mô phỏng kết quả thành công hoặc thất bại một cách ngẫu nhiên
      if (DateTime.now().millisecond % 2 == 0) {
        // THÀNH CÔNG: Cập nhật dữ liệu người dùng
        _userProfile = UserProfile(name: "PrivateGPT", email: "demo@fai.abc");
      } else {
        // THẤT BẠI: Ném ra một lỗi
        throw Exception("Không thể tải hồ sơ. Vui lòng thử lại.");
      }
    } catch (e) {
      // Bắt lỗi và cập nhật trạng thái lỗi
      _error = e.toString();
      _userProfile = null; // Xóa dữ liệu cũ nếu có lỗi
    } finally {
      // Kết thúc quá trình: đặt trạng thái không còn tải nữa
      _isLoading = false;
      notifyListeners(); // Thông báo cho UI cập nhật lần cuối (hiển thị dữ liệu hoặc lỗi)
    }
  }
}