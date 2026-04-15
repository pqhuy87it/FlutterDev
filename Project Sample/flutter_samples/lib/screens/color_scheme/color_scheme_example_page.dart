import 'package:flutter/material.dart';

class ColorSchemeExamplePage extends StatelessWidget {
  static String routeName = 'basics/color_scheme_example';

  const ColorSchemeExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy ColorScheme từ theme hiện tại
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // AppBar sẽ tự động dùng màu primary từ theme
      appBar: AppBar(title: const Text('ColorScheme Demo')),
      // Nền của Scaffold sẽ tự động dùng màu `background`
      backgroundColor: colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              // Nền của Card sẽ tự động dùng màu `surface`
              color: colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Đây là một cái Card.',
                  // Chữ trên Card sẽ dùng màu `onSurfaceVariant`
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              // Nút sẽ tự động dùng màu `primary` và `onPrimary`
              child: const Text('Nút chính'),
            ),
            const SizedBox(height: 10),
            Text(
              'Đây là văn bản thông thường.',
              // Văn bản trên nền `background` sẽ dùng màu `onBackground`
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        // FAB thường dùng màu `secondaryContainer` hoặc `tertiaryContainer`
        backgroundColor: colorScheme.secondaryContainer,
        child: Icon(Icons.add, color: colorScheme.onSecondaryContainer),
      ),
    );
  }
}
