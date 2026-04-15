import 'package:flutter/material.dart';
import 'package:project_samples/screens/aspect_ratio/aspect_ratio_basic_page.dart';
import 'package:project_samples/screens/aspect_ratio/aspect_ratio_card_page.dart';
import 'package:project_samples/screens/aspect_ratio/aspect_ratio_gridview_build_page.dart';
import 'package:project_samples/screens/aspect_ratio/image_ratio/display_aspect_ratio_image_page.dart';
import 'package:project_samples/utils/layout_spacer.dart';

class AspectRatioExamplePage extends StatelessWidget {
  static String routeName = 'basics/aspect_ratio_example';

  const AspectRatioExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grid View Example')),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AspectRatioBasicPage(),
                ),
              );
            },
            child: Text('Aspect Ratio Basic'),
          ),
          LayoutSpacer.vertical20,
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AspectRatioGridviewBuildPage(),
                ),
              );
            },
            child: Text('Aspect Ratio GridView Build'),
          ),
          LayoutSpacer.vertical20,
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AspectRatioCardPage(),
                ),
              );
            },
            child: Text('Aspect Ratio Card'),
          ),
          LayoutSpacer.vertical20,
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DisplayAspectRatioImagePage(),
                ),
              );
            },
            child: Text('Display Aspect Ratio Image'),
          ),
        ],
      ),
    );
  }
}
