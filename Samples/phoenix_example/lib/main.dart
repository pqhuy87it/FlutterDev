import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Tạo một Provider đơn giản để test state
// Khi App restart, biến này sẽ quay về 0
final counterProvider = StateProvider<int>((ref) => 0);

void main() {
  runApp(
    // 2. Bọc Phoenix ở ngoài cùng (Quan trọng)
    Phoenix(
      // 3. Bọc ProviderScope BÊN TRONG Phoenix
      // Để khi Phoenix tái sinh, ProviderScope cũng được tạo mới -> Reset hết state
      child: ProviderScope(
        child: const MaterialApp(
          home: ScreenA(),
        ),
      ),
    ),
  );
}

// --- MÀN HÌNH A ---
class ScreenA extends ConsumerWidget {
  const ScreenA({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Màn hình A (Home)")),
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Giá trị Counter: $count", style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => ref.read(counterProvider.notifier).state++,
              child: const Text("Tăng Counter (+1)"),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
              onPressed: () {
                // Chuyển sang màn hình B
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScreenB()),
                );
              },
              child: const Text("Sang Màn hình B ->"),
            ),
          ],
        ),
      ),
    );
  }
}

// --- MÀN HÌNH B ---
class ScreenB extends ConsumerWidget {
  const ScreenB({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Vẫn đọc được giá trị Counter từ màn A
    final count = ref.watch(counterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Màn hình B")),
      backgroundColor: Colors.green.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Vẫn giữ giá trị: $count", style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              onPressed: () {
                // Chuyển sang màn hình C
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScreenC()),
                );
              },
              child: const Text("Sang Màn hình C ->"),
            ),
          ],
        ),
      ),
    );
  }
}

// --- MÀN HÌNH C (Nơi gọi Phoenix) ---
class ScreenC extends ConsumerWidget {
  const ScreenC({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Màn hình C (Cuối)")),
      backgroundColor: Colors.orange.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Giá trị hiện tại: $count", style: const TextStyle(fontSize: 24)),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "Bấm nút dưới sẽ Reset App.\nCounter sẽ về 0 và quay lại Màn A.",
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            // NÚT RESTART APP
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text("GỌI PHOENIX.REBIRTH"),
              onPressed: () async {
                // Giả lập xử lý logout hoặc xóa data 1 chút
                print("Đang xóa dữ liệu...");
                await Future.delayed(const Duration(milliseconds: 500));

                // QUAN TRỌNG: Kiểm tra mounted để tránh lỗi "Bad state: ref"
                // giống câu hỏi trước của bạn nếu có dùng ref ở đây.
                if (!context.mounted) return;

                print("Bắt đầu Restart!");

                // --- GỌI PHOENIX ---
                Phoenix.rebirth(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}