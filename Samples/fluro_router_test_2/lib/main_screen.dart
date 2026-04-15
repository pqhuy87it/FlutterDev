import 'package:fluro_router_test_2/fluro_navigator.dart';
import 'package:flutter/material.dart';
import 'app_router.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                NavigatorUtils.push(
                  context,
                  MyAppRouter.screenPage1,
                  replace: true,
                );
              },
              child: const Text('Screen Page 1'),
            ),
            ElevatedButton(
              onPressed: () {
                NavigatorUtils.push(
                  context,
                  MyAppRouter.screenPage2,
                  replace: true,
                );
              },
              child: const Text('Screen Page 2'),
            ),
          ],
        ),
      ),
    );
  }
}
