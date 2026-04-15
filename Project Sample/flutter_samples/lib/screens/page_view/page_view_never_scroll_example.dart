import 'package:flutter/material.dart';

class PageViewNeverScrollExample extends StatelessWidget {
  PageViewNeverScrollExample({super.key});

  // Khai báo một ScrollController
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page View Never Scroll')),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          PageView(
            controller: _controller,
            physics: NeverScrollableScrollPhysics(),
            // Không cho người dùng vuốt
            children: <Widget>[ExamplePage1(), ExamplePage2(), ExamplePage3()],
          ),
          Positioned(
            bottom: 70,
            left: 40,
            child: ElevatedButton(
              onPressed: () {
                // Dùng controller để cuộn đến trang tiếp theo
                _controller.previousPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
              },
              child: Text('Previous'),
            ),
          ),
          Positioned(
            bottom: 70,
            right: 40,
            child: ElevatedButton(
              onPressed: () {
                // Dùng controller để cuộn đến trang tiếp theo
                _controller.nextPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
              },
              child: Text('Next'),
            ),
          ),
        ],
      ),
    );
  }
}

class ExamplePage1 extends StatelessWidget {
  const ExamplePage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Page 1')));
  }
}

class ExamplePage2 extends StatelessWidget {
  const ExamplePage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Page 2')));
  }
}

class ExamplePage3 extends StatelessWidget {
  const ExamplePage3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Page 3')));
  }
}
