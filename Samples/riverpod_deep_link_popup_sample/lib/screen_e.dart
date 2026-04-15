import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_screen.dart';

// Dùng Freezed hoặc Equatable để so sánh state (Ở đây code chay cho đơn giản)
abstract class ScreenEEvent {}

class InitialEvent extends ScreenEEvent {}

// Sự kiện yêu cầu hiện Popup
class ShowDeepLinkPopupEvent extends ScreenEEvent {
  final String data;
  ShowDeepLinkPopupEvent(this.data);
}

// Provider
final screenEControllerProvider = StateNotifierProvider<ScreenEController, ScreenEEvent>((ref) {
  return ScreenEController();
});

class ScreenEController extends StateNotifier<ScreenEEvent> {
  ScreenEController() : super(InitialEvent());

  // Hàm này được gọi khi nhận được Deep Link
  void onDeepLinkReceived(String data) {
    // 1. Set state để báo UI hiện Popup
    state = ShowDeepLinkPopupEvent(data);
  }

  // Hàm xử lý nghiệp vụ khi người dùng bấm nút trong Popup
  Future<void> processData(String data) async {
    // Thực hiện xử lý (ví dụ gọi API)
    print("Đang xử lý dữ liệu: $data");
    await Future.delayed(const Duration(seconds: 2)); // Giả lập network
    print("Xử lý xong!");

    // Reset state sau khi xong (nếu cần)
    state = InitialEvent();
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
    // Xử lý trường hợp chuyển trang từ A,B,C,D sang E kèm data (Case 2)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        // Kích hoạt logic giống như nhận deep link tại chỗ
        ref.read(screenEControllerProvider.notifier).onDeepLinkReceived(args);
      }
    });
  }

  // Hàm hiển thị Popup xử lý
  void _showProcessingDialog(BuildContext context, String data) {
    showDialog(
      context: context,
      barrierDismissible: false, // Bắt buộc người dùng phải thao tác
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Nhận được Deep Link"),
          content: Text("Dữ liệu: $data\nBạn có muốn xử lý không?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () async {
                // Đóng dialog confirm
                Navigator.of(dialogContext).pop();

                // Gọi Controller xử lý logic
                await ref.read(screenEControllerProvider.notifier).processData(data);

                // Có thể hiện thêm 1 dialog thông báo thành công nếu muốn
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Đã xử lý thành công!")),
                  );
                }
              },
              child: const Text("Xử lý ngay"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- LOGIC LẮNG NGHE ĐỂ HIỆN POPUP ---
    ref.listen<ScreenEEvent>(screenEControllerProvider, (previous, next) {
      // Nếu state mới là yêu cầu hiện Popup -> Show Dialog
      if (next is ShowDeepLinkPopupEvent) {
        _showProcessingDialog(context, next.data);
      }
    });
    // --------------------------------------

    return Scaffold(
      appBar: AppBar(title: const Text("Màn hình E")),
      body: const Center(
        child: Text("Nội dung màn hình E"),
      ),
    );
  }
}