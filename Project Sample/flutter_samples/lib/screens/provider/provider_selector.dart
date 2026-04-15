import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_settings.dart';

class ProviderSelector extends StatelessWidget {
  const ProviderSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Silver Example')),
      body: Center(
        child: Column(
          children: [
            // Widget này CHỈ lắng nghe sự thay đổi của `name`
            Selector<UserSettings, String>(
              selector: (context, settings) => settings.name,
              builder: (context, name, child) {
                print('Building Name Text');
                return Text('Name: $name');
              },
            ),

            // Widget này CHỈ lắng nghe sự thay đổi của `age`
            Selector<UserSettings, int>(
              selector: (context, settings) => settings.age,
              builder: (context, age, child) {
                print('Building Age Text');
                return Text('Age: $age');
              },
            ),

            // Widget này CHỈ lắng nghe sự thay đổi của `theme`
            Selector<UserSettings, ThemeMode>(
              selector: (context, settings) => settings.theme,
              builder: (context, theme, child) {
                print('Building Theme Switch');
                return Switch(
                  value: theme == ThemeMode.dark,
                  onChanged: (bool value) {
                    // Để gọi phương thức, chúng ta vẫn cần truy cập toàn bộ provider.
                    // Dùng Provider.of với listen: false.
                    Provider.of<UserSettings>(context, listen: false).toggleTheme();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
