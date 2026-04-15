import 'package:flutter/material.dart';

class ReverseAnimationPage extends StatefulWidget {
  const ReverseAnimationPage({super.key});

  @override
  State<ReverseAnimationPage> createState() => _ReverseAnimationPageState();
}

class _ReverseAnimationPageState extends State<ReverseAnimationPage>
    with SingleTickerProviderStateMixin {
  // Khai báo các biến animation
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _fadeOutAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Tạo "động cơ" AnimationController
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // 2. Tạo animation thuận (fade in) bằng CurvedAnimation cho mượt
    _fadeInAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    // 3. TẠO REVERSEANIMATION! (fade out)
    // Đây chính là ngôi sao của chúng ta
    _fadeOutAnimation = ReverseAnimation(_controller);
  }

  @override
  void dispose() {
    _controller.dispose(); // Đừng quên dispose!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reverse Animation Demo')),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Widget 1: Sẽ mờ dần đi (fade out)
            // Sử dụng _fadeOutAnimation (chính là ReverseAnimation)
            FadeTransition(
              opacity: _fadeOutAnimation,
              child: Container(
                width: 200,
                height: 200,
                color: Colors.blue,
                child: const Center(
                  child: Text(
                    'Widget 1',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
            ),

            // Widget 2: Sẽ hiện ra (fade in)
            // Sử dụng _fadeInAnimation (animation thuận)
            FadeTransition(
              opacity: _fadeInAnimation,
              child: Container(
                width: 200,
                height: 200,
                color: Colors.red,
                child: const Center(
                  child: Text(
                    'Widget 2',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.swap_horiz),
        onPressed: () {
          // Điều khiển animation
          if (_controller.status == AnimationStatus.completed) {
            _controller.reverse();
          } else {
            _controller.forward();
          }
        },
      ),
    );
  }
}
