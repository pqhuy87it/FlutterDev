import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data_provider.dart'; // Import file provider

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Sử dụng ChangeNotifierProvider để cung cấp DataProvider cho toàn bộ ứng dụng
    return ChangeNotifierProvider(
      create: (context) => DataProvider(),
      child: MaterialApp(
        title: 'ChangeNotifier & Future Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo ChangeNotifier với Future'),
      ),
      body: Center(
        // Consumer sẽ lắng nghe thay đổi từ DataProvider và rebuild lại UI
        child: Consumer<DataProvider>(
          builder: (context, provider, child) {
            // Dựa vào trạng thái của provider để quyết định hiển thị gì
            if (provider.isLoading) {
              return const CircularProgressIndicator();
            }

            if (provider.errorMessage != null) {
              return Text(
                'Lỗi: ${provider.errorMessage}',
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              );
            }

            return Text(
              provider.data,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // Khi nhấn nút, gọi hàm fetchData.
        // Dùng context.read thay vì context.watch vì chúng ta chỉ gọi hàm,
        // không cần rebuild lại nút này khi trạng thái thay đổi.
        onPressed: () => context.read<DataProvider>().fetchData(),
        tooltip: 'Tải dữ liệu',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}