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
                MyAppRouter.router.navigateTo(
                  context,
                  "/screen_page_1",
                  replace: true,
                );
              },
              child: Text("Push to screen 1"),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ElevatedButton(
                onPressed: () {
                  MyAppRouter.router.navigateTo(
                    context,
                    "/screen_page_2",
                    replace: true,
                  );
                },
                child: Text("Push to screen 2"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
