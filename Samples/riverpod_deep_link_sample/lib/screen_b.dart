import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'base_screen.dart';

class ScreenB extends StatelessWidget {
  const ScreenB({super.key});
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "B",
      onNext: () => Navigator.pushNamed(context, '/screen_c'),
    );
  }
}