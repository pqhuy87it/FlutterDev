import 'package:flutter/material.dart';
import 'package:project_samples/screens/alert_dialog/alert_dialog_basic_page.dart';
import 'package:project_samples/screens/alert_dialog/alert_dialog_demo1_page.dart';

class AlertDialogExamplePage extends StatelessWidget {
  static String routeName = 'basics/alert_dialog_example';

  const AlertDialogExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alert Dialog Example')),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AlertDialogBasicPage()),
              );
            },
            child: const Text('Basic'),
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AlertDialogDemo1Page()),
              );
            },
            child: const Text('Show Confirm Dialog'),
          ),
        ],
      ),
    );
  }
}
