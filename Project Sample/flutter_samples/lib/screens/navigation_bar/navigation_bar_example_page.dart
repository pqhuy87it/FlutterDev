import 'package:flutter/material.dart';
import 'package:project_samples/screens/navigation_bar/navigation_bar_demo1_page.dart';
import 'package:project_samples/screens/navigation_bar/navigation_bar_demo2_page.dart';
import 'package:project_samples/screens/navigation_bar/navigation_bar_demo3_page.dart';
import 'package:project_samples/screens/navigation_bar/navigation_bar_drawer_page.dart';
import 'package:project_samples/utils/layout_spacer.dart';

class NavigationBarExamplePage extends StatelessWidget {
  static String routeName = 'basics/navigation_bar_example';

  const NavigationBarExamplePage({super.key});

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
                    builder: (context) => NavigationBarDemo1Page(),
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
                    builder: (context) => NavigationBarDemo2Page(),
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
                    builder: (context) => const NavigationBarDemo3Page(),
                  ),
                );
              },
              child: Text('Demo 3'),
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
                    builder: (context) => const NavigationBarDrawerPage(),
                  ),
                );
              },
              child: Text('NavigationBar Drawer'),
            ),
          ),
        ],
      ),
    );
  }
}
