import 'package:flutter/material.dart';
import 'package:project_samples/screens/tab_bar/tab_bar_default.dart';
import 'package:project_samples/screens/tab_bar/tab_bar_dynamic_header.dart';
import 'package:project_samples/utils/layout_spacer.dart';

class TabBarExamplePage extends StatelessWidget {
  static String routeName = 'basics/tab_bar_example';

  const TabBarExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TabBar Example')),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TabBarDefaultPage(),
                ),
              );
            },
            child: Text('TabBar Default'),
          ),
          LayoutSpacer.vertical20,
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TabBarDynamicHeader(),
                ),
              );
            },
            child: Text('TabBar Dynamic Header'),
          ),
        ],
      ),
    );
  }
}
