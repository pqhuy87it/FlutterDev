import 'package:flutter/material.dart';
import 'package:project_samples/screens/bottom_sheet/modal_bottom_sheet_page.dart';
import 'package:project_samples/screens/bottom_sheet/persistent_bottom_sheet_page.dart';
import 'package:project_samples/utils/layout_spacer.dart';

class BottomSheetExamplePage extends StatelessWidget {
  static String routeName = 'basics/bottom_sheet_example';

  const BottomSheetExamplePage({super.key});

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
                    builder: (context) => PersistentBottomSheetPage(),
                  ),
                );
              },
              child: Text('Persistent BottomSheet'),
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
                    builder: (context) => ModalBottomSheetPage(),
                  ),
                );
              },
              child: Text('Modal BottomSheet'),
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
