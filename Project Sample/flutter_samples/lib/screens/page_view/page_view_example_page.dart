import 'package:flutter/material.dart';
import 'package:project_samples/screens/page_view/page_view_never_scroll_example.dart';
import 'package:project_samples/screens/page_view/page_view_basic_page.dart';
import 'package:project_samples/utils/layout_spacer.dart';

class PageViewExamplePage extends StatelessWidget {
  static String routeName = 'basics/page_view_example';

  const PageViewExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page View Example')),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PageViewBasicPage(),
                ),
              );
            },
            child: Text('Page View Basic'),
          ),
          LayoutSpacer.vertical20,
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PageViewNeverScrollExample(),
                ),
              );
            },
            child: Text('Page View Never Scroll'),
          ),
          LayoutSpacer.vertical20,
        ],
      ),
    );
  }
}
