import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. Provider để cung cấp đối tượng SharedPreferences một cách đồng bộ
// Việc khởi tạo sẽ được thực hiện trong hàm main()
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences has not been initialized');
});

// 2. Provider chính quản lý trạng thái xác thực
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthNotifier(prefs);
});

// 3. Lớp trạng thái (State)
// Sử dụng @immutable để đảm bảo trạng thái không bị thay đổi trực tiếp
@immutable
class AuthState {
  final String? username;
  final bool isLoading;

  const AuthState({this.username, this.isLoading = false});

  // Giúp tạo bản sao của trạng thái với các giá trị mới
  AuthState copyWith({String? username, bool? isLoading}) {
    return AuthState(
      username: username ?? this.username,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// 4. Lớp Notifier quản lý logic
class AuthNotifier extends StateNotifier<AuthState> {
  final SharedPreferences _prefs;

  AuthNotifier(this._prefs) : super(const AuthState()) {
    _init();
  }

  // Khởi tạo trạng thái ban đầu bằng cách đọc từ SharedPreferences
  void _init() {
    final username = _prefs.getString('username');
    if (username != null) {
      state = state.copyWith(username: username);
    }
  }

  // Hàm xử lý đăng nhập
  Future<void> login(String username, String password) async {
    // Bắt đầu trạng thái loading
    state = state.copyWith(isLoading: true);

    // Giả lập gọi API và đợi 2 giây
    await Future.delayed(const Duration(seconds: 2));

    // Lưu username vào SharedPreferences
    await _prefs.setString('username', username);

    // Cập nhật trạng thái ứng dụng và kết thúc loading
    state = state.copyWith(username: username, isLoading: false);
  }

  // Hàm xử lý đăng xuất
  Future<void> logout() async {
    // Xóa username khỏi SharedPreferences
    await _prefs.remove('username');
    // Reset trạng thái về ban đầu
    state = const AuthState();
  }
}