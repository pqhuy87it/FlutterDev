import 'package:flutter/material.dart';

class UserService {
  Future<String> getUserName() async {
    // Giả lập việc gọi API
    await Future.delayed(const Duration(seconds: 1));
    return 'PrivateGPT from FAI.ABC';
  }
}