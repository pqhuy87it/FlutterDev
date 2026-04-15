import 'package:flutter/material.dart';

class LinearProgressIndicatorIndeterminatePage extends StatelessWidget {
  const LinearProgressIndicatorIndeterminatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Indeterminate Progress')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Đang tải dữ liệu, vui lòng chờ...'),
              SizedBox(height: 20),
              // Chỉ cần đặt widget vào đây, không cần thuộc tính 'value'
              LinearProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
