import 'package:flutter/material.dart';
import 'package:project_samples/screens/text_field/basic_custom_text_field.dart';

class TextFieldExamplePage extends StatefulWidget {
  static String routeName = 'basics/text_field_example';

  const TextFieldExamplePage({super.key});

  @override
  State<TextFieldExamplePage> createState() => _TextFieldExamplePageState();
}

class _TextFieldExamplePageState extends State<TextFieldExamplePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Text Field Example')),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: <Widget>[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BasicCustomTextField(hintText: "Input something",),
              ],
            ),
          )
        ],
      ),
    );
  }
}
