import 'package:flutter/material.dart';
import 'package:project_samples/screens/future/future_demo1_page.dart';
import 'package:project_samples/screens/future/future_demo2_page.dart';
import 'package:project_samples/utils/layout_spacer.dart';

class FutureExamplePage extends StatelessWidget {
  static String routeName = 'basics/future_example';

  const FutureExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Future Example')),
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
                    builder: (context) => FutureDemo1Page(),
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
                    builder: (context) => const FutureDemo2Page(),
                  ),
                );
              },
              child: Text('Sliver Overlap Absorber'),
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
                //     builder: (context) => SilverListPage(),
                //   ),
                // );
              },
              child: Text('Sliver List'),
            ),
          ),
          LayoutSpacer.vertical20,
        ],
      ),
    );
  }
}
