import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class AspectRatioBasicPage extends StatelessWidget {
  const AspectRatioBasicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aspect Ratio Basic')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage, // Cần package transparent_image
              image: 'https://www.hollywoodreporter.com/wp-content/uploads/2012/01/new_universal_logo_a_l.jpg',
              fit: BoxFit.cover, // Đảm bảo ảnh lấp đầy khung
            ),
          ),
        ),
      ),
    );
  }
}
