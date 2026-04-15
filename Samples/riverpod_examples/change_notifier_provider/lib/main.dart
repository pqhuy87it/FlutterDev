import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'counter_provider.dart';
import 'counter_notifier.dart';

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
      home: const HomePage(),
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
    // Bất cứ khi nào notifyListeners() được gọi trong CounterNotifier,
    // widget này sẽ được rebuild.
    final counterNotifier = ref.watch(counterNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Riverpod Counter')),
      body: Center(
        child: Column(
          children: [
            Text('$count', style: Theme.of(context).textTheme.headlineMedium),
            SizedBox(height: 10),
            Text(
              '${counterNotifier.count}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 4. Dùng ref.read() bên trong một callback
          // .notifier cho phép bạn truy cập vào StateController để thay đổi state
          ref.read(counterProvider.notifier).state++;
          // Read provider.notifier để truy cập các phương thức của CounterNotifier
          ref.read(counterNotifierProvider.notifier).increment();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
