import 'package:flutter/material.dart';
import 'package:project_samples/screens/pass_value/pass_data_page_argument.dart';
import 'package:project_samples/screens/pass_value/pass_value_forward.dart';
import 'package:project_samples/screens/pass_value/pass_value_route_setting.dart';
import 'package:project_samples/utils/layout_spacer.dart';

class PassValueExamplePage extends StatelessWidget {
  static String routeName = 'basics/pass_value_example';

  const PassValueExamplePage({super.key});

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
                    builder: (context) => PassValueForward(),
                  ),
                );
              },
              child: Text('Pass value forward'),
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
                    builder: (context) => PassValueRouteSetting(),
                  ),
                );
              },
              child: Text('Pass value RouteSettings'),
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
                    builder: (context) => const PassDataPageArgument(),
                  ),
                );
              },
              child: Text('Pass data page argument'),
            ),
          ),
        ],
      ),
    );
  }
}
