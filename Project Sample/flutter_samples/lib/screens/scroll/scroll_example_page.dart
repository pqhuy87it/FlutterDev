import 'package:flutter/material.dart';
import 'package:project_samples/screens/scroll/draggable_scrollable_sheet_page.dart';
import 'package:project_samples/screens/scroll/scroll_configuration_example_page.dart';
import 'package:project_samples/utils/layout_spacer.dart';

class ScrollExamplePage extends StatelessWidget {
  static String routeName = 'basics/scroll_example';

  const ScrollExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scroll Example')),
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
                    builder: (context) => ScrollConfigurationExamplePage(),
                  ),
                );
              },
              child: Text('Scroll configuration example'),
            ),
          ),
          LayoutSpacer.vertical10,
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DraggableScrollableSheetPage(),
                  ),
                );
              },
              child: Text('Draggable Scrollable Sheet'),
            ),
          ),
        ],
      ),
    );
  }
}
