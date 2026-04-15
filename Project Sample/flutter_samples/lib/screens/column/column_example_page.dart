import 'package:flutter/material.dart';

class ColumnExamplePage extends StatelessWidget {
  static String routeName = 'basics/column_example';

  const ColumnExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Silver Example')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          // mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child:
                  Container(height: 20, color: Colors.blue),
                  // ElevatedButton(
                  //   onPressed: () {},
                  //   child: Text('Tap here!'),
                  // ),
                ),
              ],
            ),
            // Divider(height: 0.1,),
            Row(
              children: [
                Expanded(child: Container(height: 0.5, color: Colors.red)),
              ],
            ),
            Container(color: Colors.lightBlue,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                //mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Address'),
                  // SizedBox(width: 10),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('Tap here!'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    ;
  }
}
