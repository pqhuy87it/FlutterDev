import 'package:flutter/material.dart';
import 'package:project_samples/screens/aspect_ratio/image_ratio/aspect_ratio_image.dart';

class DisplayAspectRatioImagePage extends StatelessWidget {
  const DisplayAspectRatioImagePage({super.key});

  final String imageUrl =
      'https://images.unsplash.com/photo-1542831371-29b0f74f9713';
  final String verticalImageUrl =
      'https://images.unsplash.com/photo-1674574124349-0928f4b2bce3';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hiển thị ảnh đúng tỉ lệ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Ảnh ngang:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            // Đặt trong Card để có hiệu ứng đổ bóng và bo góc
            Card(
              clipBehavior: Clip.antiAlias, // Bo góc cho cả ảnh bên trong
              elevation: 4,
              child: AspectRatioImage(imageProvider: NetworkImage(imageUrl)),
            ),

            SizedBox(height: 24),

            Text('Ảnh dọc:', style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 8),
            Card(
              clipBehavior: Clip.antiAlias,
              elevation: 4,
              child: AspectRatioImage(
                imageProvider: NetworkImage(verticalImageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
