import 'package:flutter/material.dart';

class AspectRatioCardPage extends StatelessWidget {
  const AspectRatioCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aspect Ratio Card')),
      body: Center(
        child: Column(
          children: [
            Card(
              clipBehavior: Clip.antiAlias, // Để bo góc cho ảnh bên trong
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 3 / 2,
                    child: Image.network(
                      'https://www.hollywoodreporter.com/wp-content/uploads/2012/01/new_universal_logo_a_l.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Nội dung quảng cáo'),
                  ),
                ],
              ),
            ),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(color: Colors.red),
            ),
            Expanded(child: Text('Nội dung khác')),
          ],
        ),
      ),
    );
  }
}
