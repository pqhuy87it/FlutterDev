import 'package:flutter/material.dart';

class BadgeExamplePage extends StatelessWidget {
  static String routeName = 'basics/badge_example';

  const BadgeExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Badge Example')),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Badge(
                  label: Text('Your label'),
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.receipt),
                ),
                onPressed: () {},
              ),
              const SizedBox(height: 20),
              IconButton(
                icon: Badge.count(
                  count: 9999,
                  child: const Icon(Icons.notifications),
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
