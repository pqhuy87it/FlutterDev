import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_screen.dart';

final screenEProvider = StateNotifierProvider<ScreenENotifier, ScreenEState>((ref) {
  return ScreenENotifier();
});

class ScreenEState {
  final String data;
  ScreenEState(this.data);
}

class ScreenENotifier extends StateNotifier<ScreenEState> {
  ScreenENotifier() : super(ScreenEState("Chưa có dữ liệu"));

  // Hàm này sẽ được gọi khi nhận DeepLink và đang ở màn E
  void updateData(String newData) {
    state = ScreenEState(newData);
  }
}

class ScreenE extends ConsumerStatefulWidget {
  const ScreenE({super.key});

  @override
  ConsumerState<ScreenE> createState() => _ScreenEState();
}

class _ScreenEState extends ConsumerState<ScreenE> {
  @override
  void initState() {
    super.initState();
    // Nếu được push tới từ DeepLink (Case 2), lấy arguments để init state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        ref.read(screenEProvider.notifier).updateData(args);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe state thay đổi (Case 1: Update tại chỗ)
    final state = ref.watch(screenEProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Màn hình E")),
      body: Center(
        child: Text(
          "Dữ liệu: ${state.data}",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}