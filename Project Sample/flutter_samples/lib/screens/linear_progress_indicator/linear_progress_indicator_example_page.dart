import 'package:flutter/material.dart';
import 'package:project_samples/screens/linear_progress_indicator/linear_progress_indicator_determinate_page.dart';
import 'package:project_samples/screens/linear_progress_indicator/linear_progress_indicator_indeterminate_page.dart';
import 'package:project_samples/utils/layout_spacer.dart';

class LinearProgressIndicatorExamplePage extends StatelessWidget {
  static String routeName = 'basics/linear_progress_indicator_example';

  const LinearProgressIndicatorExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Linear Progress Indicator Example')),
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
                    builder: (context) => LinearProgressIndicatorIndeterminatePage(),
                  ),
                );
              },
              child: Text('Linear Progress Indicator Indeterminate'),
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
                    builder: (context) => LinearProgressIndicatorDeterminatePage(),
                  ),
                );
              },
              child: Text('Linear Progress Indicator Determinate'),
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
