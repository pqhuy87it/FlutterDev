import 'package:flutter/material.dart';
import 'package:project_samples/screens/chip/action_chip.dart';
import 'package:project_samples/screens/chip/filter_chip.dart';
import 'package:project_samples/screens/chip/input_chip.dart';
import 'package:project_samples/screens/chip/size_choice_chip.dart';

class ChipExamplePage extends StatelessWidget {
  static String routeName = 'basics/chip_example';

  const ChipExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ví dụ Chip cơ bản')),
      body: Center(
        child: Column(
          children: <Widget>[
            Chip(
              // Avatar ở đầu chip
              avatar: CircleAvatar(
                backgroundColor: Colors.blue.shade900,
                child: const Text('A'),
              ),
              // Nội dung chính
              label: const Text('Android Developer'),
              // Màu nền
              backgroundColor: Colors.blue.shade100,
              // Thêm viền
              shape: StadiumBorder(
                side: BorderSide(color: Colors.blue.shade300),
              ),
              // Icon xóa và hành động khi nhấn
              deleteIcon: const Icon(Icons.close),
              onDeleted: () {
                print('Chip đã bị xóa!');
              },
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizeChoiceChip(),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: CategoryFilterChip(),
            ),
            Padding(padding: const EdgeInsets.all(10.0), child: MyActionChip()),
            Padding(padding: const EdgeInsets.all(10.0), child: MyInputChip()),
          ],
        ),
      ),
    );
  }
}
