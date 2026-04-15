import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'base_screen.dart';

class ScreenA extends StatelessWidget {
  const ScreenA({super.key});
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "A",
      // Dùng context.go để đi vào route con
      onNext: () => Navigator.pushNamed(context, '/screen_b'),
    );
  }
}