import 'package:flutter/material.dart';
import 'package:project_samples/screens/choice_chip/choice_chip_widget.dart';
import 'package:project_samples/screens/choice_chip/multi_choice_chip_widget.dart';

class ChoiceChipExamplePage extends StatefulWidget {
  static String routeName = 'basics/choice_chip_example';

  const ChoiceChipExamplePage({super.key});

  @override
  State<ChoiceChipExamplePage> createState() => _ChoiceChipExamplePageState();
}

class _ChoiceChipExamplePageState extends State<ChoiceChipExamplePage> {
  final List<String> _sizes = ['S', 'M', 'L', 'XL', 'XXL'];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choice Chip Example')),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: MultiChoiceChipWidget(
              title: 'Who do you live with?',
              choices: const [
                'Living alone',
                'Spouse/Partner',
                'Parents',
                'Children over 18',
                'Children under 18',
                'Roommate(s)',
                'Relatives',
              ],
              onChanged: (val) {},
              onSaved: (value) {},
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select at least one option';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ChoiceChipWidget(
              title: 'What type of building do you live in?',
              choices: const ['House', 'Apartment', 'Condo', 'Other'],
              onChanged: (val) {},
              onSaved: (value) {},
              validator: (value) => (value == null || value.isEmpty)
                  ? 'Please select an option'
                  : null,
            ),
          ),
          SizedBox(height: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Vui lòng chọn kích cỡ:',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              // Dùng Wrap để các chip tự động sắp xếp
              Wrap(
                spacing: 8.0, // Khoảng cách ngang giữa các chip
                runSpacing: 4.0, // Khoảng cách dọc giữa các hàng chip
                children: List.generate(_sizes.length, (index) {
                  return ChoiceChip(
                    label: Text(_sizes[index]),

                    // Logic cốt lõi: chip này được chọn NẾU index của nó
                    // bằng với _selectedIndex đang được lưu trong state.
                    selected: _selectedIndex == index,

                    // Khi người dùng nhấn vào chip này...
                    onSelected: (bool selected) {
                      // ...gọi setState để cập nhật lại state.
                      // Chúng ta chỉ cập nhật khi chip được "chọn" (selected = true).
                      if (selected) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      }
                    },

                    // Tùy chỉnh thêm cho đẹp
                    selectedColor: Colors.deepPurple,
                    labelStyle: TextStyle(
                      color: _selectedIndex == index
                          ? Colors.white
                          : Colors.black,
                    ),
                    backgroundColor: Colors.grey[200],
                    shape: StadiumBorder(), // Bo tròn các góc
                  );
                }),
              ),
            ],
          )
        ],
      ),
    );
  }
}
