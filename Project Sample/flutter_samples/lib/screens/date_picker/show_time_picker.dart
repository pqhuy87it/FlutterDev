import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShowTimePickerApp extends StatelessWidget {
  const ShowTimePickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TimePickerDemo(),
    );
  }
}

class TimePickerDemo extends StatefulWidget {
  const TimePickerDemo({super.key});

  @override
  State<TimePickerDemo> createState() => _TimePickerDemoState();
}

class _TimePickerDemoState extends State<TimePickerDemo> {
  TimeOfDay? _selectedTime;

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ví dụ TimePicker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _selectedTime == null
                  ? 'Chưa chọn thời gian'
              // format(context) sẽ tự định dạng theo 12h/24h của hệ thống
                  : 'Thời gian đã chọn: ${_selectedTime!.format(context)}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectTime(context),
              child: const Text('Chọn thời gian'),
            ),
          ],
        ),
      ),
    );
  }
}