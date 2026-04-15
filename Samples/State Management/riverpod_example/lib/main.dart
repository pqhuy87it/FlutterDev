import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'counter_provider.dart'; // Import provider của bạn
import 'counter_notifier_provider.dart';

void main() {
  // Bọc toàn bộ ứng dụng bằng ProviderScope
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage1(),
    );
  }
}

// 1. Thay vì StatelessWidget, dùng ConsumerWidget
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  // 2. Phương thức build bây giờ có thêm tham số 'WidgetRef ref'
  Widget build(BuildContext context, WidgetRef ref) {

    // 3. Dùng ref.watch() để lấy giá trị và lắng nghe sự thay đổi
    // Khi giá trị của counterProvider thay đổi, widget này sẽ rebuild
    final int count = ref.watch(counterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Riverpod Counter')),
      body: Center(
        child: Text(
          '$count',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 4. Dùng ref.read() bên trong một callback
          // .notifier cho phép bạn truy cập vào StateController để thay đổi state
          ref.read(counterProvider.notifier).state++;
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class HomePage1 extends ConsumerWidget {
  const HomePage1({super.key});

  @override
  // 2. Phương thức build bây giờ có thêm tham số 'WidgetRef ref'
  Widget build(BuildContext context, WidgetRef ref) {

    // Watch provider để lấy state (int)
    final int count = ref.watch(counterNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Riverpod Counter')),
      body: Center(
        child: Text(
          '$count',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          /// Read provider.notifier để truy cập các phương thức của CounterNotifier
          ref.read(counterNotifierProvider.notifier).increment();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
