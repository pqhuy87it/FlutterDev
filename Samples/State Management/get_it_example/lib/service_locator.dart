import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'user_service.dart';

// Tạo một instance toàn cục của GetIt
final getIt = GetIt.instance;

void setupLocator() {
  // Dạy cho get_it cách tạo UserService
  getIt.registerLazySingleton<UserService>(() => UserService());

  // Bạn có thể đăng ký nhiều service khác ở đây
  // getIt.registerFactory<SomeViewModel>(() => SomeViewModel());
}