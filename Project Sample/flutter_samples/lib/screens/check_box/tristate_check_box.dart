import 'package:flutter/material.dart';

class TristateCheckboxExample extends StatefulWidget {
  const TristateCheckboxExample({super.key});

  @override
  State<TristateCheckboxExample> createState() => _TristateCheckboxExampleState();
}

class _TristateCheckboxExampleState extends State<TristateCheckboxExample> {
  // Biến trạng thái bây giờ là bool? (nullable boolean)
  bool? _parentState = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Checkbox(
        // Kích hoạt 3 trạng thái
        tristate: true,
        // value bây giờ có thể là true, false, hoặc null
        value: _parentState,
        onChanged: (bool? newValue) {
          setState(() {
            // Khi ở trạng thái null, lần nhấn tiếp theo sẽ chuyển thành true
            _parentState = newValue ?? true;
          });
        },
      ),
    );
  }
}