import 'package:flutter/material.dart';
import 'package:project_samples/screens/check_box/my_check_box.dart';
import 'package:project_samples/screens/check_box/my_check_box_list_title.dart';
import 'package:project_samples/screens/check_box/tristate_check_box.dart';

class CheckBoxExamplePage extends StatelessWidget {
  static String routeName = 'basics/check_box_example';

  const CheckBoxExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check Box Example')),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: <Widget>[
          MyCheckboxExample(),
          MyCheckboxListTileExample(),
          TristateCheckboxExample()
        ],
      ),
    );
  }
}
