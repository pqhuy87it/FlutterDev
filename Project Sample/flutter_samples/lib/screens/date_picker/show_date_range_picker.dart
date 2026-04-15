import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShowDateRangePickerApp extends StatelessWidget {
  const ShowDateRangePickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DateRangePickerDemo(),
    );
  }
}

class DateRangePickerDemo extends StatefulWidget {
  const DateRangePickerDemo({super.key});

  @override
  State<DateRangePickerDemo> createState() => _DateRangePickerDemoState();
}

class _DateRangePickerDemoState extends State<DateRangePickerDemo> {
  DateTimeRange? _selectedDateRange;

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023, 1),
      lastDate: DateTime(2025, 12),
      initialDateRange: _selectedDateRange,
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ví dụ DateRangePicker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _selectedDateRange == null
                  ? 'Chưa chọn khoảng ngày'
                  : 'Từ: ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - Đến: ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectDateRange(context),
              child: const Text('Chọn khoảng ngày'),
            ),
          ],
        ),
      ),
    );
  }
}