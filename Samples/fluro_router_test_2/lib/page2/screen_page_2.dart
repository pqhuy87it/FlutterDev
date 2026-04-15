import 'package:flutter/material.dart';
import 'page_2_router.dart';

class ScreenPage2 extends StatelessWidget {
  const ScreenPage2({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(onPressed: () {
              Navigator.pushNamed(context, Page2Router.screenPage2_1);
            }, child: Text('Screen Page 2-1')),
            ElevatedButton(onPressed: () {
              Navigator.pushNamed(context, Page2Router.screenPage2_2);
            }, child: Text('Screen Page 2-2'))
          ],
        ),
      ),
    );
  }

}