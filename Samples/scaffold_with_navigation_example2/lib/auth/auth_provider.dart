import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'auth_state.dart';

part 'auth_provider.g.dart'; // File được tạo bởi build_runner

@Riverpod(keepAlive: true)
class CurrentAuthState extends _$CurrentAuthState {
  @override
  AuthState build() {
    // Giả sử ban đầu người dùng chưa đăng nhập
    return AuthState.unauthenticated;
  }

  void login() {
    state = AuthState.authenticated;
    print('User logged in');
  }

  void logout() {
    state = AuthState.unauthenticated;
    print('User logged out');
  }
}