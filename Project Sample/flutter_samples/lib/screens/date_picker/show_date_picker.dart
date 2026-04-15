import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import thư viện intl

class ShowDatePickerApp extends StatelessWidget {
  const ShowDatePickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ShowDatePickerDemo(),
    );
  }
}

class ShowDatePickerDemo extends StatefulWidget {
  const ShowDatePickerDemo({super.key});

  @override
  State<ShowDatePickerDemo> createState() => _DatePickerDemoState();
}

class _DatePickerDemoState extends State<ShowDatePickerDemo> {
  // Biến để lưu ngày được chọn. Có thể là null ban đầu.
  DateTime? _selectedDate;

  // Hàm để hiển thị DatePicker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(), // Ngày hiển thị ban đầu
      firstDate: DateTime(2000), // Ngày bắt đầu có thể chọn
      lastDate: DateTime(2101), // Ngày cuối cùng có thể chọn
    );

    // Nếu người dùng đã chọn một ngày (không phải null)
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ví dụ DatePicker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _selectedDate == null
                  ? 'Chưa có ngày nào được chọn'
              // Dùng intl để định dạng ngày thành chuỗi 'dd/MM/yyyy'
                  : 'Ngày đã chọn: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectDate(context), // Gọi hàm khi nhấn nút
              child: const Text('Chọn ngày'),
            ),
          ],
        ),
      ),
    );
  }
}