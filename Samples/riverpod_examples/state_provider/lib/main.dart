import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

// Bước 1: Tạo provider
final counterProvider = StateProvider<int>((ref) => 0);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Bước 3: Lắng nghe trạng thái để hiển thị trên UI
    final int count = ref.watch(counterProvider);

    // Lắng nghe provider để có thể reset về trạng thái ban đầu
    ref.listen<int>(counterProvider, (previous, next) {
      // Ví dụ: hiển thị SnackBar khi giá trị đạt đến 5
      if (next == 5) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã đạt đến 5!')));
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("State Provider Example"),
        actions: [
          // Nút để reset counter
          IconButton(
            onPressed: () {
              // Cách 1: Gán lại giá trị ban đầu
              // ref.invalidate(counterProvider) cũng có tác dụng tương tự.
              ref.read(counterProvider.notifier).state = 0;
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              'Giá trị: $count',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(counterProvider.notifier).update((state) => state - 1);
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
