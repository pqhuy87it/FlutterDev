import 'package:flutter/material.dart';

class CategoryFilterChip extends StatefulWidget {
  const CategoryFilterChip({super.key});

  @override
  State<CategoryFilterChip> createState() => _CategoryFilterChipState();
}

class _CategoryFilterChipState extends State<CategoryFilterChip> {
  final List<String> _filters = ['Áo thun', 'Quần jeans', 'Giày thể thao', 'Phụ kiện'];
  // Dùng Set để lưu các lựa chọn, giúp tránh trùng lặp
  final Set<String> _selectedFilters = <String>{};

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        spacing: 8.0,
        children: _filters.map((String filterName) {
          return FilterChip(
            label: Text(filterName),
            // Kiểm tra xem filter này có trong danh sách được chọn không
            selected: _selectedFilters.contains(filterName),
            selectedColor: Colors.amber.shade300,
            // Callback khi người dùng nhấn
            onSelected: (bool selected) {
              setState(() {
                if (selected) {
                  _selectedFilters.add(filterName);
                } else {
                  _selectedFilters.remove(filterName);
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }
}