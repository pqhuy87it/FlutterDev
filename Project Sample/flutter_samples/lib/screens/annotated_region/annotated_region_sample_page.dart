import 'package:flutter/material.dart';
import 'package:project_samples/screens/annotated_region/custom_search_bar.dart';

class AnnotatedRegionSamplePage extends StatelessWidget {
  static String routeName = 'basics/annotated_region_example';

  const AnnotatedRegionSamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomSearchBar(
        hintText: 'Search something',
        onPressed: (text) {},
      ),
      body: const Center(
        child: Text('AnnotatedRegion Sample'),
      ),
    );
  }
}
