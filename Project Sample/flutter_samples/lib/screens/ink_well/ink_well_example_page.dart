import 'package:flutter/material.dart';
import 'package:project_samples/screens/ink_well/ink_well_demo3.dart';
import 'package:project_samples/utils/layout_spacer.dart';
import 'package:project_samples/screens/ink_well/ink_well_demo1.dart';
import 'package:project_samples/screens/ink_well/ink_well_demo2.dart';

class InkWellExamplePage extends StatelessWidget {
  static String routeName = 'basics/ink_well_example';

  const InkWellExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('InkWell Example')),
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
                    builder: (context) => InkWellDemo1(),
                  ),
                );
              },
              child: Text('Demo 1'),
            ),
          ),
          LayoutSpacer.vertical20,
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InkWellDemo2(),
                  ),
                );
              },
              child: Text('Demo 2'),
            ),
          ),
          LayoutSpacer.vertical20,
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InkWellDemo3(),
                  ),
                );
              },
              child: Text('Demo 3'),
            ),
          ),
        ],
      ),
    );
  }
}
