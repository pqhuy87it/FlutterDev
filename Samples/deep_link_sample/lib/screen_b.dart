import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'base_screen.dart';

class ScreenB extends StatelessWidget {
  const ScreenB({super.key});
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "B",
      // Đi tiếp vào /b/c
      onNext: () => context.go('/b/c'),
    );
  }
}