import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'base_screen.dart';

class ScreenD extends StatelessWidget {
  const ScreenD({super.key});
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "D",
      // Đi tiếp vào /b/c/d/e
      onNext: () => context.go('/b/c/d/e'),
    );
  }
}