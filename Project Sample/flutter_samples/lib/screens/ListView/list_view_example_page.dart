import 'package:flutter/material.dart';
import 'package:project_samples/screens/ListView/list_view_builder_page.dart';
import 'package:project_samples/screens/ListView/list_view_default_page.dart';
import 'package:project_samples/screens/ListView/list_view_separated_page.dart';

class ListViewExamplePage extends StatelessWidget {
  static String routeName = 'basics/list_view_example';

  const ListViewExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('List View Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ListViewDefaultPage(),
                  ),
                );
              },
              child: Text('List View Default'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ListViewBuilderPage(),
                  ),
                );
              },
              child: Text('List View Builder'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ListViewSeparatedPage(),
                  ),
                );
              },
              child: Text('List View Separated'),
            ),
          ],
        ),
      ),
    );
  }
}
