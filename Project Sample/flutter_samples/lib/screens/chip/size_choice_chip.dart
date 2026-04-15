import 'package:flutter/material.dart';

class SizeChoiceChip extends StatefulWidget {
  const SizeChoiceChip({super.key});

  @override
  State<SizeChoiceChip> createState() => _SizeChoiceChipState();
}

class _SizeChoiceChipState extends State<SizeChoiceChip> {
  int _selectedIndex = 0; // Index của chip đang được chọn
  final List<String> _options = ['S', 'M', 'L', 'XL'];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap( // Dùng Wrap để các chip tự xuống dòng nếu không đủ chỗ
        spacing: 8.0, // Khoảng cách ngang giữa các chip
        children: List<Widget>.generate(_options.length, (int index) {
          return ChoiceChip(
            label: Text(_options[index]),
            // Trạng thái được chọn dựa trên index
            selected: _selectedIndex == index,
            selectedColor: Colors.green,
            // Callback khi người dùng chọn chip này
            onSelected: (bool selected) {
              setState(() {
                // Chỉ cập nhật nếu người dùng chọn một chip mới
                if (selected) {
                  _selectedIndex = index;
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }
}