import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'counter_model.dart';

void main() {
  runApp(
    // Sử dụng ChangeNotifierProvider để cung cấp instance của CounterModel
    ChangeNotifierProvider(
      create: (context) => CounterModel(), // Tạo ra model của chúng ta
      child: const MyApp(), // Các widget con của nó có thể truy cập CounterModel
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            // Bọc widget cần cập nhật bằng Consumer
            Consumer<CounterModel>(
              builder: (context, counterModel, child) {
                // 'counterModel' là instance của CounterModel mà chúng ta đã cung cấp
                // Widget Text này sẽ tự động rebuild khi notifyListeners() được gọi
                return Text(
                  '${counterModel.count}',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Để gọi một hàm, chúng ta dùng Provider.of
          // listen: false là một tối ưu quan trọng!
          // Nó có nghĩa là: "Tôi chỉ muốn gọi hàm thôi, không cần build lại widget này khi dữ liệu thay đổi."
          Provider.of<CounterModel>(context, listen: false).increment();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
