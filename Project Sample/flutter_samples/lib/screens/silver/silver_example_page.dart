import 'package:flutter/material.dart';
import 'package:project_samples/screens/silver/silver_list_page.dart';
import 'package:project_samples/screens/silver/sliver_main_axis_group_example.dart';
import 'package:project_samples/screens/silver/sliver_overlap_absorber_page.dart';
import 'package:project_samples/utils/layout_spacer.dart';

class SilverExamplePage extends StatelessWidget {
  static String routeName = 'basics/silver_example';

  const SilverExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Silver Example')),
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
                    builder: (context) => SilverListPage(),
                  ),
                );
              },
              child: Text('Sliver List'),
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
                    builder: (context) => SliverMainAxisGroupExample(),
                  ),
                );
              },
              child: Text('Sliver Main Axis Group'),
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
                    builder: (context) => const SliverOverlapAbsorberPage(),
                  ),
                );
              },
              child: Text('Sliver Overlap Absorber'),
            ),
          ),
        ],
      ),
    );
  }
}
