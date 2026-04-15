import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'navigation_events.dart';
import 'navigation_service.dart';

class NavigationListener extends ConsumerStatefulWidget {
  final Widget child;
  const NavigationListener({super.key, required this.child});

  @override
  ConsumerState<NavigationListener> createState() => _NavigationListenerState();
}

class _NavigationListenerState extends ConsumerState<NavigationListener> {
  @override
  void initState() {
    super.initState();

    // Lắng nghe stream sự kiện từ Service
    ref.read(navigationServiceProvider).eventStream.listen((event) {
      if (event is NavigateToEScreenWithStackEvent) {
        _handleNavigateToE(event.data);
      }
    });
  }

  void _handleNavigateToE(String data) {
    // Ở ĐÂY CHÚNG TA CÓ CONTEXT!
    final nav = Navigator.of(context);

    // Logic tái tạo Stack: A -> B -> C -> D -> E
    // 1. Xóa hết về màn hình gốc (A)
    nav.popUntil((route) => route.isFirst);

    // 2. Đẩy các màn hình trung gian (tắt animation để mượt hơn nếu muốn)
    nav.pushNamed('/screen_b');
    nav.pushNamed('/screen_c');
    nav.pushNamed('/screen_d');

    // 3. Đẩy màn hình đích E với dữ liệu
    nav.pushNamed('/screen_e', arguments: data);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}