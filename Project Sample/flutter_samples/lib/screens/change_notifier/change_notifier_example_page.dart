import 'package:flutter/material.dart';
import 'package:project_samples/screens/change_notifier/change_notifier_manager.dart';
import 'package:project_samples/utils/layout_spacer.dart';

class ChangeNotifierExamplePage extends StatelessWidget {
  static String routeName = 'basics/change_notifier_example';

  const ChangeNotifierExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Notifier Example')),
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
                    builder: (context) => ChangeNotifierManager(),
                  ),
                );
              },
              child: Text('Change Notifier Manager'),
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
