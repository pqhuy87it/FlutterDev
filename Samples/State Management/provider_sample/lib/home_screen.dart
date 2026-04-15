// file: home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'counter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider siêu ngầu'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Số lần bạn đã nhấn nút:',
            ),
            // Dùng context.watch để lắng nghe thay đổi của Counter
            // Text này sẽ tự động cập nhật khi _count thay đổi
            Text(
              '${context.watch<Counter>().count}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              // Dùng context.read để gọi hàm mà không cần build lại cả widget
              context.read<Counter>().increment();
            },
            tooltip: 'Tăng',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              context.read<Counter>().decrement();
            },
            tooltip: 'Giảm',
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}