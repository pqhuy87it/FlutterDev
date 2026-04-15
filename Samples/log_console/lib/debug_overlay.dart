import 'package:flutter/material.dart';
import 'debug_logger.dart';

class DebugLogOverlay extends StatelessWidget {
  final Widget child;

  const DebugLogOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Main app
        child,

        // 2. Log Console on the top
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: LogConsoleViewer(),
        ),
      ],
    );
  }
}