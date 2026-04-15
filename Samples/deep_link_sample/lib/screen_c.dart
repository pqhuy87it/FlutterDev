import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'base_screen.dart';

class ScreenC extends StatelessWidget {
  const ScreenC({super.key});
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "C",
      // Đi tiếp vào /b/c/d
      onNext: () => context.go('/b/c/d'),
    );
  }
}