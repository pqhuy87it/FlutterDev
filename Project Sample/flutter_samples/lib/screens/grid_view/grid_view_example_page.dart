import 'package:flutter/material.dart';
import 'package:project_samples/screens/grid_view/basic_grid_view.dart';
import 'package:project_samples/screens/grid_view/grid_view_builder.dart';
import 'package:project_samples/utils/layout_spacer.dart';

class GridViewExamplePage extends StatefulWidget {
  static String routeName = 'basics/grid_view_example';

  const GridViewExamplePage({super.key});

  @override
  State<GridViewExamplePage> createState() => _GridViewExamplePageState();
}

class _GridViewExamplePageState extends State<GridViewExamplePage> {
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
                  builder: (context) => BasicGridView(),
                ),
              );
            },
            child: Text('Basic Grid View'),
          ),
          LayoutSpacer.vertical20,
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GridViewBuilder(),
                ),
              );
            },
            child: Text('BGrid View Builder'),
          ),
        ],
      ),
    );
  }
}
