import 'package:flutter/material.dart';
import 'package:project_samples/screens/bottom_app_bar/bottom_app_bar_demo1_page.dart';
import 'package:project_samples/screens/bottom_app_bar/bottom_app_bar_demo2_page.dart';
import 'package:project_samples/screens/bottom_app_bar/bottom_app_bar_demo3_page.dart';
import 'package:project_samples/utils/layout_spacer.dart';

class BottomAppBarExamplePage extends StatelessWidget {
  static String routeName = 'basics/bottom_app_bar_example';

  const BottomAppBarExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bottom Navigation Bar Example')),
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
                    builder: (context) => BottomAppBarDemo1Page(),
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
                    builder: (context) => BottomAppBarDemo2Page(),
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
                    builder: (context) => const BottomAppBarDemo3Page(),
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
