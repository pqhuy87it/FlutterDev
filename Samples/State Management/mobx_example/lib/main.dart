import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'counter_store.dart'; // Import store của bạn

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Cung cấp CounterStore cho toàn bộ ứng dụng con
    return Provider<CounterStore>(
      create: (_) => CounterStore(),
      child: const MaterialApp(
        home: CounterPage(),
      ),
    );
  }
}

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Lấy instance của store từ Provider
    final counterStore = Provider.of<CounterStore>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('MobX Counter')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            // 3. Dùng Observer để tự động rebuild widget này
            Observer(
              builder: (_) => Text(
                '${counterStore.value}', // Sử dụng observable 'value'
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 20),
            // Widget này cũng sẽ tự động cập nhật
            Observer(
              builder: (_) => Text(
                counterStore.doubleCountMessage, // Sử dụng computed 'doubleCountMessage'
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 4. Gọi action để thay đổi state
          counterStore.increment();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}