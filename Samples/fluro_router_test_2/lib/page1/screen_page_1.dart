import 'package:flutter/material.dart';
import 'page_1_router.dart';

class ScreenPage1 extends StatelessWidget {
  const ScreenPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(onPressed: () {
              Navigator.pushNamed(context, Page1Router.screenPage1_1);
            }, child: Text('Screen Page 1-1')),
            ElevatedButton(onPressed: () {
              Navigator.pushNamed(context, Page1Router.screenPage1_2);
            }, child: Text('Screen Page 1-2'))
          ],
        ),
      ),
    );
  }
}