import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_samples/screens/date_picker/date_form_field_widget.dart';

class DatePickerExamplePage extends StatefulWidget {
  static String routeName = 'basics/date_picker_example';

  const DatePickerExamplePage({super.key});

  @override
  State<DatePickerExamplePage> createState() => _DatePickerExamplePageState();
}

class _DatePickerExamplePageState extends State<DatePickerExamplePage> {
  final TextEditingController _birthdayController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Badge Example')),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20),
                    child: DateFormFieldWidget(
                      controller: _birthdayController,
                      topLabel: 'Date of Birth',
                      labelText: 'Birthday',
                      onTap: _pickBirthday,
                      // onTap: () => _pickBirthday(context),
                      onSaved: (value) {},
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your birthday';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Column(
                    children: [
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickBirthday() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1930),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthdayController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // Future<void> _pickBirthday(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: _selectedDate ?? DateTime.now(),
  //     firstDate: DateTime(1930),
  //     lastDate: DateTime(2025),
  //   );
  //   if (picked != null && picked != _selectedDate) {
  //     setState(() {
  //       _selectedDate = picked;
  //       _birthdayController.text = DateFormat('yyyy-MM-dd').format(picked);
  //     });
  //   }
  // }

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
}
