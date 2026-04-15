import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'counter_cubit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Cung cấp CounterCubit cho các widget con
    // Widget này hoạt động cho cả BLoC và Cubit
    return BlocProvider(
      create: (context) => CounterCubit(),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Cubit Counter')),
      body: Center(
        // 2. Dùng BlocBuilder để lắng nghe và rebuild UI
        // Widget này cũng hoạt động cho cả BLoC và Cubit
        child: BlocBuilder<CounterCubit, int>(
          builder: (context, count) {
            // 'count' chính là state (kiểu int) hiện tại của Cubit
            return Text(
              '$count',
              style: Theme.of(context).textTheme.headlineMedium,
            );
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              // 3. SỰ KHÁC BIỆT LỚN NHẤT LÀ ĐÂY!
              // Thay vì .add(Event()), ta gọi trực tiếp hàm của Cubit
              context.read<CounterCubit>().increment();
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: () {
              context.read<CounterCubit>().decrement();
            },
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}