import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_deep_link_sample/screen_e.dart';

import 'app_link_repository.dart';
import 'navigation_service.dart';

final appLinkControllerProvider = Provider<void>((ref) {
  final repo = ref.watch(appLinkRepositoryProvider);
  final navService = ref.watch(navigationServiceProvider);

  // Lắng nghe Stream
  repo.uriStream.listen((uri) {
    if (uri.path.contains('/e')) {
      final data = uri.queryParameters['data'] ?? '';

      if (navService.isAtScreenE) {
        // CASE 1: Đang ở E -> Gọi Controller của E để kích hoạt Popup
        ref.read(screenEControllerProvider.notifier).onDeepLinkReceived(data);
      } else {
        // CASE 2: Không ở E -> Điều hướng sang E kèm data
        navService.requestNavigateToE(data);
      }
    }
  });
});