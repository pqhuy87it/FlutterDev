import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_deep_link_sample/screen_e.dart';

import 'app_link_repository.dart';
import 'navigation_service.dart';

final appLinkControllerProvider = Provider<void>((ref) {
  final repo = ref.watch(appLinkRepositoryProvider);
  final navService = ref.watch(navigationServiceProvider);
  final screenENotifier = ref.watch(screenEProvider.notifier);

  // Lắng nghe Stream
  repo.uriStream.listen((uri) {
    // Giả sử link: myapp://example.com/e?data=HELLO
    if (uri.path.contains('/e')) {
      final data = uri.queryParameters['data'] ?? '';

      if (navService.isAtScreenE) {
        // CASE 1: Đang ở E -> Update State trực tiếp
        print("Đang ở E, update state riverpod");
        screenENotifier.updateData(data);
      } else {
        // CASE 2: Ở chỗ khác -> Dựng lại stack và chuyển trang
        print("Không ở E, dựng lại stack");
        navService.requestNavigateToE(data);
      }
    }
  });
});