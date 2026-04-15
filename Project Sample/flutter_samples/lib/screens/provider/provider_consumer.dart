import 'package:flutter/material.dart';
import 'user_settings.dart';
import 'package:provider/provider.dart';

class ProviderConsumer extends StatelessWidget {
  const ProviderConsumer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consumer Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            // Sử dụng Consumer để chỉ rebuild Text widget này
            Consumer<UserSettings>(
              builder: (context, settings, child) {
                // Widget này sẽ rebuild mỗi khi notifyListeners() được gọi
                print('Building entire settings screen UI');
                return Column(
                  children: [
                    Text('Name: ${settings.name}'),
                    Text('Age: ${settings.age}'),
                    Switch(
                      value: settings.theme == ThemeMode.dark,
                      onChanged: (bool value) {
                        // Chỉ thay đổi theme
                        settings.toggleTheme();
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
