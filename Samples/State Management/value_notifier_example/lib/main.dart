import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// Khởi tạo ValueNotifier ở đây, có thể truy cập được trong widget
final ValueNotifier<int> _counter = ValueNotifier<int>(0);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MyHomePage());
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    print('MyHomePage build() called!'); // Dòng này chỉ in ra 1 LẦN
    return Scaffold(
      appBar: AppBar(title: const Text('ValueNotifier Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            // Widget này sẽ lắng nghe và tự rebuild
            ValueListenableBuilder<int>(
              valueListenable: _counter,
              builder: (BuildContext context, int value, Widget? child) {
                print(
                  'ValueListenableBuilder rebuilt!',
                ); // Dòng này in ra mỗi lần bấm nút
                return Text(
                  '$value',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Thay đổi giá trị và kích hoạt rebuild
          _counter.value++;
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
