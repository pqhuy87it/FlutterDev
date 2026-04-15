import 'package:flutter/material.dart';
import 'package:project_samples/screens/functions/show_general_dialog/function_showGeneralDialog.dart';
import 'package:project_samples/utils/layout_spacer.dart';

class FunctionExamplePage extends StatelessWidget {
  static String routeName = 'basics/function_example';

  const FunctionExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Function Example')),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FunctionShowGeneralDialog(),
                  ),
                );
              },
              child: Text('Show general dialog'),
            ),
          ),
          LayoutSpacer.vertical20,
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: ElevatedButton(
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => SliverMainAxisGroupExample(),
                //   ),
                // );
              },
              child: Text('Sliver Main Axis Group'),
            ),
          ),
          LayoutSpacer.vertical20,
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: ElevatedButton(
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => const SliverOverlapAbsorberPage(),
                //   ),
                // );
              },
              child: Text('Sliver Overlap Absorber'),
            ),
          ),
        ],
      ),
    );
  }
}
