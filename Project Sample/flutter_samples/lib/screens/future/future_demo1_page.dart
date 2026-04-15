import 'package:flutter/material.dart';

// Giả lập việc gọi API để lấy tên người dùng
Future<String> fetchUserData() async {
  // Giả lập độ trễ mạng
  await Future.delayed(Duration(seconds: 2));

  // Giả lập trường hợp thành công
  return 'John Doe';

  // Để thử trường hợp lỗi, hãy bỏ comment dòng dưới và comment dòng trên
  // throw Exception('Không thể tải dữ liệu người dùng');
}

class FutureDemo1Page extends StatefulWidget {
  const FutureDemo1Page({super.key});

  @override
  State<FutureDemo1Page> createState() => _FutureDemo1PageState();
}

class _FutureDemo1PageState extends State<FutureDemo1Page> {
  // Quan trọng: Khai báo Future ở đây!
  late Future<String> _userDataFuture;

  @override
  void initState() {
    super.initState();
    // Gọi hàm Future MỘT LẦN DUY NHẤT trong initState
    _userDataFuture = fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FutureBuilder Demo'),
      ),
      body: Center(
        child: FutureBuilder<String>(
          // 1. Cung cấp Future
          future: _userDataFuture,

          // 2. Xây dựng UI dựa trên snapshot
          builder: (context, snapshot) {
            // Trường hợp 1: Future đang chờ
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            // Trường hợp 2: Future hoàn thành nhưng có lỗi
            else if (snapshot.hasError) {
              return Text(
                'Đã xảy ra lỗi: ${snapshot.error}',
                style: TextStyle(color: Colors.red),
              );
            }
            // Trường hợp 3: Future hoàn thành thành công và có dữ liệu
            else if (snapshot.hasData) {
              // Lấy dữ liệu từ snapshot
              String userName = snapshot.data!;
              return Text(
                'Xin chào, $userName!',
                style: TextStyle(fontSize: 24),
              );
            }
            // Trường hợp 4: Trạng thái khác (ví dụ: chưa bắt đầu)
            else {
              return Text('Không có dữ liệu.');
            }
          },
        ),
      ),
    );
  }
}
